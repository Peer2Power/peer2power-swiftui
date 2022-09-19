//
//  ForgotPasswordView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/19/22.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isSending = false
    
    @State private var errorText = ""
    @State private var showingErrorAlert = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Email Address of Your Account", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .onSubmit(sendPasswordResetEmail)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if !isSending {
                        Button("Submit", action: sendPasswordResetEmail)
                            .disabled(email.isEmpty)
                    } else {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .alert("Error Resetting Password",
                   isPresented: $showingErrorAlert,
                   actions: {
                Button("OK", role: .cancel, action: { })
            }, message: {
                Text("\(errorText)")
            })
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension ForgotPasswordView {
    private func sendPasswordResetEmail() {
        isSending.toggle()
        let client = app.emailPasswordAuth
        
        client.sendResetPasswordEmail(email) { error in
            isSending.toggle()
            
            if let error = error {
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            } else {
                dismiss()
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
