//
//  NSOpenPanel.swift
//  Iconic
//
//  Created by Utsav Patel on 7/18/18.
//  Copyright © 2018 erbittuu. All rights reserved.
//

import Cocoa

extension NSOpenPanel {
    
    func selectImage(window: NSWindow, completion: @escaping ((URL?) -> ())) {
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = NSImage.extList  // to allow only images, just comment out this line to allow any file type to be selected
        canSelectHiddenExtension = false
        prompt = "Select icon to scale"
        showsHiddenFiles = false
        showsTagField = false
        
        beginSheetModal(for: window) { (response) in
            if response == .OK, let image = self.urls.first {
                completion(image)
            }else{
                completion(nil)
            }
        }
    }
    
    func selectFolder(window: NSWindow, completion: @escaping ((URL?) -> ())) {
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canChooseFiles = false
        canCreateDirectories = false
        canSelectHiddenExtension = false
        prompt = "Select Destination"
        showsHiddenFiles = false
        showsTagField = false
        
        
        beginSheetModal(for: window) { (response) in
            if response == .OK, let image = self.urls.first {
                completion(image)
            }else{
                completion(nil)
            }
        }
    }
}
