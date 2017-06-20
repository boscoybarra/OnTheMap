//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by J B on 6/16/17.
//  Copyright © 2017 J B. All rights reserved.
//

import UIKit

class StudentsTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var locations: [StudentInformation] = [StudentInformation]()
    
    // MARK: Outlets
    
    @IBOutlet weak var locationsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OTMClient.sharedInstance().getStudentLocations { (locations, error) in
            if let locations = locations {
                self.locations = locations
                performUIUpdatesOnMain {
                    self.locationsTableView.reloadData()
                }
            } else {
                print(error ?? "empty error")
            }
        }
    }


    // MARK: - Table view data sourceff

 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)

        let student = locations[indexPath.row]
        let textForTitle = student.firstName + "" + student.lastName
        
        cell.textLabel?.attributedText = getAttributedText(textToStyle: textForTitle)
        cell.detailTextLabel!.text = student.mediaURL

        return cell
    }
    
    //Function that returns styled text from a unstyled string
    func getAttributedText(textToStyle: String) -> NSMutableAttributedString{
        let rangeToStyle = NSRange.init(location: 0, length: (textToStyle as NSString).length)
        let attributedText = NSMutableAttributedString(string: textToStyle)
        let font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        attributedText.addAttributes([NSFontAttributeName: font!], range: rangeToStyle)
        
        return attributedText
    }

}
