//
//  AppDelegate.swift
//  Iconic
//
//  Created by Utsav Patel on 7/17/18.
//  Copyright © 2018 erbittuu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindow: NSWindow!
    var lastPoint = NSPoint.zero
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        mainWindow = NSApplication.shared.windows[0]
        
        func distance(a: NSPoint, b: NSPoint) -> CGFloat {
            let xDist = a.x - b.x
            let yDist = a.y - b.y
            return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { event in
            if event.type == .leftMouseUp {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if #available(OSX 10.13, *) {
                        let drag = NSPasteboard(name: NSPasteboard.Name.drag)
                        drag.clearContents()
                    } else {
                        let drag = NSPasteboard(name: NSPasteboard.Name.dragPboard)
                        drag.clearContents()
                    }
                }
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged]) { event in
            if event.type == .leftMouseDragged {
                let newPoint = event.locationInWindow
                let dis = distance(a: newPoint, b: self.lastPoint)
                if dis > 15 {
                    if #available(OSX 10.13, *) {
                        let drag = NSPasteboard(name: NSPasteboard.Name.drag)
                        for item in drag.pasteboardItems ?? [] {
                            
                            if let urlStr = item.string(forType: NSPasteboard.PasteboardType.fileURL),
                                let url = URL(string: urlStr){
                                if NSImage.extList.contains(url.pathExtension) {
                                    if !self.mainWindow.isVisible {
                                        self.showWindow()
                                    }
                                }
                            }
                        }
                    } else {
                        let drag = NSPasteboard(name: NSPasteboard.Name.dragPboard)
                        for item in drag.pasteboardItems ?? [] {
                            
                            if let urlStr = item.string(forType: NSPasteboard.PasteboardType.filePromise),
                                let url = URL(string: urlStr){
                                if NSImage.extList.contains(url.pathExtension) {
                                    if !self.mainWindow.isVisible {
                                        self.showWindow()
                                    }
                                }
                            }
                        }
                    }
                    
                }
                self.lastPoint = newPoint
            } else {
                self.lastPoint = NSPoint.zero
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) { }

    func showWindow() {
        mainWindow.close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            NSApplication.shared.unhideWithoutActivation()
            self.mainWindow.makeKeyAndOrderFront(nil)
            self.mainWindow.makeFirstResponder(self.mainWindow)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag{
            self.showWindow()
        }
        return true
    }
}
