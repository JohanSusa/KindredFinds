//
//  KindredFindsApp.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/12/25.
//

import SwiftUI
import ParseSwift
@main
struct KindredFindsApp: App {
    init() {
        ParseSwift.initialize(applicationId: "TJkjfxpPKTBYazJBpzNdrlCKYMKmR3UxmXlLX9n1",
                              clientKey: "1ejl8DWblWE4OMJlAIkZKrS579cM0xFLEU9wwIPr",
                              serverURL: URL(string: "https://parseapi.back4app.com")!)
    }
    
    var body: some Scene {
        WindowGroup {
            SignUpView()
        }
    }
}
