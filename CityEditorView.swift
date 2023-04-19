//
//  CityEditorView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import CoreLocation

struct CityEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var cityStorage: CityStorage
    @Binding var selectedCity: City?
       let onSave: (City) -> Void

    @State private var name = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var angle1 = ""
    @State private var angle2 = ""

    var body: some View {
        VStack {
            HStack {
                
                Text(selectedCity == nil ? "Add City" : "Edit City")
                    .font(.headline)
                
                Spacer()
                
                saveButton
            }
            .padding()
            
            Form {
                TextField("City Name", text: $name)
            }
        }
        .onAppear {
            if let city = selectedCity {
                name = city.name
                latitude = "\(city.coordinate.latitude)"
                longitude = "\(city.coordinate.longitude)"
                angle1 = "\(city.angle1)"
                angle2 = "\(city.angle2)"
            }
        }
        .onChange(of: name) { newValue in
            geocodeCity(cityName: newValue)
        }
    }

    private var saveButton: some View {
        Button("Save") {
            let city = City(
                id: selectedCity?.id ?? UUID(),
                name: name,
                coordinate: Coordinate(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0),
                angle1: Double(angle1) ?? 0,
                angle2: Double(angle2) ?? 0
            )
            onSave(city)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func geocodeCity(cityName: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    self.latitude = "\(location.coordinate.latitude)"
                    self.longitude = "\(location.coordinate.longitude)"
                }
            }
        }
    }
}

struct CityEditorView_Previews: PreviewProvider {
    static var previews: some View {
        CityEditorView(selectedCity: .constant(nil), onSave: { _ in })
            .environmentObject(CityStorage())
    }
}
