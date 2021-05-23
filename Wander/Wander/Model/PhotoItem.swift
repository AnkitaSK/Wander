//
//  PhotoItem.swift
//  Wander
//
//  Created by Ankita on 22.05.21.
//

import Foundation

enum Section {
    case main
}

class PhotoItem: Hashable {
    var image: UIImage
    let url: NSURL
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage = UIImage(systemName: "rectangle")!, url: NSURL) {
        self.image = image
        self.url = url
    }
}
