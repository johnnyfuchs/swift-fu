//
//  Planet.swift
//  fu
//
//  Created by Johnny Sparks on 2/15/15.
//
//

import Foundation
import UIKit

enum PlanetType {
    case Gas, Ice, Water
}

public func ==(lhs: Planet, rhs: Planet) -> Bool {
    return (
        lhs.x == rhs.x
            && lhs.y == rhs.y
            && lhs.z == rhs.z
            && lhs.mass == rhs.mass
            && lhs.type == rhs.type
    )
}

public class Planet: Body {
    let type:PlanetType = .Water
    
    init(x: CGFloat, y: CGFloat, z: CGFloat, mass: CGFloat, type:PlanetType) {
        super.init(x: x, y: y, z: z, mass: mass)
        self.type = type
    }
    
    override public var description: String {
        get { return "\(super.description) \(type)" }
    }
}
