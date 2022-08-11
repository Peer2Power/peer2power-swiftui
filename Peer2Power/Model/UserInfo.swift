//
//  User.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/11/22.
//

import Foundation
import RealmSwift

class UserInfo: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var owner_id: String = ""
    
    @Persisted var college: College?
    
    @Persisted var party: Party = .democrat
}
