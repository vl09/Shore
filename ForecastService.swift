//
//  ForecastService.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import Foundation

class ForecastService: ObservableObject {
    @Published var forecasts: [Forecast] = []
    private let apiKey = "1281e51407b47e21ad0d70377d5344df" // Replace with your OpenWeatherMap API key
    
    
    func getWindForecast(for city: City, completion: @escaping (Result<WindForecast, Error>) -> Void) {
        // Replace "YOUR_API_KEY" with your actual OpenWeatherMap API key
        let forecastAPI = ForecastAPI(apiKey: "1281e51407b47e21ad0d70377d5344df")
        forecastAPI.fetchWindForecast(for: city.coordinate.toCLLocationCoordinate2D(), completion: completion)
    }




    func fetch(city: City) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(city.coordinate.latitude)&lon=\(city.coordinate.longitude)&exclude=current,minutely,daily,alerts&appid=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if let decodedResponse = try? decoder.decode(OpenWeatherMapResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.forecasts = decodedResponse.hourly.map { forecast in
                            Forecast(time: forecast.dt, speed: forecast.wind_speed, gusts: forecast.wind_gust ?? 0, direction: forecast.wind_deg)
                        }
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

// Data models for decoding OpenWeatherMap API response
struct OpenWeatherMapResponse: Codable {
    let hourly: [OpenWeatherMapHourly]
}

struct OpenWeatherMapHourly: Codable {
    let dt: Date
    let wind_speed: Double
    let wind_gust: Double?
    let wind_deg: Double
}
