//
//  Searchbar.swift
//  Pokedex
//
//  Created by Mike Paraskevopoulos on 20/6/23.
//

import SwiftUI
 
struct SearchBar: View {
    @Binding var text: String
 
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    var body: some View {
        HStack {
 
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6).opacity(0.7))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .padding(.top,10)
                .onTapGesture {
                    self.isEditing = true
                    self.isFocused = true
                }
                .focused($isFocused)
 
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    self.isFocused = false
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
//                .transition(.move(edge: .trailing))
//                .animation(.default)
            }
        }
    }
}
