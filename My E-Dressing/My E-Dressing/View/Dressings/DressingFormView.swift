//
//  DressingFormView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import CoreData

struct DressingFormView: View {
    // MARK: - Environnement / dépendances

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    // MARK: - Entrées

    var editingDressing: Dressing?
    var onSaved: ((Dressing) -> Void)?

    // MARK: - State

    @State private var nameText: String = ""
    @State private var selectedEmoji: String = "👗"

    // Tu pourras plus tard binder ceci à Core Data si tu ajoutes des champs
    // @State private var selectedColorHex: String = "D96C45"

    private let emojiOptions = ["👗", "🧥", "👕", "👖", "👟", "👜", "🎒", "🧣", "🧢"]

    // MARK: - Init

    init(editingDressing: Dressing? = nil,
         onSaved: ((Dressing) -> Void)? = nil) {
        self.editingDressing = editingDressing
        self.onSaved = onSaved

        // Pré-remplissage des champs
        _nameText = State(initialValue: editingDressing?.name ?? "")
        // Si plus tard tu as un champ "icon" dans Core Data, tu initialiseras selectedEmoji ici
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppTheme.paddingLarge) {
                        previewCard
                        iconSection
                        infoSection
                    }
                    .padding(.horizontal, AppTheme.paddingMedium)
                    .padding(.top, AppTheme.paddingMedium)
                    .padding(.bottom, AppTheme.paddingXLarge)
                }
            }
        }
    }

    // MARK: - Sous-vues

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("Annuler")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                    )
                    .appShadow()
            }

            Spacer()

            Button(action: { save() }) {
                Text(editingDressing == nil ? "Créer" : "Enregistrer")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(canSave ? AppTheme.primary : AppTheme.primary.opacity(0.4))
                    )
                    .appShadow(AppTheme.shadowMedium)
            }
            .disabled(!canSave)
        }
        .padding(.horizontal, AppTheme.paddingMedium)
        .padding(.top, AppTheme.paddingLarge)
        .padding(.bottom, AppTheme.paddingMedium)
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(editingDressing == nil ? "Nouveau dressing" : "Modifier le dressing")
                .font(AppTheme.titleFont)
                .foregroundColor(.black)

            Text("Visualise ton dressing comme il apparaîtra dans la liste.")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Text(selectedEmoji)
                        .font(.system(size: 30))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(nameText.isEmpty ? "Mon dressing" : nameText)
                        .font(AppTheme.headlineFont)
                        .foregroundColor(.black)

                    Text("0 vêtement")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(AppTheme.paddingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .appShadow()
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icône du dressing")
                .font(AppTheme.headlineFont)
                .foregroundColor(.black)

            Text("Choisis un emoji qui représentera ce dressing dans la liste.")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 24))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji
                                              ? AppTheme.primary.opacity(0.2)
                                              : Color.white)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(selectedEmoji == emoji
                                                ? AppTheme.primary
                                                : AppTheme.borderColor,
                                                lineWidth: selectedEmoji == emoji ? 2 : 1)
                                )
                                .appShadow(selectedEmoji == emoji ? AppTheme.shadowLight : AppTheme.shadowLight)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(AppTheme.paddingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .appShadow()
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informations")
                .font(AppTheme.headlineFont)
                .foregroundColor(.black)

            VStack(spacing: 10) {
                TextField("Nom du dressing", text: $nameText)
                    .font(AppTheme.bodyFont)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                            .fill(AppTheme.background)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                            .stroke(AppTheme.borderColor, lineWidth: 1)
                    )
            }
        }
        .padding(AppTheme.paddingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .appShadow()
    }

    // MARK: - Logique

    private var canSave: Bool {
        !nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard canSave else { return }

         func save() {
            do {
                let dressingController = DressingController(managedObjectContext: context)
                let savedDressing: Dressing
                if let dressing = editingDressing {
                    try dressingController.rename(dressing, to: nameText, to: selectedEmoji)
                    savedDressing = dressing
                } else {
                    savedDressing = try dressingController.create(name: nameText, icon: selectedEmoji)
                }
                dismiss()
                onSaved?(savedDressing)
            } catch {}
        }

        dismiss()
    }
}




