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
    @State private var fetchingTeams = true
    @State private var fetchProgress: Double = 0
    
    @State private var dbTeams: [DBTeam] = [DBTeam]()
    
    @State private var searchText = ""
    
    @State private var showingLoginSheet = false
    @State private var showingSignUpSheet = false
    
    @State private var selectedTeamID = ""
    
    @State private var showingJoinedTeamBanner = false
    @State private var showingResendConfirmView = false
    @State private var showingConfirmLogOutAlert = false
    @State private var showingConfirmTeamSelectionAlert = false
    
    @MainActor var searchResults: [DBTeam] {
        if searchText.isEmpty {
            return dbTeams.sorted { $0.name.uppercased() < $1.name.uppercased() }
        }
        
        return dbTeams.sorted { $0.name.uppercased() < $1.name.uppercased() }.filter { predTeam in
            return predTeam.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @MainActor var letters: [String] {
        var result = [String]()
        
        if searchText.isEmpty {
            for team in dbTeams {
                guard let first = team.name.first else { return [String]() }
                let charSequence = [first]
                let firstString = String(charSequence).uppercased()
                
                if !result.contains(firstString) {
                    result.append(firstString)
                }
            }
            
            return result
        }
        
        for searchResult in searchResults {
            guard let first = searchResult.name.first else { return [String]() }
            let charSequence = [first]
            let firstString = String(charSequence)
            
            if !result.contains(firstString) {
                result.append(firstString)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack {
            List {
                if !searchResults.isEmpty {
                    ForEach(letters.filter({ predLetter in
                        searchResults.contains { searchTeam in
                            searchTeam.name.first?.uppercased() == predLetter.first?.uppercased()
                        }
                    }), id: \.self) { letter in
                        Section {
                            ForEach(searchResults.filter({ predTeam in
                                predTeam.name.first?.uppercased() == letter.first?.uppercased()
                            })) { team in
                                Button(team.name) {
                                    selectedTeamID = team.id
                                    handleTeamSelected(team: team)
                                }
                            }
                        } header: {
                            Text(letter)
                        }
                    }
                } else {
                    if fetchingTeams {
                        HStack {
                            Spacer()
                            ProgressView {
                                Text("Fetching teams...")
                            }
                            Spacer()
                        }
                    } else {
                        VStack(spacing: 10.0) {
                            Text("No Teams Found")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 15)
                            Text("No teams could be found. Please change your search terms and try again.")
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 15)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationViewStyle(.columns)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a club to sign up for")
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
            .alert("Are you sure you want to log out?", isPresented: $showingConfirmLogOutAlert, actions: {
                Button("Cancel", role: .cancel, action: {})
                Button("Log Out", role: .destructive) {
                    if let currentUser = app.currentUser {
                        currentUser.logOut(completion: { error in
                            if error == nil {
                                print("Logged the current user out successfully.")
                            } else {
                                print("An error occurred while logging out the user: \(error?.localizedDescription)")
                            }
                        })
                    }
                }
            })
            .alert("Are you sure you want to join \(selectedTeamName)?", isPresented: $showingConfirmTeamSelectionAlert, actions: {
                Button("Cancel", role: .cancel, action: {})
                Button("Join") {
                    do {
                        let objectId = try ObjectId(string: selectedTeamID)
                        
                        getRealmToAddUserToTeam(with: objectId)
                    } catch {
                        print("Error creating object ID: \(error.localizedDescription)")
                    }
                }
            }, message: {
                Text("You won't be able to change your team after you join.")
            })
            .toast(isPresenting: $showingJoinedTeamBanner) {
                AlertToast(displayMode: .banner(.pop),
                           type: .complete(Color(.systemGreen)),
                           title: "Points Received!",
                           subTitle: "Your team received 1 point!")
            }
            if app.currentUser == nil {
                if UserDefaults.standard.string(forKey: "joinTeamID") != nil {
                    Button("Resend Confirmation Email") {
                        showingResendConfirmView.toggle()
                    }
                    .sheet(isPresented: $showingResendConfirmView) {
                        ResetOrResendView(currentAction: .constant(.resendConfirmation))
                    }
                }
                Button("Already have an account or just confirmed your email address? Login.") {
                    showingLoginSheet.toggle()
                }
                .padding(.horizontal, 15)
            } else {
                Button("Log Out", role: .destructive) {
                    showingConfirmLogOutAlert.toggle()
                }
            }
        }
        .onAppear(perform: fetchTeams)
    }
}

extension ClubsListView {
    private func fetchTeams() {
        guard dbTeams.isEmpty else { return }
        
        guard let url = URL(string: "\(mongoDataEndpoint)/action/find") else { return }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(mongoDataAPIKey, forHTTPHeaderField: "api-key")
        request.setValue("*", forHTTPHeaderField: "Access-Control-Request-Headers")
        
        let bodyJSON: [String: Any] = [
            "collection": "Team",
            "database": "govlab",
            "dataSource": "Demo",
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
            print("Got \(teams.count) teams.")
            
            teams.forEach { team in
                guard let id = team["_id"] as? String else { return }
                guard let name = team["name"] as? String else { return }
                
                let toInsert = DBTeam(id: id, name: name)
                
                guard !dbTeams.contains(where: { predTeam in
                    predTeam.id == id
                }) else { return }
                dbTeams.append(toInsert)
            }
            
            fetchingTeams = false
        }
        
        task.resume()
    }
    
    func handleTeamSelected(team: DBTeam) {
        guard app.currentUser != nil && app.currentUser?.state == .loggedIn else {
            showingSignUpSheet.toggle()
            return
        }
        
        showingConfirmTeamSelectionAlert.toggle()
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
    
    private var selectedTeamName: String {
        guard !selectedTeamID.isEmpty else { return "" }
        guard !dbTeams.isEmpty else { return "" }
        
        guard let selectedTeam = dbTeams.first(where: { team in
            return team.id == selectedTeamID
        }) else { return "" }
        
        return selectedTeam.name
    }
}
 
struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        ClubsListView()
    }
}
