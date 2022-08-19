//
//  TeamView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/17/22.
//

import SwiftUI
import RealmSwift

struct TeamView: View {
    @State private var teamText = ""
    @State private var scoreText = ""
    
    @ObservedResults(UserInfo.self) var userGoodies
    @ObservedResults(College.self) var schools
    @ObservedResults(Team.self) var teams
    
    var body: some View {
        VStack(spacing: 10.0) {
            Text(teamText)
                .font(.title2)
                .multilineTextAlignment(.center)
            Text(scoreText)
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .onAppear(perform: fetchTeam)
    }
}

extension TeamView {
    private func fetchTeam() {
        Task {
            guard let userInfo = userGoodies.first else {
                print("The user's goody could not be found.")
                return
            }
            
            do {
                let teamID = try ObjectId(string: userInfo.team_id)
                let teamQuery = teams.where {
                    $0._id == teamID
                }
                
                guard let userTeam = teamQuery.first else {
                    print("The user's team could not be found.")
                    return
                }
                
                let schoolID = try ObjectId(string: userTeam.school_id)
                let schoolQuery = schools.where {
                    $0._id == schoolID
                }
                
                guard let userSchool = schoolQuery.first else {
                    print("The user's school could not be found.")
                    return
                }
                
                var partyText: String
                switch userTeam.party {
                case .democrat:
                    partyText = "College Democrats"
                case .republican:
                    partyText = "College Republicans"
                case .selectParty:
                    partyText = "Select Party"
                }
                
                teamText = "You are a part of the \(userSchool.name) \(partyText)."
                scoreText = "Your team has a score of \(userTeam.score)."
            } catch {
                print("An error occurred while forming the ObjectId: \(error.localizedDescription)")
                return
            }
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView()
    }
}
