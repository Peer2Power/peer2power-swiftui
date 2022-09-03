//
//  ContactListRow.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/3/22.
//

import SwiftUI
import RealmSwift

struct ContactListRow: View {
    @ObservedRealmObject var contact: Contact
    @ObservedRealmObject var team: Team
    
    var body: some View {
        HStack {
            Text("\(contact.name)")
                .font(.title2)
            Spacer()
            Text("\(team.outreachAttempts.count) outreach attempts")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

struct ContactListRow_Previews: PreviewProvider {
    static var previews: some View {
        ContactListRow(
            contact: Contact(
                value: [
                    "name": "John Doe"
                ]),
            team: Team())
    }
}
