//
//  CityMapInterfaceView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import MapKit

struct CityMapInterfaceView: View {
    @EnvironmentObject var cityStorage: CityStorage
    var city: City
    @State private var angle1: CGFloat = 0
    @State private var angle2: CGFloat = 0
    @State private var region = MKCoordinateRegion()
    @State private var coordinate = CLLocationCoordinate2D()
    @State private var settingFirstLine: Bool = true
    @State private var isNavigating: Bool = false
    @State private var stage: Int = 0
    
    private var mapInteractionMode: MapInteractionModes {
        stage >= 1 ? [] : .all
    }

    var body: some View {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: city.coordinate.toCLLocationCoordinate2D(), latitudinalMeters: 2000, longitudinalMeters: 2000)), interactionModes: mapInteractionMode)
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                Group {
                                    if stage >= 1 {
                                        Color.clear
                                    }
                                }
                            )

                        RotatingLines(angle1: $angle1, angle2: $angle2, settingFirstLine: .constant(stage == 1), geometrySize: geometry.size)
                    }
                    .focusable(stage >= 1)
                    .digitalCrownRotation(stage >= 1 ? (stage == 1 ? $angle1 : $angle2) : .constant(0), from: -180, through: 180, by: 1, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)

                    NavigationLink(destination: ForecastView(city: city, forecastService: ForecastService()), isActive: $isNavigating) {
                        EmptyView()
                    }

                    if stage < 3 {
                        Button(action: {
                            stage += 1
                            if stage == 3 {
                                saveAngles()
                                isNavigating = true
                            }
                        }) {
                            Text(stage == 2 ? "Save" : "Next")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
    
    private func saveAngles() {
            if cityStorage.cities.contains(where: { $0.id == city.id }) {
                let updatedCity = City(
                    id: city.id,
                    name: city.name,
                    coordinate: city.coordinate,
                    angle1: Double(angle1),
                    angle2: Double(angle2)
                )
                cityStorage.edit(city: updatedCity)
                print("Angles updated: \(updatedCity.angle1), \(updatedCity.angle2)")
            }
        }
    }

struct RotatingLines: View {
    @Binding var angle1: CGFloat
    @Binding var angle2: CGFloat
    @Binding var settingFirstLine: Bool
    @State private var line1Offset: CGSize = .zero
    @State private var line2Offset: CGSize = .zero
    let geometrySize: CGSize

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: geometrySize.width / 2, y: 0))
                path.addLine(to: CGPoint(x: geometrySize.width / 2, y: geometrySize.height))
            }.stroke(Color.red)
            .rotationEffect(Angle(degrees: Double(angle1)), anchor: .center)
            .offset(line1Offset)
               .gesture(
                   DragGesture()
                       .onChanged { value in
                           line1Offset = value.translation
                       }
               )
               .background(Color.clear)
               .frame(width: geometrySize.width, height: geometrySize.height)
              
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometrySize.height / 2))
                path.addLine(to: CGPoint(x: geometrySize.width, y: geometrySize.height / 2))
            }.stroke(Color.red)
            .rotationEffect(Angle(degrees: Double(angle2)), anchor: .center)
            .offset(line2Offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        line2Offset = value.translation
                    }
            )
            .background(Color.clear)
            .frame(width: geometrySize.width, height: geometrySize.height)
        }
        .focusable(true)
        .digitalCrownRotation(settingFirstLine ? $angle1 : $angle2, from: -180, through: 180, by: 1, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)
    }
}

struct DigitalCrownRotation: View {
    @Binding var angle: CGFloat

    var body: some View {
        VStack {
            Spacer()
        }
        .focusable(true)
        .digitalCrownRotation($angle, from: -180, through: 180, by: 1, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)
    }
}
