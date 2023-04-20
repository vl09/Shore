import SwiftUI
import MapKit
import CoreLocation

struct MapView: WKInterfaceObjectRepresentable {
    typealias WKInterfaceObjectRepresentableType = WKInterfaceMap
    
    let onLocationSelected: (CLLocationCoordinate2D) -> Void
    
    func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<MapView>) -> WKInterfaceMap {
        return WKInterfaceMap()
    }
    
    func updateWKInterfaceObject(_ map: WKInterfaceMap, context: WKInterfaceObjectRepresentableContext<MapView>) {
        map.removeAllAnnotations()
        
        let location = CLLocation(latitude: 37.33233141, longitude: -122.0312186) // Replace with your initial location
        
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        map.setRegion(region)
        map.addAnnotation(coordinate, with: .red)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onLocationSelected: onLocationSelected)
    }
    
    class Coordinator: NSObject {
        let onLocationSelected: (CLLocationCoordinate2D) -> Void
        
        init(onLocationSelected: @escaping (CLLocationCoordinate2D) -> Void) {
            self.onLocationSelected = onLocationSelected
        }
        
        @objc func handleTap(_ gestureRecognizer: WKGestureRecognizer) {
            if let tapGesture = gestureRecognizer as? WKTapGestureRecognizer {
                let location = tapGesture.locationInObject()
                let coordinate = CLLocationCoordinate2D(latitude: Double(location.x), longitude: Double(location.y))
                onLocationSelected(coordinate)
            }
        }
    }
}
