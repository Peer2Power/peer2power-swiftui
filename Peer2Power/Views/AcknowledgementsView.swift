//
//  AcknowledgementsView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 10/7/22.
//

import SwiftUI
import AcknowList

struct AcknowledgementsView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return AcknowListViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct AcknowledgementsView_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgementsView()
    }
}
