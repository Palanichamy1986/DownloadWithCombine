//
//  ContentView.swift
//  DownloadWithCombine
//
//  Created by apple on 16/08/25.
//

import SwiftUI
import Combine

struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class DownloadWithCombineViewModel: ObservableObject {
    @Published var posts: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [PostModel].self, decoder: JSONDecoder())
            .sink { (completion) in
                print("COMPLETION: \(completion)")
            } receiveValue: { [weak self] (returnedData) in
                self?.posts = returnedData
            }
            .store(in: &cancellables)

    }
}

struct ContentView: View {
    @StateObject var viewModel = DownloadWithCombineViewModel()
    var body: some View {
        List {
            ForEach(viewModel.posts) { post in
                VStack {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
