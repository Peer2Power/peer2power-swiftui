//
//  ForgotPasswordView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/19/22.
//

import SwiftUI
import RealmSwift
import AlertToast

struct ResetOrResendView: View {
    @State private var email = ""
    @State private var isSending = false
    
    @State private var errorText = ""
    @State private var showingErrorAlert = false
    @State private var showingEmailSentAlert = false
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField:Field?
    
    @Binding var currentAction: Action
    
    enum Field: Hashable {
        case email
    }
    
    enum Action {
        case passwordReset
        case resendConfirmation
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
                        Button("Submit") {
                            if currentAction == .passwordReset {
                                sendPasswordResetEmail()
                            } else if currentAction == .resendConfirmation {
                                resendConfirmationEmail()
                            }
                        }
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
            .navigationTitle(currentAction == .passwordReset ? "Reset Password" : "Resend Confirmation Email")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                focusedField = .email
            }
            .onChange(of: showingEmailSentAlert, perform: { newValue in
                if newValue == false {
                    dismiss()
                }
            })
            .toast(isPresenting: $showingEmailSentAlert, duration: 4.0) {
                AlertToast(displayMode: .banner(.pop),
                           type: .complete(Color(uiColor: .systemGreen)),
                           title: bannerTitle,
                           subTitle: bannerMessage)
            }
        }
    }
}

extension ResetOrResendView {
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
    
    private func resendConfirmationEmail() {
        focusedField = nil
        isSending.toggle()
        let client = app.emailPasswordAuth
        
        client.resendConfirmationEmail(email) { error in
            isSending.toggle()
            
            if let error = error {
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            } else {
                showingEmailSentAlert.toggle()
            }
        }
    }
    
    private var bannerTitle: String {
        if currentAction == .passwordReset {
            return "Password Reset Email Sent"
        } else if currentAction == .resendConfirmation {
            return "Confirmation Email Resent"
        }
        
        return ""
    }
    
    private var bannerMessage: String {
        if currentAction == .passwordReset {
            return "Check your inbox for an email with instructions."
        } else if currentAction == .resendConfirmation {
            return "Check your inbox to confirm your email address."
        }
        
        return ""
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetOrResendView(currentAction: .constant(.passwordReset))
    }
}
