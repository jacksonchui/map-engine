//
//  SpecialTile.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/23.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation
import SceneKit

//basically, just stairs at this point

class SpecialTile: SCNNode {
    
    var pos: Position
    
    init(_ g: Graph) {
        var x, y: Int
        repeat {
            x = g.random.nextUniform(0, g.w)
            y = g.random.nextUniform(0, g.h)
            pos = Position(x, y)
        } while (!g.inRooms(x: x, y: y))
        
        super.init()
        self.geometry = SCNPlane(width: 1, height: 1)
        self.geometry!.materials.first?.diffuse.contents = UIColor.green
        self.position = SCNVector3(CGFloat(x), CGFloat(y), 0.1)
    }
    
    func resetPos(_ g: Graph) {
        var x, y: Int
        repeat {
            x = g.random.nextUniform(0, g.w)
            y = g.random.nextUniform(0, g.h)
            pos = Position(x, y)
        } while (!g.inRooms(x: x, y: y))
        self.position = SCNVector3(CGFloat(x), CGFloat(y), 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
