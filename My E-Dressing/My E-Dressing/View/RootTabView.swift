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
            Text(String(localized: "tab_dressings"))
                .tabItem { Label(String(localized: "tab_dressings"), systemImage: "cabinet") }

            GarmentFormView()
                .tabItem { Label(String(localized: "tab_add"), systemImage: "plus.circle") }
        }
    }
}
