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
    
    @State private var school_name = ""
    @State private var teamParty = ""
    
    @Binding var team_id: String
    
    @State private var errorText = ""
    @State private var showingErrorAlert = false
    @State private var showingEmptyFieldAlert = false
    @State private var showingNotConsentedAlert = false
    @State private var showingNotAcademicEmailAlert = false
    
    @State private var passwordMismatch = false
    
    @State private var signingUp = false
    @Binding var teamSelected: Bool
    
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
                if !school_name.isEmpty && !teamParty.isEmpty {
                    Text("Create an account to join the \(school_name) \(teamParty).")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                }
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
            .onAppear(perform: fetchTeamInfo)
            .interactiveDismissDisabled(true)
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
        
        guard password == confirmPassword else {
            passwordMismatch.toggle()
            signingUp.toggle()
            return
        }
        
        Task {
            signingUp.toggle()
            do {
                try await app.emailPasswordAuth.registerUser(email: email, password: password)
                
                UserDefaults.standard.set(team_id, forKey: "joinTeamID")
                print("Persisted ID \(UserDefaults.standard.string(forKey: "joinTeamID") ?? "N/A") of the team the user should join.")
                
                signingUp.toggle()
                teamSelected.toggle()
                
                dismiss()
            } catch {
                signingUp.toggle()
                print("Error signing up: \(error.localizedDescription)")
                
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            }
        }
    }
    
    private func fetchTeamInfo() {
        guard let url = URL(string: "\(mongoDataEndpoint)action/findOne") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(mongoDataAPIKey, forHTTPHeaderField: "api-key")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Request-Headers")
        
        let bodyJSON: [String: Any] = [
            "collection": "Team",
            "database": "govlab",
            "dataSource": "production",
            "filter": ["_id": ["$oid": team_id],],
            "projection": ["_id": 0, "school_name": 1, "party": 1]
        ]
        let bodyData = try? JSONSerialization.data(withJSONObject: bodyJSON)
        
        request.httpBody = bodyData
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data)
            guard let responseJSON = responseJSON as? [String: Any] else { return }
            print(responseJSON)
            
            guard let team = responseJSON["document"] as? [String: Any] else { return }
            
            guard let school_name = team["school_name"] as? String else { return }
            self.school_name = school_name
            
            guard let party = team["party"] as? String else { return }
            teamParty = party
        }
        
        task.resume()
    }
}
