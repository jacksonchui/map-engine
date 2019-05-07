//
//  Map.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/18.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation
import SceneKit

// providing functionality between map, a wrapper class
class Map: SCNNode {
    
    var g: Graph
    var tiles: [[Graph.Tile]]
    var stairs: SpecialTile
    var characters: Array<Character>
    var player: Character
    let dimension: CGFloat = 1.0
    
    init(_ s: CLongLong, _ w: Int, _ h: Int) {
        g = Graph(width: w, height: h, seed: s)
        g.fill()
        tiles = g.generate()
        characters = Array<Character>()
        player = Character(g, &tiles)
        stairs = SpecialTile(g)
        
        super.init()
        
        let inside =  SCNPlane(width: dimension, height: dimension)
        let wall = SCNBox(width: dimension, height: dimension, length: dimension*4, chamferRadius: 0)

        populateMap()
        
        characters.append(player)
        self.addChildNode(player)
        self.addChildNode(stairs)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTiles() -> [[Graph.Tile]] {
        return tiles
    }
    
    func moved(_ direction: Int) {
        switch (direction) {
        case 0:
            player.move(0, 1)
        case 1:
            player.move(-1, 0)
        case 2:
            player.move(0, -1)
        case 3:
            player.move(1, 0)
        default:
            break
        }
        if (player.pos.x == stairs.pos.x) && (player.pos.y == stairs.pos.y) {
            newMap()
        }
    }
    
    func newMap() {
        g.fill()
        tiles = g.generate()
        characters = Array<Character>()
        
        self.enumerateChildNodes{ (node, stop) in node.removeFromParentNode()}
        
        populateMap()
        
        player.resetPos(g)
        stairs.resetPos(g)
        
        self.addChildNode(player)
        self.addChildNode(stairs)
        self.position = SCNVector3(0, 0, 0)
    }
    
    func populateMap() {
        let inside =  SCNPlane(width: dimension, height: dimension)
        let wall = SCNBox(width: dimension, height: dimension, length: dimension*4, chamferRadius: 0)
        
        inside.materials.first?.diffuse.contents = UIColor.blue
        wall.materials.first?.diffuse.contents = UIColor.white
        for i in 0..<g.w {
            for j in 0..<g.h {
                let floor = SCNNode()
                floor.position = SCNVector3(CGFloat(i), CGFloat(j),  0)
                switch (tiles[i][j]) {
                case Graph.Tile.Floor:
                    floor.geometry = inside
                case Graph.Tile.Wall:
                    floor.geometry = wall
                default:
                    break
                }
                self.addChildNode(floor)
            }
        }
    }

}
