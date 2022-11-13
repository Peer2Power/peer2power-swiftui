//
//  EndOfStudyResponse.swift
//  Peer2Power
//
//  Created by Deja Jackson on 11/13/22.
//

import Foundation
import RealmSwift

class EndOfStudyReponse: EmbeddedObject {
    @Persisted var contact_ids: List<String>

    @Persisted var createdAt: Date = Date()

    @Persisted var futureRecruitLikelihood: Int?

    @Persisted var owner_id: String = ""

    @Persisted(indexed: true) var response_id: ObjectId = ObjectId.generate()
}
