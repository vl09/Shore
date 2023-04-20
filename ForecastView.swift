//
//  ForecastView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI

struct ForecastView: View {
    let city: City // Replace with your City model
    @ObservedObject var forecastService: ForecastService
    @State private var showFilteredResults = false
    @State private var windForecast: WindForecast?
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var isPresentingMap = false // Add this state variable



    
    var body: some View {
        VStack {
                    if let selectedLocation = selectedLocation {
                        Text("Selected location: \(selectedLocation.latitude), \(selectedLocation.longitude)")
                    } else {
                        Text("Tap on the map to select a location")
                    }
                    
                    Button(action: {
                        self.isPresentingMap = true
                    }) {
                        Text("Select location")
                    }
                }
        .onAppear {
            forecastService.getWindForecast(for: city) { result in
                switch result {
                case .success(let windForecast):
                    DispatchQueue.main.async {
                        self.windForecast = windForecast
                    }
                case .failure(let error):
                    print("Error fetching wind forecast: \(error)")
                }
            }
        }
        .sheet(isPresented: $isPresentingMap) {
                    MapView(onLocationSelected: { coordinate in
                        self.selectedLocation = coordinate
                        self.isPresentingMap = false
                    })
                }
    }
    
    private func filteredForecasts() -> [Forecast] {
            if let windForecast = windForecast {
                return windForecast.forecasts.filter { forecast in
                    if let angle1 = city.angle1, let angle2 = city.angle2 {
                        return AngleCalculator.isWindDirectionWithinAngles(windDirection: forecast.direction, angle1: angle1, angle2: angle2)
                    } else {
                        return false
                    }
                }
            } else {
                return []
            }
        }
}

struct ForecastRow: View {
    let forecast: Forecast // Replace with your Forecast model
    
    var body: some View {
        HStack {
            Text("\(forecast.time, formatter: DateFormatter.hour)")
                .font(.headline)
            
            Spacer()
            
            Text("Speed: \(forecast.speed) m/s")
                .font(.subheadline)
            
            Spacer()
            
            Text("Gusts: \(forecast.gusts) m/s")
                .font(.subheadline)
        }
    }
}

extension DateFormatter {
    static let hour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView(city: City.example, forecastService: ForecastService()) // Replace with your City model and an instance of your ForecastService
    }
}

