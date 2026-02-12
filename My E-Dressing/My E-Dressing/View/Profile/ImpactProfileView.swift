//
//  ImpactProfileView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import SwiftUI
import CoreData

/// Profile screen showing wardrobe statistics to raise awareness about responsible consumption.
struct ImpactProfileView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Garment.createdAt, ascending: false)]
    ) private var allGarments: FetchedResults<Garment>

    private let statisticsController = StatisticsController()

    private var stats: WardrobeStatistics {
        statisticsController.computeStatistics(from: Array(allGarments))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: - Header
                        VStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.themeAccent)

                            Text(String(localized: "profile_title"))
                                .font(.serifTitle)
                                .foregroundStyle(Color.themeSecondary)

                            Text(String(localized: "profile_subtitle"))
                                .font(.sansSubheadline)
                                .foregroundStyle(Color.themeSecondary.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 8)

                        // MARK: - Main Stats
                        HStack(spacing: 12) {
                            StatCard(
                                value: "\(stats.totalCount)",
                                label: String(localized: "stat_total"),
                                icon: "tshirt.fill",
                                color: Color.themeSecondary
                            )
                            StatCard(
                                value: "\(stats.neverWornCount)",
                                label: String(localized: "stat_never_worn"),
                                icon: "exclamationmark.triangle.fill",
                                color: Color.themePrimary
                            )
                        }
                        .padding(.horizontal)

                        // MARK: - Impact Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "profile_actions_title"))
                                .font(.serifHeadline)
                                .foregroundStyle(Color.themeSecondary)
                                .padding(.leading, 4)

                            ActionStatRow(
                                icon: "gift.fill",
                                label: String(localized: "stat_to_give"),
                                count: stats.toGiveCount,
                                color: .orange
                            )
                            ActionStatRow(
                                icon: "arrow.3.trianglepath",
                                label: String(localized: "stat_to_recycle"),
                                count: stats.toRecycleCount,
                                color: .green
                            )
                            ActionStatRow(
                                icon: "tag.fill",
                                label: String(localized: "stat_to_sell"),
                                count: stats.toSellCount,
                                color: .blue
                            )
                        }
                        .padding(.horizontal)

                        // MARK: - Awareness Banner
                        if stats.totalCount > 0 && stats.neverWornCount > 0 {
                            VStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color.themePrimary)

                                Text(String(format: String(localized: "stat_awareness_personal"), stats.neverWornPercentage))
                                    .font(.sansSubheadline)
                                    .foregroundStyle(Color.themeSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.themePrimary.opacity(0.08))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // MARK: - Extra Stats
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "profile_details_title"))
                                .font(.serifHeadline)
                                .foregroundStyle(Color.themeSecondary)
                                .padding(.leading, 4)

                            HStack(spacing: 12) {
                                MiniStatCard(
                                    icon: "arrow.counterclockwise",
                                    value: String(format: "%.1f", stats.avgWearCount),
                                    label: String(localized: "stat_avg_wear")
                                )
                                MiniStatCard(
                                    icon: "square.grid.2x2",
                                    value: "\(stats.categoryCount)",
                                    label: String(localized: "stat_categories")
                                )
                                MiniStatCard(
                                    icon: "checkmark.circle.fill",
                                    value: "\(stats.keptCount)",
                                    label: String(localized: "stat_kept")
                                )
                            }
                        }
                        .padding(.horizontal)

                        // MARK: - Most Worn
                        if let top = stats.mostWornGarment, top.wearCount > 0 {
                            VStack(spacing: 12) {
                                Text(String(localized: "stat_most_worn"))
                                    .font(.sansCaption)
                                    .foregroundStyle(Color.themeSecondary.opacity(0.6))

                                if let img = top.primaryImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }

                                Text(top.title ?? "—")
                                    .font(.sansHeadline)
                                    .foregroundStyle(Color.themeSecondary)

                                Text(String(format: String(localized: "worn_count"), top.wearCount))
                                    .font(.sansCaption2)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }

                        Color.clear.frame(height: 80)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "tab_profile"))
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary)
                }
            }
        }
    }
}

// MARK: - Stat Card

/// Large card displaying a single numeric statistic with icon and label.
private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.sansCaption)
                .foregroundStyle(Color.themeSecondary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 130)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Action Stat Row

/// Horizontal row showing an action icon, label and count (e.g. "To Give: 3").
private struct ActionStatRow: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(label)
                .font(.sansBody)
                .foregroundStyle(Color.themeSecondary)

            Spacer()

            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(count > 0 ? color : Color.themeSecondary.opacity(0.3))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Mini Stat Card

/// Compact card for secondary statistics (avg. wears, categories, kept).
private struct MiniStatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.themeSecondary.opacity(0.5))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.themeSecondary)
            Text(label)
                .font(.sansCaption2)
                .foregroundStyle(Color.themeSecondary.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
        )
    }
}
