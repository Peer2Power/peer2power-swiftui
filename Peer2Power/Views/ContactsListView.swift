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
        List {
            if (contacts.isEmpty) {
                Text("Add some contacts")
                    .foregroundColor(.gray)
            }
            ForEach(contacts) { contact in
                Text("\(contact.name)")
            }.onDelete(perform: $contacts.remove)
        }
    }
}

struct ContactsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsListView()
    }
}
