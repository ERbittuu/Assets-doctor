//
//  ExportController.swift
//  Iconic
//
//  Created by Utsav Patel on 7/18/18.
//  Copyright © 2018 erbittuu. All rights reserved.
//

import Cocoa

class ExportController: NSViewController {
    
    typealias IconsDetail = (scale: Int, size: CGFloat, type: String, name: String)
    
    private enum Icons: String {
        case mac, iphone, ipad, watch, car, universal
        
        var string: String {
            return self.rawValue
        }
        
        static func listFor(type: Icons) -> [IconsDetail] {
            switch type {
                case .mac:
                    return [(1, 16, type.string, type.string.capFirst), (2, 16, type.string, type.string.capFirst), (1, 32, type.string, type.string.capFirst), (2, 32, type.string, type.string.capFirst), (1, 128, type.string, type.string.capFirst), (2, 128, type.string, type.string.capFirst), (1, 256, type.string, type.string.capFirst), (2, 256, type.string, type.string.capFirst), (1, 512, type.string, type.string.capFirst), (2, 512, type.string, "App Store")]
                case .iphone:
                    return [(2, 20, type.string, "Notifications"), (3, 20, type.string, "Notifications"), (2, 29, type.string, "Spotlight, Settings"), (3, 29, type.string, "Spotlight, Settings"), (2, 40, type.string, "Spotlight"), (3, 40, type.string, "Spotlight"), (2, 60, type.string, "App"), (3, 60, type.string, "App"), (1, 1024, type.string, "App Store")]
                case .ipad:
                    return [(1, 20, type.string, "Notifications"), (2, 20, type.string, "Notifications"), (1, 29, type.string, "Settings"), (2, 29, type.string, "Settings"), (1, 40, type.string, "Spotlight"), (2, 40, type.string, "Spotlight"), (1, 76, type.string, "App"), (2, 76, type.string, "App"), (2, 83.5, type.string, "Pro App"), (1, 1024, type.string, "App Store")]
                case .watch:
                    return [(2, 24, type.string, "Notification Center"), (2, 27.5, type.string, "Notification Center"), (2, 29, type.string, "Companion Settings"), (3, 29, type.string, "Companion Settings"), (2, 40, type.string, "App Launcher"), (2, 44, type.string, "Long Look"), (2, 86, type.string, "Quick Look"), (2, 98, type.string, "Quick Look"), (1, 1024, type.string, "Marketing")]
                case .car:
                    return  [(2, 60, type.string, type.string.capFirst+"Play"), (3, 60, type.string, type.string.capFirst+"Play")]
                case .universal:
                    return  [(1, 0, type.string, type.string.capFirst), (2, 0, type.string, type.string.capFirst), (3, 0, type.string, type.string.capFirst)]
            }
        }
    }
    
    func imageSizeFor(scale: Int) -> CGSize {
        let size = image.size
        if scale == 1 {
            return CGSize(width: Int(size.width / 3), height: Int(size.height / 3))
        } else if scale == 2 {
            return CGSize(width: Int((size.width * 2)) / 3, height: Int((size.height * 2) / 3))
        } else {
            return CGSize(width: Int(image.size.width), height: Int(image.size.height))
        }
    }

    @IBOutlet weak var segment: NSSegmentedControl!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var iconsetButton: NSButton!
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var nameTitle: NSTextField!
    
    @IBOutlet weak var table: NSTableView!

    var segmentSelected = [Int]()
    var image = NSImage()
    var name: String!
    var newImages = [IconsDetail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _name = self.name {
            nameField.stringValue = _name
        }
    }
    
    @IBAction func onExportClick(_ sender: Any) {
        
        if self.iconsetButton.state == .on {
            let nameNew = self.nameField.stringValue
            if nameNew.count > 0  {
                self.name = nameNew
            } else {
                DispatchQueue.main.async {
                    NSAlert.dialogWith(text: "Please enter icon name.", warning: true)
                    self.nameField.becomeFirstResponder()
                }
                return
            }
        }
        
        if let window = self.view.window {
            NSOpenPanel().selectFolder(window: window) { (url) in
                if var _url = url {
                    if self.iconsetButton.state == .on {
                        
                        if !self.createIconSetDir(url: &_url, name: self.segmentSelected.contains(5) ? self.name! : nil) {
                            DispatchQueue.main.async {
                                NSAlert.dialogWith(text: "Icon set already available!!", warning: true)
                            }
                            return
                        }

                        // create Contents.json
                        if !self.createContentsJSON(url: _url) {
                            DispatchQueue.main.async {
                                NSAlert.dialogWith(text: "Icon set already available!!", warning: true)
                            }
                            return
                        }
                    }
                    
                    DispatchQueue.global().async {
                        print(_url)
                        self.convertAndSave(url: _url)
                    }
                }else{
                    print("No folder select")
                }
            }
        }
    }
    
