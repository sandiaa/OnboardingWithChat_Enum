//
//  BotCell.swift
//  ChatBotApp
//
//  Created by Admin on 07/01/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class BotCell: UICollectionViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
     baseView.layer.cornerRadius = 10
    }
    
    func populateWith(chatType : ChatType) {
        textLabel.text = chatType.getChatText()
        
        let shadowPath = UIBezierPath(roundedRect: CGRect(x: 3, y: 3, width: baseView.bounds.width, height: baseView.bounds.height), cornerRadius: 10)
        let shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        baseView.addShadowWith(shadowPath: shadowPath.cgPath, shadowColor: shadowColor.cgColor, shadowOpacity: 1.0, shadowRadius: 10, shadowOffset: CGSize(width: 3, height: 3))
        
        layoutIfNeeded()
    }
    
    
}
