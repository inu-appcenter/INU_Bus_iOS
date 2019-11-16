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
  
  // MARK: - Property
  
  /// 정보를 요청할 서버 URL
  let url = Server.address.rawValue + StringConstants.errormsg.rawValue
  
  // 다음 화면으로 넘어갈 스토리보드와 뷰컨트롤러
  let storyboardIdentifier = StringConstants.inquiry.rawValue
  let viewControllerIdentifier = StringConstants.popUpViewController.rawValue
  
 // MARK: - IBAction
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBAction func sendButtonDidTap(_ sender: Any) {
    request()
  }
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
  }
}

// MARK: - Methods

extension InquiryViewController {
  func setUp() {
    let viewControllerGesture = UITapGestureRecognizer(target: self,
                                                       action: #selector(tapViewcontroller(_:)))
    view.addGestureRecognizer(viewControllerGesture)
    contentsTextView.delegate = self
    
    titleTextField.delegate = self
    titleTextField.addTarget(self,
                             action: #selector(contentsCheck),
                             for: .editingChanged)
    phoneNumberTextField.addTarget(self,
                                   action: #selector(contentsCheck),
                                   for: .editingChanged)
    
    contentsTextView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentsTextView.topAnchor.constraint(
        equalTo: phoneNumberTextField.bottomAnchor,
        constant: 50),
      contentsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: 31),
      contentsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                              constant: -31),
      contentsTextView.heightAnchor.constraint(
        equalToConstant: heightByDevice(height: UIScreen.main.bounds.height))
    ])
    
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      sendButton.widthAnchor.constraint(equalToConstant: 70),
      sendButton.heightAnchor.constraint(equalToConstant: 32),
      sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      sendButton.topAnchor.constraint(equalTo: contentsTextView.bottomAnchor,
                                      constant: 54)
    ])
  }
  
  /// 빈 공간을  눌렀을 때의 함수
  @objc func tapViewcontroller(_ sender: UITapGestureRecognizer) {
    // 키보드를 내림
    view.endEditing(true)
    contentsCheck()
  }
  
  /// TextField, TextView가 다 채워졌으면 버튼을 활성화하는 함수
  @objc func contentsCheck() {
    if titleTextField.text != "" &&
      phoneNumberTextField.text != "" &&
      contentsTextView.text != "" {
      sendButton.alpha = 1
      sendButton.isEnabled = true
    } else {
      sendButton.alpha = 0.5
      sendButton.isEnabled = false
    }
  }
  
  /// textView를 기기 높이에 따라서 조정하기 위한 함수.
  func heightByDevice(height: CGFloat) -> CGFloat {
    return height *  174 / 667
  }
  
  /// 문의사항을 서버에 post함.
  func request() {
    let inquiry = Inquiry(title: titleTextField.text ?? "",
                          msg: contentsTextView.text,
                          device: UIDevice.current.name,
                          version: UIDevice.current.systemVersion,
                          contact: phoneNumberTextField.text ?? "")
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    do {
      let jsonBody = try encoder.encode(inquiry)
      
      guard let url = URL(string: url) else {
        errorLog("URL 에러")
        return
      }
      
      NetworkManager.shared.post(url: url,
                                 httpBody: jsonBody) { data, response, error in
        if let error = error {
          errorLog("Post 에러: \(error.localizedDescription)")
          
          DispatchQueue.main.async {
                      UIAlertController
              .alert(title: nil, message: StringConstants.networkError.rawValue)
              .action(title: "확인")
              .present(to: self)
          }
        }
        
        if let httpsStatus = response as? HTTPURLResponse {
          print("statusCode: \(httpsStatus.statusCode)")
        }
        
        if let data = data {
          print(String(data: data, encoding: .utf8) ?? "Success")
          let viewController = UIViewController
            .instantiate(storyboard: self.storyboardIdentifier,
                         identifier: self.viewControllerIdentifier)
          DispatchQueue.main.async {
            viewController.modalPresentationStyle = .overFullScreen
            self.present(viewController, animated: false)
          }
          
        }
      }
      
    } catch {
      errorLog("인코딩 에러: \(error.localizedDescription)")
    }
  }
}

extension InquiryViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    // TextView내에 내용이 변했을때를 감지함
    contentsCheck()
  }
}

extension InquiryViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //return을 눌렀을 때 키보드를 내려줌.
    textField.resignFirstResponder()
    return true
  }
}
