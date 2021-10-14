//
//  DBFlyingSpot.swift
//  FriendlyEats
//
//  Created by Mark Zhong on 10/13/21.
//  Copyright © 2021 Firebase. All rights reserved.
//

import Foundation
import Firebase

struct DBFlyingSpot {

    var id: Int?
    var itemID: String?
    var name: String?
    var latitude: Double?
    var longtitude: Double?
    var address: String?
    var site_info: String?
//    var ratingCount: Int // numRatings
//    var averageRating: Float
//    var numberFavorite: Int
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "itemID": itemID,
            "name": name,
            "latitude": latitude,
            "longtitude": longtitude,
            "address": address,
            "site_info": site_info,
//            "ratingCount": ratingCount,
//            "averageRating": averageRating,
//            "numberFavorite": numberFavorite,
        ]
    }
    
}


extension DBFlyingSpot: DocumentSerializable {

  init?(dictionary: [String : Any]) {
        let name = dictionary["name"] as? String
        let latitude = dictionary["latitude"] as? Double
        let longtitude = dictionary["longtitude"] as? Double
        let site_info = dictionary["site_info"] as? String
        let address = dictionary["address"] as? String
        let id = dictionary["id"] as? Int
        let itemID = dictionary["itemID"] as? String
//        let ratingCount = dictionary["ratingCount"] as? Int,
//        let numberFavorite = dictionary["numberFavorite"] as? Int,
//        let averageRating = dictionary["averageRating"] as? Float


    self.init(id: id,
              itemID: itemID,
              name: name,
              latitude: latitude,
              longtitude: longtitude,
              address: address,
              site_info: site_info)
    
  }
    
}
