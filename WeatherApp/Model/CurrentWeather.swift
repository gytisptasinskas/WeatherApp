//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Gytis Ptašinskas on 10/11/2023.
//

import Foundation

struct CurrentWeather: Codable {
    let location: Location
    let current: Current
}
