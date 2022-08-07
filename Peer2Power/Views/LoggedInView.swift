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
    
    var contactsFlexSyncConfig = app.currentUser!.flexibleSyncConfiguration { subs in
        if subs.first(named: "user_contacts") == nil {
            subs.append(QuerySubscription<Contact>(name: "user_contacts") { contact in
                contact.owner_id == app.currentUser!.id
            })
        }
    }
    
    var body: some View {
        VStack(spacing: 10.0) {
            Button("Upload a Contact") {
                showingContactForm.toggle()
            }
            .sheet(isPresented: $showingContactForm) {
                UploadContactView().environment(\.realmConfiguration, contactsFlexSyncConfig)
            }
            Button("View Contacts List") {
                showingContactList.toggle()
                
            }
            .sheet(isPresented: $showingContactList) {
                ContactsListView().environment(\.realmConfiguration, contactsFlexSyncConfig)
            }
            Button("Choose a Team") {
                showingCollegesList.toggle()
            }
            .sheet(isPresented: $showingCollegesList) {
                CollegeListView().environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration())
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
