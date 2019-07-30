//
//  InquiryViewController.swift
//  INUBus
//
//  Created by 임현규 on 22/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class InquiryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    let message = "소중한 의견 감사드립니다!"

   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInquiry()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func touchUpBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func titleTextContentsCheck(_ sender: Any) {
        contentsCheck()
    }
    
    @IBAction func phoneTextContentsCheck(_ sender: Any) {
        contentsCheck()
    }
    @IBAction func touchUpSendButton(_ sender: Any) {
        
        // Do any additional setup after loading the view.
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PopUpViewController {
            viewController.inquiryTitle = self.titleTextField.text ?? ""
            viewController.inquiryContact = self.phoneNumberTextField.text ?? ""
            viewController.inquiryMessage = self.contentsTextView.text ?? ""
        }
    }
}

extension InquiryViewController {
    private func setupInquiry() {

        self.titleTextField.layer.borderColor =
            UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        self.contentsTextView.layer.borderColor =
            UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        self.phoneNumberTextField.layer.borderColor =
            UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        
        self.titleTextField.layer.borderWidth = 1
        self.phoneNumberTextField.layer.borderWidth = 1
        self.contentsTextView.layer.borderWidth = 1
        
        let viewControllerGesture: UITapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(tapViewcontroller(_:)))
        
        self.view.addGestureRecognizer(viewControllerGesture)
        self.contentsTextView.delegate = self
        
    }
    
    @objc func tapViewcontroller(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.contentsCheck()
        print("공백 클릭")
        
    }
    
    func contentsCheck() {
        if self.titleTextField.text != "" &&
        self.phoneNumberTextField.text != "" &&
        self.contentsTextView.text != "" {
            self.sendButton.isEnabled = true
                //버튼 활성화
        } else {
            self.sendButton.isEnabled = false
                //버튼 비활성화
        }
    }
}

extension InquiryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.contentsCheck()
    }
}
 
