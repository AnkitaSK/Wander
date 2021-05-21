//
//  WNConstants.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import Foundation

protocol WNNetworkHandler {
    var config: WNNetworkConfig {get}
}

protocol WNNetworkConfig {
    var apiKey: String { set get }
    var server: String { set get }
}
