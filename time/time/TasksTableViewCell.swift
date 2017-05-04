//
//  TasksTableViewCell.swift
//  time
//
//  Created by Sohil Pandya on 06/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit

class TasksTableViewCell: UITableViewCell {

    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    @IBOutlet weak var liveTimerSeconds: UILabel!
    @IBOutlet weak var liveTimerMinutes: UILabel!
    @IBOutlet weak var separator: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        liveTimerMinutes.isHidden = true
        liveTimerSeconds.isHidden = true
        separator.isHidden = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
