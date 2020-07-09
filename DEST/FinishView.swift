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
	var strokeTextAttributes: [NSAttributedString.Key : Any]!
	var totalDistanceText: String!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if totalDistance < 1000{
			totalDistanceText = String(format: "%.0f m", totalDistance)
		}else{
			totalDistanceText = String(format: "%.2f km", totalDistance / 1000)
		}
		totalDistanceValueLabel.textAlignment = .center
		totalDistanceValueLabel.frame = totalDistanceValueVIew.bounds
		totalDistanceValueLabel.attributedText = NSMutableAttributedString(string: totalDistanceText, attributes: strokeTextAttributes)
	}
	
	@IBOutlet weak var totalDistanceView: UIImageView!
	@IBOutlet weak var totalDistanceValueVIew: UIView!
}
