//
//  UploadContactView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct UploadContactView: View {
    @Environment (\.dismiss) var dismiss
    
    @ObservedRealmObject var contact: Contact
    
    @State private var isAdult: Bool = false
    
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
            }
            .navigationTitle("Upload Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveContact)
                        .disabled(true)
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

extension UploadContactView {
    func saveContact() {
        
    }
}

struct UploadContactView_Previews: PreviewProvider {
    static var previews: some View {
        UploadContactView(contact: Contact())
    }
}
