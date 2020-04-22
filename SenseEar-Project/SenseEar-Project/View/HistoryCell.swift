//
//  HistoryCell.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 21/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
 
    @IBOutlet weak var fileTypeImage: UIImageView!
    @IBOutlet weak var nameOfFile: UILabel!
    @IBOutlet weak var time: UILabel!
    
    func setUp(with datasource: HistoryDataSource) {
        fileTypeImage.image = datasource.image
        nameOfFile.text = datasource.name
        time.text = datasource.time
    }
    
}
