//
//  ShorewindApp.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import SwiftUI
import WatchKit

@main
struct ShorewindApp: App {
    let cityStorage = CityStorage()
    
    @WKExtensionDelegateAdaptor(Delegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CityListView()
            }
            .environmentObject(cityStorage)
        }
    }
}

class Delegate: NSObject, WKExtensionDelegate {
    func applicationDidEnterBackground() {
    }
}
