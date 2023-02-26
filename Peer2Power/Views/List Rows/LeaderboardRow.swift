//
//  LeaderboardRow.swift
//  Peer2Power
//
//  Created by Deja Jackson on 1/10/23.
//

import SwiftUI
import RealmSwift

struct LeaderboardRow: View {
    @Environment(\.realm) private var realm
    
    @ObservedRealmObject var team: Team
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center, spacing: 10.0) {
                Text(rankNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(team.name)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                    
                    if team.member_ids.contains(where: { id in
                        return id == app.currentUser?.id
                    }) {
                        Text("Your Team".uppercased())
                            .foregroundColor(Color(.systemBlue))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            Spacer()
            Text(team.score == 1 ? "1 point" : "\(team.score) points")
                .font(.title3)
                .multilineTextAlignment(.trailing)
        }
    }
}

extension LeaderboardRow {
    private var rankNumber: String {
        guard let index = realm.objects(Team.self).sorted(by: \Team.score, ascending: false).firstIndex(where: { predTeam in
            predTeam._id == team._id
        }) else { return "" }
        
        return "\(index + 1). "
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
