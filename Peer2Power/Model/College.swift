//
//  College.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import Foundation
import RealmSwift

class College: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId

    @Persisted var name: String = ""
    
    @Persisted var owner_id: String?

    @Persisted var state: String?

    @Persisted var type: String?

    @Persisted var url: String?
}
