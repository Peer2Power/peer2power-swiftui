//
//  OutreachAttemptsListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/25/22.
//

import SwiftUI
import RealmSwift

struct OutreachAttemptsListView: View {
    @ObservedRealmObject var contact: Contact
    @ObservedRealmObject var team: Team
    
    @State private var presentingLogOutreachForm = false
    
    var body: some View {
        if team.outreachAttempts.filter("to = %@", contact.contact_id).isEmpty {
            VStack(spacing: 10.0) {
                Text("No Outreach Attempts Logged")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("Your team hasn't logged any attempts to get this contact to volunteer yet. Talk to them using your contact method of choice, then return here to log how the interaction went.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
            .padding([.leading, .trailing], 15.0)
        } else {
            List {
                ForEach(team.outreachAttempts.filter("to = %@", contact.contact_id)) { attempt in
                    OutreachListRow(attempt: attempt)
                }
            }
            .navigationTitle(contact.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        Button {
            presentingLogOutreachForm.toggle()
        } label: {
            Label("Log Outreach Attempt", systemImage: "square.and.pencil")
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $presentingLogOutreachForm) {
            LogOutreachView(contact: contact, team: team)
        }
    }
}
