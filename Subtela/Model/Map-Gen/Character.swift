//
//  Character.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/23.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation
import SceneKit

class Character: SCNNode {
    
    var pos: Position
    var world: Graph
    var t: [[Graph.Tile]]
    
    init(_ g: Graph, _ t: inout [[Graph.Tile]]) {
        world = g
        self.t = t
        var x, y: Int
        repeat {
            x = world.random.nextUniform(0, world.w)
            y = world.random.nextUniform(0, world.h)
            pos = Position(x, y)
        } while (!g.inRooms(x: x, y: y))
        super.init()
        self.geometry = SCNSphere(radius: 0.45)
        self.geometry!.materials.first?.diffuse.contents = UIColor.red
        self.position = SCNVector3(CGFloat(x), CGFloat(y), 0.0)
    }
    
    func move(_ dx: Int, _ dy: Int) {
        if (0 <= pos.x + dx) && (pos.x + dx < world.w) && (0 <= pos.y + dy) && (pos.y + dy < world.h) {
            if (t[pos.x + dx][pos.y + dy] == Graph.Tile.Floor) {
                pos.x += dx
                pos.y += dy
                self.position = SCNVector3(CGFloat(pos.x), CGFloat(pos.y), 0.0)
            }
        }
    }
    
    func resetPos(_ g: Graph) {
        var x, y: Int
        repeat {
            x = world.random.nextUniform(0, world.w)
            y = world.random.nextUniform(0, world.h)
            pos = Position(x, y)
        } while (!g.inRooms(x: x, y: y))
        self.position = SCNVector3(CGFloat(x), CGFloat(y), 0.0)
        t = g.generate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
