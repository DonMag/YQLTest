//
//  ViewController.swift
//  YQLTest
//
//  Created by DonMag on 2/12/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var stockTextField: UITextField!
	@IBOutlet weak var logoTextField: UITextField!
	
	@IBOutlet weak var resultsLabel: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	@IBAction func doTap(_ sender: Any) {
		self.handleSave()
	}
	
	func handleSave() {
	
		guard let newCompanyName = nameTextField.text else {
			// handle the error how you see fit
			showError(msg: "error getting text from Name field")
			return
		}
		
		guard let newCompanyLogo = logoTextField.text else {
			// handle the error how you see fit
			showError(msg: "error getting text from Logo field")
			return
		}
		
		guard let newCompanyStockSymbol = stockTextField.text else {
			// handle the error how you see fit
			showError(msg: "error getting text from Symbol field")
			return
		}
		
		var newCompanyStockPrice = ""
		
		// Fetch stock price from symbol provided by user for new company
		guard let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20Ask%2C%20YearHigh%2C%20YearLow%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22\(newCompanyStockSymbol)%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys") else {
			showError(msg: "URL format error")
			return
		}
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if error != nil {
				if let msg = error?.localizedDescription {
					self.showError(msg: msg)
				}
			} else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {

				guard let data = data else {
					self.showError(msg: "data was nill ?")
					return
				}
				
				let json = JSON(data: data)
				
				newCompanyStockPrice = json["query"]["results"]["quote"]["Ask"].stringValue
				
				if newCompanyStockPrice == "" {

					self.showError(msg: "no price returned")
				
				} else {
				
					DispatchQueue.main.async {
						self.save(name: newCompanyName, logo: newCompanyLogo, stockPrice: newCompanyStockPrice)
					}

				}
				
			}
		}
		task.resume()
	}
	
	func save(name: String, logo: String, stockPrice: String) -> Void {

		resultsLabel.text = "Results\n\nName: \(name)\nLogo: \(logo)\nPrice: \(stockPrice)"
		
	}
	
	func showError(msg: String) -> Void {
		DispatchQueue.main.async {
			self.resultsLabel.text = "Error\n\n\(msg)"
		}
	}

}

