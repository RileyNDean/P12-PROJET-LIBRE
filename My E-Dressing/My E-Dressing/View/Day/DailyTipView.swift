//
//  DailyTipView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import SwiftUI

/// Displays a daily awareness tip about responsible fashion.
/// The tip changes every day based on the calendar day.
/// Also shows the current weather using CoreLocation + OpenWeatherMap.
struct DailyTipView: View {

    @StateObject private var weatherController = WeatherController()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 24) {
                        // Date
                        Text(DailyTipCatalog.todayDateString.capitalized)
                            .font(.sansCaption)
                            .foregroundStyle(Color.themeSecondary.opacity(0.5))

                        // Weather icon (or leaf fallback)
                        VStack(spacing: 8) {
                            Image(systemName: weatherController.iconName)
                                .font(.system(size: 36))
                                .foregroundStyle(
                                    weatherController.isLoaded
                                        ? Color.themePrimary
                                        : Color.themeAccent
                                )

                            if let temp = weatherController.temperatureString {
                                Text(temp)
                                    .font(.serifTitle)
                                    .foregroundStyle(Color.themeSecondary)
                            }
                        }

                        // Tip text
                        Text(DailyTipCatalog.todayTip)
                            .font(.serifTitle3)
                            .foregroundStyle(Color.themeSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .fixedSize(horizontal: false, vertical: true)

                        // Decorative dots
                        HStack(spacing: 6) {
                            ForEach(0..<3) { _ in
                                Circle()
                                    .fill(Color.themePrimary.opacity(0.3))
                                    .frame(width: 5, height: 5)
                            }
                        }
                    }

                    Spacer()

                    // Bottom message
                    Text(String(localized: "tip_footer_weather"))
                        .font(.sansCaption2)
                        .foregroundStyle(Color.themeSecondary.opacity(0.3))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 90)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "tab_day"))
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary)
                }
            }
            .onAppear {
                weatherController.refresh()
            }
        }
    }
}
