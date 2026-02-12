//
//  GarmentCategory.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import Foundation

/// Represents a garment category with an icon and a localized label.
struct GarmentCategory: Identifiable, Hashable {
    let id: String          // Stored in Core Data (e.g. "hoodie")
    let iconName: String    // Image asset name (e.g. "hoodie")
    let labelKey: String    // Localization key (e.g. "category_hoodie")

    var label: String { String(localized: String.LocalizationValue(labelKey)) }
}

/// Groups categories into named sections for the picker grid.
struct CategorySection: Identifiable {
    let id: String
    let titleKey: String
    let categories: [GarmentCategory]

    var title: String { String(localized: String.LocalizationValue(titleKey)) }
}

// MARK: - Category Catalog

/// Static catalog providing all garment categories organized by section.
enum GarmentCategoryCatalog {

    // MARK: Hauts

    static let tshirtColRond     = GarmentCategory(id: "tshirt-col-rond", iconName: "tshirt-col-rond", labelKey: "category_tshirt_col_rond")
    static let tshirtColV        = GarmentCategory(id: "tshirt-col-v", iconName: "tshirt-col-v", labelKey: "category_tshirt_col_v")
    static let polo              = GarmentCategory(id: "polo", iconName: "polo", labelKey: "category_polo")
    static let debardeur         = GarmentCategory(id: "debardeur", iconName: "debardeur", labelKey: "category_debardeur")
    static let chemiseManches    = GarmentCategory(id: "chemise-manches-longues", iconName: "chemise-manches-longues", labelKey: "category_chemise_manches_longues")
    static let chemisierColOuvert = GarmentCategory(id: "chemisier-col-ouvert", iconName: "chemisier-col-ouvert", labelKey: "category_chemisier_col_ouvert")
    static let blouseLavalliere  = GarmentCategory(id: "blouse-lavalliere", iconName: "blouse-lavalliere", labelKey: "category_blouse_lavalliere")

    // MARK: Pulls & Sweats

    static let pullColV          = GarmentCategory(id: "pull-col-v", iconName: "pull-col-v", labelKey: "category_pull_col_v")
    static let sweatshirtColRond = GarmentCategory(id: "sweatshirt-col-rond", iconName: "sweatshirt-col-rond", labelKey: "category_sweatshirt_col_rond")
    static let sweatshirtColMontant = GarmentCategory(id: "sweatshirt-col-montant", iconName: "sweatshirt-col-montant", labelKey: "category_sweatshirt_col_montant")
    static let hoodie            = GarmentCategory(id: "hoodie", iconName: "hoodie", labelKey: "category_hoodie")
    static let cardigan          = GarmentCategory(id: "cardigan", iconName: "cardigan", labelKey: "category_cardigan")

    // MARK: Bas

    static let jean              = GarmentCategory(id: "jean", iconName: "jean", labelKey: "category_jean")
    static let pantalonChino     = GarmentCategory(id: "pantalon-chino", iconName: "pantalon-chino", labelKey: "category_pantalon_chino")
    static let short             = GarmentCategory(id: "short", iconName: "short", labelKey: "category_short")
    static let jupe              = GarmentCategory(id: "jupe", iconName: "jupe", labelKey: "category_jupe")
    static let jupeLongue        = GarmentCategory(id: "jupe-longue", iconName: "jupe-longue", labelKey: "category_jupe_longue")
    static let legging           = GarmentCategory(id: "legging", iconName: "legging", labelKey: "category_legging")
    static let jogging           = GarmentCategory(id: "jogging", iconName: "jogging", labelKey: "category_jogging")

    // MARK: Robes & Combinaisons

    static let robeEvasee        = GarmentCategory(id: "robe-evasee", iconName: "robe-evasee", labelKey: "category_robe_evasee")
    static let robeLongue        = GarmentCategory(id: "robe-longue", iconName: "robe-longue", labelKey: "category_robe_longue")
    static let combinaison       = GarmentCategory(id: "combinaison", iconName: "combinaison", labelKey: "category_combinaison")
    static let salopette         = GarmentCategory(id: "salopette", iconName: "salopette", labelKey: "category_salopette")

    // MARK: Vestes & Manteaux

