//
//  User.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import Foundation
import ParseSwift

struct User: ParseUser, Identifiable {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var username: String?
    var password: String?
    var email: String?
    var emailVerified: Bool?
    var authData: [String: [String: String]?]?
    var sessionToken: String?

    // Conformance to Identifiable
     var id: String { objectId ?? UUID().uuidString }

   
}
