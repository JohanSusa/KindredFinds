//
//  Post.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import Foundation
import UIKit

struct Post: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let image: UIImage
}
