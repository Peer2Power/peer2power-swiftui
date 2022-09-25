//
//  OutreachListRow.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/10/22.
//

import SwiftUI
import RealmSwift

struct OutreachListRow: View {
    @ObservedRealmObject var attempt: OutreachAttempt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            if let method = attempt.contactMethod {
                Text("This person was contacted via: \(method)")
            }
            if let desc = attempt.attemptDescription {
                Text("This attempt was described as: \(desc)")
            }
            Text("Asked whether this person had volunteered, the person who logged this attempt said: \(attempt.volunteerStatus)")
        }
    }
}

struct OutreachListRow_Previews: PreviewProvider {
    static var previews: some View {
        OutreachListRow(attempt: OutreachAttempt(value: [
            "contactMethod": "Text",
            "attemptDescription": "Boof",
            "volunteerStatus": "I'm still working on them.",
            "volunteerMethod": nil
        ]))
    }
}
