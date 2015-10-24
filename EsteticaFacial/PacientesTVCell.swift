//
//  PacientesTVCell.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 24/10/15.
//  Copyright © 2015 Ricardo Freitas. All rights reserved.
//

import UIKit

class PacientesTVCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var dataNascimentoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
