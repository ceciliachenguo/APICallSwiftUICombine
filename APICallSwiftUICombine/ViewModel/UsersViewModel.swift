//
//  UsersViewModel.swift
//  APICallSwiftUICombine
//
//  Created by Cecilia Chen on 7/27/23.
//

import Foundation

final class UsersViewModel: ObservableObject {
    
    @Published var users: [User] = []
    @Published var hasError = false
    @Published var error:UserError?
    @Published private(set) var isRefreshing = false //make sure this property won't be changed outside this viewmodel
    
    func fetchUsers() {
        
        isRefreshing = true
        hasError = false
        let usersURLString = "https://jsonplaceholder.typicode.com/users"
        
        if let url = URL(string: usersURLString) {
            URLSession
                .shared
                .dataTask(with: url) { [unowned self] data, response, error in //avoid retain cycle
//                    DispatchQueue.main.async { //make sure the response received are on the main threead
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                        if let error = error {
                            self.hasError = true
                            self.error = UserError.custom(error: error)
                        } else {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase //handle properties that look like first_name > firstName
                            
                            if let data = data, let users = try? decoder.decode([User].self, from: data) {
                                self.users = users
                            } else {
                                self.hasError = true
                                self.error = UserError.failedToDecode
                            }
                        }
                        self.isRefreshing = false
                        
                    }
                }.resume()
        }
    }
}

extension UsersViewModel {
    enum UserError: LocalizedError {
        case custom(error: Error)
        case failedToDecode
        
        var errorDescription: String? {
            switch self {
            case .failedToDecode:
                return "Failed to decode response"
            case .custom(let error):
                return error.localizedDescription
            }
        }
    }
}
