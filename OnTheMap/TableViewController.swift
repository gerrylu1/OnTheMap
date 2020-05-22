//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Gerry Low on 2020-05-20.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataViewControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformationModel.studentsInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        let studentInformation = StudentInformationModel.studentsInformation[indexPath.row]
        
        cell.textLabel?.text = studentInformation.firstName + " " + studentInformation.lastName
        cell.detailTextLabel?.text = studentInformation.mediaURL
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: StudentInformationModel.studentsInformation[indexPath.row].mediaURL) {
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
