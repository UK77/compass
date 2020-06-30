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
	var adjustedAngle: CGFloat!
	var lastAdjustedAngle: CGFloat! = 0.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManagerConfig()
		// End of viewDidLoad()
	}
	
	func locationManagerConfig(){
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.headingFilter = 5
		locationManager.startUpdatingHeading()
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
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.locationManager.distanceFilter = 15.0
		guard let location = locations.last else { return }
		current = location.coordinate
		bearing =  calculateBearing(current: current!)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		heading = CGFloat(newHeading.trueHeading)
		let bearingInDegrees = radiansToDegrees(radians: bearing)
		adjustedAngle = heading - bearingInDegrees
		adjustedAngle = -CGFloat(degreesToRadians(degrees: Double(adjustedAngle)))
		UIView.animate(withDuration: 1.0){
			self.NeedleImageView.transform =  self.NeedleImageView.transform.rotated(by: self.adjustedAngle - self.lastAdjustedAngle)
		}
		lastAdjustedAngle = adjustedAngle
	}
	// End of extension
}

func degreesToRadians(degrees: Double) -> Double {
	return degrees * .pi / 180
}
func radiansToDegrees(radians: CGFloat) -> CGFloat{
	return radians * 180 / .pi
}
