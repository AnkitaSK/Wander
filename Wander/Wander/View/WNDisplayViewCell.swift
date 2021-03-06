//
//  WNDisplayViewCell.swift
//  Wander
//
//  Created by Ankita on 22.05.21.
//

import UIKit

class WNDisplayViewCell: UITableViewCell {
    @IBOutlet var locationImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        locationImageView.contentMode = .scaleAspectFit
    }
    
    func configCell(with item: PhotoItem) {
        locationImageView.image = item.image
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
