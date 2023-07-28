//
//  User.swift
//  This file contains Model for struct User
//
//  Created by Cecilia Chen on 7/27/23.
//

import Foundation

struct User: Codable {
    //Fields are immutable, won't be changed in business logic
    let id:Int
    let name:String
    let email:String
    let company: Company
}
