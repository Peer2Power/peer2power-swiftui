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
    
    @State private var presentingOutreachForm = false
    
    // FIXME: Here's how to do this. Pass in a flexible sync subscription with some title. This subscription should then be removed before this view disappears (in the onDisappear modifier). That way, you can keep adding subscriptions for each contact.
    
    var body: some View {
        if team.outreachAttempts.isEmpty {
            VStack(spacing: 10.0) {
                Text("No Outreach Attempts Logged")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("Your team hasn't logged any attempts to get this contact to volunteer yet. Talk to them using your contact method of choice, then come back here to log how the interaction went.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Button {
                    presentingOutreachForm.toggle()
                } label: {
                    Label("Log Outreach Attempt", systemImage: "square.and.pencil")
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $presentingOutreachForm) {
                    LogOutreachView()
                }
            }
        } else {
            List {
                ForEach(team.outreachAttempts) { attempt in
                    Text("Here's an outreach attempt")
                }
            }
            .navigationTitle(contact.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct OutreachAttemptsListView_Previews: PreviewProvider {
    static var previews: some View {
        OutreachAttemptsListView(contact: Contact(), team: Team())
    }
}
