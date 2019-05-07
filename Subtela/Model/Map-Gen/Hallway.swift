//
//  Hallway.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/11.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation

class Hallway : Room {

    var vert: Bool
    
    init(_ w: Int, _ h: Int, _ g: Graph, _ v: Bool) {
        vert = v
        super.init(h, w, g)
    }
    
    func placeHallway(_ rooms: Array<Room>, _ hallways: Array<Hallway>) -> Bool {
        var pos: Position = Position()
        pos.x = world.random.nextUniform(0, world.w-1)
        pos.y = world.random.nextUniform(0, world.h-1)
        position = pos
        if (overlapFloor(rooms)) {
            return false
        }
        var inter: Bool = false
        for hw: Hallway in hallways {
            if (hw.intersects(self)) {
                inter = true
            }
            if (hw.parallelIntersect(self)) {
                return false
            }
        }
        return inter
    }
    
    func placeHallway(_ rooms: Array<Room>) -> Void {
        var x: Int
        let r1: Room = connections[0]
        let r2: Room = connections[1]
        
        var interval: [Int]? = nil
        
        if (vertical()) {
            interval = Tools.intervalIntersection(r1.position.x + 1, r1.position.x + r1.width, r2.position.x + 1, r2.position.x + r2.width)
        } else {
            interval = Tools.intervalIntersection(r1.position.y + 1, r1.position.y + r1.height, r2.position.y + 1, r2.position.y + r2.height)
        }
        
        repeat {
            x = world.random.nextUniform(interval![0], interval![1] + 1)
            if (vertical()) {
                position.x = x - 1
            } else {
                position.y = x - 1
            }
        } while (overlapFloor(rooms))
    }
    
    override func generate() -> [[Graph.Tile]] {
        var rv: [[Graph.Tile]] = super.generate()
        if (vertical()) {
            rv[1][0] = Graph.Tile.Floor
            rv[width + 1][1] = Graph.Tile.Floor
        } else {
            rv[0][1] = Graph.Tile.Floor
            rv[width + 1][1] = Graph.Tile.Floor
        }
        return rv
    }
    
    func vertical() -> Bool {
        return vert
    }
    
    func inHallwayFloor(_ x: Int, _ y: Int) -> Bool {
        if vertical() {
            return x == position.x + 1 && (Tools.inInterval(y, position.y, position.y + height + 1))
        } else { //horizontal
            return Tools.inInterval(x, position.x, position.x + width + 1) && (y == position.y + 1);
        }
    }
    
    func intersects(_ h: Hallway) -> Bool {
        var i: [Int]? = intersection(h)
        if (i == nil || parallelIntersect(h)) {
            return false
        }
        return i![0] - i![1] == -2 || i![2] - i![3] == -2
    }
    
    func parallelIntersect(_ h: Hallway) -> Bool {
        let thisDir: Bool = vertical()
        let hDir: Bool = h.vertical()
        
        if (thisDir && hDir) || (!thisDir && hDir) {
            return overlap(h)
        } else {
            return false
        }
    }
    
    func properIntersects(_ h: Hallway) -> Bool {
        if !self.intersects(h) {
            return false
        } else {
            var i: [Int]? = intersection(h)
            return (i![0] - i![1]) * (i![2] - i![3]) == 4
        }
    }
    
    func justTheTip() ->Void {
        for hw: Hallway in world.edges {
            if hw == self {
                continue
            }
            var tip: Bool = false
            if (self.intersects((hw))) {
                var i: [Int]? = self.intersection(hw)
                if (Tools.onEnd(i!, self)) {
                    if (self.vertical()) {
                        tip = i![0] - i![1] == -2;
                    } else {
                        tip = i![2] - i![3] == -2;
                    }
                }
            }
            if (tip) {
                self.connections.append(hw)
            }
        }
    }
}
