//
//  ChatControllerCollectionViewExtension.swift
//  ChatOnboarding
//
//  Created by Manoj Kumar on 18/01/19.
//  Copyright © 2019 Sandiaa. All rights reserved.
//

import Foundation
import UIKit
import WebKit


let REGISTERED_EMAIL_KEY = "registeredEmail"
let REGISTERED_PASSWORD = "registeredPassword"
let REGISTERED_SIGNUP_EMAIL = "signupEmail"
let SIGNUP_PASSWORD = "passwordMatch"
let REGISTERED_SIGNUP_PASSWORD = "signupPassword"
let REGISTERED_SIGNUP_NAME = "signupName"
let REGISTERED_SIGNUP_GENDER = "gender"
let REGISTERED_SIGNUP_DOB = "dob"
let REGISTERED_MOBILE = "mobile"
let str = String()

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
            
            var minHeight:CGFloat = 50
            
            if chatType == .signupRegisteredDob {
                minHeight = 100
            }
            
            let returnigSize = CGSize(width:UIScreen.main.bounds.width, height: max(size.height + 20, minHeight))
            return returnigSize
        }
    }
}


extension ChatController : AllSuggestionsCellDelegate {
    func didSelectSuggestion(suggestion: ChatType) {
        if suggestion == .male || suggestion == .female {
            UserDefaults.standard.set((suggestion.getChatText()), forKey: REGISTERED_SIGNUP_GENDER)

        }
        if suggestion == .viewTerms {
           setupWebView()
            }
        else {
        dataSource.append(suggestion)
        processLastChat()
        }
    }
    
}

extension ChatController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let chatType = dataSource.last
        if chatType == .mobile || chatType == .wrongMobile {
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= maxLength {
                if newString.length == maxLength {
                    textField.resignFirstResponder()
                    UserDefaults.standard.set(newString, forKey: REGISTERED_MOBILE)
                    dataSource.append(.registeredMobile)
                    txtField.text = ""
                    processLastChat()
                }
                return true
            }
            else {
                return false
            }
        }
        return true
        
    }
    
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
        if chatType == .signupEmail || chatType == .wrongSignupEmail {
            if (txtField.text ?? "").isEmail{
                UserDefaults.standard.set((txtField.text ?? ""), forKey: REGISTERED_SIGNUP_EMAIL)
                dataSource.append(.signupRegisteredEmail)
                txtField.text = ""
                processLastChat()
            }
            else {
                dataSource.append(.wrongSignupEmail)
                processLastChat()
            }
        }
        if chatType == .signinPassword || chatType == .signinEmojiPassword || chatType == .signinInvalidPassword {
            if (txtField.text ?? "").count < 6 {
                dataSource.append(.signinInvalidPassword)
                processLastChat()
            }
            else if (txtField.text ?? "").containsEmoji {
                dataSource.append(.signinEmojiPassword)
                processLastChat()
            }
            else {
                UserDefaults.standard.set((txtField.text ?? ""), forKey: REGISTERED_PASSWORD)
                dataSource.append(.signinRegisteredPassword)
                txtField.text = ""
                processLastChat()
                
            }
        }
        if chatType == .signupPassword || chatType == .signupEmojiPassword || chatType == .signupInvalidPassword {
            let whitespace = NSCharacterSet.whitespaces
            let txt = (txtField.text ?? "")
            let range = txt.rangeOfCharacter(from: whitespace)
            if (txtField.text ?? "").count < 6 {
                dataSource.append(.signupInvalidPassword)
                processLastChat()
            }
            else  if (txtField.text ?? "").containsEmoji {
                dataSource.append(.signupEmojiPassword)
                processLastChat()
            }
            else if range != nil {
                dataSource.append(.signupInvalidPassword)
                processLastChat()
            }

            else {
                UserDefaults.standard.set((txtField.text ?? ""), forKey: SIGNUP_PASSWORD)
                dataSource.append(.signupConfirmPassword)
                txtField.text = ""
                processLastChat()
        }
      
    }
        if chatType == .signupConfirmPassword || chatType == .wrongConfirmPassword {
            let text = (txtField.text ?? "")
            let firstPassword = UserDefaults.standard.value(forKey: SIGNUP_PASSWORD) as! String
            if (str.checkIfBothAreSame(firstString: firstPassword, otherString: text)) {
                UserDefaults.standard.set((txtField.text ?? ""), forKey: REGISTERED_SIGNUP_PASSWORD)
                dataSource.append(.signupRegisteredPassword)
                txtField.text = ""
                processLastChat()
            }
            else {
                dataSource.append(.wrongConfirmPassword)
                processLastChat()
            }
            
        }
        if chatType == .signupName || chatType == .wrongSignupName {
            if (txtField.text ?? "").isName {
                UserDefaults.standard.set((txtField.text ?? ""), forKey: REGISTERED_SIGNUP_NAME)
                dataSource.append(.signupRegisteredName)
                txtField.text = ""
                processLastChat()
            }
            else if (txtField.text ?? "").count < 5 {
                dataSource.append(.wrongSignupName)
                processLastChat()
            }
            else  {
                dataSource.append(.wrongSignupName)
                processLastChat()
            }

        }
        
        if chatType == .mobile || chatType == .wrongMobile {
            if (txtField.text ?? "").count > 10 || (txtField.text ?? "").count < 10 {
                dataSource.append(.wrongMobile)
                processLastChat()
            }
            else {
                UserDefaults.standard.set((txtField.text ?? ""), forKey: REGISTERED_MOBILE)
                dataSource.append(.registeredMobile)
                txtField.text = ""
                processLastChat()
            }
        }

 return true
    }
    
}
