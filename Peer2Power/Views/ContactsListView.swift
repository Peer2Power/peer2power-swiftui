//
//  ContactsListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct ContactsListView: View {
    
    @ObservedRealmObject var userTeam: Team
    @Environment (\.realm) var realm
    
    var body: some View {
        NavigationView {
            List {
                if (userTeam.contacts.isEmpty) {
                    Text("Add some contacts")
                        .foregroundColor(.gray)
                }
                ForEach(userTeam.contacts) { contact in
                    NavigationLink {
                        OutreachAttemptsListView(contact: contact)
                    } label: {
                        Text("\(contact.name)")
                    }
                }
                .onDelete(perform: $userTeam.contacts.remove)
            }
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            let subs = realm.subscriptions
        }
    }
}

struct ContactsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsListView(userTeam: Team())
    }
}
