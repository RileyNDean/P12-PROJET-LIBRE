//
//  WeatherController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import Foundation
import Combine
import CoreLocation

/// Fetches and caches current weather data using CoreLocation and OpenWeatherMap.
final class WeatherController: NSObject, ObservableObject {

    enum WeatherState {
        case idle
        case loading
        case loaded(WeatherData)
        case error
    }

    @Published private(set) var state: WeatherState = .idle

    var iconName: String {
        if case .loaded(let data) = state { return data.iconName }
        return "leaf.fill"
    }

    var temperatureString: String? {
        if case .loaded(let data) = state {
            return "\(Int(data.temperature.rounded()))°"
        }
        return nil
    }

    var isLoaded: Bool {
        if case .loaded = state { return true }
        return false
    }

    private let locationManager = CLLocationManager()
    private var cachedWeather: WeatherData?
    private let cacheInterval: TimeInterval = 30 * 60

    /// Sets up the location manager.
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Requests a weather refresh. Uses cache if data is less than 30 minutes old.
    func refresh() {
        if let cached = cachedWeather,
           Date().timeIntervalSince(cached.fetchedAt) < cacheInterval {
            state = .loaded(cached)
            return
        }

        let authStatus = locationManager.authorizationStatus
        switch authStatus {
        case .notDetermined:
            state = .loading
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            state = .loading
            locationManager.requestLocation()
        case .denied, .restricted:
            state = .error
        @unknown default:
            state = .error
        }
    }

    /// Calls the OpenWeatherMap API.
    private func fetchWeather(latitude: Double, longitude: Double) {
        let apiKey = APIKeys.openWeatherMap
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&lang=fr&appid=\(apiKey)"

        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { self.state = .error }
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self else { return }

                if error != nil {
                    self.state = .error
                    return
                }

                guard let data else {
                    self.state = .error
                    return
                }

                do {
                    let weather = try self.parseWeatherJSON(data)
                    self.cachedWeather = weather
                    self.state = .loaded(weather)
                } catch {
                    self.state = .error
                }
            }
        }.resume()
    }

    /// Parses the JSON response into a WeatherData.
    private func parseWeatherJSON(_ data: Data) throws -> WeatherData {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let main = json["main"] as? [String: Any],
              let temp = main["temp"] as? Double,
              let weatherArray = json["weather"] as? [[String: Any]],
              let firstWeather = weatherArray.first,
              let conditionCode = firstWeather["id"] as? Int,
              let description = firstWeather["description"] as? String,
              let cityName = json["name"] as? String
        else {
            throw WeatherParseError.invalidFormat
        }

        return WeatherData(
            temperature: temp,
            conditionCode: conditionCode,
            conditionDescription: description,
            iconName: WeatherIconMapper.sfSymbol(for: conditionCode),
            cityName: cityName,
            fetchedAt: Date()
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherController: CLLocationManagerDelegate {

    /// Called when a location is received.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchWeather(latitude: location.coordinate.latitude,
                     longitude: location.coordinate.longitude)
    }

    /// Called when location fails.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.state = .error
        }
    }

    /// Called when authorization status changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            state = .loading
            manager.requestLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.state = .error
            }
        default:
            break
        }
    }
}
