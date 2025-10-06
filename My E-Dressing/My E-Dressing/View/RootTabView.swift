//
//  RootTabView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Text("Dressings")
                .tabItem { Label("Dressings", systemImage: "cabinet") }

            GarmentFormView()
                .tabItem { Label("Add", systemImage: "plus.circle") }
        }
    }
}
