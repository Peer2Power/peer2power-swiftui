//
//  ChooseTeamViewModel.swift
//  Peer2Power
//
//  Created by Deja Jackson on 11/9/22.
//

import Foundation

class ChooseTeamViewModel: ObservableObject {
    static let shared: ChooseTeamViewModel = .init()
    
    @Published var selectedTeamID = ""
    @Published var teamSelected = false
    @Published var selectedParty = ""
    @Published var selectedSchoolName = ""
}