    static let blazer            = GarmentCategory(id: "blazer", iconName: "blazer", labelKey: "category_blazer")
    static let vesteLegere       = GarmentCategory(id: "veste-legere", iconName: "veste-legere", labelKey: "category_veste_legere")
    static let blousonZippe      = GarmentCategory(id: "blouson-zippe", iconName: "blouson-zippe", labelKey: "category_blouson_zippe")
    static let manteauCroise     = GarmentCategory(id: "manteau-croise", iconName: "manteau-croise", labelKey: "category_manteau_croise")
    static let costume           = GarmentCategory(id: "costume", iconName: "costume", labelKey: "category_costume")
    static let giletSansManches  = GarmentCategory(id: "gilet-sans-manches", iconName: "gilet-sans-manches", labelKey: "category_gilet_sans_manches")

    // MARK: Sous-vetements & Nuit

    static let soutienGorge      = GarmentCategory(id: "soutien-gorge", iconName: "soutien-gorge", labelKey: "category_soutien_gorge")
    static let brassiereSport    = GarmentCategory(id: "brassiere-sport", iconName: "brassiere-sport", labelKey: "category_brassiere_sport")
    static let culotte           = GarmentCategory(id: "culotte", iconName: "culotte", labelKey: "category_culotte")
    static let boxer             = GarmentCategory(id: "boxer", iconName: "boxer", labelKey: "category_boxer")
    static let pyjama            = GarmentCategory(id: "pyjama", iconName: "pyjama", labelKey: "category_pyjama")
    static let nuisette          = GarmentCategory(id: "nuisette", iconName: "nuisette", labelKey: "category_nuisette")
    static let peignoir          = GarmentCategory(id: "peignoir", iconName: "peignoir", labelKey: "category_peignoir")

    // MARK: Sport

    static let maillotSport      = GarmentCategory(id: "maillot-sport", iconName: "maillot-sport", labelKey: "category_maillot_sport")
    static let shortSport        = GarmentCategory(id: "short-sport", iconName: "short-sport", labelKey: "category_short_sport")
    static let vesteSurvetement  = GarmentCategory(id: "veste-survetement", iconName: "veste-survetement", labelKey: "category_veste_survetement")

    // MARK: Maillots de bain

    static let bikini            = GarmentCategory(id: "bikini", iconName: "bikini", labelKey: "category_bikini")
    static let maillot1Piece     = GarmentCategory(id: "maillot-1-piece", iconName: "maillot-1-piece", labelKey: "category_maillot_1_piece")

    // MARK: Enfant & Bebe

    static let bodyBebe          = GarmentCategory(id: "body-bebe", iconName: "body-bebe", labelKey: "category_body_bebe")
    static let grenouillere      = GarmentCategory(id: "grenouillere", iconName: "grenouillere", labelKey: "category_grenouillere")
    static let robeEnfant        = GarmentCategory(id: "robe-enfant", iconName: "robe-enfant", labelKey: "category_robe_enfant")
    static let bonnetBebe        = GarmentCategory(id: "bonnet-bebe", iconName: "bonnet-bebe", labelKey: "category_bonnet_bebe")
    static let bavoir            = GarmentCategory(id: "bavoir", iconName: "bavoir", labelKey: "category_bavoir")
    static let chaussettes       = GarmentCategory(id: "chaussettes", iconName: "chaussettes", labelKey: "category_chaussettes")
    static let basketsEnfant     = GarmentCategory(id: "baskets-enfant", iconName: "baskets-enfant", labelKey: "category_baskets_enfant")
    static let couvertureBebe    = GarmentCategory(id: "couverture-bebe", iconName: "couverture-bebe", labelKey: "category_couverture_bebe")
    static let pantalonBebe      = GarmentCategory(id: "pantalon-bebe", iconName: "pantalon-bebe", labelKey: "category_pantalon_bebe")

    // MARK: Chaussures

    static let sneaker           = GarmentCategory(id: "sneaker", iconName: "sneaker", labelKey: "category_sneaker")
    static let chaussureDeVille  = GarmentCategory(id: "chaussure-de-ville", iconName: "chaussure-de-ville", labelKey: "category_chaussure_de_ville")
    static let escarpin          = GarmentCategory(id: "escarpin", iconName: "escarpin", labelKey: "category_escarpin")
    static let botte             = GarmentCategory(id: "botte", iconName: "botte", labelKey: "category_botte")
    static let sandaleTalon      = GarmentCategory(id: "sandale-talon", iconName: "sandale-talon", labelKey: "category_sandale_talon")
    static let pantoufles        = GarmentCategory(id: "pantoufles", iconName: "pantoufles", labelKey: "category_pantoufles")

