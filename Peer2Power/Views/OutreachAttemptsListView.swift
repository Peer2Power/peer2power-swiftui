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
    
    // FIXME: Here's how to do this. Pass in a flexible sync subscription with some title. This subscription should then be removed before this view disappears (in the onDisappear modifier). That way, you can keep adding subscriptions for each contact.
    
    var body: some View {
        
        
        List {
            
        }
        .navigationTitle(contact.name)
    }
}

struct OutreachAttemptsListView_Previews: PreviewProvider {
    static var previews: some View {
        OutreachAttemptsListView(contact: Contact(), team: Team())
    }
}
