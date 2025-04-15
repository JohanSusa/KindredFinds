//
//  SignUpView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI
import ParseSwift

struct SignUpView: View {
    @Binding var isSignedUp: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSigningUp: Bool = false

    // For handling error messages via an alert.
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

             Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)

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
                .textContentType(.newPassword) // Help password managers
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))


            // Confirm Password Input Field
            SecureField("Confirm Password", text: $confirmPassword)
                 .textContentType(.newPassword)
                 .padding()
                 .background(Color(.systemGray6))
                 .cornerRadius(10)
                 .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))

            // Sign Up Button
             Button(action: signUpUser) {
                 HStack {
                     if isSigningUp {
                         ProgressView()
                             .progressViewStyle(CircularProgressViewStyle(tint: .white))
                     } else {
                         Text("Sign Up")
                     }
                 }
                 .foregroundColor(.white)
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(isSigningUp ? Color.green.opacity(0.6) : Color.green)
                 .cornerRadius(10)
                 .shadow(color: .green.opacity(0.3), radius: 5, y: 3)
            }
            .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || isSigningUp)
            .padding(.top)


            Spacer()
             Spacer()

        }
        .padding(.horizontal, 24)
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Up Error", isPresented: $showAlert, actions: {
             Button("OK", role: .cancel) {}
        }, message: {
             Text(errorMessage)
        })
    }

    private func signUpUser() {
        // Validation checks
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showError(message: "Please fill in all fields.")
            return
        }
        guard password == confirmPassword else {
            showError(message: "Passwords do not match.")
            return
        }
        guard isValidEmail(email) else {
             showError(message: "Please enter a valid email address.")
             return
        }

        isSigningUp = true

        // Create a new User object.
       
        var newUser = User()
        newUser.username = email
        newUser.email = email
        newUser.password = password

       

        Task {
            do {
                // Sign up the user asynchronously.
                 let signedUpUser = try await newUser.signup()
                 print("✅ Sign up successful for user: \(signedUpUser.username ?? "N/A")")
                 isSignedUp = true
                 isSigningUp = false
            } catch {
                print("❌ Sign up failed: \(error.localizedDescription)")
                showError(message: "Sign up failed: \(error.localizedDescription)")
                isSigningUp = false
            }
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showAlert = true
    }

    // Basic email validation helper
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview requires providing a binding
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView(isSignedUp: .constant(false))
        }
    }
}