    // MARK: Accessoires

    static let sacAMain          = GarmentCategory(id: "sac-a-main", iconName: "sac-a-main", labelKey: "category_sac_a_main")
    static let sacADos           = GarmentCategory(id: "sac-a-dos", iconName: "sac-a-dos", labelKey: "category_sac_a_dos")
    static let portefeuille      = GarmentCategory(id: "portefeuille", iconName: "portefeuille", labelKey: "category_portefeuille")
    static let trousse           = GarmentCategory(id: "trousse", iconName: "trousse", labelKey: "category_trousse")
    static let foulardPlie       = GarmentCategory(id: "foulard-plie", iconName: "foulard-plie", labelKey: "category_foulard_plie")
    static let echarpe           = GarmentCategory(id: "echarpe", iconName: "echarpe", labelKey: "category_echarpe")
    static let chapeau           = GarmentCategory(id: "chapeau", iconName: "chapeau", labelKey: "category_chapeau")
    static let casquette         = GarmentCategory(id: "casquette", iconName: "casquette", labelKey: "category_casquette")
    static let lunettesDeSoleil  = GarmentCategory(id: "lunettes-de-soleil", iconName: "lunettes-de-soleil", labelKey: "category_lunettes_de_soleil")
    static let gants             = GarmentCategory(id: "gants", iconName: "gants", labelKey: "category_gants")
    static let ceinture          = GarmentCategory(id: "ceinture", iconName: "ceinture", labelKey: "category_ceinture")
    static let cravate           = GarmentCategory(id: "cravate", iconName: "cravate", labelKey: "category_cravate")
    static let montre            = GarmentCategory(id: "montre", iconName: "montre", labelKey: "category_montre")
    static let collier           = GarmentCategory(id: "collier", iconName: "collier", labelKey: "category_collier")
    static let chaussettesAdulte = GarmentCategory(id: "chaussettes-adulte", iconName: "chaussettes-adulte", labelKey: "category_chaussettes_adulte")

    // MARK: - All categories (flat list)

    static let all: [GarmentCategory] = sections.flatMap(\.categories)

    // MARK: - Sections

    static let sections: [CategorySection] = [
        CategorySection(id: "tops", titleKey: "section_tops", categories: [
            tshirtColRond, tshirtColV, polo, debardeur, chemiseManches, chemisierColOuvert, blouseLavalliere
        ]),
        CategorySection(id: "knits", titleKey: "section_knits", categories: [
            pullColV, sweatshirtColRond, sweatshirtColMontant, hoodie, cardigan
        ]),
        CategorySection(id: "bottoms", titleKey: "section_bottoms", categories: [
            jean, pantalonChino, short, jupe, jupeLongue, legging, jogging
        ]),
        CategorySection(id: "dresses", titleKey: "section_dresses", categories: [
            robeEvasee, robeLongue, combinaison, salopette
        ]),
        CategorySection(id: "outerwear", titleKey: "section_outerwear", categories: [
            blazer, vesteLegere, blousonZippe, manteauCroise, costume, giletSansManches
        ]),
        CategorySection(id: "underwear", titleKey: "section_underwear", categories: [
            soutienGorge, brassiereSport, culotte, boxer, pyjama, nuisette, peignoir
        ]),
        CategorySection(id: "sport", titleKey: "section_sport", categories: [
            maillotSport, shortSport, vesteSurvetement
        ]),
        CategorySection(id: "swimwear", titleKey: "section_swimwear", categories: [
            bikini, maillot1Piece
        ]),
        CategorySection(id: "kids", titleKey: "section_kids", categories: [
            bodyBebe, grenouillere, robeEnfant, bonnetBebe, bavoir, chaussettes, basketsEnfant, couvertureBebe, pantalonBebe
        ]),
        CategorySection(id: "shoes", titleKey: "section_shoes", categories: [
            sneaker, chaussureDeVille, escarpin, botte, sandaleTalon, pantoufles
        ]),
        CategorySection(id: "accessories", titleKey: "section_accessories", categories: [
            sacAMain, sacADos, portefeuille, trousse, foulardPlie, echarpe, chapeau, casquette,
            lunettesDeSoleil, gants, ceinture, cravate, montre, collier, chaussettesAdulte
        ])
    ]

    // MARK: - Lookup

    /// Finds a category by its ID.
    static func find(by id: String?) -> GarmentCategory? {
        guard let id else { return nil }
        return all.first { $0.id == id }
    }
}
