//
//  ForgotPasswordView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/19/22.
//

import SwiftUI
import RealmSwift
import SPAlert

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isSending = false
    
    @State private var errorText = ""
    @State private var showingErrorAlert = false
    @State private var showingEmailSentAlert = false
    @State private var bannerData: BannerModifier.BannerData = .init(title: "Password Reset Email Sent",
                                                                     detail: "Check your inbox for an email with instructions to reset your password.",
                                                                     type: .Success)
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField:Field?
    
    enum Field: Hashable {
        case email
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Email Address of Your Account", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                    .onSubmit(sendPasswordResetEmail)
                    .focused($focusedField, equals: .email)
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
            .onAppear {
                focusedField = .email
            }
            .banner(data: $bannerData, show: $showingEmailSentAlert)
        }
    }
}

extension ForgotPasswordView {
    private func sendPasswordResetEmail() {
        focusedField = nil
        isSending.toggle()
        let client = app.emailPasswordAuth
        
        client.sendResetPasswordEmail(email) { error in
            isSending.toggle()
            
            if let error = error {
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            } else {
                showingEmailSentAlert.toggle()
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
