//
//  SignUpView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/12/25.
//

import SwiftUI
import ParseSwift

struct SignUpView: View {
    

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // For handling error messages via an alert.
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var userSingedUp: Bool = false
    
    var body: some View {
        
        NavigationStack{
            
            
            VStack {
                // Hidden NavigationLink
                NavigationLink(destination: FeedView(), isActive: $userSingedUp) {
                    EmptyView()
                }
                
                Text("Sign Up View")
                    .font(.title)
                    .padding()
                
                // Future sign up form elements go here.
                TextField("email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                
                SecureField("Enter Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                
                Button(action: {
                    signUpUser()
                } ){
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
            }
        } // Display an error alert
        .alert("Error", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(errorMessage)
        })

        
    }
    
    private func signUpUser() {
        
        // Make sure all fields are non-nil and non-empty.
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showError(message: "All fields are required. Please fill in every field.")
            print("All fields are required. Please fill in every field.")
            return
        }

        // Check if passwords match.
        guard password == confirmPassword else {
            showError(message: "Passwords do not match. Please re-enter them.")
            print("Passwords do not match. Please re-enter them.")
            return
        }
        
        
        var newUser = User()
        newUser.username = email
        newUser.password = password
        newUser.email = email
        
        var acl = ParseACL()
        acl.publicRead = true
        newUser.ACL = acl


        Task {
            // check for a loged in user
            if User.current != nil {
                do {
                    try await User.logout()
                } catch {
                    errorMessage = error.localizedDescription
                    showAlert = true
                    print("Logout failed: \(errorMessage)")
                   
                }
            }
                
            do {
                let signedUpUser = try await newUser.signup()
                print("Success: \(signedUpUser)")
                userSingedUp = true
            } catch {
                errorMessage = error.localizedDescription
                showAlert = true
                print(errorMessage)
            }
        }
        
    }
    
    private func showError(message: String) {
        errorMessage = message
        showAlert = true
    }
}

#Preview {
    SignUpView()
}
