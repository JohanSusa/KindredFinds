//
//  LoginView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI
import ParseSwift

struct LoginView: View {
    @Binding var isLoggedIn: Bool //binding from ContentView

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        // Use NavigationStack for modern navigation
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                // App Title/Logo Placeholder
                Text("KindredFinds")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)

                Text("Welcome Back!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                // Email Input Field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))


                // Password Input Field
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))


                // Log In Button
                Button(action: logInUser) {
                    HStack {
                        if isLoggingIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Log In")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoggingIn ? Color.blue.opacity(0.6) : Color.blue)
                    .cornerRadius(10)
                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 3)
                }
                .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                .padding(.top)


                // Sign Up Navigation Link
                NavigationLink {
                     SignUpView(isSignedUp: $isLoggedIn)
                } label: {
                    HStack(spacing: 4) {
                         Text("Don't have an account?")
                         Text("Sign Up")
                             .fontWeight(.semibold)
                             .foregroundColor(.blue)
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                }
                .padding(.top, 10)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 24)
            .alert("Login Error", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(errorMessage)
            })
        }
    }

    private func logInUser() {
        guard !email.isEmpty, !password.isEmpty else {
            showError(message: "Please enter both email and password.")
            return
        }

        isLoggingIn = true

        Task {
            do {
                let loggedInUser = try await User.login(username: email, password: password)
                print("✅ Login successful for user: \(loggedInUser.username ?? "N/A")")
                isLoggedIn = true
                isLoggingIn = false
            } catch {
                print("❌ Login failed: \(error.localizedDescription)")
                showError(message: "Login failed: \(error.localizedDescription)") 
                isLoggingIn = false
            }
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showAlert = true
    }
}

// Preview requires providing a binding
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
