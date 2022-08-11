//
//  LoggedInView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct LoggedInView: View {
    @State private var showingContactForm = false
    @State private var showingContactList = false
    @State private var showingCollegesList = false
    
    var flexSyncConfig = app.currentUser!.flexibleSyncConfiguration { subs in
        if subs.first(named: "user_contacts") == nil {
            subs.append(QuerySubscription<Contact>(name: "user_contacts") { contact in
                contact.owner_id == app.currentUser!.id
            })
        }
        
        if subs.first(named: "all_colleges") == nil {
            subs.append(QuerySubscription<College>(name: "all_colleges"))
        }
        
        if subs.first(named: "user_info") == nil {
            subs.append(QuerySubscription<UserInfo>(name: "user_info") { info in
                info.owner_id == app.currentUser!.id
            })
        }
    }
    
    var body: some View {
        VStack(spacing: 10.0) {
            Button("Upload a Contact") {
                showingContactForm.toggle()
            }
            .sheet(isPresented: $showingContactForm) {
                UploadContactView().environment(\.realmConfiguration, flexSyncConfig)
            }
            Button("View Contacts List") {
                showingContactList.toggle()
                
            }
            .sheet(isPresented: $showingContactList) {
                ContactsListView().environment(\.realmConfiguration, flexSyncConfig)
            }
            Button("Choose a Team") {
                showingCollegesList.toggle()
            }
            .sheet(isPresented: $showingCollegesList) {
                CollegeListView().environment(\.realmConfiguration, flexSyncConfig)
            }
        }
        .navigationBarTitle("Peer2Power")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
