//
//  WNPhotoModel.swift
//  Wander
//
//  Created by Ankita on 22.05.21.
//

import Foundation
import FlickrKit

class WNPhotoViewModel: NSObject {
    
    var completionBlock: (() -> (Void))?
    var photoItems = Set<PhotoItem>()
    
    func getPhoto(lat: Double, long: Double, accuracy: Int = 16, radius: Double = 5.0) {
        let urlString = "?method=flickr.photos.search&accuracy=\(accuracy)&lat=\(lat)&lon=\(long)&radius=\(radius)&per_page=1&has_geo=1&geo_context=2&radius_units=0.1"
        NetworkManager.shared.urlRequest(endpoint: urlString) { (response) in
            let topPhotos = response["photos"] as! [String: Any]
            let photoArray = topPhotos["photo"] as! [[String: Any]]
            for photoDictionary in photoArray {
//                 FKPhotoSizeSmall240
                let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small240, fromPhotoDictionary: photoDictionary)
                let item = PhotoItem(url: photoURL as NSURL, id: photoDictionary["id"] as! String, date: Date())
                self.photoItems.insert(item)
                self.completionBlock?()
            }
            
        } errorCallback: { (error) in
            
        }
    }
}

