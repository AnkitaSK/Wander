//
//  WNLocationViewModel.swift
//  Wander
//
//  Created by Ankita on 23.05.21.
//

import CoreLocation

class LocationManager {
    static let shared = CLLocationManager()
    static let sharedManager = LocationManager()
    var date: Date?
    private init() { }
}

