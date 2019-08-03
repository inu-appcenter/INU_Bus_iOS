//
//  PopUpViewController.swift
//  INUBus
//
//  Created by 임현규 on 24/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let severURL = "http://inucafeteriaaws.us.to:3829/"

    var inquiryTitle = ""
    var inquiryContact = ""
    var inquiryMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func yesButtonDidTap(_ sender: Any) {
        let presentingViewController =
        self.presentingViewController
        self.dismiss(animated: true, completion: {
            presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
}

extension PopUpViewController {
    func setupView() {
 
    self.mainView.layer.cornerRadius = 16
    self.mainView.translatesAutoresizingMaskIntoConstraints = false
    self.mainView.widthAnchor.constraint(equalToConstant: 260.5).isActive = true
    self.mainView.heightAnchor.constraint(equalToConstant: 155).isActive = true
    self.mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.mainView.centerYAnchor.constraint(equalTo:
        self.view.centerYAnchor).isActive = true
        
}
    
    func jsonPost() {
        
        let inquiry: Inquiry = Inquiry(service:
            "inu.appcenter.INUBus",
            title: self.inquiryTitle,
            contact: self.inquiryContact,
            message: self.inquiryMessage, device: "Iphone7")
        
        guard let url = URL(string: "\(self.severURL)errormsg") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(inquiry)
            request.httpBody = data
            print("encoding suceess!")
            print(data)
            
        } catch {
            print(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
                
            }
            
            if let data = data, let ut9Representation = String(data: data, encoding: .utf8) {
                print("response: ", ut9Representation)
            } else {
                print("post error!")
            }
            
            }.resume()
    }
  
}
