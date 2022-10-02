//
//  SignUpView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/25/22.
//

import SwiftUI
import RealmSwift

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var errorText = ""
    @State private var showingErrorAlert = false
    @State private var showingEmptyFieldAlert = false
    @State private var showingNotConsentedAlert = false
    @State private var showingNotAcademicEmailAlert = false
    
    @State private var passwordMismatch = false
    
    @State private var signingUp = false
    @State private var showingEmailConfirmAlert = false
    
    @State private var consentText = "Agree to the consent agreement to sign up."
    @State private var userConsented = false
    @State private var showingConsentAgreement = false
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email
        case password
        case confirmPassword
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 15.0) {
                Image("LoginLogo")
                TextField("Email Address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .confirmPassword)
                    .onSubmit {
                        signUpUser()
                    }
                Button("Sign Up", action: signUpUser)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top, 15)
                    .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || signingUp || !userConsented)
                Button(consentText) {
                    showingConsentAgreement.toggle()
                }
                .padding(.top, 25)
                .sheet(isPresented: $showingConsentAgreement) {
                    ConsentAgreementView(consented: $userConsented)
                }
                .onChange(of: userConsented) { newValue in
                    if newValue == true {
                        consentText = "You consented! You can now sign up, or change whether you consent to participate."
                    } else {
                        consentText = "You did not consent. You will not be able to sign up until you give your consent."
                    }
                }
                if signingUp {
                    ProgressView("Signing Up...")
                }
            }
            .padding(.horizontal, 15.0)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .alert("Password Mismatch", isPresented: $passwordMismatch, actions: {
                Button("OK", role: .cancel, action: {})
            }, message: {
                Text("The passwords you entered do not match. Please ensure your passwords match and try again.")
            })
            .alert("Error Signing Up", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text(errorText)
            }
            .alert("Confirm Your Email Address", isPresented: $showingEmailConfirmAlert) {
                Button("OK", role: .cancel, action: {
                    dismiss()
                })
            } message: {
                Text("Before you can proceed, you need to confirm your email address. Check your inbox for a confirmation email then return here to log in.")
            }
            .alert("Missing Information",
                   isPresented: $showingEmptyFieldAlert) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text("One or more text fields is empty. Please fill out all text fields and try again.")
            }
            .alert("Consent Not Given",
                   isPresented: $showingNotConsentedAlert) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text("You have given your consent to participate in this study. You will not be able to sign up until you agree to the informed consent agreement.")
            }
            .alert("Not an Academic Email Address",
                   isPresented: $showingNotAcademicEmailAlert) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text("You did not provide an academic email address. Please use an academic email address (ending in .edu) and try again.")
            }
        }
    }
}

extension SignUpView {
    private func signUpUser() {
        focusedField = nil
        
        guard !email.isEmpty else {
            showingEmptyFieldAlert.toggle()
            return
        }
        
        guard !password.isEmpty else {
            showingEmptyFieldAlert.toggle()
            return
        }
        
        guard !confirmPassword.isEmpty else {
            showingEmptyFieldAlert.toggle()
            return
        }
        
        guard userConsented else {
            showingNotConsentedAlert.toggle()
            return
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedEmail.hasSuffix(".edu") else {
            showingNotAcademicEmailAlert.toggle()
            return
        }
        
        passwordMismatch = password != confirmPassword
        
        if !passwordMismatch {
            Task {
                signingUp.toggle()
                do {
                    try await app.emailPasswordAuth.registerUser(email: email, password: password)
                    
                    showingEmailConfirmAlert.toggle()
                    signingUp.toggle()
                } catch {
                    signingUp.toggle()
                    print("Error signing up: \(error.localizedDescription)")
                    
                    errorText = error.localizedDescription
                    showingErrorAlert.toggle()
                }
            }
        } else {
            signingUp.toggle()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
