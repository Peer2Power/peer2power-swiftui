//
//  Team.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/13/22.
//

import Foundation
import RealmSwift

class Team: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var school_id: String = ""
    
    @Persisted var party: Party = .democrat
}
