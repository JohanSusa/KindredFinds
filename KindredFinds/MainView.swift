//
//  MainTabView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // Feed Tab
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet.rectangle.portrait")
                }
                .tag(0)

            // Post Tab
            PostView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Post Item", systemImage: "plus.circle.fill")
                }
                .tag(1)

             ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                     Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(2)

        }
    }
}

// --- Placeholder ProfileView
struct ProfileView: View {
     @Binding var isLoggedIn: Bool

     var body: some View {
         NavigationStack {
             VStack {
                 Text("Profile & Settings")
                     .font(.title)
                     .padding()

                 if let username = User.current?.username {
                      Text("Logged in as: \(username)")
                          .padding()
                 }

                 Button("Log Out") {
                     Task {
                         do {
                             try await User.logout()
                             print("✅ User logged out.")
                             isLoggedIn = false 
                         } catch {
                             print("❌ Logout failed: \(error.localizedDescription)")
                         }
                     }
                 }
                 .buttonStyle(.borderedProminent)
                 .tint(.red)
                 .padding()

                 Spacer()
             }
             .navigationTitle("Profile")
         }
     }
}


// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(isLoggedIn: .constant(true))
    }
}
