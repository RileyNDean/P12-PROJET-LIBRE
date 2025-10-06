//
//  ContentView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI
import CoreData

/// Root view displaying the list of `Dressing` objects from Core Data.
/// In MVC terms, this view is the "View" layer: it renders UI and forwards
/// user intents (add/delete) to the model via the managed object context.

/// The main list screen for dressings.
struct ContentView: View {
    /// Core Data managed object context injected via the environment.
    @Environment(\.managedObjectContext) private var viewContext

    /// Live fetch request providing the current list of `Dressing` objects.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)],
        animation: .default)
    private var dressings: FetchedResults<Dressing>
    
    @EnvironmentObject private var lang: LanguageController

    var body: some View {
        NavigationStack {
            List {
                Section("Langue / Language") {
                    Picker("Language", selection: Binding(get: { lang.selected }, set: { lang.setLanguage($0) })) {
                        ForEach(AppLanguage.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
#if os(iOS)
                    .pickerStyle(.segmented)
#endif

                    NavigationLink("Ouvrir les réglages de langue", destination: LanguageSettingsView())

                    HStack {
                        Text("Actuelle :")
                        Spacer()
                        Text(lang.selected.label).foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Locale :")
                        Spacer()
                        Text(lang.currentLocale.identifier).foregroundStyle(.secondary)
                    }
                }

                Section("Dressings") {
                    if dressings.isEmpty {
                        Text("Aucun dressing").foregroundStyle(.secondary)
                    }
                    ForEach(dressings) { dressing in
                        HStack {
                            Text(dressing.name ?? "Unnamed dressing")
                            Spacer()
                            Text((dressing.createdAt ?? Date()), formatter: dateFormatter)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteDressings)
                }
            }
            .navigationTitle("My E‑Dressing")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
#endif
                ToolbarItem { Button(action: addDressing) { Label("Add Dressing", systemImage: "plus") } }
            }
        }
        .onAppear { syncLanguageFromDefaults() }
    }

    /// Creates a new `Dressing` with default values and saves it to Core Data.
    private func addDressing() {
        withAnimation {
            let newDressing = Dressing(context: viewContext)
            newDressing.id = UUID()
            newDressing.name = "Nouveau dressing"
            newDressing.createdAt = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /// Deletes selected `Dressing` objects and persists the change.
    private func deleteDressings(offsets: IndexSet) {
        withAnimation {
            offsets.map { dressings[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// Syncs LanguageController with the persisted UserDefaults value (used after returning from settings).
    private func syncLanguageFromDefaults() {
        if let raw = UserDefaults.standard.string(forKey: "appLanguage"),
           let stored = AppLanguage(rawValue: raw),
           stored != lang.selected {
            lang.setLanguage(stored)
        }
    }
}

/// Shared date formatter for displaying creation dates.
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    let lang = LanguageController()
    return ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(\.locale, lang.currentLocale)
        .environmentObject(lang)
}
