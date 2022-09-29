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
    @State private var pastCloseDate = true
    @State private var showingUploadForm = false
    @State private var showingDeleteAlert = false
    @State private var offsetsToDelete: IndexSet?
    
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
                    // For testing assuming upload window has already closed.
                    /*
                    List {
                        ForEach(userTeam.contacts) { contact in
                            NavigationLink {
                                OutreachAttemptsListView(contact: contact, team: userTeam)
                            } label: {
                                ContactListRow(contact: contact, team: userTeam)
                            }
                        }
                    }
                    */
                    if !pastCloseDate {
                        VStack {
                            Text("The upload window is open. After it closes, you will only be able to see the half of your team's contacts assigned to the treatment group.")
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 15.0)
                    }
                    
                    List {
                        if pastCloseDate {
                            if !userTeam.contacts.isEmpty && userTeam.contacts.filter("group = %i", 1).isEmpty {
                                VStack(spacing: 10.0) {
                                    Text("Contacts Not Assigned")
                                        .font(.title)
                                        .multilineTextAlignment(.center)
                                    Text("Thank you for uploading contacts! The contacts you should recruit have not been randomly assigned yet. Please come back after your contacts have been assigned.")
                                        .font(.callout)
                                        .multilineTextAlignment(.center)
                                        .padding(.bottom, 20)
                                }
                                .padding(.horizontal, 15.0)
                            } else {
                                Text("Here is your updated contact list.")
                                    .multilineTextAlignment(.center)
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
                            }
                        } else {
                            ForEach(userTeam.contacts) { contact in
                                Text("\(contact.name)")
                                    .font(.title2)
                                    .minimumScaleFactor(0.25)
                            }
                            .onDelete { offsets in
                                offsetsToDelete = offsets
                                showingDeleteAlert.toggle()
                            }
                        }
                    }
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
                }
                
                Button {
                    showingUploadForm.toggle()
                } label: {
                    Label("Upload a Contact", systemImage: "person.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showingUploadForm) {
                    UploadContactView(userTeam: userTeam, contact: Contact(), isPastCloseDate: $pastCloseDate)
                }
            }
            .onAppear(perform: handleRemoteConfig)
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
                if pastCloseDate{
                    let filteredContacts = team.contacts.filter("group = %i", 1)
                    
                    offsets.forEach { i in
                        let contactToDelete = filteredContacts[i]
                        realm.delete(contactToDelete)
                    }
                } else {
                    team.contacts.remove(atOffsets: offsets)
                }
                
                team.score -= 2
            }
        } catch {
            print("Error deleting contact: \(error.localizedDescription)")
        }
    }
    
    private func handleRemoteConfig() {
        Task {
            try await fetchRemoteConfig()
            
            guard closeDateString.isEmpty == false else { return }
            
            updateUIWithCloseDate()
        }
    }
    
    private func updateUIWithCloseDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
        
        guard let uploadWindowCloseDate = dateFormatter.date(from: closeDateString) else { return }
        
        let compareResult = uploadWindowCloseDate.compare(Date())
        
        pastCloseDate = compareResult == .orderedSame || compareResult == .orderedAscending
    }
    
    private func fetchRemoteConfig() async throws {
        let rc = RemoteConfig.remoteConfig()
        let defaultValues = [
            "uploadWindowCloseDate": "09-09-2022 11:59" as NSObject
        ]
        rc.setDefaults(defaultValues)
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        rc.configSettings = settings
        
        do {
            let config = try await rc.fetchAndActivate()
            
            switch config {
            case .successFetchedFromRemote:
                closeDateString = rc.configValue(forKey: "uploadWindowCloseDate").stringValue ?? ""
            case .successUsingPreFetchedData:
                closeDateString = rc.configValue(forKey: "uploadWindowCloseDate").stringValue ?? ""
            case .error:
                return
            @unknown default:
                return
            }
        } catch {
            print("Error fetching remote config: \(error.localizedDescription)")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userTeam: Team())
    }
}
