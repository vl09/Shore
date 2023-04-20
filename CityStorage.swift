//
//  CityStorage.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import Foundation
import Combine

class CityStorage: ObservableObject {
    private let citiesKey = "cities"
    private let userDefaults: UserDefaults

    @Published var cities: [City] {
            didSet {
                saveCities(cities: cities)
            }
        }

    init(userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
            self.cities = []

            if let data = userDefaults.data(forKey: citiesKey),
               let loadedCities = try? JSONDecoder().decode([City].self, from: data) {
                self.cities = loadedCities
            }
        }
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    
    func getCities() -> [City] {
        return cities
    }
    
    func save(city: City) {
        objectWillChange.send()
        cities.append(city)
        saveCities(cities: cities)
        print("Saving city: \(city)")
    }

    func edit(city: City) {
        if let index = cities.firstIndex(where: { $0.id == city.id }) {
            objectWillChange.send()
            cities[index] = city
            saveCities(cities: cities)
        }
    }

    func delete(city: City) {
        if let index = cities.firstIndex(where: { $0.id == city.id }) {
            objectWillChange.send()
            cities.remove(at: index)
            saveCities(cities: cities)
        }
    }
    
    func remove(city: City) {
        var cities = loadCities()
        cities.removeAll { $0.id == city.id }
        saveCities(cities: cities)
    }
    
    func forceUpdate() {
        objectWillChange.send()
    }
    
    

    
    public func loadCities() -> [City] {
            guard let data = userDefaults.data(forKey: citiesKey),
                  let cities = try? JSONDecoder().decode([City].self, from: data) else {
                return []
            }
            return cities
        }

    
    private func saveCities(cities: [City]) {
            if let data = try? JSONEncoder().encode(cities) {
                userDefaults.set(data, forKey: citiesKey)
            }
        }
    
    private var onUpdate: (() -> Void)?

    func onUpdate(_ closure: @escaping () -> Void) {
        onUpdate = closure
    }
}
