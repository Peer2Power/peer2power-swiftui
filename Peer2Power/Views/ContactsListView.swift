//
//  ContactsListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct ContactsListView: View {
    
    @ObservedResults(Contact.self) var contacts
    @Environment (\.realm) var realm
    
    var body: some View {
        NavigationView {
            List {
                if (contacts.isEmpty) {
                    Text("Add some contacts")
                        .foregroundColor(.gray)
                }
                ForEach(contacts) { contact in
                    NavigationLink {
                        OutreachAttemptsListView(contact: contact)
                    } label: {
                        Text("\(contact.name)")
                    }
                }
                .onDelete(perform: $contacts.remove)
            }
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            let subs = realm.subscriptions
            
            if (subs.first(ofType: Contact.self, where: { contact in
                contact.owner_id == app.currentUser!.id
            }) != nil) {
                print("A subscription to the Contact type already exists.")
                print("There are \(contacts.count) contacts.")
            } else {
                print("A subscription to the Contact type does not exist.")
            }
        }
    }
}

struct ContactsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsListView()
    }
}
