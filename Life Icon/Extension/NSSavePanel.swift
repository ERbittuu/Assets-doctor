//
//  NSSavePanel.swift
//  Life Icon
//
//  Created by Utsav Patel on 7/18/18.
//  Copyright © 2018 erbittuu. All rights reserved.
//

import Cocoa

extension NSSavePanel {
    func selectExportFolder(window: NSWindow, completion: @escaping ((URL?) -> ())) {
        
        canCreateDirectories = true
        canSelectHiddenExtension = false
        prompt = "Select Destination"
        showsHiddenFiles = false
        showsTagField = false
        
        beginSheetModal(for: window) { (response) in
            if response == .OK, let url = self.url {
                completion(url)
            }else{
                completion(nil)
            }
        }
    }
}
