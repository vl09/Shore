//
//  City.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import Foundation
import CoreLocation

struct City: Identifiable, Codable {
    let id: UUID
    let name: String
    let coordinate: Coordinate
    let angle1: Double?
    let angle2: Double?
    var landStartAngle: Double?
    var landEndAngle: Double?

    init(id: UUID = UUID(), name: String, coordinate: Coordinate, angle1: Double? = nil, angle2: Double? = nil, landStartAngle: Double? = nil, landEndAngle: Double? = nil) {
        self.id = UUID()
        self.name = name
        self.coordinate = coordinate
        self.angle1 = angle1
        self.angle2 = angle2
        self.landStartAngle = landStartAngle
        self.landEndAngle = landEndAngle
    }

    static let example = City(name: "San Francisco", coordinate: Coordinate(latitude: 37.7749, longitude: -122.4194))
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
}
