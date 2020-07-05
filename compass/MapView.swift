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

class MapView: UIViewController, UISearchBarDelegate {
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
			compassView.start = setStartAndGoal().0
			compassView.goal = setStartAndGoal().1
			compassView.locationManager = locationManager
			locationManager.stopUpdatingLocation()
		}
		if segue.identifier == Segues.ToSearchView{}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func setStartAndGoal() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
		let start = locationManager.location!.coordinate
		let goal = getCenterLocation(for: mapView).coordinate
		return (start, goal)
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
	
	func getCenterLocation(for mapView: MKMapView) -> CLLocation{
		let latitude = mapView.centerCoordinate.latitude
		let longitude = mapView.centerCoordinate.longitude
		return CLLocation(latitude: latitude, longitude: longitude)
	}
}

extension MapView: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
}
