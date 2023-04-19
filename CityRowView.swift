//
//  CityRowView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/19/23.
//

import SwiftUI

struct CityRowView: View {
    @Binding var city: City
    
    var body: some View {
        Text(city.name)
    }
}

struct CityRowView_Previews: PreviewProvider {
    static var previews: some View {
        CityRowView(city: .constant(City(id: UUID(), name: "Sample City", coordinate: Coordinate(latitude: 0, longitude: 0), angle1: 0, angle2: 0)))
    }
}
