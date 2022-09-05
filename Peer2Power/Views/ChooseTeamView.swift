//
//  CollegeListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import SwiftUI
import RealmSwift

struct ChooseTeamView: View {
    @Environment (\.dismiss) var dismiss
    
    @ObservedResults(
        College.self,
        sortDescriptor: SortDescriptor(keyPath: "name", ascending: true))
    var colleges
    @ObservedResults(Team.self) var teams
    
    @State private var selectedParty: Party = .selectParty
    @State private var showingConfirmAlert = false
    
    @State private var searchText = ""
    
    @Environment(\.realm) var realm
    
    var searchResults: Results<College> {
        if searchText.isEmpty {
            return colleges
        }
        
        return colleges.where {
            $0.name.contains(searchText, options: .caseInsensitive)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults, id: \.self) { college in
                    NavigationLink {
                        List {
                            Picker("Party", selection: $selectedParty) {
                                Text("Democratic").tag(Party.democrat)
                                Text("Republican").tag(Party.republican)
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
                                            handleTeamSelection(college: college)
                                        }
                                    } message: {
                                        Text("You won't be able to change your team after joining.")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("\(college.name)")
                    }
                }
            }
            .navigationBarTitle("Choose Your School")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Enter the name of your college")
    }
}

extension ChooseTeamView {
    private func handleTeamSelection(college: College) {
        let filteredTeams = teams.where {
            $0.party == selectedParty && $0.school_id == college._id.stringValue
        }
        
        guard let currentUser = app.currentUser else { return }

        if filteredTeams.isEmpty {
            print("No team exists for this school and party.")
            
            
            
            let newTeam = Team()
            newTeam.school_id = college._id.stringValue
            newTeam.member_ids.append(currentUser.id)
            newTeam.party = selectedParty
            
            $teams.append(newTeam)
        } else {
            print("A team already exists for this school and party.")
            
            guard let team = filteredTeams.first?.thaw() else { return }
            
            do {
                try realm.write {
                    team.member_ids.append(currentUser.id)
                    
                    print("The current user was added to an existing team.")
                }
            } catch {
                print("Error adding user to team: \(error.localizedDescription)")
            }
        }
    }
}
 
struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseTeamView()
    }
}
