//
//  OutreachListRow.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/10/22.
//

import SwiftUI
import RealmSwift
import Foundation

struct OutreachListRow: View {
    @ObservedRealmObject var attempt: OutreachAttempt
    
    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        HStack(alignment: .center) {
            Text(attempt.volunteerStatus)
            Spacer()
            Label(generateDateText(for: attempt.createdAt), systemImage: "clock")
        }
    }
}

extension OutreachListRow {
    private func generateDateText(for date: Date) -> String {
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(fromTimeInterval: date.timeIntervalSinceNow)
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
