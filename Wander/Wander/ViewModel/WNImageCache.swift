//
//  WNImageCache.swift
//  Wander
//
//  Created by Ankita on 23.05.21.
//

import Foundation


class ImageCache {
    public static let imageCache = ImageCache()
    var placeholderImage = UIImage(systemName: "rectangle")!
    private let cachedImages = NSCache<NSURL, UIImage>()
    
    public final func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    final func load(url: NSURL, item: PhotoItem, completion: @escaping (PhotoItem, UIImage?) -> Void) {
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }
        
        NetworkManager.shared.downloadImage(url: url) { (data) in
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }
            self.cachedImages.setObject(image, forKey: url, cost: data.count)
            completion(item, image)
        } errorCallback: { (error) in
            
        }

    }
}
