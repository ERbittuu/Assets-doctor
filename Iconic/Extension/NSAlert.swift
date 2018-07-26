//
//  NSAlert.swift
//  Iconic
//
//  Created by Utsav Patel on 7/18/18.
//  Copyright © 2018 erbittuu. All rights reserved.
//

import Cocoa

extension NSAlert {

    static func dialogWith(text: String, buttonTitle: String = "Close", warning: Bool = false, completion:(() -> ())? = nil) {
        let alert = NSAlert()
        alert.messageText = "Life Icon"
        alert.informativeText = text
        alert.alertStyle = warning ? .warning : .informational
        alert.addButton(withTitle: buttonTitle)
        if alert.runModal().rawValue == 1000 {
            completion?()
        }
    }
    
    static func dialogThanks(url: URL) {
        let alert = NSAlert()
        alert.messageText = "Life Icon"
        alert.informativeText = "Icon converted successfully!! 😊 😊\nDo you want to open folder?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open")
        alert.addButton(withTitle: "No Thanks")
        if alert.runModal().rawValue == 1000 {
            NSWorkspace.shared.open(url)
        }
    }
}
