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
		receiverVC.start = setStartAndGoal().0
		receiverVC.goalLatitude = setStartAndGoal().1
		receiverVC.goalLongitude = setStartAndGoal().2
		locationManager.stopUpdatingHeading()
		locationManager.stopUpdatingLocation()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func setStartAndGoal() -> (CLLocationCoordinate2D, CLLocationDegrees, CLLocationDegrees) {
		let start = locationManager.location!.coordinate
		let goal = getCenterLocation(for: mapView).coordinate
		let goalLatitude = goal.latitude
		let goalLongitude = goal.longitude
		return (start, goalLatitude, goalLongitude)
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
			locationManager.startUpdatingHeading()
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

extension MapScreen: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAuthorization()
	}
}


