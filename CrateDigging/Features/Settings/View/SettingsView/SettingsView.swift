//
//  SettingsView.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach($viewModel.folderSettings) { $setting in
                    folderSettingRow(setting: $setting)
                }
                
                clearButton
                    .padding(.top, 8)
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Helper Methods
extension SettingsView {
    private func folderSettingRow(
        setting: Binding<FolderSetting>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(setting.wrappedValue.title)
                .font(.headline)
            
            HStack {
                Text(viewModel.displayText(for: setting.wrappedValue))
                    .font(.subheadline)
                    .foregroundColor(viewModel.foregroundColor(for: setting.wrappedValue))
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                // Only show Change button for Root Folder
                if viewModel.isRootFolder(setting.wrappedValue) {
                    Button("Change...") {
                        Task {
                            await viewModel.changeFolder(for: setting.wrappedValue)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private var clearButton: some View {
        Button(role: .destructive) {
            Task {
                await viewModel.clearAllData()
            }
        } label: {
            Text("Clear All Data")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

#Preview {
    SettingsView()
}

