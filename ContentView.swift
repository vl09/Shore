//
//  ContentView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var selectedCity: City? // Replace with your City model
    @State private var windData: [Forecast] = [] // Replace with your WindData model
    @State private var isEditing: Bool = true

    var body: some View {
            NavigationView {
                VStack {
                    if let city = selectedCity {
                        if isEditing {
                            CityMapInterfaceView(city: city)
                                .onDisappear {
                                    isEditing = false
                                    // Fetch wind forecast data for the selected city
                                }
                        } else {
                            ForecastView(city: city, forecastService: ForecastService()) // Replace with your City model and an instance of your ForecastService
                        }
                    } else {
                        Text("No city selected.")
                    }
                }
                .navigationTitle("Wind Forecast")
                .onAppear(perform: {
                    // Fetch user's current location and the nearest coastal city
                })
            }
        }
    }


struct WindInfoView: View {
    let windData: [Forecast]

    var body: some View {
        VStack {
            // Display wind forecast information for the selected city
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
