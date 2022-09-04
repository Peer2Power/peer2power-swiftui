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
    
    @State private var countText = ""
    
    var body: some View {
        HStack {
            Text("\(contact.name)")
                .font(.title2)
            Spacer()
            Text(countText)
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .onAppear(perform: populateCountLabel)
    }
}

extension ContactListRow {
    private func populateCountLabel() {
        let attemptCount = team.outreachAttempts.filter("to = %@", contact.contact_id).count
        
        if attemptCount == 1 {
            countText = "1 outreach attempt"
        } else {
            countText = "\(attemptCount) outreach attempts"
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
