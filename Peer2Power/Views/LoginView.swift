//
//  LoginView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/2/22.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var newUser = false
    
    var body: some View {
        VStack(spacing: 16.0) {
            Image("LoginLogo")
            TextField("Email", text: $email)
                .submitLabel(.next)
                .textContentType(.emailAddress)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .submitLabel(.go)
                .onSubmit(loginUser)
            Toggle(isOn: $newUser) {
                Text("Register New User?")
            }
            Button(action: loginUser) {
                Text(newUser ? "Sign Up" : "Log In")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
    }
}

extension LoginView {
    func loginUser() {
        Task {
            if newUser {
                do {
                    try await app.emailPasswordAuth.registerUser(email: email, password: password)
                } catch {
                    print("An error occurred while signing up the user: \(error.localizedDescription)")
                    return
                }
            }
            
            app.login(credentials: .emailPassword(email: email, password: password)) { result in
                switch result {
                case .failure(let error):
                    print("An error occurred while logging in the user: \(error.localizedDescription)")
                case .success(let user):
                    print("Logged in user with ID \(user.id)")
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
