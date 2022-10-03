//
//  Contact.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import Foundation
import RealmSwift

class Contact: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var ageBracket: String?

    @Persisted(indexed: true) var contact_id: ObjectId = ObjectId.generate()

    @Persisted var createdAt: Date = Date()

    @Persisted var email: String = ""
    
    @Persisted var group: Int?

    @Persisted var name: String = ""

    @Persisted var owner_id: String = ""

    @Persisted var relationship: String?

    @Persisted var updatedAt: Date?

    @Persisted var volunteerLikelihood: String?
}

