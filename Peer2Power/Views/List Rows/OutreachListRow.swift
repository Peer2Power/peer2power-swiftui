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
            HStack {
                Text("\u{2022} Attempt logged: ")
                Spacer()
                TextDate(date: attempt.createdAt)
            }
            Text("\u{2022} \(attempt.volunteerStatus)")
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
