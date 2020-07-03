//
//  File.swift
//  compass
//
//  Created by 上井一起 on 2020/07/02.
//  Copyright © 2020 上井一起. All rights reserved.
//

import UIKit

class  FinishView: UIViewController {
	@IBOutlet weak var totalDistanceValueLabel: UILabel!
	
	var totalDistance: Double!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if totalDistance < 1000{
			totalDistanceValueLabel.text = String(format: "%.0f m", totalDistance)
		}else{
			totalDistanceValueLabel.text = String(format: "%.2f km", totalDistance / 1000)
		}
		totalDistanceValueLabel.textAlignment = .center
		totalDistanceValueLabel.font = UIFont.boldSystemFont(ofSize: 100)
		gradTextLabel(label: totalDistanceValueLabel)
	}
	
	@IBOutlet weak var totalDistanceView: UIImageView!
	@IBOutlet weak var totalDistanceValueVIew: UIView!
	
	func gradTextLabel(label: UILabel){
		let gradLayer = CAGradientLayer()
		gradLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
		gradLayer.startPoint = CGPoint(x: 0.0, y:0.5)
		gradLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		gradLayer.frame = totalDistanceValueVIew.bounds
		totalDistanceValueVIew.layer.addSublayer(gradLayer)
		label.frame = totalDistanceValueVIew.bounds
		// Tha magic! Set the label as the views mask
		totalDistanceValueVIew.mask = label
		}
}
