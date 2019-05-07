//
//  Room.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/11.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation

class Room : Equatable, Hashable{
    var connections: Array<Room>
    var world: Graph
    var height: Int //height of room, not including walls
    var width: Int //width of room, not including walls
    var position: Position
    
    init() {
        position = Position()
        connections = Array<Room>()
        height = -1
        width = -1
        world = Graph(width: -1, height: -1, seed: 1234567890)
    }
    
    init(_ h: Int, _ w: Int, _ g: Graph) {
        world = g;
        position = Position()
        connections = Array<Room>()
        height = h;
        width = w;
    }
    
    func adjacent(_ rooms: Array<Room>) -> Array<Room> {
        var rv: Array<Room> = Array<Room>()
        rv.append(contentsOf: adjacentVert(1, rooms))
        rv.append(contentsOf: adjacentVert(-1, rooms))
        rv.append(contentsOf: adjacentHorz(1, rooms))
        rv.append(contentsOf: adjacentHorz(-1, rooms))
        return rv;
    }
    
    func adjacentVert(_ vdir: Int, _ rooms: Array<Room>) -> Array<Room> {
        var adjacent = Array<Room>()
        var i, j: Int
        var y: Int
        if (vdir < 0) {
            y = position.y - 1;
        } else {
            y = position.y + height + 2;
        }

        for i in position.x + 1...position.x + width {
            j = y
            while (0 <= j && j < world.h) {
                for rm: Room in rooms {
                    if (rm.inRoom(i, j)) {
                        j += vdir
                        if (rm.inRoomFloor(i, j)) {
                            adjacent.append(rm)
                        }
                        j = -2
                        break
                    }
                }
                j += vdir
            }
        }
        
        adjacent = adjacent.filter { $0 != self };
        return adjacent
    }
    
    func adjacentHorz(_ hdir: Int, _ rooms: Array<Room>) -> Array<Room> {
        var adjacent = Array<Room>()
        
        var i, j: Int
        var x: Int
        
        if (hdir < 0) {
            x = position.x - 1
        } else {
            x = position.x + width + 2
        }
        
        for var j in position.y + 1...position.y + height {
            i = x
            while (0 <= i && i < world.w) {
                for rm: Room in rooms {
                    if (rm.inRoom(i, j)) {
                        i += hdir
                        if (rm.inRoomFloor(i, j)) {
                            adjacent.append(rm)
                        }
                        j = -2
                        break
                    }
                }
                i += hdir
            }
        }
        
        adjacent = adjacent.filter { $0 === self };
        return adjacent
    }
    
    func placeRoom(_ placed: Array<Room>) -> Bool{
        if (!world.hasSpace(self)) {
            return false
        }
        var x, y: Int
        repeat {
            x = world.random.nextUniform(0, world.w)
            y = world.random.nextUniform(0, world.h)
            self.position.x = x;
            self.position.y = y;
        } while (overlap(placed))
        self.position.x = x;
        self.position.y = y;
        return true;
    }
    
    func generate() -> [[Graph.Tile]] {
        var rv: [[Graph.Tile]] = Array(repeating: Array(repeating: Graph.Tile.Floor, count: height + 2), count: width + 2)
        for i: Int in 0..<width + 2 {
            for j: Int in 0..<height + 2 {
                if (i == 0 || i == width + 1 || j == 0 || j == height + 1) {
                    rv[i][j] = Graph.Tile.Wall
                }
            }
        }
        return rv;
    }
    
    func copyTo(_ t: inout [[Graph.Tile]]) -> Void {
        let x = position.x
        let y = position.y
        var tw = self.generate()
        for i in 0..<tw.count {
           t[x + i][y..<y+tw[0].count] = tw[i][0..<tw[0].count]
        }
    }
    
    func overlap(_ placed: Array<Room>) -> Bool{
        if (position.x + width + 1 > world.w - 1) {
            return true
        }
        if (position.y + height + 1 > world.h - 1) {
            return true
        }
        for rm: Room in placed {
            for i: Int in position.x...position.x + width + 1 {
                for j: Int in position.y...position.y + height + 1 {
                    if (rm.inRoom(i, j)) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func overlapFloor(_ placed: Array<Room>) -> Bool {
        if (position.x + width + 1 > world.w - 1) {
            return true
        }
        if (position.y + height + 1 > world.h - 1) {
            return true
        }
        for i: Int in position.x...position.x + width + 1  {
            for j: Int in position.y...position.y + height + 1 {
                for rm: Room in placed {
                    if (rm.inRoomFloor(i, j)) {
                        return true
                    }
                }
            }
        }
        return false;
    }
    
    func overlap(_ rm: Room) -> Bool {
        if (position.x + width + 1 > world.w - 1) {
            return true
        }
        if (position.y + height + 1 > world.h - 1) {
            return true
        }
        for i: Int in  position.x...position.x + width + 1 {
            for j: Int in position.y...position.y + height + 1 {
                if (rm.inRoom(i, j)) {
                    return true
                }
            }
        }
        return false
    }
    
    //includes walls
    func inRoom(_ x: Int, _ y: Int) -> Bool {
        return Tools.inInterval(x, position.x, position.x + width + 1)
        && Tools.inInterval(y, position.y, position.y + height + 1)
    }
    
    //floor only
    func inRoomFloor(_ x: Int, _ y: Int) -> Bool{
        return Tools.inInterval(x, position.x + 1, position.x + width)
    && Tools.inInterval(y, position.y + 1, position.y + height)
    }
    
    func intersection(_ h: Room) -> [Int]? {
        var intersection: [Int]?
        intersection = [-1, -1, -1, -1, -1]
        var a2b2: [Int]? = Tools.intervalIntersection(position.y, position.y + height + 1,
        h.position.y, h.position.y + h.height + 1)
        var a1b1: [Int]? = Tools.intervalIntersection(position.x, position.x + width + 1,
        h.position.x, h.position.x + h.width + 1)
        if (a2b2 == nil || a1b1 == nil) {
            return nil
        }
        intersection![0] = a1b1![0]
        intersection![1] = a1b1![1]
        intersection![2] = a2b2![0]
        intersection![3] = a2b2![1]
        //0 for vertical, 1 for horizontal
        if (a1b1![0] - a1b1![1] != 3) {
            intersection![4] = 0;
        } else if (a2b2![0] - a2b2![1] != 3) {
            intersection![4] = 1;
        }
        return intersection;
    }
    
    func globalPosition(x: Int, y: Int) -> [Int] {
        var rv: [Int] = Array(repeating: 0, count: 2)
        rv[0] = x + position.x;
        rv[1] = y + position.y;
        return rv
    }
    
    func localPosition(x: Int, y: Int) -> [Int]{
        var rv: [Int] = Array(repeating: 0, count: 2)
        rv[0] = x - position.x;
        rv[1] = y - position.y;
        return rv;
    }
    
    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs === rhs
    }
    
    func copy() -> Room {
        var rm: Room = Room(width, height, world)
        rm.connections = self.connections
        rm.position = self.position
        return rm
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(height)
        hasher.combine(width)
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
}
