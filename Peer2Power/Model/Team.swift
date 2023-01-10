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

    @Persisted var contacts: List<Contact>

    @Persisted var endOfStudyResponses: List<EndOfStudyReponse>

    @Persisted var member_ids: List<String>

    @Persisted var name: String = ""

    @Persisted var outreachAttempts: List<OutreachAttempt>

    @Persisted var score: Int = 0
}
