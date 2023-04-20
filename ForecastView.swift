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
    
    var body: some View {
        VStack {
            Text(city.name)
                .font(.title)
                .padding(.bottom)
            
            Toggle(isOn: $showFilteredResults) {
                Text("Show Filtered Results")
            }
            .padding(.horizontal)
            
            List {
                if showFilteredResults {
                    ForEach(filteredForecasts()) { forecast in
                        ForecastRow(forecast: forecast)
                    }
                } else {
                    ForEach(forecastService.forecasts) { forecast in
                        ForecastRow(forecast: forecast)
                    }
                }
            }
        }
        .onAppear {
            forecastService.fetch(city: city)
        }
    }
    
    private func filteredForecasts() -> [Forecast] {
        forecastService.forecasts.filter { forecast in
            // Replace `city.angle1` and `city.angle2` with the appropriate properties from your City model
            AngleCalculator.isWindDirectionWithinAngles(windDirection: forecast.direction, angle1: city.angle1, angle2: city.angle2)
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

