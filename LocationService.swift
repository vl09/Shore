//
//  LocationService.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var coastalCities: [City] // Add a list of coastal cities you want to support

    var currentLocation: CLLocation?
    var nearestCoastalCity: City?

    override init() {
        locationManager = CLLocationManager()
        coastalCities = [] // Initialize the coastalCities property
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            findNearestCoastalCity()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    // MARK: - Helper Methods
    
    private func findNearestCoastalCity() {
        guard let currentLocation = currentLocation else { return }
        
        var closestCity: City?
        var shortestDistance: CLLocationDistance = CLLocationDistanceMax
        
        for city in coastalCities {
            let cityLocation = CLLocation(latitude: city.coordinate.latitude, longitude: city.coordinate.longitude)
            let distance = currentLocation.distance(from: cityLocation)
            
            if distance < shortestDistance {
                shortestDistance = distance
                closestCity = city
            }
        }
        
        nearestCoastalCity = closestCity
    }
}

