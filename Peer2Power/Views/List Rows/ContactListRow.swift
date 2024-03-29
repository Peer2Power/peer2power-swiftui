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
    
    // @State private var showingEditContactForm = false
    
    var body: some View {
        HStack {
            HStack {
                Text("\(contact.name)")
                    .font(.title2)
                    .minimumScaleFactor(0.25)
                /* if !team.outreachAttempts.filter("to = %@", contact.contact_id).filter("volunteerStatus = %@", theyVolunteeredText).isEmpty || !team.endOfStudyResponses.filter("%@ in contact_ids", contact.contact_id.stringValue).isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical, 15.0)
                        .frame(maxHeight: 60)
                        .foregroundColor(.accentColor)
                } */
            }
            
            Spacer()
            Text("\(populateCountLabel())")
                .font(.title3)
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.25)
        }
        // TODO: get editing contact info working.
        /* .sheet(isPresented: $showingEditContactForm) {
            UploadContactView(userTeam: team, contact: contact, isPastCloseDate: .constant(true))
        } */
    }
}

extension ContactListRow {
    private func populateCountLabel() -> String {
        let attemptCount = team.outreachAttempts.filter("to = %@", contact.contact_id).count
        var countText = ""
        
        if attemptCount == 1 {
            countText = "1 outreach attempt"
        } else {
            countText = "\(attemptCount) outreach attempts"
        }
        
        return countText
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
