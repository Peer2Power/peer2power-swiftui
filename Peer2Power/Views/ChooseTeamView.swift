//
//  CollegeListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import SwiftUI
import RealmSwift
import SPAlert

struct DBTeam: Identifiable, Codable {
    let id: String
    let school_name: String
    let state: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id", school_name, state
    }
}

struct ChooseTeamView: View {
    @ObservedResults(Team.self) var teams
    @State private var dbTeams: [DBTeam] = [DBTeam]()
    @State private var states: [String] = [String]()
    
    @State private var selectedParty: Party = .selectParty
    @State private var showingConfirmAlert = false
    @State private var showingDidSignUpAlert = false
    
    @State private var searchText = ""
    
    @Environment(\.realm) private var realm
    @Environment(\.dismiss) private var dismiss
    
    /*
    var searchResults: Results<Team> {
        if searchText.isEmpty {
            return teams.sorted(by: \Team.school_name, ascending: true).distinct(by: [\Team.school_name])
        }
        
        return teams.where {
            $0.school_name.contains(searchText, options: .caseInsensitive)
        }.distinct(by: [\Team.school_name]).sorted(by: \Team.school_name, ascending: true)
    }
     */
    
    var searchResults: [DBTeam] {
        if searchText.isEmpty {
            return dbTeams
        }
        
        return dbTeams.filter { predTeam in
            return predTeam.school_name.contains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(states.filter({ predState in
                searchResults.contains { searchTeam in
                    searchTeam.state == predState
                }
            }), id: \.self) { state in
                Section {
                    ForEach(searchResults.filter({ predTeam in
                        predTeam.state == state
                    })) { team in
                        Text(team.school_name)
                    }
                } header: {
                    Text(state)
                }
            }
        }
        .onAppear(perform: fetchTeams)
        .navigationTitle("Choose Your School")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Enter the name of your school")
        .listStyle(.insetGrouped)
        /*
        List {
            ForEach(searchResults.distinct(by: [\Team.state]).sorted(by: \Team.state, ascending: true), id: \.self) { stateTeam in
                Section {
                    ForEach(searchResults.filter("state = %@", stateTeam.state)) { team in
                        NavigationLink {
                            List {
                                Picker("Party", selection: $selectedParty) {
                                    ForEach(Party.allCases, id: \.self) { party in
                                        Text(party.rawValue).tag(party)
                                    }
                                }
                                .toolbar {
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Choose") {
                                            showingConfirmAlert.toggle()
                                        }
                                        .disabled(selectedParty == .selectParty)
                                        .alert("Are you sure you want to join this team?", isPresented: $showingConfirmAlert) {
                                            Button(role: .cancel, action: {}) {
                                                Text("Cancel")
                                            }
                                            Button("Choose") {
                                                handleTeamSelection(for: team.school_name)
                                            }
                                        } message: {
                                            Text("You won't be able to change your team after joining.")
                                        }
                                    }
                                }
                            }
                            .navigationBarTitle("Choose Your Party")
                        } label: {
                            Text("\(team.school_name)")
                        }
                    }
                } header: {
                    Text("\(stateTeam.state)")
                }
            }
        }
        .navigationTitle("Choose Your School")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Enter the name of your school")
        .onAppear(perform: fetchTeams)
        .listStyle(.insetGrouped)
        .SPAlert(isPresent: $showingDidSignUpAlert,
                 title: "Points Received!",
                 message: "Your team received 1 points because you signed up!",
                 duration: 4,
                 dismissOnTap: true,
                 preset: .done,
                 haptic: .success,
                 layout: nil) {
            dismiss()
        } */
    }
}

extension ChooseTeamView {
    private func fetchTeams() {
        guard let url = URL(string: "\(mongoDataEndpoint)action/find") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(mongoDataAPIKey, forHTTPHeaderField: "api-key")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Request-Headers")
        
        let bodyJSON: [String: Any] = [
            "collection": "Team",
            "database": "peer2power",
            "dataSource": "prod",
            "limit": 5000,
            "sort": ["state": 1],
            "projection": ["_id": 1, "school_name": 1, "state": 1]
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
            
            guard let teams = responseJSON["documents"] as? [[String: Any]] else { return }
            
            teams.forEach { team in
                guard let id = team["_id"] as? String else { return }
                guard let school_name = team["school_name"] as? String else { return }
                guard let state = team["state"] as? String else { return }
                
                let schoolAlreadyIn = dbTeams.contains { predTeam in
                    predTeam.school_name == school_name
                }
                
                if !schoolAlreadyIn {
                    let arrTeam = DBTeam(id: id, school_name: school_name, state: state)
                    dbTeams.append(arrTeam)
                }
                
                let stateAlreadyIn = states.contains { predState in
                    state == predState
                }
                
                if !stateAlreadyIn {
                    states.append(state)
                }
            }
        }
        
        task.resume()
    }
    
    private func handleTeamSelection(for schoolName: String) {
        let filteredTeams = teams.where {
            $0.party == selectedParty && $0.school_name == schoolName
        }
        
        guard !filteredTeams.isEmpty else { return }
        
        guard let currentUser = app.currentUser else { return }

        print("A team already exists for this school and party.")
        
        guard let team = filteredTeams.first?.thaw() else { return }
        
        do {
            try realm.write {
                team.member_ids.append(currentUser.id)
                team.score += 1
                
                print("The current user was added to an existing team.")
                showingDidSignUpAlert.toggle()
            }
        } catch {
            print("Error adding user to team: \(error.localizedDescription)")
        }
    }
}
 
struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseTeamView()
    }
}
