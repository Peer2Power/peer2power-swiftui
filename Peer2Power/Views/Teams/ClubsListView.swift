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

struct ClubsListView: View {
    @State private var dbTeams: [DBTeam] = [DBTeam]()
    
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
                        Button(result.name) {
                            handleTeamSelected(team: result)
                        }
                    }
                }
                .id(UUID())
                .navigationTitle(app.currentUser == nil ? "Sign Up": "Choose a Team")
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
                if app.currentUser == nil {
                    Button("Already have an account or just confirmed your email address? Login.") {
                        showingLoginSheet.toggle()
                    }
                    .padding(.horizontal, 15)
                }
            } else {
                Text("No Teams Found")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                Text("No teams could be found. Please check your internet connection and try again.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
            }
        }
        .onAppear(perform: fetchTeams)
    }
}

extension ClubsListView {
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
            "limit": 250,
            "sort": ["name": 1],
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
    
    func handleTeamSelected(team: DBTeam) {
        guard app.currentUser != nil && app.currentUser?.state == .loggedIn else {
            showingSignUpSheet.toggle()
            return
        }
        
        do {
            let objectId = try ObjectId(string: team.id)
            
            getRealmToAddUserToTeam(with: objectId)
        } catch {
            print("Error creating object ID: \(error.localizedDescription)")
        }
    }
    
    func getRealmToAddUserToTeam(with id: ObjectId) {
        guard let currentUser = app.currentUser else { return }
        
        Realm.asyncOpen(configuration: currentUser.flexibleSyncConfiguration()) { result in
            switch result {
            case .success(let realm):
                let subs = realm.subscriptions
                let foundSub = subs.first(named: allTeamsSubName)
                
                subs.update {
                    if foundSub == nil {
                        subs.append(QuerySubscription<Team>(name: allTeamsSubName))
                    }
                } onComplete: { error in
                    guard error == nil else {
                        print("Error appending subscription: \(error?.localizedDescription)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        addUserToTeam(user: currentUser, using: realm, to: id)
                    }
                }
            case .failure(let error):
                print("Error opening realm: \(error.localizedDescription)")
            }
        }
    }
    
    func addUserToTeam(user: User, using realm: Realm, to id: ObjectId) {
        guard let team = realm.object(ofType: Team.self, forPrimaryKey: id) else {
            print("The team could not be found.")
            return
        }
        print("Found a team with ID \(team._id.stringValue)")
        
        do {
            try realm.write {
                team.member_ids.append(user.id)
                print("Added the current user to a team.")
                
                awardPointForSignUp(to: team)
            }
        } catch {
            print("Error writing to realm: \(error.localizedDescription)")
        }
    }
    
    func awardPointForSignUp(to team: Team) {
        team.score += 1
        showingJoinedTeamBanner.toggle()
    }
}
 
struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        ClubsListView()
    }
}
