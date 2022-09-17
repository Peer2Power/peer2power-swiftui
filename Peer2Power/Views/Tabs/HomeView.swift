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
    
    @Environment(\.realm) var realm
    
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
                    .padding([.leading, .trailing], 15.0)
                } else {
                    if !pastCloseDate {
                        VStack {
                            Text("The upload window is open.")
                        }
                    }
                    
                    List {
                        if pastCloseDate {
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
                    .alert("Are you sure you want to delete this contact?", isPresented: $showingDeleteAlert) {
                        Button("Cancel", role: .cancel, action: {})
                        Button("Delete", role: .destructive, action: deleteContact)
                    }
                }
                
                Button {
                    showingUploadForm.toggle()
                } label: {
                    Label("Upload a Contact", systemImage: "person.badge.plus")
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showingUploadForm) {
                    UploadContactView(userTeam: userTeam)
                }
            }
            .onAppear(perform: handleRemoteConfig)
            .navigationTitle("Peer2Power")
            .navigationBarTitleDisplayMode(.large)
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
