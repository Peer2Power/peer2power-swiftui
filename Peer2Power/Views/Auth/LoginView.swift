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
    
    @Binding var showingJoinedTeamAlert: Bool
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.realm) private var realm
    
    @StateObject private var viewModel: ChooseTeamViewModel = .shared
    
    enum Field: Hashable {
        case email
        case password
    }
    
    var body: some View {
        ScrollView {
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
                    if viewModel.selectedTeamID.isEmpty {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                        .disabled(loggingIn)
                    }
                }
            }
            .interactiveDismissDisabled(loggingIn)
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
                
                if !viewModel.selectedTeamID.isEmpty {
                    print("Trying to append user to team with ID \(viewModel.selectedTeamID)")
                    
                    getTeamToAdd(user: user, with: viewModel.selectedTeamID)
                } else {
                    print("No ID of a team for the user to join is being persisted.")
                }
                
                loggingIn.toggle()
            } catch {
                loggingIn.toggle()
                
                errorText = error.localizedDescription
                showingErrorAlert.toggle()
            }
        }
    }
    
    @MainActor
    private func getTeamToAdd(user: User, with teamID: String) {
        print("The user should join a team with the ID \(teamID)")
        
        do {
            let objectID = try ObjectId(string: teamID)
            
            Realm.asyncOpen(configuration: user.flexibleSyncConfiguration()) { result in
                switch result {
                case .success(let realm):
                    let subs = realm.subscriptions
                    let foundSub = subs.first(named: allTeamsSubName)
                    
                    subs.update {
                        if foundSub == nil {
                            subs.append(QuerySubscription<Team>(name: allTeamsSubName))
                        }
                    } onComplete: { error in
                        guard error == nil else {
                            print("Error appending subscription: \(error?.localizedDescription)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            getTeamToAdd(realm, user: user, to: objectID)
                        }
                    }
                case .failure(let failure):
                    print("Error opening realm: \(failure.localizedDescription)")
                }
            }
        } catch {
            print("Error creating object ID: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func getTeamToAdd(_ realm: Realm, user: User, to objectID: ObjectId) {
        guard let team = realm.object(ofType: Team.self, forPrimaryKey: objectID) else {
            print("The team could not be found.")
            return
        }
        
        print("Found a team with ID \(team._id.stringValue)")
        
        append(user: user, to: team, using: realm)
    }
    
    @MainActor
    private func append(user: User, to team: Team, using realm: Realm) {
        do {
            try realm.write {
                team.member_ids.append(user.id)
                print("Added the current user to a team.")
                
                team.score += 1
                showingJoinedTeamAlert.toggle()
                
                /* UserDefaults.standard.set(nil, forKey: "joinTeamID")
                if UserDefaults.standard.string(forKey: "joinTeamID") == nil {
                    print("Removed the ID of the team the user should join from UserDefaults since they have joined it.")
                } */
            }
        } catch {
            print("Error adding user to team: \(error.localizedDescription)")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showingJoinedTeamAlert: .constant(false))
    }
}
