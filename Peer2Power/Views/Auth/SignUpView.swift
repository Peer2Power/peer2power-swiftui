//
//  SignUpView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/25/22.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var signingUp = false
    
    var body: some View {
        VStack(spacing: 15.0) {
            Image("LoginLogo")
            TextField("Email Address", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
            Button("Sign Up", action: signUpUser)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(signingUp)
            
            if signingUp {
                ProgressView("Signing Up...")
            }
        }
        .padding(.horizontal, 15.0)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

extension SignUpView {
    private func signUpUser() {
        signingUp.toggle()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
