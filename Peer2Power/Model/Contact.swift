//
//  Contact.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import RealmSwift
import Foundation

class Contact: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var owner_id: String = ""
    @Persisted var team_id: String = ""
    
    @Persisted var name: String = ""
    @Persisted var email: String = ""
    
    @Persisted var ageBracket: String = "Select Age Bracket"
    @Persisted var relationship: String = "Select Relationship"
    @Persisted var volunteerLikelihood: String = "Select Likelihood"
    
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date?
}
