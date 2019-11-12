//
//  PopUpViewController.swift
//  INUBus
//
//  Created by 임현규 on 24/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var thanksLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  // MARK: - Properties
  
  // 정보를 요청할 서버 URL
  let url = Server.address.rawValue + StringConstants.errormsg.rawValue
  let device = UIDevice.current
  
  var inquiryTitle = ""
  var inquiryContact = ""
  var inquiryMessage = ""
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    // Do any additional setup after loading the view.
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  // MARK: - IBActions
  
  @IBAction func yesButtonDidTap(_ sender: Any) {
    
    request()
    print(device.name)
    print(device.systemVersion)
    let presentingViewController =
      self.presentingViewController
    self.dismiss(animated: true, completion: {
      presentingViewController?.dismiss(animated: true, completion: nil)
    })
  }
}

// MARK: - Methods

extension PopUpViewController {
  func setupView() {
    
    self.mainView.translatesAutoresizingMaskIntoConstraints = false
    self.mainView.widthAnchor.constraint(equalToConstant: 260.5).isActive = true
    self.mainView.heightAnchor.constraint(equalToConstant: 155).isActive = true
    self.mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.mainView.centerYAnchor.constraint(equalTo:
      self.view.centerYAnchor).isActive = true
    
  }
  
  // HTTP POST 통신을 하는 함수
  func request() {
    
    let inquiry = Inquiry(title: self.inquiryTitle, msg: self.inquiryMessage,
                          device: "\(device.name)", version: "\(device.systemVersion)", contact: self.inquiryContact)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonBody = try? encoder.encode(inquiry)
    print(String(data: jsonBody!, encoding: .utf8)!)
    
    guard let url = URL(string: url) else { return }
    
    PostManager.shared.request(url: url, method: .post, httpBody: jsonBody!) {(data, response, error) in
      
      guard let data = data, error == nil else {
        print("error=\(error)")
        return
      }
      
      if let httpStatus = response as? HTTPURLResponse {
        print("statusCode = \(httpStatus.statusCode)")
      }
      
      let responseString = String(data: data, encoding: .utf8)
      print("responseString = \(responseString)")
      
    }
  }

}
