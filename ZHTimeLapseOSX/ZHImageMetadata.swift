//
//  ZHImageMetadata.swift
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 1/24/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import Cocoa

class ZHImageMetadata: NSObject {

    var file: String? = nil
    var size: String? = nil
    var resolution: String? = nil
    var type: String? = nil
    
    
    
    
    private var url: NSURL? = nil
    init?(url: NSURL) {
        self.url = url
        
        self.file = url.pathComponents?.last

        do {
            let attr = try NSFileManager.defaultManager().attributesOfItemAtPath(url.path!)

//            Key: NSFileCreationDate
//            Key: NSFileGroupOwnerAccountName
//            Key: NSFileType
//            Key: NSFileHFSTypeCode
//            Key: NSFileSystemNumber
//            Key: NSFileOwnerAccountName
//            Key: NSFileReferenceCount
//            Key: NSFileModificationDate
//            Key: NSFileExtensionHidden
//            Key: NSFileSize
//            Key: NSFileGroupOwnerAccountID
//            Key: NSFileOwnerAccountID
//            Key: NSFilePosixPermissions
//            Key: NSFileHFSCreatorCode
//            Key: NSFileSystemFileNumber
            
            if let size = attr["NSFileSize"] as? UInt {
                print("Inspect size; \(size)")
                let mega = UInt(1024 * 1024)
                let kilo = UInt(1024)
                if size > mega {
                    let fileSize = Double(size) / Double(mega)
                    self.size = NSString(format: "%.1f MB", fileSize) as String
                } else if size > 1000 {
                    let fileSize = Double(size) / Double(kilo)
                    self.size = NSString(format: "%.1f KB", fileSize) as String

                } else {
                    self.size = NSString(format: ".1f bytes", size) as String
                }
            }
            
        } catch _ {
            print("Caught exception in metatdata")
            self.size = "size"
            self.resolution = "res"
            self.type = "type"

        }
        
        
        if let image = NSImage(contentsOfURL: url) {
            self.resolution = "\(image.size.width)x\(image.size.height)"
        }
        
        
     
        
    }
}
