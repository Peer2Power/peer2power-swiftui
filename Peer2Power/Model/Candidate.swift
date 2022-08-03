//
//  Candidate.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import RealmSwift
import Foundation

enum CandidateParty: String, PersistableEnum {
    case independent
    case democrat
    case republican
}

class Candidate: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var name: String = ""
    @Persisted var summary: String = ""
    @Persisted var party: CandidateParty = .independent
    @Persisted var portrait: Data?
}
