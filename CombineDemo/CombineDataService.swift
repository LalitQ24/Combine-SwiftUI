
//
//  CombineDataService.swift
//  CombineDemo
//
//  Created by Lalit Kumar on 12/12/24.
//

import Combine
import SwiftUI
import Foundation
import Swift

//MARK: Constant Api endPoints
struct Constant {
    struct EndPointUrl {
        static let userDeatails: URL = URL(string: "https://wwww/example.com/details")!
        static func addUserId(_ userId: Int) -> URL {
            URL(string: "https://wwww/example.com/\(userId)")!
        }
    }
}

class CombineDataService {
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUsers() -> AnyPublisher<[UserModel], Error> {
        let url = Constant.EndPointUrl.userDeatails
        return URLSession.shared.dataTaskPublisher(for: url) //  pass request
            .map({$0.data})
            .decode(type: [UserModel].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    //MARK: Post UserData
    func postUserData()  {
        let dicdata = ["name": "", "userAddress": ":" ]
        let requestBody = try? JSONSerialization.data(withJSONObject: dicdata, options: [])
        let url = URL(string: "")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        request.setValue("token", forHTTPHeaderField: "Autorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Add some necessary methof
        let _ = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (output) -> Data in
                let statusCode = (output.response as! HTTPURLResponse).statusCode
                if 400..<500 ~= statusCode {
                    throw  APIError.badRequest
                }
                return output.data
            }
        // .decode(type: [UserModel].self, decoder: JSONDecoder())
        // .eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in
                print("recive completion")
            }, receiveValue: { user in
                print("user: \(user)")
            })
        
    }
    
    //MARK: Load server with Generic Data uses of Future publisher
    func loadServerData<T:Decodable>(userId: Int?, type: T.Type) -> Future<[T], Error> {
        return Future<[T], Error> { [weak self] promise in
            let userId = userId ?? 0
            let url = Constant.EndPointUrl.addUserId(userId)
            guard let self = self  else {
                return promise(.failure(APIError.invalidURl))
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap {element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw APIError.invalidURl
                    }
                    return element.data
                }
                .decode(type: [T].self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { compeltion in
                    if case let .failure(error) = compeltion {
                        switch error {
                        case let apiError as APIError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(APIError.invalidURl))
                        }
                    }
                } receiveValue: { value in
                    promise(.success(value))
                }
                .store(in: &self.cancellables)
        }
    }
    
    //MARK: Multiple request send to server
    func multipleApiRequestToServer() {
        let url1 = URL(string: "")
        let url2 = URL(string: "")
        let publisher1 = URLSession.shared.dataTaskPublisher(for: url1!)
            .map({$0.data})
            .decode(type: [UserModel].self, decoder: JSONDecoder())
        let publisher2 = URLSession.shared.dataTaskPublisher(for: url2!)
            .map({$0.data})
            .decode(type: [PostModel].self, decoder: JSONDecoder())
        
        let cancellable = Publishers.Zip(publisher1, publisher2)
            .eraseToAnyPublisher()
            .catch{_ in
                Just(([], []))
            }
            .sink(receiveValue: { user, post in
                print("User \(user)")
                print("post \(post)")
            })
    }
}

enum APIError: Error {
    case badRequest
    case invalidURl
    case invalidRespnse
    case decodingEroor(String)
}
