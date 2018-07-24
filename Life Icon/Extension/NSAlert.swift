//
//  NSAlert.swift
//  Life Icon
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
}
