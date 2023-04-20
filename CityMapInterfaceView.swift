//
//  CityMapInterfaceView.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import MapKit

struct EquatableCoordinate: Equatable {
    let coordinate: CLLocationCoordinate2D
    
    static func ==(lhs: EquatableCoordinate, rhs: EquatableCoordinate) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}


struct CityMapInterfaceView: View {
    @EnvironmentObject var cityStorage: CityStorage
    var city: City
    @State private var angle1: CGFloat = 0
    @State private var angle2: CGFloat = 0
    @State private var stage: Int = 0
    @State private var isNavigating: Bool = false
    @State private var region = MKCoordinateRegion()
    @State private var coordinate = EquatableCoordinate(coordinate: CLLocationCoordinate2D())

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Map(coordinateRegion: $region, interactionModes: stage >= 1 ? [] : .all)
                        .edgesIgnoringSafeArea(.all)
                        .onChange(of: coordinate, perform: { equatableCoordinate in
                                                    region = MKCoordinateRegion(center: equatableCoordinate.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                                                })

                    RotatingLines(angle1: $angle1, angle2: $angle2, settingFirstLine: .constant(stage == 1), geometrySize: geometry.size)
                }
                .focusable(stage >= 1)
                .digitalCrownRotation(stage >= 1 ? (stage == 1 ? $angle1 : $angle2) : .constant(0), from: -180, through: 180, by: 1, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)

                if stage < 3 {
                    Button(action: {
                        if stage == 2 {
                            saveAngles()
                            isNavigating = true
                        } else {
                            stage += 1
                        }
                    }) {
                        Text(stage == 2 ? "Save" : "Next")
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    coordinate = EquatableCoordinate(coordinate: city.coordinate.toCLLocationCoordinate2D())
                    region = MKCoordinateRegion(center: city.coordinate.toCLLocationCoordinate2D(), latitudinalMeters: 2000, longitudinalMeters: 2000)
                }
            }
        }
        .background(NavigationLink(destination: ForecastView(city: city, forecastService: ForecastService()), isActive: $isNavigating) {
            EmptyView()
        })
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
    @State private var accumulatedLine1Offset: CGSize = .zero
    @State private var accumulatedLine2Offset: CGSize = .zero
    let geometrySize: CGSize

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: geometrySize.width / 2, y: 0))
                path.addLine(to: CGPoint(x: geometrySize.width / 2, y: geometrySize.height))
            }.stroke(Color.red)
            .rotationEffect(Angle(degrees: Double(angle1)), anchor: .center)
            .offset(accumulatedLine1Offset)
               .gesture(
                   DragGesture()
                       .onChanged { value in
                           line1Offset = value.translation
                           accumulatedLine1Offset = CGSize(width: line1Offset.width + accumulatedLine1Offset.width, height: line1Offset.height + accumulatedLine1Offset.height)
                       }
                        .onEnded { value in
                            accumulatedLine1Offset = CGSize(width: line1Offset.width + accumulatedLine1Offset.width, height: line1Offset.height + accumulatedLine1Offset.height)
                                        }
               )
               .background(Color.clear)
               .frame(width: geometrySize.width, height: geometrySize.height)
              
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometrySize.height / 2))
                path.addLine(to: CGPoint(x: geometrySize.width, y: geometrySize.height / 2))
            }.stroke(Color.red)
            .rotationEffect(Angle(degrees: Double(angle2)), anchor: .center)
            .offset(accumulatedLine2Offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        line2Offset = value.translation
                        accumulatedLine2Offset = CGSize(width: line2Offset.width + accumulatedLine2Offset.width, height: line2Offset.height + accumulatedLine2Offset.height)
                    }
                    .onEnded { value in
                        accumulatedLine2Offset = CGSize(width: line2Offset.width + accumulatedLine2Offset.width, height: line2Offset.height + accumulatedLine2Offset.height)
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
