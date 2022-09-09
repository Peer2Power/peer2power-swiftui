//
//  SettingsView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/31/22.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {
    @State private var showingLogOutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        List {
            Button("Log Out", role: .destructive) {
                showingLogOutAlert.toggle()
            }
            .alert(Text("Are you sure you want to log out?"), isPresented: $showingLogOutAlert) {
                Button("Cancel", role: .cancel, action: {})
                Button("Log Out", role: .destructive) {
                    app.currentUser!.logOut(completion: { error in
                        if let error = error {
                            print("An error occured while logging out: \(error.localizedDescription)")
                        }
                        
                        print("Current user logged out successfully.")
                    })
                }
            }
            Button("Delete Account", role: .destructive) {
                showingDeleteAccountAlert.toggle()
            }
            .alert(Text("Are you sure you want to delete your account?"), isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel, action: {})
                Button("Delete Account", role: .destructive) {
                    // FIXME: remove all associated data after account deletion
                    app.currentUser!.delete { error in
                        if let error = error {
                            print("An error occurred while logging out: \(error.localizedDescription)")
                        }
                        
                        print("Current user deleted successfully.")
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
