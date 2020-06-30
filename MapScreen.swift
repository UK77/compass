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



class MapScreen: UIViewController {
	@IBOutlet weak var mapView: MKMapView!
	
	let locationManager = CLLocationManager()
	let regionInMeters: Double = 10000
	
	override func viewDidLoad() {
		super.viewDidLoad()
		checkLocationServices()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let receiverVC = segue.destination as! CompassScreen
		receiverVC.goalLatitude = setGoal().0
		receiverVC.goalLongitude = setGoal().1
		receiverVC.currentLatitude = setCurrent().0
		receiverVC.currentLongitude = setCurrent().1
		
		//receiverVC.heading = locationManager.headingOrientation
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func setCurrent() -> (CLLocationDegrees, CLLocationDegrees) {
		let current = locationManager.location!.coordinate
		let currentLatitude = current.latitude
		let currentLongitude = current.longitude
		return (currentLatitude, currentLongitude)
	}
	
	
	func setGoal() -> (CLLocationDegrees, CLLocationDegrees) {
		let goal = getCenterLocation(for: mapView).coordinate
		let goalLatitude = goal.latitude
		let goalLongitude = goal.longitude
		return (goalLatitude, goalLongitude)
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
			locationManager.startUpdatingHeading()
			break
		case .denied:
			// show alert instructing them to turn on permissions
			break
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .restricted:
			// show alert letting them know what's up
			break
		case .authorizedAlways:
			break
		}
	}
	
	func getCenterLocation(for mapView: MKMapView) -> CLLocation{
		let latitude = mapView.centerCoordinate.latitude
		let longitude = mapView.centerCoordinate.longitude
		return CLLocation(latitude: latitude, longitude: longitude)
	}


}

extension MapScreen: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
		mapView.setRegion(region, animated: true)
	}
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		print(newHeading.trueHeading)
	}
	
}


