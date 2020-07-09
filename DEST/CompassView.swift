//
//  CompassView.swift
//  compass
//
//  Created by 上井一起 on 2020/06/29.
//  Copyright © 2020 上井一起. All rights reserved.
//

import UIKit
import CoreLocation

class CompassView: UIViewController{
	@IBOutlet weak var NeedleImageView: UIImageView!
	
	var locationManager: CLLocationManager!
	
	var start: CLLocationCoordinate2D!
	var goals: [CLLocationCoordinate2D]!
	var goal: CLLocationCoordinate2D!
	
	var current: CLLocationCoordinate2D?
	var heading: CGFloat!
	var lastHeading: CGFloat! = 0.0
	
	var bearing: CGFloat!
	var adjustedAngle: CGFloat!
	var lastAdjustedAngle: CGFloat! = 0.0
	
	var totalDistance: Double! = 0.0
	var lastLocation:CLLocationCoordinate2D!
	
	let strokeTextAttributes = [
		NSAttributedString.Key.strokeColor : UIColor(red: 147/255, green: 250/255, blue: 244/255, alpha: 1),
		NSAttributedString.Key.foregroundColor : UIColor.clear,
		NSAttributedString.Key.strokeWidth : 4.0,
		NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 70)
		] as [NSAttributedString.Key : Any]
	
	@IBOutlet weak var baseImageView: UIImageView!
	@IBOutlet weak var toTheDestinationImageView: UIImageView!
	
	func setConstraints(){
		// constraints of baseImageView
		baseImageView.translatesAutoresizingMaskIntoConstraints = false
		baseImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4, constant: 0).isActive = true
		baseImageView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4, constant: 0).isActive = true
		baseImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 10).isActive = true
		baseImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		//constraints of NeedleImageView
		NeedleImageView.translatesAutoresizingMaskIntoConstraints = false
		NeedleImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40, constant: 0).isActive = true
		NeedleImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 10).isActive = true
		
		//constraints of distanceToTheDestination
		DistanceToTheDestinationView.bottomAnchor.constraint(equalTo: toTheDestinationImageView.bottomAnchor, constant: -80  ).isActive = true
		//print()
		
	}

	@IBOutlet weak var DistanceToTheDestinationView: UIView!
	@IBOutlet weak var ToTheDestination: UILabel!
	
	override func viewDidLoad() {
		goal = goals[0]
		if  (goals.count == 1){
			nextButton.removeFromSuperview()
		}
		super.viewDidLoad()
		setConstraints()
		locationManagerConfig()
		UIApplication.shared.isIdleTimerDisabled = true
		lastLocation = start
		bearing = calculateBearing(current: start, goal: goal)
		current = start
		ToTheDestination.frame = DistanceToTheDestinationView.bounds
		ToTheDestination.textAlignment = .center
		ToTheDestination.attributedText = NSMutableAttributedString(string: setDistanceLabel(start: start, end: goal), attributes: strokeTextAttributes)
		// End of viewDidLoad()
	}
		
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ToFinishView"{
			let finishView = segue.destination as! FinishView
			finishView.totalDistance = totalDistance
			finishView.strokeTextAttributes = strokeTextAttributes
		}
	}
	
	@IBOutlet weak var nextButton: UIButton!
	var count = 1
	@IBAction func changeToNextGoal(_ sender: Any) {
			goal = goals[count]
			ToTheDestination.text =  setDistanceLabel(start: current!, end: goal!)
			bearing =  calculateBearing(current: current!, goal: goal!)
			count += 1
			if goals.count >= count {
				nextButton.removeFromSuperview()
			}
	}
	
	func locationManagerConfig(){
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		locationManager.distanceFilter = 20.0
		locationManager.startUpdatingLocation()
		locationManager.headingFilter = 5
		locationManager.startUpdatingHeading()
		locationManager.headingOrientation = .portrait
	}
	
	func calculateBearing(current: CLLocationCoordinate2D, goal:CLLocationCoordinate2D) -> CGFloat{
		let fLat = degreesToRadians(degrees: current.latitude)
		let fLng = degreesToRadians(degrees: current.longitude)
		let tLat = degreesToRadians(degrees: goal.latitude)
		let tLng = degreesToRadians(degrees:goal.longitude)
		
		let a = CGFloat(sin(fLng-tLng)*cos(tLat));
		let b = CGFloat(cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(fLng-tLng))
		return -atan2(a, b)
		// End of calculateBearing()
	}
	
	func calculateDistance(start: CLLocationCoordinate2D, end:CLLocationCoordinate2D) -> Double{
		let sLat = degreesToRadians(degrees: start.latitude)
		let sLng = degreesToRadians(degrees: start.longitude)
		let tLat = degreesToRadians(degrees: end.latitude)
		let tLng = degreesToRadians(degrees:end.longitude)
		let dLat = tLat - sLat
		let dLng = tLng - sLng
		
		let R: Double = 6371000
		let a = pow(sin(dLat / 2), 2) + cos(sLat) * cos(tLat) * pow(sin(dLng / 2), 2)
		let c = 2 * atan2(sqrt(a), sqrt(1 - a))
		let distance = R * c  //in meters
		return distance
	}
	
	func  setDistanceLabel(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D)  -> String{
		let distanceToDestination = calculateDistance(start: start, end: end)
		if distanceToDestination > 1000 {
			return String(format: "%.2f km", distanceToDestination / 1000)
		}else{
			return String(format: "%.0f m", distanceToDestination)
		}
	}
	// End of class: CompassView
}


extension CompassView: CLLocationManagerDelegate{
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		current = location.coordinate
		if (goal != nil) {goal = goals[0]}
		ToTheDestination.text =  setDistanceLabel(start: current!, end: goal!)
		totalDistance += calculateDistance(start: current!, end: lastLocation)
		lastLocation = current
		bearing =  calculateBearing(current: current!, goal: goal!)
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
