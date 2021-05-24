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
    let identifier: String
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
//    static func < (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
//        return lhs.date < rhs.date
//    }
    
    init(image: UIImage = UIImage(systemName: "rectangle")!, url: NSURL, id: String, date: Date) {
        self.image = image
        self.url = url
        self.identifier = id
        self.date = date
    }
}
