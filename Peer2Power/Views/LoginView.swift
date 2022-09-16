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
    
    @State private var showingErrorAlert = false
    @State private var errorText = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email
        case password
    }
    
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
                .onSubmit {
                    focusedField = .password
                }
            SecureField("Password", text: $password)
                .submitLabel(.go)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .password)
                .onSubmit(loginUser)
            Button("Login", action: loginUser)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Button("Sign Up") {
                newUser.toggle()
                loginUser()
            }
                .buttonStyle(.bordered)
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
        .alert(Text("Error Logging In"), isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text(errorText)
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
                loggingIn.toggle()
                
                app.login(credentials: .emailPassword(email: email, password: password)) { result in
                    switch result {
                    case .failure(let error):
                        errorText = error.localizedDescription
                        loggingIn.toggle()
                        showingErrorAlert.toggle()
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
