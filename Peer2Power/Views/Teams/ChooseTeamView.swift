//
//  ChooseTeamView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 10/2/22.
//

import SwiftUI

struct ChooseTeamView: View {
    @State var school_name: String
    @State private var selectedParty: Party = .selectParty
    
    @State private var teamScore: Int?
    @State private var teamMemberCount: Int?
    
    var body: some View {
        List {
            Picker("Party", selection: $selectedParty) {
                ForEach(Party.allCases, id: \.self) { party in
                    Text(party.rawValue).tag(party)
                }
            }
            
            if selectedParty != .selectParty {
                VStack {
                    Text("Score: \(teamScore ?? 0) points")
                    Text("Members: \(teamMemberCount ?? 0)")
                }
            }
        }
        .onChange(of: selectedParty) { newValue in
            if newValue != .selectParty {
                fetchTeamInfo()
            }
        }
    }
}

extension ChooseTeamView {
    private func fetchTeamInfo() {
        
    }
}

struct ChooseTeamView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseTeamView(school_name: "Lafayette College")
    }
}
