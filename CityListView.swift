//
//  CityListView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import MapKit

struct CityListView: View {
    @StateObject private var cityStorage = CityStorage()
    @State private var selectedCity: City?
    @State private var showCityEditor: Bool = false
    @State private var refreshFlag = false
    
    var body: some View {
        ScrollView {
            VStack {
                if let city = selectedCity {
                    CityMapInterfaceView(city: city)
                        .environmentObject(cityStorage)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    VStack {
                        ForEach(cityStorage.cities, id: \.id) { city in
                            NavigationLink(destination: CityMapInterfaceView(city: city)) {
                                Text(city.name)
                            }
                        }
                        .onDelete(perform: removeCity)
                    }
                    .id(refreshFlag)
                    
                    Button(action: {
                        showCityEditor.toggle()
                    }) {
                        Text("Add City")
                    }
                    .sheet(isPresented: $showCityEditor) {
                        CityEditorView(selectedCity: $selectedCity, onSave: { newCity in
                            if let index = cityStorage.cities.firstIndex(where: { $0.id == newCity.id }) {
                                cityStorage.edit(city: newCity)
                            } else {
                                cityStorage.save(city: newCity)
                            }
                            refreshFlag.toggle() // Toggle the refreshFlag after saving or editing a city
                        })
                    }
                }
            }
        }
    }
    
    
    private func removeCity(at offsets: IndexSet) {
        offsets.forEach { index in
            let cityToRemove = cityStorage.cities[index]
            cityStorage.delete(city: cityToRemove)
        }
    }
    
    func saveCity(newCity: City) {
        if cityStorage.cities.contains(where: { $0.id == newCity.id }) {
            cityStorage.edit(city: newCity)
        } else {
            cityStorage.save(city: newCity)
        }
        cityStorage.forceUpdate()
    }
    
    
    struct CityListView_Previews: PreviewProvider {
        static var previews: some View {
            CityListView()
        }
    }
}
