
//
//  CombineViewModel.swift
//  CombineDemo
//
//  Created by Lalit Kumar on 12/12/24.
//

import Combine
import SwiftUI

class CombineViewModel: ObservableObject {
    private var combineService: CombineDataService?
    @Published var users: [UserModel] = []
    var canellable: Set<AnyCancellable> = []
    
    init(combineService: CombineDataService) {
        self.combineService = combineService
    }
    func getUserData() {
        self.combineService?.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink { comletion in
                switch comletion {
                case .finished:
                    print("Completd")
                case .failure(let error):
                    print("fetching userr \(error)")
                }
            } receiveValue: { user in
                self.users = user
            }
            .store(in: &canellable)
    }
    
    func getUserDeatils(userId: Int)  {
        self.combineService?.loadServerData(userId: userId, type: UserModel.self)
            .sink(receiveCompletion: { _ in
                print("completion")
            }, receiveValue: { userModelDetails in
                print("userModelDeail: \(userModelDetails)")
            })
    }
}
