//
//  ContentView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)],
        animation: .default)
    private var dressings: FetchedResults<Dressing>
    
    @EnvironmentObject private var languageController: LanguageController

    var body: some View {
        NavigationStack {
            List {
                Section("Language") {
                    Picker("Language", selection: Binding(get: { languageController.selected }, set: { newLanguage in languageController.setLanguage(newLanguage) })) {
                        ForEach(AppLanguage.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
#if os(iOS)
                    .pickerStyle(.segmented)
#endif

                    NavigationLink("Open language settings", destination: LanguageSettingsView())

                    HStack {
                        Text("Current:")
                        Spacer()
                        Text(languageController.selected.label).foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Locale:")
                        Spacer()
                        Text(languageController.currentLocale.identifier).foregroundStyle(.secondary)
                    }
                }

                Section("Dressings") {
                    if dressings.isEmpty {
                        Text("No dressings").foregroundStyle(.secondary)
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

    private func addDressing() {
        withAnimation {
            let newDressing = Dressing(context: viewContext)
            newDressing.id = UUID()
            newDressing.name = "New dressing"
            newDressing.createdAt = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

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
    
    private func syncLanguageFromDefaults() {
        if let rawLanguageValue = UserDefaults.standard.string(forKey: "appLanguage"),
           let storedLanguage = AppLanguage(rawValue: rawLanguageValue),
           storedLanguage != languageController.selected {
            languageController.setLanguage(storedLanguage)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    let languageController = LanguageController()
    return ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(\.locale, languageController.currentLocale)
        .environmentObject(languageController)
}
