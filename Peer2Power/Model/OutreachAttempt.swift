//
//  OutreachAttempt.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/19/22.
//

import Foundation
import RealmSwift

class OutreachAttempt: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var contactMethod: String?

    @Persisted var createdAt: Date = Date()

    @Persisted(indexed: true) var outreachAttempt_id: ObjectId = ObjectId.generate()

    @Persisted var owner_id: String = ""

    @Persisted var to: ObjectId

    @Persisted var updatedAt: Date?

    @Persisted var attemptDescription: String?

    @Persisted var volunteerMethod: String?

    @Persisted var volunteerStatus: String = ""
}
