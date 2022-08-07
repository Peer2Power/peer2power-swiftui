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
    
    var flexSyncConfig = app.currentUser!.flexibleSyncConfiguration { subs in
        if subs.first(named: "user_contacts") != nil {
            print("A Contact subscription already exists.")
        } else {
            print("Appending a new subscription for Contact...")
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
                UploadContactView().environment(\.realmConfiguration, flexSyncConfig)
            }
            NavigationLink("View Contacts List") {
                ContactsListView().environment(\.realmConfiguration, flexSyncConfig)
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
