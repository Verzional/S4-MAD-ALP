
//
//  UserModel.swift
//  S4-MAD-ALP
//
//  Created by Gabriela Sihutomo on 22/05/25.
//

import Foundation

struct UserModel{
    var id: String?
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var image: String = ""
    var level: Int = 0
    var currXP: Int = 0
    var maxXP: Int = 50
}
