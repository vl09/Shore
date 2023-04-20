//
//  AngleCalculator.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import Foundation
import CoreLocation

struct AngleCalculator {
    static func windAngle(from direction: Double) -> Double {
        // Calculate the wind angle in degrees clockwise from North
        let windAngle = direction.truncatingRemainder(dividingBy: 360)
        return windAngle < 0 ? windAngle + 360 : windAngle
    }
    
    static func isWindDirectionWithinAngles(windDirection: Double, angle1: Double, angle2: Double) -> Bool {
        let windAngle = windAngle(from: windDirection)
        let angle1 = angle1.truncatingRemainder(dividingBy: 360)
        let angle2 = angle2.truncatingRemainder(dividingBy: 360)
        if angle1 < angle2 {
            return angle1 <= windAngle && windAngle <= angle2
        } else {
            return angle1 <= windAngle || windAngle <= angle2
        }
    }
    
    static func bearing(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = origin.latitude.toRadians()
        let lat2 = destination.latitude.toRadians()
        let deltaLon = (destination.longitude - origin.longitude).toRadians()
        
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearing = atan2(y, x).toDegrees()
        
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
}
