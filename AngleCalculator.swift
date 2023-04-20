//
//  AngleCalculator.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import Foundation

class AngleCalculator {
    static func isWindDirectionWithinAngles(windDirection: Double, angle1: Double, angle2: Double) -> Bool {
        let startAngle: Double
        let endAngle: Double
        
        if angle1 < angle2 {
            startAngle = angle1
            endAngle = angle2
        } else {
            startAngle = angle2
            endAngle = angle1
        }
        
        return (startAngle...endAngle).contains(windDirection)
    }
}
