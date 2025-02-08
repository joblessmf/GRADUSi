//
//  WeatherModel.swift
//  GRADUSi
//
//  Created by Nikolay Simeonov on 9.02.25.
//

import Foundation

struct WeatherModel {
    let cityName: String
    let temperature: Double
    let conditionId: Int
    let description: String
    
    var temperatureString: String {
        String(format: "%.0f", temperature)
        + "°C"
    }
    
    var conditionName: String {
     switch conditionId {
     case 200...232:
         return "cloud.bolt"
         case 300...321:
         return "cloud.drizzle"
     case 500...531:
         return "cloud.rain"
     case 600...622:
         return "cloud.snow"
     case 700...781:
         return "smoke"
         case 800:
         return "customSunIcon"
         case 801...804:
         return "cloud"
     default:
         return "questionmark"
        }
    }
    
}
