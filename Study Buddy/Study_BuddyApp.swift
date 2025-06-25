//
//  Study_BuddyApp.swift
//  Study Buddy
//
//  Created by Randimal Geeganage on 2025-06-18.
//

import SwiftUI

@main
struct Study_BuddyApp: App {
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showLaunchScreen ? 0 : 1)
                if showLaunchScreen {
                    AnimatedLaunchScreen()
                        .transition(.opacity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                    withAnimation {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}
