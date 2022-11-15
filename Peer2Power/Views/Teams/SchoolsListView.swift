//
//  CollegeListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import SwiftUI
import RealmSwift
import AlertToast

struct DBTeam: Identifiable, Codable {
    let id: String
    let school_name: String
    let state: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id", school_name, state
    }
}

struct SchoolsListView: View {
    @State private var dbTeams: [DBTeam] = [DBTeam]()
    @State private var states: [String] = [String]()
    
    @State private var searchText = ""
    
    @State private var showingLoginSheet = false
    @State private var showingSignUpSheet = false
    
    @State private var selectedTeamID = ""
    @State private var selectedParty: Party = .selectParty
    
    @State private var showingJoinedTeamBanner = false
    
    @MainActor var searchResults: [DBTeam] {
        if searchText.isEmpty {
            return dbTeams
        }
        
        return dbTeams.filter { predTeam in
            return predTeam.school_name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack {
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
                            NavigationLink {
                                ChooseTeamView(school_name: team.school_name,
                                               selectedParty: $selectedParty,
                                               teamID: $selectedTeamID,
                                               teamSelected: $showingSignUpSheet)
                            } label: {
                                Text(team.school_name)
                            }
                        }
                    } header: {
                        Text(state)
                    }
                }
            }
            .onAppear(perform: fetchTeams)
            .navigationTitle("Sign Up")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a school to sign up under")
            .autocorrectionDisabled(true)
            .listStyle(.insetGrouped)
            .sheet(isPresented: $showingLoginSheet) {
                NavigationView {
                    LoginView(showingJoinedTeamAlert: $showingJoinedTeamBanner)
                }
            }
            .sheet(isPresented: $showingSignUpSheet, content: {
                NavigationView {
                    SignUpView(team_id: $selectedTeamID,
                               teamSelected: $showingLoginSheet)
                }
            })
            .toast(isPresenting: $showingJoinedTeamBanner) {
                AlertToast(displayMode: .banner(.pop),
                           type: .complete(Color(uiColor: .systemGreen)),
                           title: "Points Received!",
                           subTitle: "Your team received 1 point!")
            }
            Button("Already part of a team? Login.") {
                showingLoginSheet.toggle()
            }
        }
    }
}

extension SchoolsListView {
    private func fetchTeams() {
        guard let url = URL(string: "\(mongoDataEndpoint)action/find") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(mongoDataAPIKey, forHTTPHeaderField: "api-key")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Request-Headers")
        
        let bodyJSON: [String: Any] = [
            "collection": "Team",
            "database": "govlab",
            "dataSource": "production",
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
}
 
struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        SchoolsListView()
    }
}
