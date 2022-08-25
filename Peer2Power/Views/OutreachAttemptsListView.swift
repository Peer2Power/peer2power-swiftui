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
    
    @ObservedResults(
        OutreachAttempt.self,
        sortDescriptor: SortDescriptor(keyPath: "createdAt", ascending: true))
    var outreachAttempts
    
    var body: some View {
        
        
        List {
            
        }
        .navigationTitle(contact.name)
    }
}

struct OutreachAttemptsListView_Previews: PreviewProvider {
    static var previews: some View {
        OutreachAttemptsListView(contact: Contact())
    }
}
