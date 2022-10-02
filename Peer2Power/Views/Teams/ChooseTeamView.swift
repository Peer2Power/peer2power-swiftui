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
                Section {
                    VStack(alignment: .leading) {
                        Text("Score: \(teamScore ?? 0) points")
                        Text("Members: \(teamMemberCount ?? 0)")
                    }
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
        guard let url = URL(string: "\(mongoDataEndpoint)action/findOne") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(mongoDataAPIKey, forHTTPHeaderField: "api-key")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Request-Headers")
        
        let bodyJSON: [String: Any] = [
            "collection": "Team",
            "database": "peer2power",
            "dataSource": "prod",
            "filter": ["school_name": school_name, "party": selectedParty.rawValue],
            "projection": ["_id": 0, "score": 1, "member_ids": 1]
        ]
        let bodyData = try? JSONSerialization.data(withJSONObject: bodyJSON)
        
        request.httpBody = bodyData
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data)
            guard let responseJSON = responseJSON as? [String: Any] else { return }
            print(responseJSON)
            
            guard let team = responseJSON["document"] as? [String: Any] else { return }
            
            guard let score = team["score"] as? Int else { return }
            teamScore = score
            
            //FIXME: figure out how member ids would be represented
            guard let members = team["member_ids"] as? [String] else { return }
            teamMemberCount = members.count
        }
        
        task.resume()
    }
}

struct ChooseTeamView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseTeamView(school_name: "Lafayette College")
    }
}
