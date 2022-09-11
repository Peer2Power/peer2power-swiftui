//
//  OutreachAttemptsListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/25/22.
//

import SwiftUI
import RealmSwift

struct OutreachAttemptsListView: View {
    @ObservedRealmObject var contact: Contact
    @ObservedRealmObject var team: Team
    
    @State private var presentingLogOutreachForm = false
    @State private var presentingEditContactInfoForm = false
    
    @State private var showingDeleteAttemptAlert = false
    @State private var offsetsToDelete: IndexSet?
    
    @Environment(\.realm) var realm
    
    var body: some View {
        if team.outreachAttempts.filter("to = %@", contact.contact_id).isEmpty {
            VStack(spacing: 10.0) {
                Text("No Outreach Attempts Logged")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("Your team hasn't logged any attempts to get this contact to volunteer yet. Talk to them using your contact method of choice, then return here to log how the interaction went.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
            .padding([.leading, .trailing], 15.0)
        } else {
            List {
                ForEach(team.outreachAttempts.filter("to = %@", contact.contact_id)) { attempt in
                    OutreachListRow(attempt: attempt)
                }
                .onDelete { offsets in
                    offsetsToDelete = offsets
                    showingDeleteAttemptAlert.toggle()
                }
            }
            .navigationTitle(contact.name)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Are you sure you want to delete this outreach attempt?", isPresented: $showingDeleteAttemptAlert) {
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive, action: deleteOutreachAttempt)
            } message: {
                Text("Your team will lose the 4 points it gained for logging this outreach attempt.")
            }

        }
        HStack {
            Button {
                presentingLogOutreachForm.toggle()
            } label: {
                Label("Log Outreach Attempt", systemImage: "square.and.pencil")
            }
            .disabled(team.outreachAttempts.filter("to = %@", contact.contact_id).filter("volunteerStatus = %@", "They volunteered!").count > 0)
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $presentingLogOutreachForm) {
                LogOutreachView(contact: contact, team: team)
            }
            Spacer()
            Button {
                presentingEditContactInfoForm.toggle()
            } label: {
                Label("Edit Contact Info", systemImage: "person.text.rectangle")
            }
            .buttonStyle(.bordered)
            .sheet(isPresented: $presentingEditContactInfoForm) {
                UploadContactView(userTeam: team)
            }
        }
        .padding([.leading, .trailing], 15.0)
    }
}

extension OutreachAttemptsListView {
    private func deleteOutreachAttempt() {
        guard let team = team.thaw() else { return }
        guard let offsets = offsetsToDelete else { return }
        // TODO: get the outreach attempt by figuring out its index using the provided IndexSet.
        
        do {
            try realm.write {
                team.outreachAttempts.remove(atOffsets: offsets)
                
                team.score -= 4
                // TODO: remove 8 points for attempts that triggered the multiplier
                
                print("Deleted outreach attempt and subtracted points.")
            }
        } catch {
            print("Error deleting outreach attempt: \(error.localizedDescription)")
        }
    }
}
