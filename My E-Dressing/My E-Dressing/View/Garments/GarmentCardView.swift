//
//  GarmentCardView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//
import SwiftUI
import UIKit
import CoreData

/// Expandable card view for a garment using horizontal/grid photo layout.
struct GarmentCardView: View {
    let garment: Garment
    let onEdit: () -> Void

    @State private var isExpanded = false
    @State private var showViewer = false
    @State private var viewerIndex = 0

    private var images: [UIImage] {
        garment.allLoadedImages.map(\.image)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            if isExpanded {
                PhotoGrid(images: images) { idx in
                    viewerIndex = idx
                    showViewer = true
                }
            } else {
                HorizontalPhotoStrip(images: images) { idx in
                    viewerIndex = idx
                    showViewer = true
                }
            }

            HStack {
                Text(garment.title ?? "").font(.serifHeadline)
                Spacer()
                if let wear = garment.value(forKey: "wearCount") as? Int32, wear > 0 {
                    Label("×\(wear)", systemImage: "tshirt")
                        .font(.sansCaption).padding(6)
                        .background(Color.gray.opacity(0.15)).cornerRadius(8)
                }
            }

            Text(GarmentStatus(rawValue: garment.statusRaw)?.label ?? "")
                .font(.sansSubheadline).foregroundStyle(.secondary)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    infoRow(String(localized: "brand_placeholder"), garment.brand)
                    infoRow(String(localized: "color_placeholder"), garment.color)
                    infoRow(String(localized: "size_placeholder"), garment.size)
                    infoRow(String(localized: "category_placeholder"), garment.category)
                    if let notes = garment.notes, !notes.isEmpty {
                        Text(notes).font(.sansFootnote).foregroundStyle(.secondary).padding(.top, 4)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut) { isExpanded.toggle() } }
        .sheet(isPresented: $showViewer) {
            PhotoFullScreenViewer(images: images, startIndex: $viewerIndex)
        }
    }

    // MARK: - Helpers

    /// Renders a key-value info row.
    private func infoRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label).font(.sansCaption).foregroundStyle(.secondary)
            Spacer()
            Text(value?.isEmpty == false ? value! : "—").font(.sansCaption)
        }
    }
}

// MARK: - Private Components

/// Square thumbnail image used in the photo strip and grid.
private struct PhotoThumb: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 96, height: 144)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Horizontally scrollable strip of photo thumbnails.
private struct HorizontalPhotoStrip: View {
    let images: [UIImage]
    let onTap: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(images.indices, id: \.self) { i in
                    PhotoThumb(image: images[i]).onTapGesture { onTap(i) }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: 160)
    }
}

/// Adaptive grid layout for photos in expanded mode.
private struct PhotoGrid: View {
    let images: [UIImage]
    let onTap: (Int) -> Void

    private let cols = [GridItem(.adaptive(minimum: 96), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: cols, spacing: 12) {
            ForEach(images.indices, id: \.self) { i in
                PhotoThumb(image: images[i]).onTapGesture { onTap(i) }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

/// Paged fullscreen photo viewer with swipe navigation.
private struct PhotoFullScreenViewer: View {
    let images: [UIImage]
    @Binding var startIndex: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            TabView(selection: $startIndex) {
                ForEach(images.indices, id: \.self) { i in
                    Image(uiImage: images[i])
                        .resizable()
                        .scaledToFit()
                        .tag(i)
                        .background(Color.black)
                        .ignoresSafeArea()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .background(Color.black.ignoresSafeArea())

            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}
