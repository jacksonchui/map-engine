//
//  Graph.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/04.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation

class Graph {
    // references to rooms // hallways
    var vertices: Array<Room>
    var edges: Array<Hallway>
    
    // map sizes and things
    var h: Int
    var w: Int
    var roomNums: Int
    var minRooms: Int
    var maxRooms: Int
    var rv: [[Tile]]
    var random: Random
    
    init(width: Int, height: Int, seed: CLongLong) {
        w = width
        h = height
        minRooms = 2
        maxRooms = 40
        vertices = Array<Room>()
        edges = Array<Hallway>()
        rv = [[Tile]]()
        random = Random(seed)
        repeat {
            roomNums = Tools.roomNums(random, width: w, height: h);
        } while (roomNums < minRooms || roomNums > maxRooms)

    }
    
    func fill() -> Void {
        vertices = Array<Room>()
        edges = Array<Hallway>()
        var connected: Bool = false
        while (!connected) {
            var filled: Bool;
            if (vertices.isEmpty || vertices.count < minRooms) {
                repeat {
                    filled = fillRooms();
                    roomNums = Int(ceil(0.9 * Double(roomNums)))
                } while ((Double(area()) > 0.75 * Double(w) * Double(h)) || !filled)
            }
            connected = fillConnections()
        }
        fillHallways()
    }
    
    func generate() -> [[Graph.Tile]] {
        rv = Array(repeating: Array(repeating: Graph.Tile.Outside, count: h), count: w)
//        for i in 0..<w {
//            for j in 0..<h {
//
//            }
//        }
        for rm: Room in vertices {
            rm.copyTo(&rv)
        }
        for hw: Hallway in edges {
            hw.copyTo(&rv)
        }
        
        rv = MapEditor.clearTips(&rv, self)
        rv = MapEditor.clearIntersections(&rv, self)
        rv = MapEditor.wrapWalls(&rv, self)
        return rv
    }
    
    func fillRooms() -> Bool {
        vertices = Array<Room>();
        var factor: Double = 0.5
        var resetAllRooms: Int = 0
        var resetRoom: Int = 0
        while (vertices.count < roomNums) {
            while (resetAllRooms < 3) {
                while (resetRoom < 10) {
                    if (addRoom(factor)) {
                        resetRoom = 0
                        if (vertices.count == roomNums) {
                            break
                        }
                    } else {
                        resetRoom += 1
                    }
                }
                if (vertices.count == roomNums) {
                    break
                }
                resetRoom = 0
                resetAllRooms += 1
                vertices = Array<Room>()
            }
            resetAllRooms = 0
            factor = factor * 0.9
        }
        
        if (vertices.count == 0) {
            return false
        }
        return true
    }
    
    func fillConnections() -> Bool {
        //cannot connect an empty graph
        if (vertices.isEmpty) {
            return false
        }
        
        //remove vertices that are not adjacent to anything
        let cloned: Array<Room> = vertices.map{ $0 }
        for rm: Room in cloned {
            if (rm.adjacent(vertices).isEmpty) {
                vertices.remove(at: vertices.firstIndex(of: rm)!)
            }
        }
        
        for rm: Room in vertices {
            for rq: Room in rm.adjacent(vertices) {
                rm.connections.append(rq)
            }
        }
        
        if (!connected()) {
            while (connectedComponents().count > 1) {
                let c: Set<Room> = connectedComponents().first(where: {_ in true})!
                vertices.removeAll(where: { c.contains($0) })
            }
        }
        
        resetConnections()
        
        for rm: Room in vertices {
            for rq: Room in rm.adjacent(vertices) {
                if (random.nextUniform() > 0.6) {
                    rm.connections.append(rq)
                    rq.connections.append(rm)
                }
            }
        }
        
        return connected()
    }
    
    func fillHallways() -> Void {
        
        for rm: Room in vertices {
            while (!rm.connections.isEmpty) {
                let rq: Room = rm.connections[0]
                edges.append(addHallway(rm,rq))
                rm.connections.remove(at: rm.connections.firstIndex(of: rq)!)
                rq.connections.remove(at: rq.connections.firstIndex(of: rm)!)
            }
        }
        
        for hw: Hallway in edges {
            let rm: Room = hw.connections[0]
            let rq: Room = hw.connections[1]
            rm.connections.append(rm)
            rq.connections.append(rq)
        }
        
        for _  in 0..<15 {
            let length: Int = random.nextUniform(3, min(self.w, self.h))
            var hw: Hallway
            if (random.nextUniform() > 0.5) {
                hw = Hallway(length, 1, self, false)
            } else {
                hw = Hallway(1, length, self, true)
            }
            for _ in 0..<10 {
                if (hw.placeHallway(vertices, edges)) {
                    edges.append(hw)
                    break
                }
            }
        }
        for hw: Hallway in edges {
            if (hw.connections.isEmpty) {
                hw.justTheTip()
            }
        }
    }
    
