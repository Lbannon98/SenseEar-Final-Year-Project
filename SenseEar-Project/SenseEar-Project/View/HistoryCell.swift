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
    
    /// Controls setup of the cell with the selected file metadata within the datasource
    /// - Parameter datasource: datasource takes the parameters of the metadata
    func setup(with datasource: HistoryDataSource) {
        
        fileTypeImage.image = datasource.image
        nameOfFile.text = datasource.name
        time.text = datasource.time
        
    }
    
}
