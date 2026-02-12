//
//  MainTabView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

// MARK: - Tab Item Model

/// Represents a single tab in the floating menu bar.
struct TabItem: Identifiable {
    let id: Int
    let icon: String
    let label: String
    var isVisible: Bool = true
}

// MARK: - Main Tab View

/// Root view hosting all four main tabs with a custom floating tab bar.
struct MainTabView: View {
    @State private var selectedTab = 0

    private let tabs = [
        TabItem(id: 0, icon: "cabinet", label: "tab_dressing"),
        TabItem(id: 1, icon: "sun.max.fill", label: "tab_day"),
        TabItem(id: 2, icon: "magnifyingglass", label: "tab_search"),
        TabItem(id: 3, icon: "person", label: "tab_profile")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: ModernDressingList()
                case 1: DailyTipView()
                case 2: SearchView()
                case 3: ImpactProfileView()
                default: ModernDressingList()
                }
            }

            FloatingTabBar(tabs: tabs, selectedTab: $selectedTab)
                .fixedSize()
                .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Floating Tab Bar

/// A floating pill-shaped tab bar placed at the bottom of the screen.
struct FloatingTabBar: View {
    let tabs: [TabItem]
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 20) {
            ForEach(tabs.filter(\.isVisible)) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab.id
                    }
                } label: {
                    Image(systemName: tab.icon)
                        .font(.system(size: 22))
                        .fontWeight(selectedTab == tab.id ? .semibold : .regular)
                        .foregroundStyle(selectedTab == tab.id ? Color.themePrimary : .white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.themeSecondary)
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Placeholder Views

/// Placeholder view shown while the search feature is loading.
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
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary.opacity(0.5))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "tab_search"))
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary)
                }
            }
        }
    }
}