    func area() -> Int { //includes wall area
        var sum: Int = 0
        for rm: Room in vertices {
            sum += (rm.height + 2) * (rm.width + 2);
        }
        return sum;
    }
    
    func addRoom(_ factor: Double) -> Bool {
        var size: [Int] = Tools.roomSize(random, factor, w, h, roomNums)
        let x: Int = size[0]
        let y: Int = size[1]
        let rm: Room = Room(x, y, self)
        
        if (rm.placeRoom(vertices)) {
            vertices.append(rm);
            return true
        }
        
        return false
    }
    
    func addHallway(_ r1: Room, _ r2: Room) -> Hallway {
        var point: [Int] = pointOfConnection(r1, r2)
        var width, height: Int
        var vert: Bool = false
        if (point[0] == point[2]) {
            width = 1
            height = point[1] - point[3] - 1
            vert = true
        } else {
            width = point[0] - point[2] - 1
            height = 1
        }
        var hw: Hallway = Hallway(width, height, self, vert)
        hw.connections.append(r1)
        hw.connections.append(r2)
        hw.position.x = point[2]
        hw.position.y = point[3]
        hw.placeHallway(vertices)
        
        return hw
    }
    
    func connectedComponents() -> Set<Set<Room>> {
        var connectedComponents: Set< Set<Room> > = Set< Set<Room> >()
        for rm: Room in vertices {
            var component: Array<Room> = Array<Room>()
            connected(&component, rm)
            connectedComponents.insert(Set<Room>(component))
        }
        return connectedComponents
    }
    
    func resetConnections() -> Void {
        for rm in vertices {
            rm.connections =  Array<Room>()
        }
    }
    /**
     * Traverses the graph to look for vertices
     * @return whether all vertices are connected
     */
    func connected() -> Bool {
        if (vertices.isEmpty) {
            return false
        }
        var found: Array<Room> = Array<Room>()
        var rm: Room = vertices[0]
        found.append(rm);
        connected(&found, rm);
        return found.count == vertices.count
    }

    /**
     * Updates the found list and continues traversing the graph. Recursive.
     * @param found the vertices already traversed
     * @param base the vertex to begin with
     */
    func connected(_ found: inout Array<Room>,_ base: Room) -> Void {
        for rm: Room in base.connections {
            if (!found.contains(rm)) {
                found.append(rm);
                connected(&found, rm);
            }
        }
    }

    
    func pointOfConnection(_ r1: Room, _ r2: Room) -> [Int] {
        var point: [Int] = [-1, -1, -1, -1] //start goes first, end goes next
    
        var vertical: [Int]? = Tools.intervalIntersection(r1.position.x + 1,
            r1.position.x + r1.width,
            r2.position.x + 1,
            r2.position.x + r2.width)
        var horizontal: [Int]? = Tools.intervalIntersection(r1.position.y + 1,
            r1.position.y + r1.height,
            r2.position.y + 1,
            r2.position.y + r2.height)
        //vertical or horizontal?
    
        if let vertical = vertical {
                point[0] = vertical[0] - 1
                point[1] = Tools.higherRoom(r1, r2).position.y
                point[2] = point[0]
                point[3] = Tools.lowerRoom(r1, r2).position.y + Tools.lowerRoom(r1, r2).height + 1
            } else {
                let horizontal = horizontal!
                point[0] = Tools.rightRoom(r1, r2).position.x
                point[1] = horizontal[0] - 1
                point[3] = point[1]
                point[2] = Tools.leftRoom(r1, r2).position.x + Tools.leftRoom(r1, r2).width + 1
            }
        return point
    }
    
    func hasSpace(_ rm: Room) -> Bool{
        for i in 0..<w {
            for j in 0..<h {
                rm.position.x = i
                rm.position.y = j
                if (!rm.overlap(vertices)) {
                    rm.position.x = -1
                    rm.position.y = -1
                    return true
                }
            }
        }
        return false
    }
    
    func inRooms(x: Int, y: Int) -> Bool {
        for rm: Room in vertices {
            if (rm.inRoomFloor(x,y)) {
                return true
            }
        }
        return false
    }
    
    func whichRoom(p: Position) -> Room? {
        for rm: Room in vertices {
            if (rm.inRoomFloor(p.x, p.y)) {
                return rm;
            }
        }
        return nil;
    }
    
    func inHallways(p: Position) -> Bool{
        for hw: Hallway in edges {
            if (hw.inRoomFloor(p.x, p.y)) {
                return true
            }
        }
        return false
    }
    
    
    func whichHallway(p: Position) -> Hallway? {
        for hw: Hallway in edges {
            if (hw.inHallwayFloor(p.x, p.y)) {
                return hw
            }
        }
        return nil;
    }
    
    enum Tile {
        case Floor
        case Outside
        case Wall
    }
    
}
