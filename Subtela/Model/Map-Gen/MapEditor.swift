//
//  MapEditor.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/20.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation

class MapEditor {
    
    /**
     Used to edit the ends of hallways. Also, edits the map passed in
    **/
    static func clearTips(_ t: inout [[Graph.Tile]], _ g: Graph) -> [[Graph.Tile]]{
        for hw: Hallway in g.edges {
            
            // First fill end both ends of hallway, regardless if connected to room or not
            let ends: [Int] = Tools.endPoints(hw)
            t[ends[0]][ends[1]] = Graph.Tile.Wall
            t[ends[2]][ends[3]] = Graph.Tile.Wall
            
            //now, unblock rooms based on connections
            for rm: Room in hw.connections {
                // we assume intersection is not nil because they are connected
                let i: [Int]? = hw.intersection(rm)
                if (Tools.whichEnd(i!, hw)) {
                    t[ends[0]][ends[1]] = Graph.Tile.Floor
                } else {
                    t[ends[2]][ends[3]] = Graph.Tile.Floor
                }
            }
        }
        return t
    }
    
    /***
    Used to edit intersections between hallways so that they are properly unblocked
    ***/
    static func clearIntersections (_ t: inout [[Graph.Tile]], _ g: Graph) -> [[Graph.Tile]] {
        // 3x3 (standard intersections
        for hw: Hallway in g.edges {
            for hq: Hallway in g.edges {
                if (hw.intersects(hq)) {
                    let i: [Int]? = hw.intersection(hq)
                    var mid: [Int] = Tools.midIntersection(i!, hw)
                    t[mid[0]][mid[1]] = Graph.Tile.Floor
                    t[mid[2]][mid[3]] = Graph.Tile.Floor
                    
                    // valid because hallway connections are added at the end of list !!
                    if !hw.connections.isEmpty && !(hw.connections[0] is Hallway) {
                        continue
                    }
                    
                    if (hw.connections.contains(hq) && hw.properIntersects(hq)) || (Tools.onEnd(i!, hw) && hq.connections.contains(hw)) {
                        let index: Int = Tools.whichEndIndex(i!, hw)
                        //if i[2] is the end, then u want mid[0] and mid[1]
                        //if i[3] is the end, then u want mid[2] and mid[3]
                        //if i[0] is the end, then u want mid[0] and mid[1]
                        //if i[1] is the end, then u want mid[2] and mid[3]
                        t[mid[(-2 * ((index + 1) % 2)) + 2]][mid[(-2) * ((index + 1) % 2) + 3]]
                            = Graph.Tile.Wall
                    }
                }
            }
        }
        return t
    }
    
    static func wrapWalls (_ t: inout [[Graph.Tile]], _ g: Graph) -> [[Graph.Tile]] {
        
        for i in 0..<g.w {
            for j in 0..<g.h {
                if (t[i][j] == Graph.Tile.Outside) {
                    for k in 0..<9 {
                        if (validIndex(i - 1  + (k % 3), j - 1 + (k / 3), g.w, g.h) && t[i-1+(k%3)][j-1+(k/3)] == Graph.Tile.Floor) {
                            t[i][j] = Graph.Tile.Wall
                            break
                        }
                    }
                }
            }
        }
        return t
    }

    private static func validIndex(_ i: Int, _ j: Int, _ w: Int, _ h: Int) -> Bool {
        return i >= 0 && i < w && j >= 0 && j < h
    }

}
