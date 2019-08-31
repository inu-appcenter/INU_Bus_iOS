//
//  Inquiry.swift
//  INUBus
//
//  Created by 임현규 on 27/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

struct Inquiry: Codable {
  
    let title: String
    let contact: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case title, contact
        case message = "msg"
    }
}
