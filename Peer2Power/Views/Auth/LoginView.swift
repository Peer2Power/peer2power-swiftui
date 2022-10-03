//
//  LoginView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/2/22.
//

import SwiftUI
import RealmSwift

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loggingIn = false
    @State private var showingPasswordResetForm = false
    @State private var showingSignUpSheet = false
    
    @State private var showingErrorAlert = false
    @State private var errorText = ""
    @State private var showingEmptyFieldAlert = false
    
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.realm) private var realm
    
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
        .alert("Missing Information",
               isPresented: $showingEmptyFieldAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("One or more text fields is empty. Please fill out all text fields and try again.")
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
}

extension LoginView {
    private func loginUser() {
        focusedField = nil
        
        guard !email.isEmpty else {
            showingEmptyFieldAlert.toggle()
            return
        }
        
        guard !password.isEmpty else {
            showingEmptyFieldAlert.toggle()
            return
        }
        
        Task {
            loggingIn.toggle()
            do {
                let user = try await app.login(credentials: .emailPassword(email: email, password: password))
                
                print("Logged in user with ID \(user.id)")
                
                // FIXME: the team can't be found even though supplying the method with a string literal ID works. Not sure why it doesn't work with a string from UserDefaults.
                if let joinTeamID = UserDefaults.standard.string(forKey: "joinTeamID") {
                    DispatchQueue.main.async {
                        add(user: user, to: "\(joinTeamID)")
                    }
                }
                
                /*
                UserDefaults.standard.set("633a3245572a32cab38687e8", forKey: "joinTeamID")
                if let id = UserDefaults.standard.string(forKey: "joinTeamID") {
                    print("The following ID is being persisted: \(id)")
                }
                
                let teamID = "633a3245572a32cab38687e8"
                DispatchQueue.main.async {
                    add(user: user, to: teamID)
                } */
                
                loggingIn.toggle()
            } catch {
                loggingIn.toggle()
                
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            }
        }
    }
    
    private func add(user: User, to teamID: String) {
        print("User should join a team with ID \(teamID)")
        
        do {
            let teamRealm = try Realm(configuration: user.flexibleSyncConfiguration(initialSubscriptions: { subs in
                subs.append(QuerySubscription<Team>(name: allTeamsSubName))
            }))
            
            guard let team = teamRealm.object(ofType: Team.self, forPrimaryKey: try ObjectId(string: teamID)) else {
                print("The team could not be found.")
                return
            }
            
            try teamRealm.write {
                team.member_ids.append(user.id)
                
                print("Added the current user to a team.")
                UserDefaults.standard.set(nil, forKey: "joinTeamID")
                dismiss()
            }
        } catch {
            print("Error adding user to team: \(error.localizedDescription)")
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
