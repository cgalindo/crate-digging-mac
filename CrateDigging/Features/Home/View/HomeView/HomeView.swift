//
//  HomeView.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedItem) {
                ForEach(MenuItem.allCases, id: \.self) { item in
                    NavigationLink(value: item) {
                        Label(item.title, systemImage: item.icon)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            Group {
                switch viewModel.selectedItem {
                case .collection:
                    CollectionView()
                case .crates:
                    CratesView()
                case .mixes:
                    MixesView()
                }
            }
        }
        .frame(minWidth: 954, minHeight: 400)
    }
}



#Preview {
    HomeView()
}
