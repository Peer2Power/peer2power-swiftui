//
//  EndOfStudyTask.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/16/22.
//

import ResearchKit
import RealmSwift

class EndOfStudyTask: ORKOrderedTask {
    static func whoVolunteeredStep(team: Team) -> ORKQuestionStep {
        let step = ORKQuestionStep(identifier: String(describing: Identifier.whichVolunteeredStep),
                                   title: nil,
                                   question: "Please talk to these contacts and confirm whether they volunteered.",
                                   answer: nil)
        var textChoices = [ORKTextChoice]()
        
        for contact in team.contacts {
            let filteredOutreachAttempts = team.outreachAttempts.filter("to = %@", contact.contact_id)
                .filter("volunteerStatus = %@", "They volunteered!")
            
            if filteredOutreachAttempts.isEmpty {
                let textChoice = ORKTextChoice(text: contact.name, value: contact.name as NSCoding & NSCopying & NSObjectProtocol)
                textChoices.append(textChoice)
            }
        }
        
        let answerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)
        step.answerFormat = answerFormat
        
        step.isOptional = false
        
        return step
    }
    
    static func questionsAboutUserStep() -> ORKFormStep {
        let step = ORKFormStep(identifier: String(describing: Identifier.aboutUserFormStep))
        
        let isFirstTimeFormItem = ORKFormItem(identifier: String(describing: Identifier.isFirstTimeFormItem),
                                              text: "Is this your first time recruiting people to volunteer for a campaign?",
                                              answerFormat: ORKBooleanAnswerFormat())
        
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Very likely", value: "Very likely" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Somewhat likely", value: "Somewhat likely" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Neither likely nor unlikely", value: "Neither likely nor unlikley" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Somewhat unlikely", value: "Somewhat unlikely" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Very unlikely", value: "Very unlikely" as NSCoding & NSCopying & NSObjectProtocol)]
        let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let futureRecruitLikelihoodFormItem = ORKFormItem(identifier: String(describing: Identifier.futureRecruitLikelihoodFormItem),
                                                          text: "How likely are you to recruit volunteers again in the future?",
                                                          answerFormat: answerFormat)
        
        let didUserVolunteerFormItem = ORKFormItem(identifier: String(describing: Identifier.didUserVolunteerFormItem),
                                                   text: "Did you volunteer for a campaign during your participation in this study?",
                                                   answerFormat: ORKBooleanAnswerFormat())
        
        let friendsOrFamTextChoices: [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther(text: "This does not apply to me.", value: "This does not apply to me." as NSCoding & NSCopying & NSObjectProtocol)]
        let friendsOrFamAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: friendsOrFamTextChoices)
        
        let didVolunteerWithFriendsOrFamilyFormItem = ORKFormItem(identifier: String(describing: Identifier.didVolunteerWithFriendsOrFamilyFormItem),
                                                                  text: "If you did volunteer with a campaign during this study, did you volunteer with friends or family?",
                                                                  answerFormat: friendsOrFamAnswerFormat)
        
        step.formItems = [
            isFirstTimeFormItem,
            futureRecruitLikelihoodFormItem,
            didUserVolunteerFormItem,
            didVolunteerWithFriendsOrFamilyFormItem
        ]
        
        return step
    }
    
    static override func makeCompletionStep() -> ORKCompletionStep {
        let step = ORKCompletionStep(identifier: String(describing: Identifier.endOfStudyCompletionStep))
        
        step.title = "Thank you for completing this survey!"
        step.detailText = "Thank you for participating in the political process and encouraging others to do so! We hope you keep up the good work!"
        
        return step
    }
    
    override func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        // let identifier = step?.identifier
        
        /*
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
        case String(describing: Identifier.volunteerMethodFormStep):
            guard let prevStep = step as? ORKFormStep else { return nil }
            return EndOfStudyTask.campaignTypeStep(prevStep: prevStep)
        case String(describing: Identifier.campaignTypeFormStep):
            guard let prevStep = step as? ORKFormStep else { return nil }
            return EndOfStudyTask.whyVolunteerStep(prevStep: prevStep)
        case String(describing: Identifier.whyVolunteerFormStep):
            return EndOfStudyTask.questionsAboutUserStep()
        case String(describing: Identifier.aboutUserFormStep):
            return EndOfStudyTask.makeCompletionStep()
        default:
            break
        }
         */
        
        return super.step(after: step, with: result)
    }
}
