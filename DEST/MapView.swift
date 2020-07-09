//
//  ViewController.swift
//  compass
//
//  Created by 上井一起 on 2020/06/29.
//  Copyright © 2020 上井一起. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum Segues{
	static let ToCompassView = "ToCompassView"
	static let ToSearchView = "ToSearchView"
}

class MapView: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
	@IBOutlet weak var mapView: MKMapView!
	
	let locationManager = CLLocationManager()
	let regionInMeters: Double = 10000
	
	var selectedLatitude: CLLocationDegrees?
	var selectedLongitude: CLLocationDegrees?
	
	@IBOutlet weak var searchBarButton: UIButton!
	func setConstraints(){
		searchBarButton.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 1/9, constant: 0).isActive = true
	}
		
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setConstraints()
		if (selectedLatitude != nil){
			let location = CLLocationCoordinate2D(latitude: selectedLatitude!, longitude: selectedLongitude!)
			let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters / 10, longitudinalMeters: regionInMeters / 10)
			mapView.setRegion(region, animated: true)
		}else{
			checkLocationServices()
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Segues.ToCompassView{
			let compassView = segue.destination as! CompassView
			compassView.start = locationManager.location!.coordinate
			compassView.goals = goals
			compassView.locationManager = locationManager
			locationManager.stopUpdatingLocation()
		}
		if segue.identifier == Segues.ToSearchView{}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBOutlet weak var buttonStackView: UIStackView!
	
	func setupStackView(){
		buttonStackView.alignment = .center
		buttonStackView.distribution = .fillEqually
		buttonStackView.axis = .horizontal
		buttonStackView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setupStartButton(){
		setupStackView()
		let startButton = UIButton()
		startButton.setImage(UIImage(named: "START"), for: .normal)
		buttonStackView.addArrangedSubview(startButton)
	}
	
	var goals: [CLLocationCoordinate2D] = []
	
	@IBAction func addGoals(_ sender: Any) {
		let goal = MKPointAnnotation()
		//firstGoal.title = String(count)
		goal.coordinate = getCenterLocation(for: mapView).coordinate
		goals.append(goal.coordinate)
		mapView.addAnnotation(goal)
		if goals.count == 1{
			setupStartButton()
		}
	}
	
	func getCenterLocation(for mapView: MKMapView) -> CLLocation{
		let latitude = mapView.centerCoordinate.latitude
		let longitude = mapView.centerCoordinate.longitude
		return CLLocation(latitude: latitude, longitude: longitude)
	}
	
	func centerViewOnUserLocation(){
		if let location = locationManager.location?.coordinate{
			let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
			mapView.setRegion(region, animated: true)
		}
	}
	
	func checkLocationServices(){
		if CLLocationManager.locationServicesEnabled(){
			setupLocationManager()
			checkLocationAuthorization()
		}else{
			//alert
		}
	}
	
	func setupLocationManager(){
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
	func checkLocationAuthorization(){
		switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse:
			mapView.showsUserLocation = true
			centerViewOnUserLocation()
			locationManager.startUpdatingLocation()
			break
		case .denied:
			// show alert instructing them to turn on permissions
			alertLocationAuthorization()
			break
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .restricted:
			// show alert letting them know what's up
			alertLocationAuthorization()
			break
		case .authorizedAlways:
			mapView.showsUserLocation = true
			centerViewOnUserLocation()
			locationManager.startUpdatingLocation()
			break
		@unknown default:
			break
		}
	}
	
	func alertLocationAuthorization(){
		let alertController = UIAlertController (title: "位置情報の共有が\n許可されていません", message: "このAppを使用するには位置情報を\n\"このAppの使用中のみ許可\"\nに設定してください", preferredStyle: .alert)
		
		let settingsAction = UIAlertAction(title: "設定へ", style: .default) { (_) -> Void in
			
			guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
				return
			}
			
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
					print("Settings opened: \(success)") // Prints true
				})
			}
		}
		alertController.addAction(settingsAction)
		let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
}

extension MapView: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
}
