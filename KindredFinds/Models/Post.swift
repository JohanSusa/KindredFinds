//
//  Post.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    // These are required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own custom properties.
    var address: String?
    var caption: String?
    var itemDescription: String?
    var user: User?
    var imageFile: ParseFile?
    var geoPoint: ParseGeoPoint?
    
}
