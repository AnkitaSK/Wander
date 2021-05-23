//
//  WNNetworkManager.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import Foundation

class NetworkConfig: WNNetworkConfig {
    var apiKey: String = ""
    var server: String = ""
}

public class NetworkManager: WNNetworkHandler {
    typealias WNJsonResult = (_ dataResult: [String: Any]) -> Void
    typealias WNDataResult = (_ data: Data) -> Void
    typealias WNErrorCallback = ((_ error: Error) -> Void)
    
    static let shared = NetworkManager()
    
    var config: WNNetworkConfig = NetworkConfig()
    var urlSession: URLSession
    
    init() {
        urlSession = URLSession(configuration: .default) // need to change for background
    }
    
    func urlRequest(endpoint: String,
                    result: @escaping WNJsonResult,
                    errorCallback: WNErrorCallback?) {
        var requestUrlString = NetworkManager.shared.config.server
        requestUrlString += endpoint
        requestUrlString += "&api_key=\(NetworkManager.shared.config.apiKey)"
        requestUrlString += "&format=json&nojsoncallback=1"
        
        
        let requestUrl = URL(string: requestUrlString)!
        
        let task = urlSession.dataTask(with: requestUrl) { (data, response, error) in
            if let error = error {
                errorCallback?(error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("Unauthorized error")
                    return
                } else if httpResponse.statusCode == 404 {
//                    print(response)
                    return
                }
            }
            
            if let data = data {
                print(String(data: data, encoding: .utf8) ?? "NoStringData")
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        result(json)
                    }
                } catch let error {
                    errorCallback?(error)
                }
                return
            }
        }
        
        
        task.resume()
    }
    
    func downloadImage(url: NSURL, result: @escaping WNDataResult,
                       errorCallback: WNErrorCallback?) {
        urlSession.dataTask(with: url as URL) { (data, response, error) in
            if let error = error {
                errorCallback?(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("Unauthorized error")
                    return
                } else if httpResponse.statusCode == 404 {
//                    print(response)
                    return
                }
            }
            
            if let data = data {
                result(data)
            } else {
//                errorCallback?(error)
            }
            
        }.resume()
    }
}

