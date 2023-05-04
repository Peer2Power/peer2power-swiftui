//
//  UploadContactView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift
import AlertToast

struct UploadContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.realm) private var realm
    
    @ObservedRealmObject var userTeam: Team
    
    var contact: Contact
    
    var isUpdating: Bool {
        contact.realm != nil
    }
    
    @State private var isAdult = false
    @Binding var showingContactUploadedBanner: Bool
    
    @State private var showingDuplicateContactAlert = false
    @State private var showingInvalidEmailAlert = false
    @State private var showingConfirmCancelAlert = false
    
    let ageBrackets = ["18 - 25", "26-39", "40+"]
    let relationships = ["Friend", "Family"]
    let likelihoods = ["Extremely Unlikely", "Unlikely", "Unsure", "Likely", "Exremely Likely"]
    
    @State private var selectedAgeBracket = "Select Age Bracket"
    @State private var selectedRelationship = "Select Relationship"
    @State private var selectedLikelihood = "Select Likelihood"
    
    @State private var contactName: String = ""
    @State private var contactEmail: String = ""
    
    enum Field: Hashable {
        case name
        case email
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            Form {
                HStack(alignment: .center) {
                    TextField("Name", text: $contactName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .email
                        }
                    if focusedField == .name {
                        Button {
                            contactName = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(.systemGray2))
                        }
                    }
                }
                .buttonStyle(.plain)
                HStack(alignment: .center) {
                    TextField("Email", text: $contactEmail).textContentType(.emailAddress).autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                    if focusedField == .email {
                        Button {
                            contactEmail = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(.systemGray2))
                        }
                    }
                }
                .buttonStyle(.plain)
                if !isUpdating {
                    Toggle(isOn: $isAdult) {
                        Text("I certify that this person is 18 or older.")
                    }
                }
                Section("Optional Information") {
                    Picker("Likelihood to Email an Elected Representative", selection: $selectedLikelihood) {
                        Text("Select Likelihood").tag("Select Likelihood")
                        ForEach(likelihoods, id: \.self) { likelihood in
                            Text("\(likelihood)")
                        }
                    }
                    Picker("Age Bracket", selection: $selectedAgeBracket) {
                        Text("Select Age Bracket").tag("Select Age Bracket")
                        ForEach(ageBrackets, id: \.self) { ageBracket in
                            Text("\(ageBracket)")
                        }
                    }
                    Picker("Relationship", selection: $selectedRelationship) {
                        Text("Select Relationship").tag("Select Relationship")
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
                    .disabled(contactName.isEmpty || contactEmail.isEmpty || !isAdult)
                }
                ToolbarItem(placement: .cancellationAction) {
                    if !isUpdating {
                        Button {
                            if !contactName.isEmpty || !contactEmail.isEmpty {
                                showingConfirmCancelAlert.toggle()
                            } else {
                                dismiss()
                            }
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
            Text("Your team or another team has already uploaded a contact with this email address. Please use a different email address and try again.")
        })
        .alert("Invalid Email Address",
               isPresented: $showingInvalidEmailAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("The email address you provided for your contact is invalid. Please enter a valid email address and try again.")
        }
        .confirmationDialog("Alert", isPresented: $showingConfirmCancelAlert, titleVisibility: .hidden, actions: {
            Button("Discard Contact", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Are you sure you want to discard this contact?")
        })
        .onChange(of: isAdult, perform: { newValue in
            focusedField = nil
        })
        .onAppear {
            focusedField = .name
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
        guard isValidEmail(contactEmail) else {
            showingInvalidEmailAlert.toggle()
            return
        }
        
        guard realm.objects(Team.self).where({ predTeam in
            return predTeam.contacts.email == contactEmail
        }).isEmpty else {
            showingDuplicateContactAlert.toggle()
            return
        }
        
        contact.owner_id = app.currentUser!.id
        contact.volunteerLikelihood = selectedLikelihood
        contact.ageBracket = selectedAgeBracket
        contact.relationship = selectedRelationship
        contact.name = contactName
        contact.email = contactEmail
        
        let randomInt = Int.random(in: 0...1)
        contact.group = randomInt
        
        if contact.group == 1 {
            print("Contact was assigned to the treatment group.")
        } else {
            print("Contact was assigned to the control group.")
        }
        
        $userTeam.contacts.append(contact)
        
        guard let team = userTeam.thaw() else { return }
        
        do {
            try realm.write {
                team.score += 2
                print("Awarded 2 points for uploading a contact.")
                
                if contact.group == 1 {
                    showingContactUploadedBanner.toggle()
                }
                
                dismiss()
            }
        } catch {
            print("Error awarding points for uploading a contact: \(error.localizedDescription)")
        }
    }
    
    private func setTableBackgroundColor() {
        UITableView.appearance().backgroundColor = .clear
    }
}
