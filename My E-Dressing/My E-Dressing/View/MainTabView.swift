//
//  MainTabView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

enum Tab: Int, CaseIterable {
    case search, calendar, home, day, profile

    var icon: String {
        switch self {
        case .search: "magnifyingglass"
        case .calendar: "calendar"
        case .home: "house.fill"
        case .day: "sun.max.fill"
        case .profile: "person"
        }
    }

    var labelKey: String {
        switch self {
        case .search: "tab_search"
        case .calendar: "tab_calendar"
        case .home: "tab_home"
        case .day: "tab_day"
        case .profile: "tab_profile"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .search:
                    SearchPlaceholderView()
                case .calendar:
                    CalendarPlaceholderView()
                case .home:
                    ModernDressingList()
                case .day:
                    DayPlaceholderView()
                case .profile:
                    ProfilePlaceholderView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                if tab == .home {
                    homeButton(tab)
                } else {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Color.themeSecondary
                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                .shadow(color: Color.black.opacity(0.15), radius: 10, y: -5)
        )
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                Text(String(localized: String.LocalizationValue(tab.labelKey)))
                    .font(.system(size: 10))
            }
            .foregroundStyle(selectedTab == tab ? Color.themePrimary : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
        }
    }

    private func homeButton(_ tab: Tab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(selectedTab == tab ? Color.themePrimary : Color.white.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: tab.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.7))
                }
                .offset(y: -14)

                Text(String(localized: String.LocalizationValue(tab.labelKey)))
                    .font(.system(size: 10))
                    .foregroundStyle(selectedTab == tab ? Color.themePrimary : .white.opacity(0.5))
                    .offset(y: -10)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Rounded Corner Helper

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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
