//
//  ContactsListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct ContactsListView: View {
    @AsyncOpen(appId: realmAppID, timeout: 4000) var asyncOpen
    
    @ObservedResults(Contact.self) var contacts
    
    var body: some View {
        switch asyncOpen {
        case .connecting:
            ProgressView()
        case .waitingForUser:
            ProgressView("Waiting for user to log in...")
        case .open(let realm):
            List {
                if contacts.isEmpty {
                    Text("Add some contacts")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                ForEach(contacts) { contact in
                    Text("\(contact.name)")
                }
            }
            .onAppear {
                let subscriptions = realm.subscriptions
                subscriptions.update {
                    if subscriptions.first(named: "user_contacts") != nil {
                        print("Contact subscription already exists.")
                        return
                    } else {
                        print("Appending new Contact subscription.")
                        subscriptions.append(QuerySubscription<Contact>(name: "user_contacts") { contact in
                            contact.owner_id == app.currentUser!.id
                        })
                    }
                }
            }
        case .progress(let progress):
            ProgressView(progress)
        case .error(let error):
            ErrorView(error: error, retryAction: {})
        }
    }
}

struct ContactsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsListView()
    }
}
