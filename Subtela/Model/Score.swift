//
//  Score.swift
//  DungeonSettings
//
//  Created by Jackson on 4/22/19.
//  Copyright © 2019 Jackson. All rights reserved.
//
//  Purpose: Object to represent score in dungeon

import Foundation
import Timepiece
import RealmSwift

@objcMembers class Score: Object {
    // TODO: Determine criteria for a score
    dynamic var username: String = ""
    dynamic var dateCompleted: Date = Date.today()
    dynamic var dateStarted: Date = Date.today()
    dynamic var timeTaken: Double = 0 // in seconds
    dynamic var distanceCovered: Double = 0
    // map vision on average at a given floor as a percentage of the overall map
    dynamic var avgMapVision: Double = 0
    
    // TODO: Add way to change the weights of these things later
    func overallScore() -> Double {
//        let overall = self.timeTaken + self.distanceCovered + self.avgMapVision
//        return overall
        return 0
    }
    
}
