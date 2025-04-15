//
//  KindredFindsApp.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa


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
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isLoggedIn: Bool = User.current != nil

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn) // Pass binding to allow logout
            } else {
                LoginView(isLoggedIn: $isLoggedIn) // Pass binding to update state on login
            }
        }
        
    }
}
