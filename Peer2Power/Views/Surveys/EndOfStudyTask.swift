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
        let step = ORKFormStep(identifier: String(describing: Identifier.knownContactsFormStep), title: nil, text: nil)
        var formItems = [ORKFormItem]()
        
        for contact in contacts {
            let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I was not able to find out.", value: "I was not able to find out." as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I don't know this person.", value: "I don't know this person." as NSCoding & NSCopying & NSObjectProtocol)]
            let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
            
            let formItemText = "Did " + contact.name + " volunteer for a 2022 general election campaign?"
            let formItem = ORKFormItem(identifier: "know" + contact.contact_id.stringValue,
                                       text: formItemText,
                                       answerFormat: answerFormat)
            
            formItem.isOptional = false
            
            formItems.append(formItem)
        }
        
        step.formItems = formItems
        
        step.isOptional = false
        
        return step
    }
    
    static func volunteerMethodStep(stepResult: ORKStepResult) -> ORKFormStep? {
        let step = ORKFormStep(identifier: String(String(describing: Identifier.volunteerMethodFormStep)), title: nil, text: nil)
        
        guard let results = stepResult.results else { return nil }
        var formItems = [ORKFormItem]()
        
        for result in results {
            guard let result = result as? ORKChoiceQuestionResult else { return nil }
            guard let choiceAnswers = result.choiceAnswers else { return nil }
            
            for choiceAnswer in choiceAnswers {
                if choiceAnswer.isEqual("Yes" as NSCoding & NSCopying & NSObjectProtocol) {
                    print("Adding a form item for an answer in the affirmative...")
                    
                    let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Canvass", value: "Canvass" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Phone bank", value: "Phone bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Text Bank", value: "Text bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Write postcards", value: "Write postcards" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: false, textViewPlaceholderText: "Please specify")]
                    let answerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)
                    
                    let formItemText = "How did they volunteer?"
                    let formItem = ORKFormItem(identifier: "\(arc4random())",
                                               text: formItemText,
                                               answerFormat: answerFormat)
                    
                    formItems.append(formItem)
                }
            }
        }
        
        /*
        print("Scanning \(choiceAnswers.count) answers.")
        
        for choiceAnswer in choiceAnswers {
            if choiceAnswer.isEqual("Yes" as NSCoding & NSCopying & NSObjectProtocol) {
                print("Adding a form item for an answer in the affirmative...")
                
                let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Canvass", value: "Canvass" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Phone bank", value: "Phone bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Text Bank", value: "Text bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Write postcards", value: "Write postcards" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: false, textViewPlaceholderText: "Please specify")]
                let answerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)
                
                let formItemText = "How did they volunteer?"
                let formItem = ORKFormItem(identifier: "\(arc4random())",
                                           text: formItemText,
                                           answerFormat: answerFormat)
                
                formItems.append(formItem)
            }
        }
         */
        
        step.formItems = formItems
        
        return step
    }
    
    override func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        let identifier = step?.identifier
        
        switch identifier {
        case String(describing: Identifier.knownContactsFormStep):
            guard let stepResult = result.stepResult(forStepIdentifier: String(describing: Identifier.knownContactsFormStep)) else { return nil }
            guard let results = stepResult.results as? [ORKChoiceQuestionResult] else { return nil }
            
            for result in results {
                guard let answers = result.choiceAnswers else { return nil }
                
                let hasYes = answers.contains { answer in
                    return answer.isEqual("Yes" as NSCoding & NSCopying & NSObjectProtocol)
                }
                
                if hasYes {
                    return EndOfStudyTask.volunteerMethodStep(stepResult: stepResult)
                }
            }
        default:
            break
        }
        
        return super.step(after: step, with: result)
    }
}
