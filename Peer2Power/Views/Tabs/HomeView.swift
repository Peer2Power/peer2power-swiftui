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
    @State private var pastCloseDate: Bool?
    @State private var showingUploadForm = false
    
    @ObservedRealmObject var userTeam: Team
    
    var body: some View {
        NavigationView {
            VStack {
                // TODO: add handling of upload window by checking if it's past the window close date.
                
                if userTeam.contacts.isEmpty {
                    VStack {
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
                    List {
                        ForEach(userTeam.contacts) { contact in
                            NavigationLink {
                                OutreachAttemptsListView(contact: contact, team: userTeam)
                            } label: {
                                ContactListRow(contact: contact, team: userTeam)
                            }
                        }
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
