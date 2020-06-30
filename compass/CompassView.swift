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
	
	var locationManager = CLLocationManager()
	
	var start: CLLocationCoordinate2D!
	var goalLatitude: CLLocationDegrees!
	var goalLongitude: CLLocationDegrees!
	
	var currentLocation: CLLocationCoordinate2D?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let destinationAngle = calculateAngle(current: start) - .pi / 2
		NeedleImageView.transform = NeedleImageView.transform.rotated(by: destinationAngle)
		// End of viewDidLoad()
	}
	
	func calculateAngle(current: CLLocationCoordinate2D) -> CGFloat{
		let fLat = degreesToRadians(degrees: current.latitude)
		let fLng = degreesToRadians(degrees: current.longitude)
		let tLat = degreesToRadians(degrees: goalLatitude)
		let tLng = degreesToRadians(degrees:goalLongitude)

		let a = CGFloat(sin(fLng-tLng)*cos(tLat));
		let b = CGFloat(cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(fLng-tLng))
		return atan2(b, a)
		// End of calculateAngle()
	}
	// End of class: CompassScreen
}

extension CompassScreen: CLLocationManagerDelegate{
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		let heading = newHeading
		
	}
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let currentLocation = locations.last else { return }
	}
	// End of extension
}

func degreesToRadians(degrees: Double) -> Double {
	return degrees * .pi / 180
}
func radiansToDegrees(radians: CGFloat) -> CGFloat{
	return radians * 180 / .pi
}
