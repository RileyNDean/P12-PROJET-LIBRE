//
//  GarmentCardView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import UIKit
import CoreData

struct GarmentCardView: View {
    let garment: Garment
    let onEdit: () -> Void

    @State private var isExpanded = false

    private var images: [UIImage] {
        garment.orderedPhotos.compactMap { $0.path }.compactMap { MediaStore.shared.loadImage(at: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isExpanded {
                if let first = images.first {
                    Image(uiImage: first)
                        .resizable().scaledToFill()
                        .frame(height: 220).clipped().cornerRadius(12)
                }
            } else {
                collageView(images: images)
            }

            HStack {
                Text(garment.title ?? "").font(.headline)
                Spacer()
                if let wear = garment.value(forKey: "wearCount") as? Int32, wear > 0 {
                    Label("×\(wear)", systemImage: "tshirt")
                        .font(.caption).padding(6)
                        .background(Color.gray.opacity(0.15)).cornerRadius(8)
                }
            }

            Text(GarmentStatus(rawValue: garment.statusRaw)?.label ?? "")
                .font(.subheadline).foregroundStyle(.secondary)

            if isExpanded {
                // Toutes les photos en grille
                if images.count > 1 {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(images.indices, id: \.self) { idx in
                            Image(uiImage: images[idx])
                                .resizable().scaledToFill()
                                .frame(height: 90).clipped().cornerRadius(8)
                        }
                    }
                }
                // Détails
                VStack(alignment: .leading, spacing: 6) {
                    infoRow("Marque", garment.brand)
                    infoRow("Couleur", garment.color)
                    infoRow("Taille", garment.size)
                    infoRow("Catégorie", garment.category)
                    if let notes = garment.notes, !notes.isEmpty {
                        Text(notes).font(.footnote).foregroundStyle(.secondary).padding(.top, 4)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .overlay(alignment: .topTrailing) {
            if isExpanded {
                Button(action: onEdit) {
                    Image(systemName: "pencil").padding(8)
                }
                .background(.ultraThinMaterial, in: Circle()).padding(8)
            }
        }
        .onTapGesture { withAnimation(.easeInOut) { isExpanded.toggle() } }
    }

    // MARK: helpers
    private func infoRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Spacer()
            Text(value?.isEmpty == false ? value! : "—").font(.caption)
        }
    }

    /// Affiche 1, 2, 3 ou 4 vignettes avec "+X" sur la dernière si >4.
    @ViewBuilder
    private func collageView(images: [UIImage]) -> some View {
        let count = images.count
        if count <= 1 {
            Image(uiImage: images.first ?? UIImage())
                .resizable().scaledToFill()
                .frame(height: 140).clipped().cornerRadius(12)
        } else {
            let shown = Array(images.prefix(4))
            let extra = max(0, count - 4)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(shown.indices, id: \.self) { idx in
                    ZStack {
                        Image(uiImage: shown[idx]).resizable().scaledToFill()
                        if extra > 0 && idx == 3 {
                            Rectangle().fill(.ultraThinMaterial)
                            Text("+\(extra) photos").font(.headline).bold()
                        }
                    }
                    .frame(height: 80).clipped().cornerRadius(10)
                }
            }
            .frame(height: 168)
        }
    }
}
