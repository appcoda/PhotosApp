//
//  HeaderView.swift
//  PhotosApp
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class HeaderView: NSView {
 
    @IBOutlet weak var label: NSTextField!
 
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(white: 0.5, alpha: 1.0).cgColor
    }
    
}
