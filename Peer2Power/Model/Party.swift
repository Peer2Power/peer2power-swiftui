//
//  Party.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/11/22.
//

import Foundation
import RealmSwift

enum Party: String, PersistableEnum {
    case selectParty = "Select Party"
    case democrat = "Democrats"
    case republican = "Republicans"
}
