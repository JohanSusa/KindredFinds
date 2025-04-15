//
//  Post.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import Foundation
import ParseSwift

struct Post: ParseObject, Identifiable { // Added Identifiable
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var address: String?
    var caption: String?
    var itemDescription: String?
    var user: User?
    var imageFile: ParseFile?
    var geoPoint: ParseGeoPoint? 

     var id: String { objectId ?? UUID().uuidString } // Use objectId or fallback
}
