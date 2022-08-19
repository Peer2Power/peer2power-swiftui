//
//  Contact.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import RealmSwift

class Contact: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var owner_id: String = "" // TODO: get contacts to be tied to a team with team_id rather than an individual's owner_id
    
    @Persisted var name: String = ""
    @Persisted var email: String = ""
    
    @Persisted var ageBracket: String = "Select Age Bracket"
    @Persisted var relationship: String = "Select Relationship"
    @Persisted var volunteerLikelihood: String = "Select Likelihood"
}
