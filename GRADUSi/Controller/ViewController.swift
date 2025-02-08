//
//  ViewController.swift
//  GRADUSi
//
//  Created by Nikolay Simeonov on 8.02.25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    var blurEffectView: UIVisualEffectView!
    
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var conditionText: UILabel!
    @IBOutlet weak var conditionIcon: UIImageView!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var locationButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        weatherManager.delegate = self
        searchField.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let blur = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blur)
            blurEffectView.frame = view.bounds
            blurEffectView.alpha = 0
        view.addSubview(blurEffectView)
        

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSearch))
            blurEffectView.addGestureRecognizer(tapGesture)
        bringsSubviewsToFront()
        }
    
    func bringsSubviewsToFront() {
        view.bringSubviewToFront(searchField)
        view.bringSubviewToFront(locationButton)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @objc func dismissSearch() {
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView.alpha = 0
        }
        searchField.resignFirstResponder()
    }
}

//MARK: - SearchFieldDelegate
extension ViewController:  UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            UIView.animate(withDuration: 0.3) {
                self.blurEffectView.alpha = 1
            }
        }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let cityName = searchBar.text {
            weatherManager.fetchWeather(cityName: cityName)
        }
        searchBar.text = ""
        searchBar.resignFirstResponder()
        dismissSearch()
    }
    
    // Метод за повдигане на само SearchField при показване на клавиатурата
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            // Проверяваме дали SearchField е близо до долната част
            if searchField.frame.maxY > (view.frame.height - keyboardHeight) {
                let offset = (searchField.frame.maxY - (view.frame.height - keyboardHeight)) + 50
                
                UIView.animate(withDuration: 0.3) {
                    self.searchField.transform = CGAffineTransform(translationX: 0, y: -offset)
                }
            }
        }
    }
    //връщане на SearchField обратно
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.searchField.transform = .identity
        }
    }
}

//MARK: - WeatherManagerDelegate
extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityName.text = weather.cityName.uppercased()
            self.tempLabel.text = weather.temperatureString
            if let customIcon = UIImage(named: weather.conditionName) {
                self.conditionIcon.image = customIcon
            } else {
                self.conditionIcon.image = UIImage(systemName: weather.conditionName)
            }
            self.conditionText.text = weather.description.uppercased()
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(lat: lat, lon: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("Достъпът до локация е отказан.")
            case .locationUnknown:
                print("Локацията не може да бъде определена в момента.")
            default:
                print("Грешка при локацията: \(clError.localizedDescription)")
            }
        } else {
            print("Неизвестна грешка: \(error.localizedDescription)")
        }
    }
}
