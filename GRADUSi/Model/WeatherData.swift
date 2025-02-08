//
//  WeatherData.swift
//  GRADUSi
//
//  Created by Nikolay Simeonov on 9.02.25.
//

import Foundation

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let description: String
}
