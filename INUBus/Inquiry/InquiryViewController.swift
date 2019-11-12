//
//  InquiryViewController.swift
//  INUBus
//
//  Created by 임현규 on 22/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

final class InquiryViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var phoneNumberTextField: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var sendButton: UIButton!
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInquiry()
    
  }
  
  // MARK: - IBActions
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    self.dismiss(animated: true)
    changeStatusBarColor(barStyle: .default)
  }
  
  @IBAction func titleTextContentsCheck(_ sender: Any) {
    contentsCheck()
  }
  
  @IBAction func phoneTextContentsCheck(_ sender: Any) {
    contentsCheck()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let viewController = segue.destination as? PopUpViewController {
      viewController.inquiryTitle = self.titleTextField.text ?? ""
      viewController.inquiryContact = self.phoneNumberTextField.text ?? ""
      viewController.inquiryMessage = self.contentsTextView.text ?? ""
    }
  }
}

// MARK: - Methods

extension InquiryViewController {
  func setupInquiry() {
    
    self.contentsTextView.layer.borderColor =
      UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
    
    self.contentsTextView.layer.borderWidth = 1
    
    let viewControllerGesture: UITapGestureRecognizer =
      UITapGestureRecognizer(target: self, action: #selector(tapViewcontroller(_:)))
    self.view.addGestureRecognizer(viewControllerGesture)
    self.contentsTextView.delegate = self
  }
  
  // 빈 공간을 눌렀을 때의 함수
  @objc func tapViewcontroller(_ sender: UITapGestureRecognizer) {
    // 키보드를 내려줌
    self.view.endEditing(true)
    self.contentsCheck()
  }
  
  // TextField, TextView가 다 채워졌으면 버튼을 활성화하는 함수
  func contentsCheck() {
    if self.titleTextField.text != "" &&
      self.phoneNumberTextField.text != "" &&
      self.contentsTextView.text != "" {
      self.sendButton.isEnabled = true
    } else {
      self.sendButton.isEnabled = false
    }
  }
}

// MARK: - UITextViewDelegate

extension InquiryViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    self.contentsCheck()
  }
}
