//
//  UploadContactView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct UploadContactView: View {
    @AsyncOpen(appId: realmAppID, timeout: 4000) var asyncOpen
    
    var body: some View {
        switch asyncOpen {
        case .connecting:
            ProgressView()
        case .waitingForUser:
            ProgressView("Waiting for user to log in...")
        case .open(let realm):
            UploadForm(realm: realm)
        case .progress(let progress):
            ProgressView(progress)
        case .error(let error):
            ErrorView(error: error, retryAction: { })
        }
    }
}

struct UploadForm: View {
    @Environment (\.dismiss) var dismiss
    
    @State private var newContact = Contact()
    
    @State private var isAdult: Bool = false
    
    let realm: Realm
    
    let ageBrackets = ["18 - 25", "26-39", "40+"]
    let relationships = ["Friend", "Family"]
    let likelihoods = ["Extremely Unlikely", "Unlikely", "Unsure", "Likely", "Exremely Likely"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $newContact.name)
                    .textContentType(.name)
                    .autocapitalization(.words)
                TextField("Email", text: $newContact.email).textContentType(.emailAddress).autocapitalization(.none)
                    .keyboardType(.emailAddress)
                Toggle(isOn: $isAdult) {
                    Text("I certify that this person is 18 or older.")
                }
                Section("Optional Information") {
                    Picker("Likelihood to Volunteer", selection: $newContact.volunteerLikelihood) {
                        ForEach(likelihoods, id: \.self) { likelihood in
                            Text("\(likelihood)")
                        }
                    }
                    Picker("Age Bracket", selection: $newContact.ageBracket) {
                        ForEach(ageBrackets, id: \.self) { ageBracket in
                            Text("\(ageBracket)")
                        }
                    }
                    Picker("Relationship", selection: $newContact.relationship) {
                        ForEach(relationships, id: \.self) { relationship in
                            Text("\(relationship)")
                        }
                    }
                }
            }
            .onAppear(perform: setSubscription)
            .navigationTitle("Upload Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        newContact.owner_id = app.currentUser!.id
                        
                        do {
                            try realm.write {
                                realm.add(newContact)
                            }
                        } catch {
                            print("An error occurred while trying to upload the contact: \(error)")
                        }
                        
                        dismiss()
                    }
                    .disabled(false)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

extension UploadForm {
    private func setSubscription() {
        let subscriptions = realm.subscriptions
        subscriptions.update {
            if subscriptions.first(named: "user_contacts") != nil {
                print("Contact subscription already exists.")
                return
            } else {
                print("Appending new Contact subscription.")
                subscriptions.append(QuerySubscription<Contact>(name: "user_contacts") { contact in
                    contact.owner_id == app.currentUser!.id
                })
            }
        }
    }
}

struct UploadContactView_Previews: PreviewProvider {
    static var previews: some View {
        UploadContactView()
    }
}
