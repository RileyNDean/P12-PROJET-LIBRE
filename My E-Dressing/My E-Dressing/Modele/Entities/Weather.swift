//
//  Weather.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import Foundation

/// Represents the current weather data fetched from OpenWeatherMap.
struct WeatherData {
    let temperature: Double
    let conditionCode: Int
    let conditionDescription: String
    let iconName: String
    let cityName: String
    let fetchedAt: Date
}

/// Maps OpenWeatherMap condition codes to SF Symbols.
enum WeatherIconMapper {

    /// Returns an SF Symbol name for the given OpenWeatherMap condition code.
    static func sfSymbol(for conditionCode: Int) -> String {
        switch conditionCode {
        case 200...232: return "cloud.bolt.rain.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...504: return "cloud.rain.fill"
        case 511:       return "cloud.sleet.fill"
        case 520...531: return "cloud.heavyrain.fill"
        case 600...622: return "cloud.snow.fill"
        case 701:       return "cloud.fog.fill"
        case 711:       return "smoke.fill"
        case 721:       return "sun.haze.fill"
        case 731, 761:  return "sun.dust.fill"
        case 741:       return "cloud.fog.fill"
        case 751:       return "sun.dust.fill"
        case 762:       return "aqi.high"
        case 771:       return "wind"
        case 781:       return "tornado"
        case 800:       return "sun.max.fill"
        case 801:       return "cloud.sun.fill"
        case 802:       return "cloud.fill"
        case 803, 804:  return "smoke.fill"
        default:        return "cloud.fill"
        }
    }
}

/// Error thrown when the API response cannot be parsed.
enum WeatherParseError: Error {
    case invalidFormat
}