    @IBAction func onSegmentClick(_ sender: Any) {
        
        let index = segment.selectedSegment
        
        if !segmentSelected.isEmpty {
            if segmentSelected.contains(5) {
                // 1x, 2x, 3x selected
                if index != 5 {
                    print("Next index is for icon, it is not allowed")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { NSAlert.dialogWith(text: "Can't select icon slicing and scale both!!!") }
                    segment.trackingMode = .selectOne
                    self.segment.selectSegment(withTag: self.segmentSelected.first!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.segment.trackingMode = .selectAny
                        for _ind in  self.segmentSelected {
                            self.segment.selectSegment(withTag: _ind)
                        }
                    }
                    return
                }
            } else {
                // 1x, 2x, 3x not selected
                if index == 5 {
                    
                    print("Next index is for 1x, 2x, 3x selected, it is not allowed")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { NSAlert.dialogWith(text: "Can't select scale and icon slicing both!!!") }
                    segment.trackingMode = .selectOne
                    self.segment.selectSegment(withTag: self.segmentSelected.first!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.segment.trackingMode = .selectAny
                        for _ind in  self.segmentSelected {
                            self.segment.selectSegment(withTag: _ind)
                        }
                    }
                    return
                }
            }
        }
        
        if segmentSelected.contains(index) {
            // deselect action
            segmentSelected.remove(at: segmentSelected.index { (_index) -> Bool in
                return _index == index
                }!)
        } else {
            // select action
            segmentSelected.append(index)
        }
        
        saveButton.isEnabled = !segmentSelected.isEmpty
        iconsetButton.isEnabled = !segmentSelected.isEmpty
        
        nameField.isHidden = !segmentSelected.contains(5)
        nameTitle.isHidden = !segmentSelected.contains(5)
            
        prepeareList()
    }
    
    func prepeareList() {
        
        newImages.removeAll()
        
        if segmentSelected.contains(5) { // car
            newImages.append(contentsOf: Icons.listFor(type: .universal))
        } else {
            for index in segmentSelected.sorted() {
                if index == 0 { // mac
                    newImages.append(contentsOf: Icons.listFor(type: .mac))
                }
                
                if index == 1 { // ios
                    newImages.append(contentsOf: Icons.listFor(type: .iphone))
                }
                
                if index == 2 { //ipad
                    newImages.append(contentsOf: Icons.listFor(type: .ipad))
                    if segmentSelected.contains(1) { // also contain iphone
                        newImages.removeLast()
                    }
                }
                
                if index == 3 { // watch
                    newImages.append(contentsOf: Icons.listFor(type: .watch))
                }
                
                if index == 4 { // car
                    newImages.append(contentsOf: Icons.listFor(type: .car))
                }
            }
        }
        table.reloadData()
    }
    
