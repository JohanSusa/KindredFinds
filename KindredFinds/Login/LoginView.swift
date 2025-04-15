//
//  LoginView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/12/25.
//

import SwiftUI

struct LoginView: View {
    // State variables to hold email and password text.
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var userLogedIn: Bool = false
    
    var body: some View {
        // NavigationView allows us to use NavigationLink for the sign up button.
        NavigationView {
            VStack(spacing: 20) {
                
                NavigationLink(destination: FeedView(), isActive: $userLogedIn){
                    EmptyView()
                }
                
                Text("KindredFinds")
                    .font(.title)
                    .padding(.top, 60)
                // welcomw Text
                Text("Welcome!")
                    .fontWeight(.bold)
                    .padding()
                
                // Email Input Field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none) // Disable auto-capitalization for email
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                
                // Password Input Field using SecureField for privacy
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                
                // Log In Button
                Button(action: {
                    logInUser()
                }) {
                    Text("Log In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                }
                
                // Sign Up Navigation Link
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }.alert("Error", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(errorMessage)
        })
    }
    
    private func logInUser() {
        
        // Make sure all fields are non-nil and non-empty.
        guard !email.isEmpty, !password.isEmpty else {
            showError(message: "All fields are required. Please fill in every field.")
            print("All fields are required. Please fill in every field.")
            return
        }


        Task {
            // check for a loged in user
            if User.current != nil {
                do {
                    try await User.logout()
                } catch {
                    // Handle logout error if needed.
                    print("Logout failed: \(error.localizedDescription)")
    
                }
            }
            do {
                try await User.login(username: email, password: password)
                print("login successfull")
                userLogedIn = true
            } catch{
                errorMessage = error.localizedDescription
                showError(message: errorMessage)
                showAlert = true
                print("login failed: \(error.localizedDescription)")

            }
           
            
        }
        
    }
    
    private func showError(message: String) {
        errorMessage = message
        showAlert = true
    }
    
}

// Preview for SwiftUI canvas
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

