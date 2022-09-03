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
    
    @Environment(\.realm) var realm
    
    @ObservedRealmObject var userTeam: Team
    
    var body: some View {
        NavigationView {
            VStack {
                /* if pastCloseDate == false {
                    Text("The upload window is open.")
                        .font(.title)
                } else if contacts.isEmpty {
                    Text("Upload some contacts.")
                } else { */
                    List {
                        ForEach(userTeam.contacts) { contact in
                            Text("\(contact.name)")
                        }
                    }
                    HStack {
                        Spacer()
                        Button {
                            print("DO SOMETHING Twitter be like")
                        } label: {
                            Image(systemName: "person.crop.circle.badge.plus")
                        }

                    }
                // }
            }
            .onAppear(perform: handleRemoteConfig)
            .navigationTitle("Peer2Power")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

extension HomeView {
    private func handleRemoteConfig() {
        let subs = realm.subscriptions
        print("This view has \(subs.count) subscriptions.")
        
        if let sub = subs.first {
            print("This view has a subscription named \(sub.name)")
        }
        
        if subs.first(named: allContactsSubName) != nil {
            print("A subscription to the Contact type already exists.")
        } else {
            print("No subscription to the Contact type exists.")
        }
        
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
