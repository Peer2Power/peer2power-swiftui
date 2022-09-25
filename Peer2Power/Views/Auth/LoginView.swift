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
    @State private var loggingIn = false
    @State private var showingPasswordResetForm = false
    @State private var showingSignUpSheet = false
    
    @State private var showingErrorAlert = false
    @State private var errorText = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email
        case password
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15.0) {
            Image("LoginLogo")
            TextField("Email Address", text: $email)
                .submitLabel(.next)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    focusedField = .password
                }
            SecureField("Password", text: $password)
                .submitLabel(.go)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .focused($focusedField, equals: .password)
                .onSubmit(loginUser)
            Button("Login", action: loginUser)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty || loggingIn)
            Button("Sign Up") {
                showingSignUpSheet.toggle()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .sheet(isPresented: $showingSignUpSheet) {
                SignUpView()
            }
            Button("Forgot your password?") {
                showingPasswordResetForm.toggle()
            }
            .sheet(isPresented: $showingPasswordResetForm) {
                ForgotPasswordView()
            }
            if loggingIn {
                ProgressView {
                    Text("Logging in...")
                }
            }
        }
        .padding(.horizontal, 15.0)
        .alert(Text("Error Logging In"), isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text(errorText)
        }
    }
}

extension LoginView {
    private func loginUser() {
        focusedField = nil
        
        Task {
            loggingIn.toggle()
            do {
                let user = try await app.login(credentials: .emailPassword(email: email, password: password))
                
                print("Logged in user with ID \(user.id)")
                loggingIn.toggle()
            } catch {
                loggingIn.toggle()
                
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
