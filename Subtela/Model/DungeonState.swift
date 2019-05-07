//
//  DungeonState.swift
//  DungeonSettings
//
//  Created by Jackson on 4/22/19.
//  Copyright © 2019 Jackson. All rights reserved.
//

import Foundation
import UIKit
import Timepiece

// we have preset dungeon states that people can take on
// but all the data for each dungeon type is coppied

class DungeonState {
    var player: String // TODO: Later you can add more players
    var config: DungeonConfig
    var saveNickname: String
    var currentFloor: Int
    var dateStarted: Date
    var dateLastPlayed: Date
    var timeElapsed: Double
    var averageVision: [Double]
    
    
    init() {
        player = "Jane Doe"
        config = DungeonConfig()
        saveNickname = "A Dungeon of Sorts"
        currentFloor = 30
        dateStarted = Date.today()
        dateLastPlayed = Date.today()
        timeElapsed = 0
        averageVision = [50, 20, 100, 30]
    }
    
    // FUNC - update on close
    
    // Custom init file incoming later
}







