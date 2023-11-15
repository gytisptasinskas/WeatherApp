//
//  ViewController.swift
//  WeatherApp
//
//  Created by Gytis Ptašinskas on 10/11/2023.
//

import UIKit
import Alamofire
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var backgroundColor: UIView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var mainTempLabel: UILabel!
    @IBOutlet weak var feelLikeLabel: UILabel!
    @IBOutlet weak var texfieldInput: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var textfieldAndButtonStackBottomConstraint: NSLayoutConstraint!
    
    let apiKey:String = "b0441acdb1msh70d9957e8759edep19ec80jsn299e0bab0fe8"
    let apiHost:String = "weatherapi-com.p.rapidapi.com"
    let apiUrl:String = "https://weatherapi-com.p.rapidapi.com/current.json"
    let city: String = "New York"
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentWeather: CurrentWeather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        loadWeatherData(for: city)
        setupKeyboardNotifications()
        UIStyling()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            locationManager.stopUpdatingLocation()
            loadWeatherData(location: location)
        }
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadWeatherData(for city: String = "New York", location: CLLocation? = nil) {
        let headers: [String: String] = ["X-RapidAPI-Key": apiKey, "X-RapidAPI-Host": apiHost]
        
        var params: [String: String]
        if let location = location {
            params = ["q": "\(location.coordinate.latitude),\(location.coordinate.longitude)"]
        } else {
            params = ["q": city]
        }
        
        AF.request(apiUrl, method: .get, parameters: params, headers: HTTPHeaders(headers)).responseDecodable(of: CurrentWeather.self) { response in
            switch response.result {
            case .success(let value):
                self.currentWeather = value
                self.updateUIWithWeatherData()
                if let isDay = value.current.isDay {
                    self.updateBackgroundGradient(isDay: isDay == 1)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func updateUIWithWeatherData() {
        if let weather = currentWeather {
            cityLabel.text = weather.location.name
            mainTempLabel.text = "\(weather.current.tempC ?? 0)°C"
            feelLikeLabel.text = "Feels like \(weather.current.feelslikeC ?? 0)°C"
        }
    }
    
    func updateBackgroundGradient(isDay: Bool) {
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.backgroundColor.bounds
            
            // Update label colors based on day or night
            let labelColor = isDay ? UIColor.black : UIColor.white
            self.cityLabel.textColor = labelColor
            self.mainTempLabel.textColor = labelColor
            self.feelLikeLabel.textColor = labelColor
            
            // Set background gradient for day or night
            if isDay {
                gradientLayer.colors = [UIColor.white.cgColor, UIColor.systemCyan.cgColor]
            } else {
                gradientLayer.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
            }
            
            self.backgroundColor.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            self.backgroundColor.layer.insertSublayer(gradientLayer, at: 0)
            
            print("Background and label colors updated: \(isDay ? "Day" : "Night")")
        }
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        if let city = texfieldInput.text, !city.isEmpty {
            loadWeatherData(for: city)
            texfieldInput.text = ""
        }
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.textfieldAndButtonStackBottomConstraint.constant = keyboardSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.textfieldAndButtonStackBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func UIStyling() {
        texfieldInput.layer.cornerRadius = 16.0
        texfieldInput.placeholder = "Enter city here"
        
        // Styling the button
        confirmButton.backgroundColor = UIColor.systemBlue
        confirmButton.tintColor = UIColor(.white)
        confirmButton.layer.cornerRadius = 16.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
