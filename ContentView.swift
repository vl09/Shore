//
//  ContentView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import MapKit
import WatchKit

struct ContentView: View {
    @State private var selectedCity: City?
    @State private var windData: [Forecast] = []
    @State private var isEditing: Bool = true
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var isPresentingMap = false
    @State private var shouldRotateRedLine = true
    @State private var isDefiningLandSea = false
    @State private var landSea: LandSea?
        
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
                        
                        Button(action: {
                            self.isPresentingMap = true
                        }) {
                            Text("Select location")
                        }
                    } else if isDefiningLandSea {
                        DefineLandSeaView(onLandSeaDefined: { landSea in
                            self.landSea = landSea
                            self.isDefiningLandSea = false
                        })
                        .onAppear { shouldRotateRedLine = false }
                        .onDisappear { shouldRotateRedLine = true }
                    } else if let selectedLocation = selectedLocation {
                        RedLineView(coordinate: selectedLocation, shouldRotate: shouldRotateRedLine)
                            .onAppear { shouldRotateRedLine = true }
                    } else {
                        ForecastView(city: city, forecastService: ForecastService())
                    }
                } else {
                    Text("No city selected.")
                }
            }
            .navigationTitle("Wind Forecast")
            .onAppear(perform: {
                // Fetch user's current location and the nearest coastal city
            })
            .sheet(isPresented: $isPresentingMap) {
                MapView(onLocationSelected: { coordinate in
                    self.selectedLocation = coordinate
                    self.isPresentingMap = false
                    
                    // Use the selected location to determine the nearest coastal city
                })
            }
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

struct RedLineView: WKInterfaceObjectRepresentable {
    typealias WKInterfaceObjectRepresentableType = WKInterfaceImage
    
    let coordinate: CLLocationCoordinate2D
    let shouldRotate: Bool
    
    func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<RedLineView>) -> WKInterfaceImage {
        let image = WKInterfaceImage()
        image.setImage(UIImage(systemName: "arrow.up")!)
        return image
    }
    
    func updateWKInterfaceObject(_ image: WKInterfaceImage, context: WKInterfaceObjectRepresentableContext<RedLineView>) {
        let initialRotation = bearing(
            from: coordinate,
            to: CLLocationCoordinate2D(latitude: coordinate.latitude + 0.01, longitude: coordinate.longitude)
        )
        image.setTintColor(.red)
        image.setRotaryEncoderValue(initialRotation, animated: true)
        image.addRotaryEncoder(
            with: { (value: Float, finalValue: Float, rotated: Bool, click: Bool) in
                if rotated {
                    image.setRotaryEncoderValue(Double(value), animated: false)
                }
            }
        )
    }
    
    private func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLat = degreesToRadians(degrees: from.latitude)
        let fromLng = degreesToRadians(degrees: from.longitude)
        let toLat = degreesToRadians(degrees: to.latitude)
        let toLng = degreesToRadians(degrees: to.longitude)
        let dLng = toLng - fromLng
        let y = sin(dLng) * cos(toLat)
        let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(dLng)
        return radiansToDegrees(radians: atan2(y, x))
    }
    
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180
    }
    
    private func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / .pi
    }
}


enum LandSea {
    case land
    case sea
}

struct DefineLandSeaView: View {
    let onLandSeaDefined: (LandSea) -> Void
    
    var body: some View {
        VStack {
            Text("Define land/sea quadrants")
                .font(.headline)
            
            Spacer()
            
            MapView(onLocationSelected: { _ in })
            
            Spacer()
            
            Button(action: {
                self.onLandSeaDefined(.land)
            }) {
                Text("Define Land")
            }
            
            Button(action: {
                self.onLandSeaDefined(.sea)
            }) {
                Text("Define Sea")
            }
            
            Spacer()
        }
    }
}
