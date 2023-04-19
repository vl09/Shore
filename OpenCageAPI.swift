//
//  OpenCageAPI.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import Foundation
import CoreLocation

struct OpenCageAPI {
    private let apiKey = "7acc3c1325264886bb8166e636ca27e5"
    
    func fetchCoordinates(cityName: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let urlString = "https://api.opencagedata.com/geocode/v1/json?q=\(cityName)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(OpenCageResponse.self, from: data)
                if let coordinate = response.results.first?.geometry {
                    let location = CLLocationCoordinate2D(latitude: coordinate.lat, longitude: coordinate.lng)
                    completion(.success(location))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No coordinates found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

struct OpenCageResponse: Codable {
    let results: [OpenCageResult]
}

struct OpenCageResult: Codable {
    let geometry: OpenCageGeometry
}

struct OpenCageGeometry: Codable {
    let lat: Double
    let lng: Double
}
