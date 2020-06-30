//
//  CompassView.swift
//  compass
//
//  Created by 上井一起 on 2020/06/29.
//  Copyright © 2020 上井一起. All rights reserved.
//

import UIKit
import CoreLocation

class CompassScreen: UIViewController{
	@IBOutlet weak var NeedleImageView: UIImageView!
	
	let locationManager = CLLocationManager()
	
	var start: CLLocationCoordinate2D!
	var goalLatitude: CLLocationDegrees!
	var goalLongitude: CLLocationDegrees!
	
	var current: CLLocationCoordinate2D?
	var heading: CGFloat!
	var lastHeading: CGFloat! = 0.0
	
	var bearing: CGFloat!
	var lastBearing: CGFloat! = 0.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManagerConfig()
		bearing =  calculateBearing(current: start)
		NeedleImageView.transform = NeedleImageView.transform.rotated(by: bearing)
		lastBearing = bearing
		// End of viewDidLoad()
	}
	
	func locationManagerConfig(){
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.headingFilter = 5
		//locationManager.startUpdatingHeading()
		locationManager.startUpdatingLocation()
		locationManager.headingOrientation = .portrait
	}
	
	func calculateBearing(current: CLLocationCoordinate2D) -> CGFloat{
		let fLat = degreesToRadians(degrees: current.latitude)
		let fLng = degreesToRadians(degrees: current.longitude)
		let tLat = degreesToRadians(degrees: goalLatitude)
		let tLng = degreesToRadians(degrees:goalLongitude)

		let a = CGFloat(sin(fLng-tLng)*cos(tLat));
		let b = CGFloat(cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(fLng-tLng))
		return -atan2(a, b)
		// End of calculateBearing()
	}
	
	// End of class: CompassScreen
}


extension CompassScreen: CLLocationManagerDelegate{
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		UIView.animate(withDuration: 2.0){
			self.heading = CGFloat(newHeading.trueHeading)
			self.NeedleImageView.transform = self.NeedleImageView.transform.rotated(by: self.heading)
			self.lastHeading = self.heading
		}
		print("heading changed")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.locationManager.distanceFilter = 15.0
		guard let location = locations.last else { return }
		current = location.coordinate
		bearing =  calculateBearing(current: current!)
		NeedleImageView.transform = NeedleImageView.transform.rotated(by: bearing - lastBearing)
		lastBearing = bearing
		print("location has changed")
		print(bearing)
	}
	// End of extension
}

func degreesToRadians(degrees: Double) -> Double {
	return degrees * .pi / 180
}
func radiansToDegrees(radians: CGFloat) -> CGFloat{
	return radians * 180 / .pi
}
