//
//  ChatBrain.swift
//  ChatOnboarding
//
//  Created by Manoj Kumar on 18/01/19.
//  Copyright © 2019 Sandiaa. All rights reserved.
//

import Foundation
import UIKit

enum UserInputTypes {
    case suggestion
    case textField
}

enum OriginType {
    case bot
    case user
}

enum ChatType {
    case hi
    case userHi
    case hello
    case intro
    case signin
    case signup
    case signinEmail
    case signinPassword
    case signinRegisteredEmail
    case wrongSignInEmail
    case none
    
    func getSuggestions() -> [ChatType]{
        switch self {
        case .hi:
            return [.userHi, .hello]
        case .intro:
            return [.signin, .signup]
        default :
            return []
        }
    }
    
    func getBotResponse() -> ChatType {
        switch self {
        case .userHi, .hello:
            return .intro
        case .signin:
            return .signinEmail
        case .signinRegisteredEmail:
            return .signinPassword
        default:
            return .none
        }
    }
    
    func getOriginType() -> OriginType{
        switch self {
        case .hi, .intro, .signinEmail, .signinPassword, .wrongSignInEmail:
            return .bot
        default:
            return .user
        }
    }
    
    func getChatText() -> String {
        switch self {
        case .hi :
            return "Hi"
        case .userHi :
            return "Hi"
        case .hello :
            return "Hello"
        case .intro :
            return "I am here to assist you with onboarding. Would you like to signin or signup?"
        case .signin :
            return "Signin"
        case .signup :
            return "Signup"
        case .signinEmail :
            return "Enter your email"
        case .signinRegisteredEmail:
            return UserDefaults.standard.value(forKey: REGISTERED_EMAIL_KEY) as! String
        case .signinPassword:
            return "Enter your password"
        case .wrongSignInEmail:
            return "Please enter a valid Email"
        default :
            return ""
            
        }
    }
    
    func getUserInputType() -> UserInputTypes {
        switch self {
        case .signinEmail, .signinPassword, .wrongSignInEmail:
            return .textField
        default :
            return .suggestion
        }
    }
    
    func getKeyboardType() -> UIKeyboardType {
        switch self {
        case .signinEmail, .wrongSignInEmail:
            return .emailAddress
        case .signinPassword:
            return .asciiCapable
        default:
            return .default
        }
    }
    
    func isTextFieldSecure()->Bool {
        if self == .signinPassword {
            return true
        }
        return false
    }
}
