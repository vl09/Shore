//
//  ForecastAPI.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/20/23.
//

import Foundation
import CoreLocation

struct ForecastAPI {
    let apiKey: String

        func fetchWindForecast(for coordinate: CLLocationCoordinate2D, completion: @escaping (Result<WindForecast, Error>) -> Void) {
            let baseURL = "https://api.openweathermap.org/data/2.5/forecast?"
                let locationQuery = "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
                let apiKeyQuery = "&appid=\(apiKey)"
                let unitsQuery = "&units=metric"
                let urlString = baseURL + locationQuery + apiKeyQuery + unitsQuery

                guard let url = URL(string: urlString) else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                    completion(.failure(error))
                    return
                }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                    return
                }

                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    let windForecast = WindForecast(from: weatherData.list)
                    completion(.success(windForecast))
                } catch {
                    completion(.failure(error))
                }



            }

            task.resume()
        }
}

struct WeatherData: Decodable {
    let list: [ForecastData]
    
    struct ForecastData: Decodable {
        let dt: TimeInterval
        let wind: Wind
        
        struct Wind: Decodable {
            let speed: Double
            let deg: Double
        }
    }
}


struct Forecast: Identifiable {
    let id = UUID()
    let time: Date
    let speed: Double
    let gusts: Double
    let direction: Double

    init(time: Date, speed: Double, gusts: Double, direction: Double) {
        self.time = time
        self.speed = speed
        self.gusts = gusts
        self.direction = direction
    }
}


struct Wind: Codable {
    let speed: Double
    let deg: Double
}

struct WindForecast {
    let forecasts: [Forecast]

    init(from weatherDataForecasts: [WeatherData.ForecastData]) {
        self.forecasts = weatherDataForecasts.map { forecast in
            let date = Date(timeIntervalSince1970: forecast.dt)
            return Forecast(time: date, speed: forecast.wind.speed, gusts: 0, direction: forecast.wind.deg)
        }
    }
}




