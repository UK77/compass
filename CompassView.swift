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
	
	var goalLatitude : CLLocationDegrees?
	var goalLongitude: CLLocationDegrees?
	
	var currentLatitude : CLLocationDegrees?
	var currentLongitude: CLLocationDegrees?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print(goalLatitude, goalLongitude)
		print(currentLatitude,currentLongitude)
	}
	
	func calculateDegree(location: CLLocation, heading: CLHeading){
		
	}
	
}

extension CompassScreen: CLLocationManagerDelegate{
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		let heading = newHeading
		
	}
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		let currentLatitude = location.coordinate.latitude
		let currentLongtitude = location.coordinate.longitude
		
	}
}
