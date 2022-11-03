//
//  ChooseTeamView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 10/2/22.
//

import SwiftUI

struct ChooseTeamView: View {
    @State var school_name: String
    @Binding var selectedParty: Party
    
    @State private var teamScore: Int?
    @State private var teamMemberCount: Int?
    @Binding var teamID: String
    
    @State private var showingConfirmAlert = false
    @Binding var teamSelected: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            List {
                Picker("Party", selection: $selectedParty) {
                    ForEach(Party.allCases, id: \.self) { party in
                        Text(party.rawValue).tag(party)
                    }
                }
                .listRowBackground(Color("RowBackground"))
                
                if selectedParty != .selectParty {
                    Section {
                        VStack(alignment: .leading) {
                            if teamScore != 1 {
                                Text("Score: \(teamScore ?? 0) points")
                                    .font(.title2)
                            } else {
                                Text("Score: 1 point")
                                    .font(.title2)
                            }
                            Text("Members: \(teamMemberCount ?? 0)")
                                .font(.title2)
                        }
                        .listRowBackground(Color("RowBackground"))
                    } footer: {
                        if selectedParty != .selectParty {
                            HStack {
                                Spacer()
                                Button("Sign Up and Join Team") {
                                    showingConfirmAlert.toggle()
                                }
                                .controlSize(.large)
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 45)
                                Spacer()
                            }
                            .listRowBackground(Color("RowBackground"))
                        }
                    }
                }
            }
            .alert("Are you sure you want to join this team?", isPresented: $showingConfirmAlert) {
                Button("Cancel", role: .cancel, action: {})
                Button("Join") {
                    teamSelected.toggle()
                    dismiss()
                }
            } message: {
                Text("You won't be able to change teams after signing up.")
            }
            .onAppear(perform: {
                if selectedParty != .selectParty {
                    fetchTeamInfo()
                }
            })
            .onChange(of: selectedParty) { newValue in
                if newValue != .selectParty {
                    fetchTeamInfo()
                }
            }
            .listStyle(.plain)
            .background(Color("Background"))
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
            "database": "govlab",
            "dataSource": "production",
            "filter": ["school_name": school_name, "party": selectedParty.rawValue],
            "projection": ["_id": 1, "score": 1, "member_ids": 1]
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
            
            guard let id = team["_id"] as? String else { return }
            teamID = id
            
            guard let score = team["score"] as? Int else { return }
            teamScore = score
            
            guard let members = team["member_ids"] as? [String] else { return }
            teamMemberCount = members.count
        }
        
        task.resume()
    }
}
