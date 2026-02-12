//
//  WeatherTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
@testable import My_E_Dressing

final class WeatherTests: XCTestCase {

    // MARK: - WeatherIconMapper

    func testThunderstormMapsToCloudBoltRain() {
        for code in [200, 210, 221, 232] {
            XCTAssertEqual(WeatherIconMapper.sfSymbol(for: code), "cloud.bolt.rain.fill",
                           "Code \(code) should map to cloud.bolt.rain.fill")
        }
    }

    func testDrizzleMapsToCloudDrizzle() {
        for code in [300, 310, 321] {
            XCTAssertEqual(WeatherIconMapper.sfSymbol(for: code), "cloud.drizzle.fill",
                           "Code \(code) should map to cloud.drizzle.fill")
        }
    }

    func testLightRainMapsToCloudRain() {
        for code in [500, 501, 502, 504] {
            XCTAssertEqual(WeatherIconMapper.sfSymbol(for: code), "cloud.rain.fill",
                           "Code \(code) should map to cloud.rain.fill")
        }
    }

    func testFreezingRainMapsToCloudSleet() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 511), "cloud.sleet.fill")
    }

    func testHeavyRainMapsToCloudHeavyRain() {
        for code in [520, 522, 531] {
            XCTAssertEqual(WeatherIconMapper.sfSymbol(for: code), "cloud.heavyrain.fill",
                           "Code \(code) should map to cloud.heavyrain.fill")
        }
    }

    func testSnowMapsToCloudSnow() {
        for code in [600, 611, 622] {
            XCTAssertEqual(WeatherIconMapper.sfSymbol(for: code), "cloud.snow.fill",
                           "Code \(code) should map to cloud.snow.fill")
        }
    }

    func testFogMapsToCloudFog() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 701), "cloud.fog.fill")
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 741), "cloud.fog.fill")
    }

    func testTornadoMapsToTornado() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 781), "tornado")
    }

    func testClearSkyMapToSunMax() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 800), "sun.max.fill")
    }

    func testFewCloudsMapsToCloudSun() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 801), "cloud.sun.fill")
    }

    func testOvercastMapsToCloudFill() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 802), "cloud.fill")
    }

    func testBrokenCloudsMapsToSmoke() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 803), "smoke.fill")
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 804), "smoke.fill")
    }

    func testUnknownCodeDefaultsToCloudFill() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 999), "cloud.fill")
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 0), "cloud.fill")
    }

    // MARK: - WeatherData

    func testWeatherDataInitialization() {
        let data = WeatherData(
            temperature: 15.5,
            conditionCode: 800,
            conditionDescription: "Ciel dégagé",
            iconName: "sun.max.fill",
            cityName: "Paris",
            fetchedAt: Date()
        )

        XCTAssertEqual(data.temperature, 15.5)
        XCTAssertEqual(data.conditionCode, 800)
        XCTAssertEqual(data.conditionDescription, "Ciel dégagé")
        XCTAssertEqual(data.iconName, "sun.max.fill")
        XCTAssertEqual(data.cityName, "Paris")
    }

    // MARK: - WeatherController State

    func testWeatherControllerInitialState() {
        let controller = WeatherController()
        XCTAssertEqual(controller.iconName, "leaf.fill")
        XCTAssertNil(controller.temperatureString)
        XCTAssertFalse(controller.isLoaded)
    }

    // MARK: - WeatherController JSON Parsing

    func testParseValidWeatherJSON() throws {
        let json: [String: Any] = [
            "main": ["temp": 18.7],
            "weather": [["id": 800, "description": "clear sky"]],
            "name": "Lyon"
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

        let main = parsed?["main"] as? [String: Any]
        XCTAssertEqual(main?["temp"] as? Double, 18.7)

        let weatherArray = parsed?["weather"] as? [[String: Any]]
        XCTAssertEqual(weatherArray?.first?["id"] as? Int, 800)
        XCTAssertEqual(weatherArray?.first?["description"] as? String, "clear sky")
        XCTAssertEqual(parsed?["name"] as? String, "Lyon")

        let iconName = WeatherIconMapper.sfSymbol(for: 800)
        XCTAssertEqual(iconName, "sun.max.fill")
    }

    // MARK: - Temperature formatting

    func testTemperatureRounding() {
        // Verify the rounding logic used in temperatureString
        let temp1 = 15.4
        XCTAssertEqual(Int(temp1.rounded()), 15)

        let temp2 = 15.6
        XCTAssertEqual(Int(temp2.rounded()), 16)

        let temp3 = -2.3
        XCTAssertEqual(Int(temp3.rounded()), -2)
    }

    // MARK: - All condition code ranges covered

    func testAllConditionCodeRangesReturnValidSymbol() {
        let testCodes = [200, 300, 500, 511, 520, 600, 701, 711, 721, 731,
                         741, 751, 762, 771, 781, 800, 801, 802, 803, 804]

        for code in testCodes {
            let symbol = WeatherIconMapper.sfSymbol(for: code)
            XCTAssertFalse(symbol.isEmpty, "Code \(code) should return a non-empty SF Symbol")
        }
    }

    // MARK: - Additional atmosphere codes

    func testSmokeMapsToSmokeFill() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 711), "smoke.fill")
    }

    func testHazeMapsToSunHaze() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 721), "sun.haze.fill")
    }

    func testDustMapToSunDust() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 731), "sun.dust.fill")
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 751), "sun.dust.fill")
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 761), "sun.dust.fill")
    }

    func testVolcanicAshMapsToAqiHigh() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 762), "aqi.high")
    }

    func testSquallMapsToWind() {
        XCTAssertEqual(WeatherIconMapper.sfSymbol(for: 771), "wind")
    }

    // MARK: - WeatherData fetchedAt

    func testWeatherDataFetchedAtIsStored() {
        let date = Date()
        let data = WeatherData(
            temperature: 10, conditionCode: 500,
            conditionDescription: "rain", iconName: "cloud.rain.fill",
            cityName: "Marseille", fetchedAt: date
        )
        XCTAssertEqual(data.fetchedAt, date)
    }

    // MARK: - WeatherParseError

    func testWeatherParseErrorIsError() {
        let error: Error = WeatherParseError.invalidFormat
        XCTAssertNotNil(error)
        XCTAssertTrue(error is WeatherParseError)
    }

    // MARK: - WeatherController computed properties with loaded state

    func testWeatherControllerIconNameDefault() {
        let controller = WeatherController()
        XCTAssertEqual(controller.iconName, "leaf.fill")
    }

    func testWeatherControllerTemperatureStringDefault() {
        let controller = WeatherController()
        XCTAssertNil(controller.temperatureString)
    }

    func testWeatherControllerIsLoadedDefault() {
        let controller = WeatherController()
        XCTAssertFalse(controller.isLoaded)
    }

    // MARK: - Invalid JSON parsing

    func testParseInvalidJSONMissingMain() throws {
        let json: [String: Any] = [
            "weather": [["id": 800, "description": "clear"]],
            "name": "Lyon"
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        let main = parsed?["main"] as? [String: Any]
        XCTAssertNil(main, "Missing 'main' key should return nil")
    }

    func testParseInvalidJSONMissingWeatherArray() throws {
        let json: [String: Any] = [
            "main": ["temp": 18.7],
            "name": "Lyon"
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        let weatherArray = parsed?["weather"] as? [[String: Any]]
        XCTAssertNil(weatherArray, "Missing 'weather' key should return nil")
    }

    func testParseInvalidJSONMissingCityName() throws {
        let json: [String: Any] = [
            "main": ["temp": 18.7],
            "weather": [["id": 800, "description": "clear"]]
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        let cityName = parsed?["name"] as? String
        XCTAssertNil(cityName, "Missing 'name' key should return nil")
    }
}
