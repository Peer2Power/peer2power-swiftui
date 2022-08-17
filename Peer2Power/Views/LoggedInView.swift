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
        if subs.first(named: contactSubName) == nil {
            subs.append(QuerySubscription<Contact>(name: contactSubName) { contact in
                contact.owner_id == app.currentUser!.id
            })
        }
        
        if subs.first(named: collegeSubName) == nil {
            subs.append(QuerySubscription<College>(name: collegeSubName))
        }
        
        if subs.first(named: teamSubName) == nil {
            subs.append(QuerySubscription<Team>(name: teamSubName))
        }
        
        if subs.first(named: userInfoSubName) == nil {
            subs.append(QuerySubscription<UserInfo>(name: userInfoSubName) { info in
                info.owner_id == app.currentUser!.id
            })
        }
        
        return
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
            NavigationLink("View Your Team") {
                TeamView().environment(\.realmConfiguration, flexSyncConfig)
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
