//
//  FAQView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 11/12/22.
//

import SwiftUI
import SafariServices

struct WebView: UIViewControllerRepresentable {
    @Binding var url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
