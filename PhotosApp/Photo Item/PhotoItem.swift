//
//  PhotoItem.swift
//  PhotosApp
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class PhotoItem: NSCollectionViewItem {

    var doubleClickActionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.cornerRadius = 8.0
    }
    
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            
            if isSelected {
                view.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
            } else {
                view.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if event.clickCount == 2 {
            doubleClickActionHandler?()
        }
    }
}
