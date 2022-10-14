//
//  ContentView.swift
//  NLPDairy
//
//  Created by Khawlah Khalid on 14/10/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                List{
                    ForEach(vm.searchResults,id: \.self) { entry  in
                        Text(entry)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $vm.searchText, prompt: "Look for something")
            }
            .navigationTitle("My Dairy")
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
