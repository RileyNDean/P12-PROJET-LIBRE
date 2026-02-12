//
//  ModernDressingList.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI
import CoreData

/// Main list screen showing all user dressings with add/edit/delete capabilities.
struct ModernDressingList: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)])
    var dressings: FetchedResults<Dressing>
    
    @State private var showNewDressing = false
    @State private var dressingToEdit: Dressing?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()

                if dressings.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cabinet.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.themeSecondary.opacity(0.18))

                        Text(String(localized: "empty_dressings_title"))
                            .font(.serifHeadline)
                            .foregroundStyle(Color.themeSecondary.opacity(0.5))

                        Text(String(localized: "empty_dressings_subtitle"))
                            .font(.sansCaption)
                            .foregroundStyle(Color.themeSecondary.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dressings) { dressing in
                            ZStack {
                                NavigationLink(destination: ModernGarmentListView(dressing: dressing)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                DressingRowCard(dressing: dressing)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewContext.delete(dressing)
                                    try? viewContext.save()
                                } label: {
                                    Label(String(localized: "delete"), systemImage: "trash")
                                }

                                Button {
                                    dressingToEdit = dressing
                                } label: {
                                    Label(String(localized: "edit"), systemImage: "pencil")
                                }
                                .tint(Color.themePrimary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "my_dressings"))
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button { showNewDressing = true } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 56, height: 56)
                        .background(Color.themeSecondary)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 100)
            }
            .overlay {
                if showNewDressing || dressingToEdit != nil {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showNewDressing = false
                            dressingToEdit = nil
                        }
                        .transition(.opacity)

                    ModernDressingFormView(
                        editingDressing: dressingToEdit,
                        onDismiss: {
                            showNewDressing = false
                            dressingToEdit = nil
                        }
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showNewDressing)
            .animation(.easeInOut(duration: 0.25), value: dressingToEdit)
        }
    }
}

/// A card row displaying a dressing's icon, name and garment count.
struct DressingRowCard: View {
    @ObservedObject var dressing: Dressing

    private var dressingColor: Color {
        Color(hex: dressing.colorHex ?? DressingColor.defaultHex)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                dressingColor.opacity(0.15)
                Image(systemName: dressing.iconName ?? DressingIcon.defaultIcon)
                    .font(.largeTitle)
                    .foregroundStyle(dressingColor)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dressing.name ?? String(localized: "dressing"))
                    .font(.serifHeadline)
                    .foregroundStyle(Color.themeSecondary)

                Text(String(format: String(localized: "garments_count"), dressing.garments?.count ?? 0))
                    .font(.sansSubheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.themeSecondary.opacity(0.3))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}







