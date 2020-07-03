//
//  SearchViewController.swift
//  compass
//
//  Created by 上井一起 on 2020/07/01.
//  Copyright © 2020 上井一起. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchView: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate{
	let locationManager = CLLocationManager()
	var searchCompleter = MKLocalSearchCompleter()
	var searchResults = [MKLocalSearchCompletion]()
	
	private var lat: CLLocationDegrees!
	private var lon: CLLocationDegrees!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		searchCompleter.delegate = self
		searchBar.delegate = self
		searchResultsTable?.delegate = self
		searchResultsTable?.dataSource = self
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let mapScreen = segue.destination as! MapScreen
		mapScreen.selectedLatitude = lat
		mapScreen.selectedLongitude = lon
	}
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var searchResultsTable: UITableView!
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		let searchRequest = MKLocalSearch.Request()
		searchRequest.naturalLanguageQuery = searchBar.text
		let activeSearch = MKLocalSearch(request: searchRequest)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchCompleter.queryFragment = searchText
	}
	
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		searchResults = completer.results
		searchResultsTable.reloadData()
	}
	
	func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		//error
	}
	
	// End of the class declaration
}

extension SearchView: UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let searchResult = searchResults[indexPath.row]
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

		cell.textLabel?.text = searchResult.title
		cell.textLabel?.textColor = .black
		cell.detailTextLabel?.text = searchResult.subtitle
		cell.detailTextLabel?.textColor = .black
		cell.backgroundColor = .none

		 return cell
	}
}

extension SearchView: UITableViewDelegate{
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let result = searchResults[indexPath.row]
		let searchRequest = MKLocalSearch.Request(completion: result)
		
		let search = MKLocalSearch(request: searchRequest)
		search.start{ (response, error) in
			guard let coordinate = response?.mapItems[0].placemark.coordinate else{ return }
			guard let name = response?.mapItems[0].name else { return }
			self.lat = coordinate.latitude
			self.lon = coordinate.longitude
			self.performSegue(withIdentifier: "ToMapScreen", sender: self)
		}
	}
}
