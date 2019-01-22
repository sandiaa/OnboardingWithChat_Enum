//
//  ChatController.swift
//  ChatOnboarding
//
//  Created by Manoj Kumar on 18/01/19.
//  Copyright © 2019 Sandiaa. All rights reserved.
//

import UIKit
import WebKit

class ChatController: UIViewController {

    @IBOutlet weak var webViewBackButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var textFieldBaseView: UIView!
    
    @IBOutlet weak var lcCollectionViewBottomSpace: NSLayoutConstraint!
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    var dataSource = [ChatType]()
    var currentSuggestion = [ChatType]()
    let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(dismissPicker))
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        dataSource.append(ChatType.hi)
        setupColletionView()
        processLastChat()
        setUpView()
    }

    @objc func dismissPicker() {
        view.endEditing(true)
        let selectedDate = datePicker.date
        let registerDate = getDateInChatFormat(date: selectedDate)
        UserDefaults.standard.set((registerDate), forKey: REGISTERED_SIGNUP_DOB)
        dataSource.append(.signupRegisteredDob)
        txtField.isHidden = false
        textFieldBaseView.isHidden = false
        processLastChat()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func setUpView() {
        textFieldBaseView.backgroundColor = .white
        textFieldBaseView.addShadowWith(shadowPath: UIBezierPath(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)).cgPath, shadowColor: UIColor.black.withAlphaComponent(0.6).cgColor, shadowOpacity: 0.5, shadowRadius: 10.0, shadowOffset: CGSize.zero)
        
        txtField.delegate = self
    }
    func setupColletionView() {
        
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        
        chatCollectionView.register(UINib(nibName:"UserCell", bundle: nil), forCellWithReuseIdentifier: "UserCell")
        chatCollectionView.register(UINib(nibName:"BotCell", bundle: nil), forCellWithReuseIdentifier: "BotCell")
        chatCollectionView.register(UINib(nibName:"AllSuggestionsCell", bundle: nil), forCellWithReuseIdentifier: "AllSuggestionsCell")
        
        let springLayout = SpringyFlowLayout()
        springLayout.scrollDirection = .vertical
        springLayout.minimumLineSpacing = 10
        springLayout.minimumInteritemSpacing = 10
        springLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        chatCollectionView.setCollectionViewLayout(springLayout, animated: false)
        springLayout.invalidateLayout()
        chatCollectionView.reloadData()
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        let endFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if endFrame.origin.y == UIScreen.main.bounds.height {//Keyboard is hidden
            lcCollectionViewBottomSpace.constant = 0
        }
        else {//Keyboard is visible
            lcCollectionViewBottomSpace.constant = endFrame.height + 60
        }
        view.layoutIfNeeded()
        chatCollectionView.scrollToItem(at: IndexPath(row: dataSource.count-1, section: 0), at: .bottom, animated: true)
    }
    
    func processLastChat() {
        guard let chatType = dataSource.last else {return}
        currentSuggestion.removeAll()
        if chatType.getOriginType() == .bot {
            if chatType.getUserInputType() == .suggestion  {
                currentSuggestion = chatType.getSuggestions()
                if chatType != dataSource.first {
                    insertSuggestionCell()
                }
            }
            else {
                txtField.keyboardType = chatType.getKeyboardType()
                txtField.placeholder = chatType.getPlaceholderText()
                txtField.isSecureTextEntry = chatType.isTextFieldSecure()
                txtField.returnKeyType = .done
                
                if chatType == .signupDob {
                    txtField.inputAccessoryView = toolBar
                    txtField.isHidden = true
                    textFieldBaseView.isHidden = true
                    datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -15, to: Date())
                    txtField.inputView = datePicker
                }
                
                if chatType == .wrongSignInEmail || chatType == .signinEmojiPassword || chatType == .signinInvalidPassword ||
                    chatType == .wrongSignupName || chatType == .wrongSignupEmail || chatType == .signupEmojiPassword ||
                    chatType == .signupInvalidPassword || chatType == .signupConfirmPassword || chatType == .wrongConfirmPassword ||
                    chatType == .signupWrongDob || chatType == .wrongMobile || chatType == .declineSelected || chatType == .okay
                {
                    var indexPathsToInsert = [IndexPath]()
                    var indexPathsToDelete = [IndexPath]()
                    
                    let userResponseIndexpath = IndexPath(row: dataSource.count-1, section: 0)
                    indexPathsToInsert.append(userResponseIndexpath)
                    if dataSource[dataSource.count-2].getSuggestions().count > 0 {
                        indexPathsToDelete.append(userResponseIndexpath)
                    }
                    
                    (self.chatCollectionView.collectionViewLayout as! SpringyFlowLayout).dynamicAnimator = nil
                    chatCollectionView.performBatchUpdates({
                        self.chatCollectionView.deleteItems(at: indexPathsToDelete)
                        self.chatCollectionView.insertItems(at: indexPathsToInsert)
                    }) { (finished) in
                        self.txtField.becomeFirstResponder()
                    }
                }
                else {
                    txtField.becomeFirstResponder()
                }
            }
        }
        else {
            var indexPathsToInsert = [IndexPath]()
            var indexPathsToDelete = [IndexPath]()
            
            let userResponseIndexpath = IndexPath(row: dataSource.count-1, section: 0)
            indexPathsToInsert.append(userResponseIndexpath)
            if dataSource[dataSource.count-2].getSuggestions().count > 0 {
                indexPathsToDelete.append(userResponseIndexpath)
            }
            let botResponse = chatType.getBotResponse()
            if botResponse != .none {
                dataSource.append(botResponse)
                let botResponseIndexpath = IndexPath(row: dataSource.count-1, section: 0)
                indexPathsToInsert.append(botResponseIndexpath)
            }
            
            (self.chatCollectionView.collectionViewLayout as! SpringyFlowLayout).dynamicAnimator = nil
            chatCollectionView.performBatchUpdates({
                self.chatCollectionView.deleteItems(at: indexPathsToDelete)
                self.chatCollectionView.insertItems(at: indexPathsToInsert)
            }) { (finished) in
                if botResponse != .none {
                    self.processLastChat()
                }
            }
        }
    }
    
    func insertSuggestionCell() {
        if currentSuggestion.count > 0 {
            let suggestionIndexPath = IndexPath(row: dataSource.count, section: 0)
            (self.chatCollectionView.collectionViewLayout as! SpringyFlowLayout).dynamicAnimator = nil
            chatCollectionView.performBatchUpdates({
                self.chatCollectionView.insertItems(at: [suggestionIndexPath])
            }) { (finished) in
                if self.chatCollectionView.contentSize.height > self.chatCollectionView.frame.height {
                    self.chatCollectionView.setContentOffset(CGPoint(x: 0, y: self.chatCollectionView.contentSize.height - (self.chatCollectionView.frame.height - 30)), animated: false)
                }
            }
        }
    }
    func setupWebView() {
        webView.isHidden = false
        webViewBackButton.isHidden = false
        let url = URL(string: "https://www.google.com")
        let request = URLRequest(url: url!)
        webView.load(request)

    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        webView.isHidden = true
        webViewBackButton.isHidden = true
        
      
    }
}
