//
//  ViewController.swift
//  Iconic
//
//  Created by Laptop on 6/29/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

class MainController: NSViewController {

    let exportControllerOpen = NSStoryboardSegue.Identifier(rawValue: "ExportControllerOpen")
    let defaultImage = NSImage(imageLiteralResourceName: "App-Icon-Default")
    
    @IBOutlet weak var imageMain: DropView!
    
    @IBAction func onSelected(_ sender: Any) {
        if let window = self.view.window {
            NSOpenPanel().selectImage(window: window) { (url) in
                if let _url = url {
                    self.imageMain.filePath = _url.absoluteString
                    let image = NSImage(byReferencingFile: _url.path)!
                    DispatchQueue.main.async { self.imageMain.image = image }
                }else{
                    print("No image select")
                }
            }
        }
    }

    @IBAction func onExportClick(_ sender: Any) {
        if imageMain.image == defaultImage {
            NSAlert.dialogWith(text: "Please select image!!")
        }else{
            performSegue(withIdentifier: exportControllerOpen, sender: nil)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        func randomInt(min: Int, max:Int) -> Int {
            return min + Int(arc4random_uniform(UInt32(max - min + 1)))
        }
        
        if segue.identifier == exportControllerOpen {
            if let dest = segue.destinationController as? ExportController {
                dest.image = imageMain.image!
                if let path = imageMain.filePath {
                    let url = URL(fileURLWithPath: path)
                    dest.name = "\(url.lastPathComponent.replacingOccurrences(of: url.pathExtension, with: "").dropLast())"
                }else{
                    dest.name = "Icon\(randomInt(min: 1, max: 16))"
                }
            }
        }
       
    }
}
