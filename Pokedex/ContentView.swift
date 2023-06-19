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
    @State private var isAnimating = false
       @State private var showProgress = false
       var foreverAnimation: Animation {
           Animation.linear(duration: 2.0)
               .repeatForever(autoreverses: false)
       }
    
    func setup() async {
        await fetchPokemon()
    }
    
    func fetchPokemon() async {
        await apiManager.fetchPokemon(from: 0, to: 1010)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            loading = false
        }
    }
    
    func pokemonChanged(_ id:Int){
        
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
                                    Text(pok.name).tag(pok.id)
                                    Spacer()
                                    Text(pok.pokemonId)
                                }
                            }
                        }.pickerStyle(.wheel)
                            .onChange(of: selectedPokemonIndex) { tag in  pokemonChanged(tag)}
                    }
                }
            }else{
                Image("pokeballSpin").resizable().frame(width: 100,height: 100)
                                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                                    .animation(self.isAnimating ? foreverAnimation : .default, value: isAnimating)
                                    .onAppear { self.isAnimating = true }
                                    .onDisappear { self.isAnimating = false }
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


