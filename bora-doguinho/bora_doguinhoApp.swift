//
//  bora_doguinhoApp.swift
//  bora-doguinho
//
//  Created by Rennan Trabalho TI on 02/10/26.
//

import SwiftUI

@main
struct bora_doguinhoApp: App {
    @StateObject private var session = AuthSessionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
