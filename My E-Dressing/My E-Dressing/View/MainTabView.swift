//
//  MainTabView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ModernDressingList()
                .tag(0)
                .tabItem {
                    Image(systemName: "house")
                    Text(String(localized: "tab_home"))
                }

            SearchPlaceholderView()
                .tag(1)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text(String(localized: "tab_search"))
                }

            CalendarPlaceholderView()
                .tag(2)
                .tabItem {
                    Image(systemName: "calendar")
                    Text(String(localized: "tab_calendar"))
                }

            ProfilePlaceholderView()
                .tag(3)
                .tabItem {
                    Image(systemName: "person")
                    Text(String(localized: "tab_profile"))
                }
        }
        .tint(Color.themePrimary)
    }
}

// MARK: - Placeholder Views

struct SearchPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.themeSecondary.opacity(0.2))
                    Text(String(localized: "tab_search"))
                        .font(.title3)
                        .foregroundStyle(Color.themeSecondary.opacity(0.5))
                }
            }
            .navigationTitle(String(localized: "tab_search"))
        }
    }
}

struct CalendarPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.themeSecondary.opacity(0.2))
                    Text(String(localized: "tab_calendar"))
                        .font(.title3)
                        .foregroundStyle(Color.themeSecondary.opacity(0.5))
                }
            }
            .navigationTitle(String(localized: "tab_calendar"))
        }
    }
}

struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "person")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.themeSecondary.opacity(0.2))
                    Text(String(localized: "tab_profile"))
                        .font(.title3)
                        .foregroundStyle(Color.themeSecondary.opacity(0.5))
                }
            }
            .navigationTitle(String(localized: "tab_profile"))
        }
    }
}