    func createIconSetDir(url: inout URL, name: String?) -> Bool {
        var folder = url
        folder.appendPathComponent(name != nil ? "\(name!).imageset" : "AppIcon.appiconset", isDirectory: true)
        var isFolder: ObjCBool = true
        if !FileManager.default.fileExists(atPath: folder.path, isDirectory: &isFolder) {
            do{
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false, attributes: nil)
            }
            catch _ {
                return false
            }
        } else {
            return false
        }
        url = folder
        return true
    }
    
    func nameOf(item: IconsDetail) -> String {
        
        if item.type == "universal" {
            return "\(name!)\(item.scale == 1 ? "" : "@\(item.scale)x").png"
        }else{
            return "\(item.type)\(item.size.clean)\(item.scale == 1 ? "" : "@\(item.scale)x").png"
        }
    }
    
    func createContentsJSON(url: URL) -> Bool {
        // "create Contents.json"
        var folder = url
        folder.appendPathComponent("Contents.json", isDirectory: true)
        let info: [String : Any] = [ "version" : 1, "author"  : "xcode" ]
        var images = [[String : Any]]()

        for item in newImages {
            
            var idiom = item.type
            
            if (item.type == "iphone" || item.type == "Ipad") && item.scale == 1 && item.size == 1024 {
                idiom = "ios-marketing"
            }
            
            if item.type == "watch" {
                var image = ["idiom": idiom, "size": "\(item.size.clean)x\(item.size.clean)", "scale": "\(item.scale)x", "filename": nameOf(item: item)]
                if item.size == 24 {
                    image["role"] = "notificationCenter"
                    image["subtype"] = "38mm"
                } else if item.size == 27.5 {
                    image["role"] = "notificationCenter"
                    image["subtype"] = "42mm"
                } else if item.size == 29 {
                    image["role"] = "companionSettings"
                } else if item.size == 40 {
                    image["role"] = "appLauncher"
                    image["subtype"] = "38mm"
                } else if item.size == 44 {
                    image["role"] = "longLook"
                    image["subtype"] = "42mm"
                } else if item.size == 86 {
                    image["role"] = "quickLook"
                    image["subtype"] = "38mm"
                } else if item.size == 98 {
                    image["role"] = "quickLook"
                    image["subtype"] = "42mm"
                } else if item.size == 1024 {
                    image["idiom"] = "watch-marketing"
                }
                
                images.append(image)
            } else if item.type == "universal" {
                images.append(["idiom": idiom, "size": "\(imageSizeFor(scale: item.scale).width)x\(imageSizeFor(scale: item.scale).height)", "scale": "\(item.scale)x", "filename": nameOf(item: item)])
            } else {
                images.append(["idiom": idiom, "size": "\(item.size.clean)x\(item.size.clean)", "scale": "\(item.scale)x", "filename": nameOf(item: item)])
            }
        }

        let final = ["info": info, "images": images] as [String : Any]

        if let text = final.prettyPrintedJSON {
            // Writing to disk
            do {
                try text.write(to: folder, atomically: false, encoding: .utf8)
                return true
            }
            catch { return false }
        } else {
            return false
        }
    }
    
    func convertAndSave(url: URL) {
        print("convert start")
        
        for item in newImages {
            let size = CGFloat(item.scale) * item.size
            var image: NSImage!
            if size == 0 {
                image = self.image.resize(imageSizeFor(scale: item.scale).width, imageSizeFor(scale: item.scale).height);
            } else {
               image = self.image.resize(size, size);
            }
            image.save(url.appendingPathComponent(self.nameOf(item: item)).absoluteString)
        }
        
        DispatchQueue.main.async {
            self.dismiss(nil)
            NSAlert.dialogThanks(url: url)
        }
        
        print("convert done")
    }
}

extension ExportController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return newImages.count == 0 ? 1 : newImages.count
    }
}

extension ExportController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if newImages.count == 0 {
            if (tableColumn?.identifier)!.rawValue == "name" {
                return "Please select icon type..."
            }
            return nil
        }
        
        let item = newImages[row]
        
        if (tableColumn?.identifier)!.rawValue == "name" {
           
            if item.name == "App Store" {
                return "App Store"
            }
            
            if item.type == "watch" {
                return "Apple " + item.type.capFirst + " " + item.name
            } else if item.type == "car" {
                 return item.type.capFirst + " Icon"
            } else if item.type == "iphone" {
                return item.type.capFirst + " " + item.name
            } else if item.type == "ipad" {
                return item.type.capFirst + " " + item.name
            } else if item.type == "mac" {
                return item.type.capFirst + " Icon"
            } else if item.type == "universal" {
                return name! + " Image"
            }else {
                return item.type.capFirst
            }
            
        } else if (tableColumn?.identifier)!.rawValue == "size" {
            return item.size == 0 ? "\(Int(imageSizeFor(scale: item.scale).width))x\(Int(imageSizeFor(scale: item.scale).height))" : "\(Int(item.size))pt"
        } else {
            return "@\(item.scale)x"
        }
    }
    
    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
        return self.tableView(tableView, objectValueFor: tableColumn, row: row) as? String ?? ""
    }
    
}

fileprivate extension String {
    
    var capFirst: String {
        if self == "iphone" {
            return "iPhone"
        } else if self == "ipad" {
            return "iPad"
        } else {
            let first = String(prefix(1)).capitalized
            let other = String(dropFirst())
            return first + other
        }
    }
}

extension Dictionary {
    var prettyPrintedJSON: String? {
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch _ {
            return nil
        }
    }
}

extension CGFloat {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : "\(self)"
    }
}
