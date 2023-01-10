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
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id", name
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
            return predTeam.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack {
            if !searchResults.isEmpty {
                List {
                    ForEach(searchResults) { result in
                        Text(result.name)
                    }
                }
                .id(UUID())
                .onAppear(perform: fetchTeams)
                .navigationTitle("Sign Up")
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a club to sign up for")
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
                Button("Already part of a team or just confirmed your email address? Login.") {
                    showingLoginSheet.toggle()
                }
            } else {
                Text("No Teams Found")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("No teams could be found. Please check your internet connection and try again.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 15)
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
            "projection": ["_id": 1, "name": 1]
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
                guard let name = team["name"] as? String else { return }
                
                let toInsert = DBTeam(id: id, name: name)
                dbTeams.append(toInsert)
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
