//
//  ContentView.swift
//  APICallSwiftUICombine
//
//  Created by Cecilia Chen on 7/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = UsersViewModel()
    
    var body: some View {
        NavigationView{
            ZStack {
                if vm.isRefreshing {
                    ProgressView()
                } else {
                    List {
                        ForEach(vm.users, id: \.id) { user in
                            UserView(user: user)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Users")
                }
            }
            .onAppear(perform: vm.fetchUsersNew)
            .alert(isPresented: $vm.hasError, error: vm.error) {
                Button(action: vm.fetchUsersNew){
                    Text("Retry")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
