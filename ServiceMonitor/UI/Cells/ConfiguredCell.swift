//
//  ConfiguredCell.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 13.09.2021.
//

import UIKit

class ConfiguredCell: UICollectionViewCell {
    let cornerRadius: CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = cornerRadius
        layer.cornerRadius = cornerRadius
    }
}
