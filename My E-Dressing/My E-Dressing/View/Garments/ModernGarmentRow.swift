//
//  ModernGarmentRow.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI

struct ModernGarmentRow: View {
    let garment: Garment
    @Binding var expandedGarmentId: UUID?
    let onEdit: () -> Void
    
    var isExpanded: Bool {
        return expandedGarmentId == garment.id
    }
    
    private var primaryImage: UIImage? {
        if let path = garment.primaryPhotoPath {
            return MediaStore.shared.loadImage(at: path)
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                if let image = primaryImage {
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
                    Text(garment.title ?? "Untitled")
                        .font(.headline)
                        .foregroundStyle(Color.themeSecondary)
                    
                    if let brand = garment.brand, !brand.isEmpty {
                        Text(brand.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.themePrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.themePrimary.opacity(0.1))
                            .cornerRadius(4)
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
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider().background(Color.themeSecondary.opacity(0.1))
                    
                    if let image = primaryImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .cornerRadius(12)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        DetailItem(icon: "ruler", title: "Size", value: garment.size)
                        DetailItem(icon: "paintpalette", title: "Color", value: garment.color)
                        DetailItem(icon: "tag", title: "Category", value: garment.category)
                        DetailItem(icon: "arrow.counterclockwise", title: "Worn", value: "\(garment.wearCount) times")
                    }
                    
                    Button(action: onEdit) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit / Add photos")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(Color.themePrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themePrimary.opacity(0.1))
                        .cornerRadius(10)
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
    }
}

struct DetailItem: View {
    let icon: String
    let title: String
    let value: String?
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.themeSecondary)
            VStack(alignment: .leading) {
                Text(title).font(.caption2).foregroundStyle(.secondary)
                Text(value ?? "—").font(.subheadline).fontWeight(.medium)
            }
        }
    }
}
