//
//  Position.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/11.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation

class Position {
    var x: Int
    var y: Int
    
    init() {
        self.x = -1
        self.y = -1
    }
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}
