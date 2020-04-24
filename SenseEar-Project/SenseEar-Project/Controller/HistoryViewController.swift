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
    
    var viewModel: SelectedFileViewModel?
    let cellReuseIdentifier = "HistoryCell"
    
    var vc: ViewController? = ViewController(filename: nil, selectedFile: nil, viewModel: nil)
    
    public static var arrayData: [HistoryDataSource] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
        
        if HistoryViewController.arrayData.isEmpty == true {
            self.tableview.separatorStyle = .none
        } else {
            self.tableView.separatorStyle = .singleLine
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadEmptyStateForTableView(self.tableView)
    }
       
    override func viewDidLoad() {
        setUp()
        
        self.vc?.readingHistoryDataFromFirebase()
        sleep(2)
    }
    
    public func setUp() {
        
        tableView.rowHeight = 90
        
        tableview.delegate = self
        tableview.dataSource = self
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
            
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return HistoryViewController.arrayData.count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let datasource = HistoryViewController.arrayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HistoryCell
        
        cell.setUp(with: datasource)

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
