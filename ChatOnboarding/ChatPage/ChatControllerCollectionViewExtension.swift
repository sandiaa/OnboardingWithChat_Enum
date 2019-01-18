//
//  ChatControllerCollectionViewExtension.swift
//  ChatOnboarding
//
//  Created by Manoj Kumar on 18/01/19.
//  Copyright © 2019 Sandiaa. All rights reserved.
//

import Foundation
import UIKit

let REGISTERED_EMAIL_KEY = "registeredEmail"

extension ChatController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count =  dataSource.count
        if currentSuggestion.count > 0 {
            count += 1
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if currentSuggestion.count > 0 && indexPath.row == dataSource.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllSuggestionsCell", for: indexPath) as!
            AllSuggestionsCell
            cell.delegate = self
            cell.populateWith(userSuggestions: currentSuggestion)
            return cell
        }
        else {
            let chatType = dataSource[indexPath.row]
            if chatType.getOriginType() == .bot {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BotCell", for: indexPath) as!
                BotCell
                cell.populateWith(chatType: chatType)
                return cell
            }
            else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as!
                UserCell
                cell.populateWith(chatType: chatType)
                return cell
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentSuggestion.count > 0 && indexPath.row == dataSource.count {
            return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
        }
        else {
            let chatType = dataSource[indexPath.row]
            let str = chatType.getChatText()
            
            let lbl = UILabel()
            lbl.text = str
            lbl.numberOfLines = 0
            lbl.font = UIFont.systemFont(ofSize: 17)
            
            let size = lbl.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 130, height: CGFloat.infinity))
            return CGSize(width:UIScreen.main.bounds.width, height: max(size.height + 20, 50))
        }
    }
}


extension ChatController : AllSuggestionsCellDelegate {
    func didSelectSuggestion(suggestion: ChatType) {
        dataSource.append(suggestion)
        processLastChat()
    }
}

extension ChatController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtField.resignFirstResponder()
        
        let chatType = dataSource.last
        if chatType == .signinEmail || chatType == .wrongSignInEmail {
            if (txtField.text ?? "").isEmail {
                UserDefaults.standard.set((txtField.text ?? ""), forKey: REGISTERED_EMAIL_KEY)
                dataSource.append(.signinRegisteredEmail)
                txtField.text = ""
                processLastChat()
            }
            else {
                dataSource.append(.wrongSignInEmail)
                processLastChat()
            }
        }
        
        return true
    }
}
