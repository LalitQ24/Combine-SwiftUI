//
//  ContentView.swift
//  CombineDemo
//
//  Created by Lalit Kumar on 12/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel =  CombineViewModel(combineService: CombineDataService())
    var body: some View {
        VStack {
            Button("Click Button ") {
                //  viewModel.getUserData()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
