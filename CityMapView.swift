//
//  CityMapView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import MapKit

struct CityMapView: View {
    let city: City
    @State private var firstLineAngle: Double = 0
    @State private var secondLineAngle: Double = 45

    var body: some View {
        VStack {
            Text(city.name)
                .font(.title)
                .padding(.bottom)
            
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(from: city.coordinate), latitudinalMeters: 2000, longitudinalMeters: 2000)), interactionModes: [])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension CLLocationCoordinate2D {
    init(from coordinate: Coordinate) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct CityMapView_Previews: PreviewProvider {
    static var previews: some View {
        CityMapView(city: City(name: "San Francisco", coordinate: Coordinate(latitude: 37.7749, longitude: -122.4194), angle1: 0.0, angle2: 0.0))
    }
}
