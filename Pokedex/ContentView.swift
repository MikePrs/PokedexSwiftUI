//
//  ContentView.swift
//  Pokedex
//
//  Created by Mike Paraskevopoulos on 18/6/23.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @ObservedObject var apiManager = ApiManager()
    @State private var selectedPokemonIndex = 1
    @State var loading = true
    
    func setup() async {
        await fetchPokemon()
    }
    
    func fetchPokemon() async {
        await apiManager.fetchPokemon(from: 0, to: 100)
        loading = false
    }
    
    var body: some View {
        ZStack {
            if !loading{
                ZStack{
                    Image("pokeballBackground")
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                        .frame(minWidth: 0)
                        .ignoresSafeArea(.all)
                    
                    VStack{
                        HStack{Image(systemName: "circle.fill").foregroundColor(.green);Spacer()}.padding(.leading,20)
                        AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"+String(selectedPokemonIndex)+".png")) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }.frame(width: 250, height: 250).background(.white.opacity(0.3)).cornerRadius(10.0).padding(.top,30)
                        Spacer()
                        Text("Selected pokemon: \(apiManager.pokemonList[selectedPokemonIndex-1].name)")
                        
                        Picker("",selection:$selectedPokemonIndex){
                            ForEach(apiManager.pokemonList){ pok in
                                HStack{
                                    Text(pok.name)
                                    Spacer()
                                    Text(String(format:"%03d", pok.id))
                                }
                            }
                        }.pickerStyle(.wheel)
                    }
                }
            }else{
                ProgressView()
            }
        }.task{
            await self.setup()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

