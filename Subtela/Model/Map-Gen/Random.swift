//
//  Random.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/23.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import Foundation
import GameKit

class Random {
    
    var seed: CLongLong
    var random_source: GKARC4RandomSource
    var gaussian_distribution: GKGaussianDistribution
    
    init(_ seed: CLongLong) {
        self.seed = seed
        var seed_copy = seed
        self.random_source = GKARC4RandomSource(seed: Data(bytes: &seed_copy, count: MemoryLayout<CLongLong>.size))
        self.gaussian_distribution = GKGaussianDistribution(randomSource: random_source, mean: 0, deviation: 1)
        
    }
    
    // generates next guassina in distribution with mean, deviation
    func nextGaussian(_ mean: Float, _ deviation: Float) -> Float {
        return gaussian_distribution.nextUniform() * deviation + mean
    }
    
    // generates next uniform integer in [floor, ceil)
    func nextUniform(_ floor: Int, _ ceil: Int) -> Int {
        return random_source.nextInt(upperBound: ceil - floor) + floor
    }
    
    //generates next double in [0, 1)
    func nextUniform() -> Double {
        return Double(random_source.nextUniform())
    }
}
