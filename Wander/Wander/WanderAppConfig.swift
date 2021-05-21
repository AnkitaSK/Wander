//
//  WNConfigFile.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import Foundation

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=a83d8f4dca55c759ab23d54c9f63e2f1&accuracy=16&has_geo=0&lat=49.902550&lon=10.884520&radius=1&format=json&nojsoncallback=1

let host = "https://www.flickr.com/services/rest/"
let kApiKey = "de7c19d60a8c2baefa17e4f9e43ce99f"
let kSecretKey = "563a328a218c455c"

final class ClientAppConfigProvider: AppConfigProvider {
    func handleApiConfig() {
        NetworkManager.shared.config.server = host
        NetworkManager.shared.config.apiKey = kApiKey
    }
}
