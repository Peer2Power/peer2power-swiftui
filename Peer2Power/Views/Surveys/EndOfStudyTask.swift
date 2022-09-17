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
        let step = ORKFormStep(identifier: String(describing: Identifier.knownContactsFormStep), title: "Who Volunteered?", text: "Please indicate which of your contacts volunteered.")
        var formItems = [ORKFormItem]()
        
        for contact in contacts {
            let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I was not able to find out.", value: "I was not able to find out." as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I don't know this person.", value: "I don't know this person." as NSCoding & NSCopying & NSObjectProtocol)]
            let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
            
            let formItemText = "Did " + contact.name + " volunteer for a 2022 general election campaign?"
            let formItem = ORKFormItem(identifier: "know" + contact.contact_id.stringValue,
                                       text: formItemText,
                                       answerFormat: answerFormat)
            
            // FIXME: make this required for production.
            // formItem.isOptional = false
            
            formItems.append(formItem)
        }
        
        step.formItems = formItems
        
        // FIXME: make this required for production.
        // step.isOptional = false
        
        return step
    }
    
    static func volunteerMethodStep(result: ORKChoiceQuestionResult) -> ORKFormStep {
        let step = ORKFormStep(identifier: String(String(describing: Identifier.volunteerMethodFormStep)), title: "How Did They Volunteer?", text: "Please indicate how the contacts you know volunteered.")
        
        guard let choiceAnswers = result.choiceAnswers else { return ORKFormStep(identifier: "uhoh") }
        
        var formItems = [ORKFormItem]()
        
        for choiceAnswer in choiceAnswers {
            if choiceAnswer.isEqual("Yes" as NSCoding & NSCopying & NSObjectProtocol) {
                let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Canvass", value: "Canvass" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Phone bank", value: "Phone bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Text Bank", value: "Text bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Write postcards", value: "Write postcards" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: false, textViewPlaceholderText: "Please specify")]
                let answerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)
                
                let formItemText = "How did they volunteer?"
                let formItem = ORKFormItem(identifier: "\(arc4random())",
                                           text: formItemText,
                                           answerFormat: answerFormat)
                
                formItems.append(formItem)
            }
        }
        
        step.formItems = formItems
        
        return step
    }
    
    override func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        let identifier = step?.identifier
        
        switch identifier {
        case String(describing: Identifier.knownContactsFormStep):
            let stepResult = result.stepResult(forStepIdentifier: String(describing: Identifier.knownContactsFormStep))
            
            if let result = stepResult?.firstResult as? ORKChoiceQuestionResult {
                if let hasYes = result.choiceAnswers?.contains(where: { answers in
                    return answers.isEqual("Yes" as NSCoding & NSCopying & NSObjectProtocol)
                }) {
                    if hasYes {
                        return EndOfStudyTask.volunteerMethodStep(result: result)
                    }
                }
            }
        default:
            break
        }
        
        return super.step(after: step, with: result)
    }
}
