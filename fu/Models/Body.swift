//
//  Body.swift
//  fu
//
//  Created by Johnny Sparks on 2/15/15.
//
//

import Foundation
import UIKit

public func ==(lhs: Body, rhs: Body) -> Bool {
    return (
        lhs.x == rhs.x
        && lhs.y == rhs.y
        && lhs.z == rhs.z
        && lhs.mass == rhs.mass
    )
}

public class Body: Printable, Equatable {
    let x, y, z, mass:CGFloat;
    
    init(x:CGFloat, y:CGFloat, z:CGFloat, mass:CGFloat){
        self.x = x
        self.y = y
        self.z = z
        self.mass = mass
    }

    public var description: String {
        get { return "\(x) \(y) \(z)" }
    }
}
