//
//  OutreachAttempt.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/19/22.
//

import Foundation
import RealmSwift

class OutreachAttempt: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var contactMethod: String = ""
    
    @Persisted var createdAt: Date = Date()
    
    @Persisted var owner_id: String = ""
    
    @Persisted var team_id: String = ""
    
    @Persisted var to: String = ""
    
    @Persisted var updatedAt: Date?
    
    @Persisted var volunteerInterest: String = ""
    
    @Persisted var volunteerMethod: String?
    
    @Persisted var volunteerStatus: String = ""
}
