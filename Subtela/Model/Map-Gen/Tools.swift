//
//  Tools.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/04.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation
import GameplayKit

class Tools {
    
    static func inInterval(_ x: Int, _ a: Int, _ b: Int) -> Bool {
        return a <= x && x <= b
    }
    
    static func intervalOverlap(_ a1: Int, _ b1: Int, _ a2: Int, _ b2: Int) -> Bool{
        return inInterval(a1, a2, b2) || inInterval(b1, a2, b2)
            || inInterval(a2, a1, b1) || inInterval(b2, a1, b1)
    }
    
    static func coordInInterval(_ p : Position,_ i: [Int]) -> Bool {
        return inInterval(p.x, i[0], i[1]) && inInterval(p.y, i[2], i[3])
    }
    
    static func roomSize(_ r: Random, _ factor: Double, _ w: Int, _ h: Int, _ roomNums: Int) -> [Int] {
        var size: [Int] = Array(repeating: 0, count: 2)
        let avgRoomHeight: Float = Float(w) / sqrt(Float(roomNums))
        let avgRoomWidth = Float(h) / sqrt(Float(roomNums))
        let avgRoomDim: Float = min(avgRoomHeight, avgRoomWidth)
        var randomwidth  = Int(ceil(r.nextGaussian(avgRoomDim, avgRoomWidth) * Float(factor)))
        var randomheight = Int(ceil(r.nextGaussian(avgRoomDim, avgRoomHeight) * Float(factor)))
//        var randomwidth: Int = Int(ceil(GKGaussianDistribution(randomSource: GKRandomSource(), mean: Float(avgRoomDim), deviation: Float(avgRoomWidth)).nextUniform() * Float(factor)))
//
//        var randomheight: Int = Int(ceil(GKGaussianDistribution(randomSource: GKRandomSource(), mean: Float(avgRoomDim), deviation: Float(avgRoomHeight)).nextUniform() * Float(factor)))
        while (randomwidth < 2) {
            randomwidth = Int(ceil(r.nextGaussian(avgRoomDim, avgRoomWidth) * Float(factor)))
        }
        while (randomheight < 2) {
            randomheight  = Int(ceil(r.nextGaussian(avgRoomDim, avgRoomHeight) * Float(factor)))
        }
        size[0] = randomwidth
        size[1] = randomheight
        return size
    }
    
    // return number of rooms
    // TODO: base number of rooms on height / width of map
    static func roomNums(_ r: Random, width w: Int, height h: Int) -> Int{
        let numRooms: Int = r.nextUniform(10, 20)
        if (numRooms < 2) {
            return roomNums(r, width: w, height: h);
        }
        return numRooms
    }
    
    static func intervalIntersection(_ a1: Int, _ b1: Int, _ a2: Int, _ b2: Int) -> [Int]? {
        var a, b: Int
        if (!intervalOverlap(a1, b1, a2, b2)) {
            return nil
        } else {
            if (inInterval(a1, a2, b2)) {
                a = a1
            } else {
                a = a2
            }
            if (inInterval(b1, a1, b2)) {
                b = b1
            } else {
                b = b2
            }
        }
        var rv: [Int]? = [a, b]
        return rv
    }
    
    
    static func higherRoom(_ r1: Room, _ r2: Room) -> Room {
        if (r1.position.y >= r2.position.y) {
            return r1
        }
        return r2
    }
    
    static func lowerRoom(_ r1: Room, _ r2: Room) -> Room {
        if (r1.position.y >= r2.position.y) {
            return r2
        }
        return r1
    }
    
    static func rightRoom(_ r1: Room, _ r2: Room) -> Room {
        if (r1.position.x >= r2.position.x) {
            return r1
        }
        return r2
    }
    static func leftRoom(_ r1: Room, _ r2: Room) -> Room {
        if (r1.position.x >= r2.position.x) {
            return r2
        }
        return r1
    }
    
    static func onEnd(_ i: [Int], _ hw: Hallway) -> Bool {
        if (hw.vertical()) {
            return i[2] == hw.position.y || i[3] == hw.position.y + hw.height + 1
        } else {
            return i[0] == hw.position.x || i[1] == hw.position.x + hw.width + 1
        }
    }
    
    static func whichEnd(_ intersection: [Int], _ hw: Hallway) -> Bool {
        if (hw.vertical()) {
            return intersection[2] == hw.position.y
        }
        else {
            return intersection[0] == hw.position.x;
        }
    }
    
    static func whichEndIndex(_ i: [Int], _ hw: Hallway) -> Int {
        if (!onEnd(i, hw)) {
            return -1
        }
        if (hw.vertical() && whichEnd(i, hw)) {
            return 2
        } else if (hw.vertical() && !whichEnd(i, hw)) {
            return 3
        } else if (whichEnd(i, hw)) {
            return 0
        } else {
            return 1
        }
    }
    
    static func midIntersection(_ i: [Int], _ hw: Hallway) -> [Int] {
        var inter: [Int] = [-1, -1, -1, -1]
        var index: Int = whichEndIndex(i, hw)
        if (hw.vertical()) {
            inter[0] = hw.position.x + 1
            inter[1] = i[2]
            inter[2] = inter[0]
            inter[3] = i[3]
            return inter;
        } else {
            inter[0] = i[0]
            inter[1] = hw.position.y + 1
            inter[2] = i[1]
            inter[3] = inter[1]
            return inter
        }
    }
    
    static func endPoints(_ hw: Hallway) -> [Int] {
        var end: [Int] = [-1, -1, -1, -1] //format {x1, y1, x2, y2} //in global coordinates
        if (hw.vertical()) {
            end[0] = 1 + hw.position.x;
            end[1] = hw.position.y;
            end[2] = end[0];
            end[3] = hw.position.y + hw.height + 1;
        } else {
            end[0] = hw.position.x;
            end[1] = 1 + hw.position.y;
            end[2] = hw.position.x + hw.width + 1;
            end[3] = end[1];
        }
        return end;
    }
    
    
    
    
    
}
