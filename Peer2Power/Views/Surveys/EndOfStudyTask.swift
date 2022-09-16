//
//  EndOfStudyTask.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/16/22.
//

import ResearchKit
import RealmSwift

class EndOfStudyTask: ORKOrderedTask {
    static func knowContactsStep(contacts: List<Contact>) -> ORKFormStep {
        let step = ORKFormStep(identifier: String(describing: Identifier.knownContactsFormStep), title: "Select Contacts", text: "Select which contacts you know.")
        var formItems = [ORKFormItem]()
        
        for contact in contacts {
            let formItemText = "Do you know " + contact.name + "?"
            let formItem = ORKFormItem(identifier: contact.contact_id.stringValue,
                                       text: formItemText,
                                       answerFormat: ORKBooleanAnswerFormat())
            
            formItems.append(formItem)
        }
        
        step.formItems = formItems
        
        return step
    }
}
