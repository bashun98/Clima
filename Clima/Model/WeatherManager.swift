//
//  WeatherManager.swift
//  Clima
//
//  Created by Евгений Башун on 11.02.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate: AnyObject {
    func getModel(weatherModel: WeatherModel)
    func didFail(with error: Error)
}

protocol WeatherManagerDescription {
    var output: WeatherManagerDelegate? { get set }
    func fetchWeather(cityName: String)
    func perfomRequest(with urlString: String)
    func parseJSON(_ data: Data) -> WeatherModel?
}

struct WeatherManager: WeatherManagerDescription {
    static let shared: WeatherManagerDescription = WeatherManager()
    static let appId = "22524f29e63ff1d044e0dbbf24b4a329"
    weak var output: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&units=metric&appid=\(Self.appId)"
        perfomRequest(with: urlString)
    }
    
    func perfomRequest(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                output?.didFail(with: error!)
                return
            }
            if let data = data {
                guard let weatherModel = parseJSON(data) else {return}
                output?.getModel(weatherModel: weatherModel)
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let id = decodedData.weather[0].id
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            output?.didFail(with: error)
            return nil
        }
    }
}
