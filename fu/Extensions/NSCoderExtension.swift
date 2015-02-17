//
//  NSCoderExtension.swift
//  fu
//
//  Created by Johnny Sparks on 2/16/15.
//
//

import Foundation

extension NSCoder {
    class func empty() -> NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.finishEncoding()
        return NSKeyedUnarchiver(forReadingWithData: data)
    }
}