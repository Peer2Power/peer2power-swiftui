//
//  OutreachAttemptsListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/25/22.
//

import SwiftUI
import RealmSwift
import AlertToast
import FirebaseRemoteConfig

struct OutreachAttemptsListView: View {
    @ObservedRealmObject var contact: Contact
    @ObservedRealmObject var team: Team
    
    @State private var presentingLogOutreachForm = false
    @State private var presentingEditContactInfoForm = false
    
    @State private var showingDeleteAttemptAlert = false
    @State private var offsetsToDelete: IndexSet?
    
    @State private var showingAttemptLoggedBanner = false
    @State private var showingDidVolunteerBanner = false
    
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
            .padding(.horizontal, 15.0)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            VStack {
                List {
                    ForEach(team.outreachAttempts.filter("to = %@", contact.contact_id).sorted(by: \OutreachAttempt.createdAt, ascending: true)) { attempt in
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
                    Text("Your team will lose the points it gained for logging this outreach attempt.")
                }
                .toolbar {
                    EditButton()
                }
                .toast(isPresenting: $showingAttemptLoggedBanner, duration: 4.0) {
                    AlertToast(displayMode: .banner(.pop),
                               type: .complete(Color(uiColor: .systemGreen)),
                               title: "Outreach Attempt Logged!",
                               subTitle: "Your team received 4 points!")
                }
                .toast(isPresenting: $showingDidVolunteerBanner, duration: 4.0) {
                    AlertToast(displayMode: .banner(.pop),
                               type: .complete(Color(uiColor: .systemGreen)),
                               title: "Outreach Attempt Logged!",
                               subTitle: "Your team received 7 points!")
                }
            }
        }
        if !team.outreachAttempts.filter("to = %@", contact.contact_id).filter("volunteerStatus = %@", "I have confirmed that they volunteered.").isEmpty {
            Text("This contact volunteered.")
                .multilineTextAlignment(.center)
        }
        if !team.endOfStudyResponses.filter("%@ in contact_ids", contact.contact_id.stringValue).isEmpty {
            Text("A team member marked this contact as a confirmed volunteer in the end-of-study survey.")
                .multilineTextAlignment(.center)
        }
        Button {
            presentingLogOutreachForm.toggle()
        } label: {
            Label("Log Outreach Attempt", systemImage: "square.and.pencil")
        }
        .disabled(!team.outreachAttempts.filter("to = %@", contact.contact_id).filter("volunteerStatus = %@", "I have confirmed that they volunteered.").isEmpty || !team.endOfStudyResponses.filter("%@ in contact_ids", contact.contact_id.stringValue).isEmpty || isPastCompDate)
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $presentingLogOutreachForm) {
            LogOutreachView(contact: contact, team: team, showDidVolunteerBanner: $showingDidVolunteerBanner, showAttemptLoggedBanner: $showingAttemptLoggedBanner)
                .interactiveDismissDisabled(true)
        }
        // HStack {
            
            // FIXME: give this button functionality.
            /*
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
            */
        /* }
        .padding(.horizontal, 15.0) */
    }
}

extension OutreachAttemptsListView {
    private func deleteOutreachAttempt() {
        guard let team = team.thaw() else { return }
        guard let offsets = offsetsToDelete else { return }
        // TODO: get the outreach attempt by figuring out its index using the provided IndexSet.
        
        let filteredAttempts = team.outreachAttempts.filter("to = %@", contact.contact_id)
        guard !filteredAttempts.isEmpty else { return }
        
        do {
            try realm.write {
                offsets.forEach { i in
                    let attemptToDelete = filteredAttempts[i]
                    let volunteeredAttempt = attemptToDelete.volunteerStatus == "I have confirmed that they volunteered."
                    
                    realm.delete(attemptToDelete)
                    
                    if volunteeredAttempt {
                        guard team.score > 0 else { return }
                        
                        team.score -= 7
                    } else {
                        guard team.score > 0 else { return }
                        
                        team.score -= 4
                    }
                }
                // TODO: remove 8 points for attempts that triggered the multiplier
            }
        } catch {
            print("Error deleting outreach attempt: \(error.localizedDescription)")
        }
    }
    
    private var isPastCompDate: Bool {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        guard let fetchedDate = remoteConfig["endOfStudySurveyAvailableDate"].stringValue else { return false }
        print("Got end of study date \(fetchedDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        
        guard let date = dateFormatter.date(from: fetchedDate) else { return false }
        let compareResult = Date().compare(date)
        
        return compareResult == .orderedSame || compareResult == .orderedAscending
    }
}
