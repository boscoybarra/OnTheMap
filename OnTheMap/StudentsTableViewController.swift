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
    
    var locations = DataSource.students
    
    // MARK: Outlets
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OTMClient.getStudentsLocation { (locations, error) in
            if let locations = locations {
                self.locations = locations
                self.executeOnMain {
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath){
            if let toOpen = cell.detailTextLabel?.text, let url = NSURL(string: toOpen), app.canOpenURL(url as URL) {
                if UIApplication.shared.canOpenURL(NSURL(string: toOpen)! as URL){
                    app.openURL(url as URL)
                    print("Url should have opened")
                } else {
                    presentErrorAlertController("Unable to load webpage", alertMessage: "Webpage couldn't be opened because the link was invalid.")
                }
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)

        let student = locations[indexPath.row]
        let textForTitle = student.firstName! + "" + student.lastName!
        
        cell.textLabel?.attributedText = getAttributedText(textToStyle: textForTitle)
        if let mediaURL = student.mediaURL {
            let stringURL = String(describing: mediaURL)
            cell.detailTextLabel?.text = stringURL
        } else {
            cell.detailTextLabel?.text = "Unknown Media URL"
        }

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
