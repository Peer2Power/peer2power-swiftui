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
    
    var body: some View {
        VStack(spacing: 10.0) {
            Button("Upload a Contact") {
                showingContactForm.toggle()
            }
            .sheet(isPresented: $showingContactForm) {
                // FIXME: this code creating the flexible sync subscription isn't being executed. This MIGHT be the cause of the crash whenever the app attempts to write a new Contact to the database.
                let config = app.currentUser!.flexibleSyncConfiguration { subs in
                    if subs.first(named: "user_contacts") != nil {
                        print("A flexible sync subscription to Contact already exists.")
                        return
                    } else {
                        print("Creating flexible sync synscription for Contact...")
                        subs.append(QuerySubscription<Contact>(name: "user_contacts") {
                            $0.owner_id == app.currentUser!.id
                        })
                    }
                }
                
                UploadContactView().environment(\.realmConfiguration, config)
            }
            NavigationLink("View Contacts List") {
                ContactsListView()
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
