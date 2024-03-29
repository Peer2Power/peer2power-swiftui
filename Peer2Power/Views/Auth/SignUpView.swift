//
//  SignUpView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/25/22.
//

import SwiftUI
import RealmSwift
import AlertToast

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var clubName = ""
    
    @Binding var team_id: String
    
    @State private var errorText = ""
    @State private var showingErrorAlert = false
    @State private var showingEmptyFieldAlert = false
    @State private var showingNotConsentedAlert = false
    @State private var showingNotAcademicEmailErrorAlert = false
    @State private var showingNameTakenErrorAlert = false
    
    @State private var passwordMismatch = false
    
    @State private var signingUp = false
    @Binding var teamSelected: Bool
    
    @State private var consentText = "Agree to the consent agreement to sign up."
    @State private var userConsented = false
    @State private var showingConsentAgreement = false
    
    @FocusState private var focusedField: Field?
    
    @StateObject private var viewModel: ChooseTeamViewModel = .shared
    
    enum Field: Hashable {
        case email
        case password
        case confirmPassword
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15.0) {
                if !clubName.isEmpty {
                    Text("Create an account to join the \(clubName) team.")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .padding(.top, 35)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Image("LoginLogo")
                TextField("Email Address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        focusedField = .password
                    }
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .onSubmit {
                        signUpUser()
                    }
                Button("Sign Up", action: signUpUser)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top, 15)
                    .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || signingUp || !userConsented)
                Text("Please note, you can only sign up with a Lafayette College academic email address (one that ends in lafayette.edu).")
                    .multilineTextAlignment(.center)
                CheckboxField(label: VStack {
                    Text("By signing up, you agree to the")
                    Button("Informed Consent Agreement") {
                        showingConsentAgreement.toggle()
                    }
                    .fullScreenCover(isPresented: $showingConsentAgreement) {
                        ConsentAgreementView(consented: $userConsented)
                            .ignoresSafeArea(.container, edges: .bottom)
                    }
                }, size: 45, color: Color(UIColor.label), checked: $userConsented)
                .padding(.top, 15)
                if signingUp {
                    ProgressView("Signing Up...")
                }
            }
            .padding(.horizontal, 15.0)
            .frame(maxWidth: .infinity)
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                focusedField = .email
                
                fetchTeamInfo()
            })
            .onChange(of: userConsented, perform: { newValue in
                focusedField = nil
            })
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
                   isPresented: $showingNotAcademicEmailErrorAlert) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text("You did not provide an academic email address. Please use a Lafayette College academic email address (ending in lafayette.edu) and try again.")
            }
            .alert("Email Already Taken", isPresented: $showingNameTakenErrorAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("If you already have an account but are not yet part of a team, please go back to the previous screen and try to login to your existing account before picking a club team to join.")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .disabled(signingUp)
            }
        }
        .navigationBarTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
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
        
        guard trimmedEmail.range(of: "lafayette.edu", options: .caseInsensitive) != nil else {
            showingNotAcademicEmailErrorAlert.toggle()
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
                
                teamSelected.toggle()
                signingUp.toggle()
            } catch {
                guard error.localizedDescription != "name already in use" else {
                    showingNameTakenErrorAlert.toggle()
                    signingUp.toggle()
                    return
                }
                
                signingUp.toggle()
                print("Error signing up: \(error.localizedDescription)")
                
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            }
        }
    }
    
    private func fetchTeamInfo() {
        guard let url = URL(string: "\(mongoDataEndpoint)/action/findOne") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(mongoDataAPIKey, forHTTPHeaderField: "api-key")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Request-Headers")
        
        let bodyJSON: [String: Any] = [
            "collection": "Team",
            "database": "govlab",
            "dataSource": "production",
            "filter": ["_id": ["$oid": team_id],],
            "projection": ["_id": 0, "name": 1]
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
            
            guard let name = team["name"] as? String else { return }
            clubName = name
        }
        
        task.resume()
    }
}
