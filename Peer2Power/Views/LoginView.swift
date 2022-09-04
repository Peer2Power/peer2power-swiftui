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
    @State private var showingEmailConfirmAlert = false
    
    var body: some View {
        VStack(spacing: 16.0) {
            Image("LoginLogo")
            TextField("Email", text: $email)
                .submitLabel(.next)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
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
            
            if loggingIn {
                ProgressView {
                    Text("Logging in...")
                }
            }
        }
        .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/)
        .alert(Text("Confirm Your Email"), isPresented: $showingEmailConfirmAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Before you can proceed, you will have to confirm your email address. Return here to log in after confirming your email address.")
        }
    }
}

extension LoginView {
    private func loginUser() {
        Task {
            // TODO: add visual feedback that app is logging user in.
            if newUser {
                do {
                    try await app.emailPasswordAuth.registerUser(email: email, password: password)
                    
                    showingEmailConfirmAlert.toggle()
                    newUser.toggle()
                } catch {
                    print("An error occurred while signing up the user: \(error.localizedDescription)")
                    return
                }
            } else {
                app.login(credentials: .emailPassword(email: email, password: password)) { result in
                    switch result {
                    case .failure(let error):
                        print("An error occurred while logging in the user: \(error.localizedDescription)")
                        loggingIn.toggle()
                    case .success(let user):
                        print("Logged in user with ID \(user.id)")
                        loggingIn.toggle()
                    }
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
