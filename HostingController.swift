//
//  HostingController.swift
//  Shorewind Watch App
//
//  Created by Valentijn Leenaers on 4/18/23.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    let cityStorage = CityStorage()

    override var body: AnyView {
        return AnyView(CityListView().environmentObject(cityStorage))
    }
}
