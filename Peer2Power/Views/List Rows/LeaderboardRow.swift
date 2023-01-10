//
//  LeaderboardRow.swift
//  Peer2Power
//
//  Created by Deja Jackson on 1/10/23.
//

import SwiftUI
import RealmSwift

struct LeaderboardRow: View {
    @ObservedRealmObject var team: Team
    
    var body: some View {
        HStack {
            Text(team.name)
                .font(.title2)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(team.score == 1 ? "1 point" : "\(team.score) points")
                .font(.title3)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct LeaderboardRow_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardRow(team: Team(value: [
            "name": "Open Debate Club",
            "score": 1
        ]))
    }
}
