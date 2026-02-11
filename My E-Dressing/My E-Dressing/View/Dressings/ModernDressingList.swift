//
//  ModernDressingList.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI
import CoreData

struct ModernDressingList: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)])
    var dressings: FetchedResults<Dressing>
    
    @State private var showNewDressing = false
    @State private var dressingToEdit: Dressing?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.themeBackground.ignoresSafeArea()
                
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
                
                Button { showNewDressing = true } label: {
                    HStack {
                        Image(systemName: "cabinet")
                        Text(String(localized: "new"))
                    }
                    .padding()
                    .background(Color.themeSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 5)
                }
                .padding()
            }
            .navigationTitle(String(localized: "my_dressings"))
            .sheet(isPresented: $showNewDressing) {
                ModernDressingFormView(editingDressing: nil)
            }
            .sheet(item: $dressingToEdit) { dressing in
                ModernDressingFormView(editingDressing: dressing)
            }
        }
    }
}

struct DressingRowCard: View {
    @ObservedObject var dressing: Dressing
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Color.themeSecondary.opacity(0.1)
                Image(systemName: "cabinet")
                    .font(.largeTitle)
                    .foregroundStyle(Color.themeSecondary)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dressing.name ?? String(localized: "dressing"))
                    .font(.headline)
                    .foregroundStyle(Color.themeSecondary)

                Text(String(format: String(localized: "garments_count"), dressing.garments?.count ?? 0))
                    .font(.subheadline)
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







