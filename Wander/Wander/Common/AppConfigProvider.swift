//
//  AppConfigProvider.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import Foundation

public protocol AppConfigProvider {
    func handleApiConfig()
}

public final class AppConfigHandler {
    public static var provider: AppConfigProvider!
}
