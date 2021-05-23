//
//  WNPhotoModel.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import Foundation
import FlickrKit

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=a83d8f4dca55c759ab23d54c9f63e2f1&accuracy=16&has_geo=0&lat=49.902550&lon=10.884520&radius=1&format=json&nojsoncallback=1

class WNPhotoViewModel: NSObject {
//    var network = NetworkManager()
    
    var completionBlock: (() -> (Void))?
    
    var photoItems = [PhotoItem]()
//    private oldPhotos = [PhotoItem]()
    
    func getPhoto(lat: Double, long: Double, accuracy: Int, radius: Double) {
        let urlString = "?method=flickr.photos.search&accuracy=\(accuracy)&lat=\(lat)&lon=\(long)&radius=\(radius)&per_page=1&has_geo=1&geo_context=2&radius_units=0.1"
        NetworkManager.shared.urlRequest(endpoint: urlString) { (response) in
            let topPhotos = response["photos"] as! [String: Any]
            let photoArray = topPhotos["photo"] as! [[String: Any]]
            for photoDictionary in photoArray {
                // FKPhotoSizeSmall240
                let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize(rawValue: 6)!, fromPhotoDictionary: photoDictionary)
                let item = PhotoItem(url: photoURL as NSURL)
                self.photoItems.append(item)
//                if oldPhotos.count == 0 {
//                    oldPhotos = photoItems
//                }
//                self.rearrangePhotos()
                self.completionBlock?()
            }
            
        } errorCallback: { (error) in
            
        }
    }
    
//    private func rearrangePhotos() {
//        let temp = self.photoItems
//        self.photoItems.removeAll()
//        self.photoItems.append(contentsOf: self.viewModel.photoItems)
//        self.photoItems.append(contentsOf: temp)
//    }
}
