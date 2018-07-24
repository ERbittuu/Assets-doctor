//
//  NSImage.swift
//  Life Icon
//
//  Created by Utsav Patel on 7/18/18.
//  Copyright © 2018 erbittuu. All rights reserved.
//

import Cocoa

extension NSImage {
    var pngData: Data? {
        guard
            let tiffRepresentation = tiffRepresentation,
            let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
            else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    
    func resize(_ width: CGFloat, _ height: CGFloat) -> NSImage {
        let img = NSImage(size: CGSize(width: width, height: height))
        img.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = .high
        let oldRect = NSMakeRect(0, 0, size.width, size.height)
        let newRect = NSMakeRect(0, 0, width, height)
        self.draw(in: newRect, from: oldRect, operation: .copy, fraction: 1)
        img.unlockFocus()
        
        return img
    }
    
    @discardableResult
    func save(_ path: String) -> Bool {
        guard let url = URL(string: path) else { return false }
        
        do {
            try pngData?.write(to: url, options: .atomic)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    static let extList: [String] = ["tiff", "tif", "jpg", "jpeg", "gif", "png", "bmp", "bmpf", "ico", "cur", "xbm", "xcodeproj"]
    
    static var pasteboardTypes : [NSPasteboard.PasteboardType]  {
        return self.extList.map { $0.pasteboardType }
    }
}

extension String {
    var pasteboardType: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType.fileNameType(forPathExtension: self)
    }
}
