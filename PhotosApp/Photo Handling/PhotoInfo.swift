//
//  PhotoInfo.swift
//  PhotosApp
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Cocoa

class PhotoInfo {
    var url: URL?
    var thumbnail: NSImage?
    
    init(with url: URL) {
        self.url = url
    }
    
}
