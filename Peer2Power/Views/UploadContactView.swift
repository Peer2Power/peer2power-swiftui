//
//  UploadContactView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct UploadContactView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    @ObservedRealmObject var userTeam: Team
    
    @State private var newContact = Contact()
    
    @State private var isAdult: Bool = false
    
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
            // .onAppear(perform: setSubscription)
            .navigationTitle("Upload Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        newContact.owner_id = app.currentUser!.id
                        
                        $userTeam.contacts.append(newContact)
                        
                        guard let team = userTeam.thaw() else { return }
                        
                        do {
                            try realm.write {
                                team.score += 2
                                print("Awarded 2 points for uploading a contact.")
                            }
                        } catch {
                            print("Error awarding points for uploading a contact: \(error.localizedDescription)")
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

struct UploadContactView_Previews: PreviewProvider {
    static var previews: some View {
        UploadContactView(userTeam: Team())
    }
}
