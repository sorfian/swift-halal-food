//
//  RouteTableViewController.swift
//  Halal Food
//
//  Created by Sorfian on 28/03/23.
//

import UIKit
import MapKit

class RouteTableViewController: UITableViewController {
    
    var routeSteps: [MKRoute.Step] = [MKRoute.Step()]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepscell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = routeSteps[indexPath.row].instructions
        cell.contentConfiguration = content
        
        return cell
        
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
