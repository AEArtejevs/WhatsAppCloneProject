//
//  ContactModels.swift
//  WhatsAppClone
//
//  Created by Andris on 10/05/2026.
//

import Foundation

struct ContactResponse: Codable, Identifiable {

    let id: Int
    let username: String
    let email: String
    let createdAt: String

}
