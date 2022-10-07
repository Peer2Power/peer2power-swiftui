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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.realm) private var realm
    
    @ObservedRealmObject var userTeam: Team
    
    @ObservedRealmObject var contact: Contact
    
    var isUpdating: Bool {
        contact.realm != nil
    }
    
    @State private var isAdult = false
    @State private var showingContactUploadedAlert = false
    @Binding var isPastCloseDate: Bool
    
    @State private var showingDuplicateContactAlert = false
    @State private var showingInvalidEmailAlert = false
    
    let ageBrackets = ["18 - 25", "26-39", "40+"]
    let relationships = ["Friend", "Family"]
    let likelihoods = ["Extremely Unlikely", "Unlikely", "Unsure", "Likely", "Exremely Likely"]
    
    @State private var selectedAgeBracket = "Select age bracket"
    @State private var selectedRelationship = "Select relationship"
    @State private var selectedLikelihood = "Select likelihood"
    
    enum Field: Hashable {
        case name
        case email
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $contact.name)
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .focused($focusedField, equals: .name)
                TextField("Email", text: $contact.email).textContentType(.emailAddress).autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                if !isUpdating {
                    Toggle(isOn: $isAdult) {
                        Text("I certify that this person is 18 or older.")
                    }
                }
                Section("Optional Information") {
                    Picker("Likelihood to Volunteer", selection: $selectedLikelihood) {
                        Text("Select likelihood").tag("Select likelihood")
                        ForEach(likelihoods, id: \.self) { likelihood in
                            Text("\(likelihood)")
                        }
                    }
                    Picker("Age Bracket", selection: $selectedAgeBracket) {
                        Text("Select age bracket").tag("Select age bracket")
                        ForEach(ageBrackets, id: \.self) { ageBracket in
                            Text("\(ageBracket)")
                        }
                    }
                    Picker("Relationship", selection: $selectedRelationship) {
                        Text("Select relationship").tag("Select relationship")
                        ForEach(relationships, id: \.self) { relationship in
                            Text("\(relationship)")
                        }
                    }
                }
            }
            .navigationTitle(isUpdating ? "Edit Contact" : "Upload Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isUpdating ? "Done" : "Save") {
                        if isUpdating {
                            dismiss()
                        } else {
                            uploadNewContact()
                        }
                    }
                    .disabled(contact.name.isEmpty || contact.email.isEmpty || !isAdult)
                }
                ToolbarItem(placement: .cancellationAction) {
                    if !isUpdating {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
        .alert(Text("Contact Already Uploaded"),
               isPresented: $showingDuplicateContactAlert,
               actions: {
            Button("OK", role: .cancel, action: {})
        }, message: {
            Text("You or someone on your team has already uploaded a contact with this email address. Please use a different email address and try again.")
        })
        .alert("Invalid Email Address",
               isPresented: $showingInvalidEmailAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("The email address you provided for your contact is invalid. Please enter a revised email address and try again.")
        }
        .onChange(of: isAdult, perform: { newValue in
            focusedField = nil
        })
        .SPAlert(isPresent: $showingContactUploadedAlert,
                 title: "Points Received!",
                 message: "Your team received 2 points for uploading this contact!",
                 duration: 4,
                 dismissOnTap: true,
                 preset: .done,
                 haptic: .success,
                 layout: nil) {
            dismiss()
        }
    }
}

extension UploadContactView {
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func uploadNewContact() {
        guard isValidEmail(contact.email) else {
            showingInvalidEmailAlert.toggle()
            return
        }
        
        guard userTeam.contacts.filter("email = %@", contact.email).isEmpty else {
            showingDuplicateContactAlert.toggle()
            return
        }
        
        contact.owner_id = app.currentUser!.id
        contact.volunteerLikelihood = selectedLikelihood
        contact.ageBracket = selectedAgeBracket
        contact.relationship = selectedRelationship
        
        if isPastCloseDate {
            let randomFloat = Float.random(in: 0..<1)
            
            if randomFloat > 0.5 {
                contact.group = 1
                print("Contact was assigned to the treatment group.")
            } else {
                contact.group = 0
                print("Contact was assigned to the control group.")
            }
        }
        
        $userTeam.contacts.append(contact)
        
        guard let team = userTeam.thaw() else { return }
        
        do {
            try realm.write {
                team.score += 2
                print("Awarded 2 points for uploading a contact.")
                showingContactUploadedAlert.toggle()
            }
        } catch {
            print("Error awarding points for uploading a contact: \(error.localizedDescription)")
        }
    }
}
