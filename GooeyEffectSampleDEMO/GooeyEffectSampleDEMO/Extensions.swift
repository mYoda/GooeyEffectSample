//
//  Extensions.swift
//  GooeyEffectSampleDEMO
//
//  Created by Anton Nechayuk on 17.07.18.
//  Copyright © 2018 Anton Nechayuk. All rights reserved.
//

import UIKit

enum pointMovementType {
    case leftUp
    case left
    case leftDown
    case Down
    case rightDown
    case right
    case rightUp
    case Up
}

extension CGPoint {
    
    mutating func movePoint(forValue value: CGFloat, forType type: pointMovementType) {
        
        switch type {
        case .left:
            self.x = (self.x - value)
        case .leftUp:
            self.x = (self.x - value)
            self.y = (self.y - value)
        case .leftDown:
            self.x = (self.x - value)
            self.y = (self.y + value)
        case .Down:
            self.y = (self.y + value)
        case .rightDown:
            self.x = (self.x + value)
            self.y = (self.y + value)
        case .right:
            self.x = (self.x + value)
        case .rightUp:
            self.x = (self.x + value)
            self.y = (self.y - value)
        case .Up:
            self.y = (self.y - value)
        }
        
    }
    
    func plus(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    
    func minus(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - point.x, y: self.y - point.y)
    }
    
    func length() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    
}
