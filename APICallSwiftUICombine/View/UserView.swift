//
//  UserView.swift
//  APICallSwiftUICombine
//
//  Created by Cecilia Chen on 7/27/23.
//

import SwiftUI

struct UserView: View {
    
    let user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("**Name**: \(user.name)")
            Text("**Email**: \(user.email)")
            Divider()
            Text("**Company**: \(user.company.name)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 4)
    }
}

#Preview {
    UserView(user: .init(id: 0, name: "Cecilia", email: "cecilia.g.chen@outlook.com", company: .init(name: "Ceci Company")))
}
