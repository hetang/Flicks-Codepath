//
//  MovieListCell.swift
//  
//
//  Created by Hetang.Shah on 9/13/17.
//
//

import UIKit

class MovieListCell: UITableViewCell {
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
