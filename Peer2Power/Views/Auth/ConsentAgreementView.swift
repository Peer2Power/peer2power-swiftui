//
//  ConsentAgreementView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/28/22.
//

import SwiftUI
import ResearchKit

struct ConsentAgreementView: UIViewControllerRepresentable {
    @Binding var consented: Bool
    
    private func generateConsentDocument() -> ORKConsentDocument {
        let consentDocument = ORKConsentDocument()
        
        let section1 = ORKConsentSection(type: .overview)
        section1.title = "Key Information"
        section1.content = "We are seeking your consent to participate in a non-partisan, voluntary study of civic engagement and political participation. You were invited to this survey because you are connected to a campus community in Pennsylvania. Participating in this study should involve no more than the minimal risks of political volunteering work in congressional campaigns. You will not receive direct benefits for participating in this study, but your participation will improve our understanding of American politics and help college students interested in public service."
        
        let section2 = ORKConsentSection(type: .custom)
        section2.title = "Eligibility"
        section2.content = "You must be at least 18 years old to participate in this study."
        
        let section3 = ORKConsentSection(type: .studySurvey)
        section3.title = "Purpose"
        section3.content = "The purpose of this study is to assess the most effective means of recruiting volunteers to political campaigns. The anonymized information we gather from this study will be used to shape class discussion, to advise college students interested in electoral politics, and to conduct research on American campaigns."
        
        let section4 = ORKConsentSection(type: .custom)
        section4.title = "Procedures"
        section4.content = "The study will run between Monday, October 17th and Monday, November 7th."
        
        let section5 = ORKConsentSection(type: .custom)
        section5.title = "Risks"
        section5.content = "This study is expected to involve no more than the minimal risks of volunteering for a political campaign of your choice alongside your friends or family."
        
        let section6 = ORKConsentSection(type: .custom)
        section6.title = "Benefits"
        section6.content = "While this study will not benefit you directly, your participation will advance our knowledge of American politics and civic engagement."
        
        let section7 = ORKConsentSection(type: .custom)
        section7.title = "Compensation"
        section7.content = "There is no financial compensation for participating."
        
        let section8 = ORKConsentSection(type: .timeCommitment)
        section8.title = "Cost"
        section8.content = "Other than your time, there is no cost to you for being in this study."
        
        let section9 = ORKConsentSection(type: .dataUse)
        section9.title = "Confidentiality"
        section9.content = "The information you give in this study will not be encrypted while the study is running. This is because we will need the email addresses of contacts assigned to the generic contact group to send them general information about volunteering for political campaigns. Once the study is complete, we will delete all identifiable information. Any data exported for analysis will remain anonymous, and we will not share your data with any third-party groups or organizations. If any publication results from this research, you will not be identified by name."
        
        let section10 = ORKConsentSection(type: .withdrawing)
        section10.title = "Statement of Rights"
        section10.content = "You have rights as a research volunteer. Your being in this study is completely voluntary. You do not have to be in this study. You may stop taking part in this study for any reason at any time without penalty. Because data are anonymous, you may not withdraw after the study is complete. If you wish, you may have a copy of this form to keep.  You do not waive any of your legal rights by completing this agreement."
        
        let section11 = ORKConsentSection(type: .custom)
        section11.title = "Contact Persons"
        section11.content = "If you have questions about your participation in this research, write to Dr. Andrew Clarke at clarkeaj@lafayette. If you have questions about your rights as a research participant, e-mail the Chair of Lafayette IRB at irb@lafayette.edu."
        
        let section12 = ORKConsentSection(type: .overview)
        section12.title = "Conclusion"
        section12.content = "I have read and understand the consent form. I agree to participate in this research study. (Participants may print this screen for their records.) By submitting information on this application or website, I consent to participate."
        
        consentDocument.sections = [section1, section2, section3, section4, section5, section6, section7, section8, section9, section10, section11, section12]
        
        return consentDocument
      }
    
    func makeUIViewController(context: Context) -> ORKConsentReviewStepViewController {
        let step = ORKConsentReviewStep(identifier: String(describing: Identifier.consentReviewStep),
                                        signature: nil,
                                        in: generateConsentDocument())
        step.reasonForConsent = "Are you sure you consent to participate in this study? It will be assumed that consent is given unless you decide to withdraw."
        
        let controller = ORKConsentReviewStepViewController(step: step)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ORKStepViewControllerDelegate {
        var parent: ConsentAgreementView
        
        init(_ parent: ConsentAgreementView) {
            self.parent = parent
        }
        
        func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController) {
            guard let result = stepViewController.result else { return }
            guard let sigResult = result.firstResult as? ORKConsentSignatureResult else { return }
            
            parent.consented = sigResult.consented
            
            stepViewController.dismiss(animated: true)
        }

        func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection) {
            
        }
        
        
        
        func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?) {
            
        }
        
        func stepViewController(_ stepViewController: ORKStepViewController, recorder: ORKRecorder, didFailWithError error: Error) {
            
        }
    }
}
