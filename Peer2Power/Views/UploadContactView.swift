//
//  UploadContactView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift
import SPAlert

struct UploadContactView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    @ObservedRealmObject var userTeam: Team
    
    @ObservedRealmObject var contact: Contact
    
    @State private var isAdult = false
    @State private var showingContactUploadedAlert = false
    @Binding var isPastCloseDate: Bool
    
    let ageBrackets = ["18 - 25", "26-39", "40+"]
    let relationships = ["Friend", "Family"]
    let likelihoods = ["Extremely Unlikely", "Unlikely", "Unsure", "Likely", "Exremely Likely"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $contact.name)
                    .textContentType(.name)
                    .autocapitalization(.words)
                TextField("Email", text: $contact.email).textContentType(.emailAddress).autocapitalization(.none)
                    .keyboardType(.emailAddress)
                Toggle(isOn: $isAdult) {
                    Text("I certify that this person is 18 or older.")
                }
                /*
                Section("Optional Information") {
                    Picker("Likelihood to Volunteer", selection: $contact.volunteerLikelihood) {
                        ForEach(likelihoods, id: \.self) { likelihood in
                            Text("\(likelihood)")
                        }
                    }
                    Picker("Age Bracket", selection: $contact.ageBracket) {
                        ForEach(ageBrackets, id: \.self) { ageBracket in
                            Text("\(ageBracket)")
                        }
                    }
                    Picker("Relationship", selection: $contact.relationship) {
                        ForEach(relationships, id: \.self) { relationship in
                            Text("\(relationship)")
                        }
                    }
                }
                 */
            }
            .navigationTitle("Upload Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        contact.owner_id = app.currentUser!.id
                        
                        if isPastCloseDate {
                            let randomFloat = Float.random(in: 0..<1)
                            
                            if randomFloat > 0.5 {
                                contact.group = 1
                            } else {
                                contact.group = 0
                            }
                        }
                        
                        $userTeam.contacts.append(contact)
                        
                        guard let team = userTeam.thaw() else { return }
                        
                        do {
                            try realm.write {
                                team.score += 2
                                print("Awarded 2 points for uploading a contact.")
                                showingContactUploadedAlert.toggle()
                                
                                dismiss()
                            }
                        } catch {
                            print("Error awarding points for uploading a contact: \(error.localizedDescription)")
                        }
                    }
                    .disabled(contact.name.isEmpty || contact.email.isEmpty || !isAdult)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .SPAlert(isPresent: $showingContactUploadedAlert,
                     title: "Points Received!",
                     message: "Your team received 2 points for uploading a contact!",
                     preset: .custom(UIImage(systemName: "plus.circle")!),
                     haptic: .success)
        }
    }
}
