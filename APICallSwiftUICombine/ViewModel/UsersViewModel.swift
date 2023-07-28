//
//  UsersViewModel.swift
//  APICallSwiftUICombine
//
//  Created by Cecilia Chen on 7/27/23.
//

import Foundation
import Combine

final class UsersViewModel: ObservableObject {
    
    @Published var users: [User] = []
    @Published var hasError = false
    @Published var error:UserError?
    @Published private(set) var isRefreshing = false //make sure this property won't be changed outside this viewmodel
    
    private var cancelBag = Set<AnyCancellable>()
    
    //MARK: - Regular URLSession Usage
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
    
    //MARK: - Use Combine in URLSession
    func fetchUsersNew() {
        let usersURLString = "https://jsonplaceholder.typicode.com/users"
        if let url = URL(string: usersURLString) {
            
            isRefreshing = true
            hasError = false
            
            URLSession.shared
                .dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap({ response in                   //throw decode error using try, can add my own customized error
                    guard let nextLevelResponse = response.response as? HTTPURLResponse, nextLevelResponse.statusCode >= 200 && nextLevelResponse.statusCode <= 300 else {
                        throw UserError.invalidStatusCode
                    }
                    let decoder = JSONDecoder()
                    guard let users = try? decoder.decode([User].self, from: response.data) else {
                        throw UserError.failedToDecode
                    }
                    return users
                })
                .sink { response in
                    defer {self.isRefreshing = false } //last thing to execute within the scope of this closure
                    
                    switch response {
                    case .failure(let error):
                        self.hasError = true
                        self.error = UserError.custom(error: error)
                    default: break
                        
                    }
                } receiveValue: { [unowned self] users in
                    self.users = users
                }
                .store(in: &cancelBag)
        }
    }
}

extension UsersViewModel {
    enum UserError: LocalizedError {
        case custom(error: Error)
        case failedToDecode
        case invalidStatusCode
        
        var errorDescription: String? {
            switch self {
            case .failedToDecode:
                return "Failed to decode response"
            case .custom(let error):
                return error.localizedDescription
            case .invalidStatusCode:
                return "Request falls within an invalid range"
            }
        }
    }
}
