//
//  HistoryViewController.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 21/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import UIKit
import UIEmptyState
import FirebaseDatabase

class HistoryDataSource {
    
    let image: UIImage
    let name: String
    let time: String
    
    init(image: UIImage, name: String, time: String) {
        self.image = image
        self.name = name
        self.time = time
    }
    
}

class HistoryViewController: UITableViewController {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var emptyStateView: UIView!
    
    let cellReuseIdentifier = "HistoryCell"
    
    var vc: ViewController? = ViewController(filename: nil, selectedFile: nil, viewModel: nil)
    
    public static var arrayData: [HistoryDataSource] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.tableview.reloadData()

        self.reloadEmptyState()

        if HistoryViewController.arrayData.count > 0 {

           self.tableView.separatorStyle = .singleLine

       } else {

           self.tableview.separatorStyle = .none

       }

    }
       
    override func viewDidLoad() {
        
        setUp()
        self.vc?.readingHistoryDataFromFirebase()
        
    }
    
    /// Controls the setup of the view
    public func setUp() {
        
        tableView.rowHeight = 90
        
        tableview.delegate = self
        tableview.dataSource = self
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
    }
    
    /// Controls the number of cells that are displayed
    /// - Parameters:
    ///   - tableView: Tableview for displaying the cells
    ///   - section: Section for displaying the content
    /// - Returns: Int value of cells to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return HistoryViewController.arrayData.count
    }
    
    /// Controls the setup of the cell at each row
    /// - Parameters:
    ///   - tableView: Tableview for displaying the cells
    ///   - indexPath: Index path of the cell
    /// - Returns: Table view cell setup with the datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let datasource = HistoryViewController.arrayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HistoryCell
        
        cell.setup(with: datasource)

        return cell
    }
    
}

extension HistoryViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {

    var emptyStateImage: UIImage? {
        return #imageLiteral(resourceName: "empty-state-history")
    }

    var emptyStateTitle: NSAttributedString {

        let attrs = [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)]
        return NSAttributedString(string: "No History", attributes: attrs)

    }

}
