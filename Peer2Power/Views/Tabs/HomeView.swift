//
//  HomeView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/31/22.
//

import SwiftUI
import Foundation
import FirebaseRemoteConfig
import RealmSwift
import AlertToast

struct HomeView: View {
    @State private var closeDateString = ""
    @State private var showingUploadForm = false
    @State private var showingDeleteAlert = false
    @State private var showingDeleteNotAllowedAlert = false
    @State private var offsetsToDelete: IndexSet?
    
    @State private var showingControlGroupAlert = false
    @State private var showingContactUploadedBanner = false
    
    @State private var currentContactGroup: ContactGroup = .treatment
    
    @Binding var canUploadContacts: Bool
    @Binding var isPastCompDate: Bool
    @ObservedRealmObject var userTeam: Team
    
    @Environment(\.realm) private var realm
    
    enum ContactGroup {
        case control
        case treatment
    }
    
    var body: some View {
        if isPastCompDate {
            VStack(spacing: 10.0) {
                Text("Competiton Over")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("The competition is over! The contacts your team uploaded have been erased. Thank you for participating!")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
        } else {
            VStack {
                if userTeam.contacts.isEmpty {
                    VStack(spacing: 10.0) {
                        Text("No Contacts Uploaded")
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Text("Your team hasn't uploaded any contacts to recruit to email an elected representative yet.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 15.0)
                } else {
                    // TODO: tinker with putting the leaderboard above the contacts list.
                    if userTeam.contacts.filter("group = %i", 1).isEmpty {
                        VStack(spacing: 10.0) {
                            Text("No Contacts Assigned to Be Recruited")
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("Thank you for uploading contacts! None of your team's contacts have been assigned to be recruited yet. Upload some more contacts to start recruiting them to email an elected representative.")
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 20)
                        }
                        .padding(.horizontal, 15.0)
                    } else {
                        List {
                            Section {
                                ForEach(userTeam.contacts.sorted(by: \Contact.name, ascending: true).filter("group = %i", 1)) { contact in
                                    NavigationLink {
                                        OutreachAttemptsListView(contact: contact, team: userTeam, canLogOutreachAttempts: $canUploadContacts)
                                    } label: {
                                        ContactListRow(contact: contact, team: userTeam)
                                    }
                                }
                                .onDelete { offsets in
                                    offsetsToDelete = offsets
                                    currentContactGroup = .treatment
                                    showingDeleteAlert.toggle()
                                }
                            } header: {
                                Text("Contacts to be recruited")
                            } footer: {
                                Text("These are the contacts who your team should recruit to email an elected representative.")
                            }
                            Section {
                                ForEach(userTeam.contacts.sorted(by: \Contact.name, ascending: true).filter("group = %i", 0)) { contact in
                                    Text("\(contact.name)")
                                }
                                .onDelete { offsets in
                                    offsetsToDelete = offsets
                                    currentContactGroup = .control
                                    showingDeleteAlert.toggle()
                                }
                            } header: {
                                Text("Contacts to not recruit")
                            } footer: {
                                Text("Your team should not recruit these contacts. This list is here to remind you which contacts were already uploaded.")
                            }
                        }
                        .toolbar {
                            EditButton()
                        }
                        .alert("Are you sure you want to delete this contact?",
                               isPresented: $showingDeleteAlert) {
                            Button("Cancel", role: .cancel, action: {})
                            Button("Delete", role: .destructive, action: getGroupToDeleteContactFrom)
                        } message: {
                            Text("Your team will lose any points it received for uploading this contact. All outreach attempts for this contact will also be deleted and your team will lose all points awarded for logging these.")
                        }
                        .alert("Cannot Delete Contact", isPresented: $showingDeleteNotAllowedAlert, actions: {
                            Button("OK", action: {})
                        }, message: {
                            Text("You can't delete contacts that another team member uploaded.")
                        })
                    }
                }
                if !canUploadContacts && !isPastCompDate {
                    Text("You can no longer upload any contacts or log any outreach attempts.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                    Button("Please complete the end of study survey.") {
                        
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                }
                Button {
                    showingUploadForm.toggle()
                } label: {
                    Label("Upload a Contact", systemImage: "person.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canUploadContacts)
                .sheet(isPresented: $showingUploadForm, onDismiss: {
                    guard let uploadedContact = userTeam.contacts.last else { return }
                    
                    if uploadedContact.group == 0 {
                        showingControlGroupAlert.toggle()
                    }
                }, content: {
                    UploadContactView(userTeam: userTeam, contact: Contact(), showingContactUploadedBanner: $showingContactUploadedBanner)
                })
                .padding(.horizontal, 15)
                .padding(.top, 5)
                .padding(.bottom, 10)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("LoginLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .toast(isPresenting: $showingControlGroupAlert, duration: 4.0) {
                AlertToast(displayMode: .banner(.pop),
                           type: .regular,
                           title: "Contact Not Visible",
                           subTitle: "\(lastContactName) was randomly assigned to not be contacted. 2 points were still awarded.")
            }
            .toast(isPresenting: $showingContactUploadedBanner, duration: 4.0) {
                AlertToast(displayMode: .banner(.pop),
                           type: .complete(Color(.systemGreen)),
                           title: "Contact Uploaded",
                           subTitle: "Your team received 2 points!")
            }
            .onChange(of: showingContactUploadedBanner) { newValue in
                guard newValue == true else { return }
                
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.getPendingNotificationRequests { requests in
                    if requests.contains(where: { request in
                        return request.identifier == uploadReminderNotifIdentifier
                    }) {
                        removeUploadReminderNotification()
                    }
                }
            }
        }
    }
}

extension HomeView {
    private func getGroupToDeleteContactFrom() {
        guard let team = userTeam.thaw() else { return }
        guard let offsets = offsetsToDelete else { return }
        
        do {
            try realm.write {
                for i in offsets {
                    if currentContactGroup == .treatment {
                        let treatmentContacts = team.contacts.filter("group = %i", 1).sorted(by: \Contact.name, ascending: true)
                        delete(contact: treatmentContacts[i], from: team)
                    } else if currentContactGroup == .control {
                        let controlContacts = team.contacts.filter("group = %i", 0).sorted(by: \Contact.name, ascending: true)
                        delete(contact: controlContacts[i], from: team)
                    }
                }
            }
        } catch {
            print("Error deleting contact: \(error.localizedDescription)")
        }
    }
    
    private func delete(contact: Contact, from team: Team) {
        guard contact.owner_id == app.currentUser!.id else {
            showingDeleteNotAllowedAlert.toggle()
            return
        }
        
        let contactID = contact.contact_id
        
        realm.delete(contact)
        
        guard team.score > 0 else { return }
        team.score -= 2
        
        for outreachAttempt in team.outreachAttempts.filter("to = %@", contactID) {
            let volunteerStatus = outreachAttempt.volunteerStatus
            
            realm.delete(outreachAttempt)
            
            if volunteerStatus == theyVolunteeredText {
                team.score -= 7
                print("Deleted an outreach attempt and subtracted seven points from the team's score.")
            } else {
                team.score -= 4
                print("Deleted an outreach attempt and subtracted four points from the team's score.")
            }
        }
        
        print("Deleted a contact and subtracted two points.")
    }
    
    private var lastContactName: String {
        guard let lastContact = userTeam.contacts.last else { return "" }
        
        return lastContact.name
    }
    
    private func removeUploadReminderNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uploadReminderNotifIdentifier])
        
        print("Removed upload contact reminder notification.")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(canUploadContacts: .constant(true), isPastCompDate: .constant(false), userTeam: Team())
    }
}
