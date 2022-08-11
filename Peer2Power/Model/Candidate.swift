//
//  Candidate.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import RealmSwift
import Foundation

class Candidate: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var name: String = ""
    @Persisted var summary: String = ""
    @Persisted var party: Party = .independent
    @Persisted var portrait: Data?
}
