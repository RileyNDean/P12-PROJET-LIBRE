//
//  MainTabView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        let greenBg = UIColor(red: 47/255, green: 72/255, blue: 66/255, alpha: 1) // #2F4842
        let orangeAccent = UIColor(red: 217/255, green: 108/255, blue: 69/255, alpha: 1) // #D96C45

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = greenBg

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        appearance.stackedLayoutAppearance.selected.iconColor = orangeAccent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: orangeAccent]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchPlaceholderView()
                .tag(0)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text(String(localized: "tab_search"))
                }

            CalendarPlaceholderView()
                .tag(1)
                .tabItem {
                    Image(systemName: "calendar")
                    Text(String(localized: "tab_calendar"))
                }

            ModernDressingList()
                .tag(2)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(String(localized: "tab_home"))
                }

            DayPlaceholderView()
                .tag(3)
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text(String(localized: "tab_day"))
                }

            ProfilePlaceholderView()
                .tag(4)
                .tabItem {
                    Image(systemName: "person")
                    Text(String(localized: "tab_profile"))
                }
        }
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

struct DayPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.themeSecondary.opacity(0.2))
                    Text(String(localized: "tab_day"))
                        .font(.title3)
                        .foregroundStyle(Color.themeSecondary.opacity(0.5))
                }
            }
            .navigationTitle(String(localized: "tab_day"))
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
