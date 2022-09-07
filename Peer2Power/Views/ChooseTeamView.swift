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
    
    @ObservedResults(Team.self) var teams
    
    @State private var selectedParty: Party = .selectParty
    @State private var showingConfirmAlert = false
    
    @State private var searchText = ""
    
    @Environment(\.realm) var realm
    
    var searchResults: Results<Team> {
        if searchText.isEmpty {
            return teams.sorted(byKeyPath: "school_name", ascending: true).distinct(by: [\Team.school_name])
        }
        
        return teams.where {
            $0.school_name.contains(searchText, options: .caseInsensitive)
        }.distinct(by: [\Team.school_name]).sorted(byKeyPath: "school_name", ascending: true)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults, id: \.self) { team in
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
            }
            .navigationBarTitle("Choose Your School")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Enter the name of your college")
    }
}

extension ChooseTeamView {
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
                
                print("The current user was added to an existing team.")
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
