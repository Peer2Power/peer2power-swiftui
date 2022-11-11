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

struct HomeView: View {
    @State private var closeDateString = ""
    @State private var showingUploadForm = false
    @State private var showingDeleteAlert = false
    @State private var offsetsToDelete: IndexSet?
    
    @State private var showingControlGroupAlert = false
    
    @ObservedRealmObject var userTeam: Team
    
    @Environment(\.realm) private var realm
    
    var body: some View {
        NavigationView {
            VStack {
                if userTeam.contacts.isEmpty {
                    VStack(spacing: 10.0) {
                        Text("No Contacts Uploaded")
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Text("Your team hasn't uploaded any contacts to recruit to volunteer yet.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 15.0)
                } else {
                    // TODO: tinker with putting the leaderboard above the contacts list.
                    List {
                        if !userTeam.contacts.isEmpty && userTeam.contacts.filter("group = %i", 1).isEmpty {
                            VStack(spacing: 10.0) {
                                Text("Contacts Not Assigned")
                                    .font(.title)
                                    .multilineTextAlignment(.center)
                                Text("Thank you for uploading contacts! None of your team's contacts have been assigned to be recruited yet. Upload some more contacts to start recruiting them to volunteer.")
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 20)
                            }
                            .padding(.horizontal, 15.0)
                        } else {
                            Section {
                                ForEach(userTeam.contacts.filter("group = %i", 1)) { contact in
                                    NavigationLink {
                                        OutreachAttemptsListView(contact: contact, team: userTeam)
                                    } label: {
                                        ContactListRow(contact: contact, team: userTeam)
                                    }
                                }
                                .onDelete { offsets in
                                    offsetsToDelete = offsets
                                    showingDeleteAlert.toggle()
                                }
                            } footer: {
                                Text("You can only see the contacts your team should recruit to volunteer.")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .toolbar {
                        EditButton()
                    }
                    .alert("Are you sure you want to delete this contact?",
                           isPresented: $showingDeleteAlert) {
                        Button("Cancel", role: .cancel, action: {})
                        Button("Delete", role: .destructive, action: deleteContact)
                    } message: {
                        Text("Your team will lose any points it received for this contact.")
                    }
                    .alert("Contact Not Visible", isPresented: $showingControlGroupAlert) {
                        Button("OK", role: .cancel, action: {})
                    } message: {
                        Text("Your should not try to recruit this contact to volunteer, so you will not see them in your contacts list.")
                    }
                }
                Button {
                    showingUploadForm.toggle()
                } label: {
                    Label("Upload a Contact", systemImage: "person.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showingUploadForm, onDismiss: {
                    guard let uploadedContact = userTeam.contacts.last else { return }
                    
                    if uploadedContact.group == 0 {
                        showingControlGroupAlert.toggle()
                    }
                }, content: {
                    UploadContactView(userTeam: userTeam, contact: Contact())
                })
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("LoginLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

extension HomeView {
    private func deleteContact() {
        guard let team = userTeam.thaw() else { return }
        guard let offsets = offsetsToDelete else { return }
        
        do {
            try realm.write {
                team.contacts.remove(atOffsets: offsets)
                
                guard team.score > 0 else { return }
                team.score -= 2
            }
        } catch {
            print("Error deleting contact: \(error.localizedDescription)")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userTeam: Team())
    }
}
