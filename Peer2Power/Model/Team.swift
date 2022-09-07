//
//  Team.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/13/22.
//

import Foundation
import RealmSwift

class Team: Object {
    @Persisted(primaryKey: true) var _id: ObjectId

    @Persisted var contacts: List<Contact>

    @Persisted var member_ids: List<String>

    @Persisted var outreachAttempts: List<OutreachAttempt>

    @Persisted var owner_id: String = ""

    @Persisted var party: Party = .selectParty

    @Persisted var school_name: String = ""

    @Persisted var score: Int = 0

    @Persisted var state: String?
}
