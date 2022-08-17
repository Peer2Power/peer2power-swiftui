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
    @State private var loggingIn = false
    
    var body: some View {
        VStack(spacing: 16.0) {
            Image("LoginLogo")
            TextField("Email", text: $email)
                .submitLabel(.next)
                .textContentType(.emailAddress)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .submitLabel(.go)
                .textFieldStyle(.roundedBorder)
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
        
        if loggingIn {
            ProgressView()
            Text("Logging In...")
        }
    }
}

extension LoginView {
    private func loginUser() {
        loggingIn.toggle()
        
        Task {
            // TODO: add visual feedback that app is logging user in.
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
