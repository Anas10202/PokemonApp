//
//  TableViewCell.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/22/24.
//

import UIKit
import Nuke

class TableViewCell: UITableViewCell {
    var pokemon: Pokemon!

    
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    @IBOutlet weak var pokemonTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
   
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
