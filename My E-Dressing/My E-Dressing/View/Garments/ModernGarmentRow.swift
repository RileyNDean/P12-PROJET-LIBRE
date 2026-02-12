//
//  ModernGarmentRow.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI

/// Expandable card displaying a garment's summary and details.
struct ModernGarmentRow: View {
    let garment: Garment
    @Binding var expandedGarmentId: UUID?
    let onEdit: () -> Void
    let onDelete: () -> Void

    var isExpanded: Bool {
        expandedGarmentId == garment.id
    }

    @State private var selectedImage: IdentifiableImage? = nil

    private var subtitleParts: [AnyView] {
        var parts: [AnyView] = []

        // Status (icon only)
        let status = GarmentStatus(rawValue: garment.statusRaw) ?? .kept
        parts.append(AnyView(
            Image(systemName: status.icon)
                .font(.system(size: 12))
                .foregroundStyle(Color.themeSecondary.opacity(0.5))
        ))

        if let brand = garment.brand, !brand.isEmpty {
            parts.append(AnyView(
                Text(brand)
                    .font(.sansCaption2)
                    .foregroundStyle(Color.themeSecondary.opacity(0.6))
            ))
        }

        return parts
    }

    private var allImages: [IdentifiableImage] {
        garment.allLoadedImages.map { IdentifiableImage(id: $0.id, image: $0.image) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: Collapsed header
            HStack(spacing: 16) {
                if let image = garment.primaryImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.themeSecondary.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "tshirt").foregroundStyle(Color.themeSecondary))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(garment.title ?? String(localized: "untitled"))
                        .font(.serifHeadline)
                        .foregroundStyle(Color.themeSecondary)

                    // Subtitle: Brand · 🏷 Category · ✅ Status
                    HStack(spacing: 4) {
                        ForEach(Array(subtitleParts.enumerated()), id: \.offset) { index, part in
                            if index > 0 {
                                Text("·")
                                    .font(.sansCaption2)
                                    .foregroundStyle(Color.themeSecondary.opacity(0.3))
                            }
                            part
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundStyle(Color.themeSecondary.opacity(0.5))
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if isExpanded {
                        expandedGarmentId = nil
                    } else {
                        expandedGarmentId = garment.id
                    }
                }
            }

            // MARK: Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider().background(Color.themeSecondary.opacity(0.1))

                    let images = allImages
                    if !images.isEmpty {
                        if images.count == 1, let item = images.first {
                            // Single photo — show large
                            Image(uiImage: item.image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(12)
                                .onTapGesture { selectedImage = item }
                        } else {
                            // Multiple photos — horizontal scroll of thumbnails
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(images) { item in
                                        Image(uiImage: item.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 90, height: 90)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .onTapGesture { selectedImage = item }
                                    }
                                }
                            }
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        DetailItem(icon: "ruler", title: String(localized: "size_placeholder"), value: garment.size)
                        DetailItem(icon: "paintpalette", title: String(localized: "color_placeholder"), value: garment.color)
                        CategoryDetailItem(categoryId: garment.category)
                        DetailItem(icon: "arrow.counterclockwise", title: String(localized: "wearcount_title"), value: String(format: String(localized: "worn_count"), garment.wearCount))
                    }

                    HStack(spacing: 12) {
                        Button(action: onEdit) {
                            HStack {
                                Image(systemName: "pencil")
                                Text(String(localized: "edit_add_photos"))
                            }
                            .font(.sansHeadline)
                            .foregroundColor(Color.themePrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.themePrimary.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: onDelete) {
                            HStack {
                                Image(systemName: "trash")
                                Text(String(localized: "delete"))
                            }
                            .font(.sansHeadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: isExpanded ? Color.themePrimary.opacity(0.15) : Color.black.opacity(0.05), radius: isExpanded ? 15 : 5, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.vertical, 6)
        .fullScreenCover(item: $selectedImage) { item in
            FullscreenImageView(image: item.image)
        }
    }
}

// MARK: - Identifiable Image Wrapper

/// A uniquely identifiable wrapper around a UIImage for fullscreen viewing.
struct IdentifiableImage: Identifiable {
    let id: UUID
    let image: UIImage
}

// MARK: - Fullscreen Image Viewer

/// Fullscreen image viewer with pinch-to-zoom.
struct FullscreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = value.magnification
                        }
                        .onEnded { _ in
                            withAnimation { scale = max(1.0, scale) }
                        }
                )
                .onTapGesture {
                    dismiss()
                }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
        .statusBarHidden()
    }
}

// MARK: - Detail Items

/// A detail cell showing an SF Symbol icon, a title and a value.
struct DetailItem: View {
    let icon: String
    let title: String
    let value: String?

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.themeSecondary)
                .frame(height: 24)
            Text(title).font(.sansCaption2).foregroundStyle(.secondary)
            Text(value ?? "—").font(.sansSubheadline).fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Shows the category icon + label when a known category is set, falls back to generic tag icon.
struct CategoryDetailItem: View {
    let categoryId: String?

    private var category: GarmentCategory? {
        GarmentCategoryCatalog.find(by: categoryId)
    }

    var body: some View {
        VStack(spacing: 6) {
            if let cat = category {
                Image(cat.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "tag")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.themeSecondary)
                    .frame(height: 24)
            }
            Text(String(localized: "category_placeholder")).font(.sansCaption2).foregroundStyle(.secondary)
            if let cat = category {
                Text(cat.label).font(.sansSubheadline).fontWeight(.medium)
            } else {
                Text(categoryId ?? "—").font(.sansSubheadline).fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
