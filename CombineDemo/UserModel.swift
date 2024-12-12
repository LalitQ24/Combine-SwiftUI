//
//  UserModel.swift
//  CombineDemo
//
//  Created by Lalit Kumar on 12/12/24.
//

import SwiftUI

struct UserModel: Decodable, Hashable {
    let id: Int
    let name: String
    let userAddress: String
}


struct PostModel: Decodable, Hashable {
    let id: Int
    let post: String
    let date: Date?
}
