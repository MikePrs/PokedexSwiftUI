//
//  ContentView.swift
//  Pokedex
//
//  Created by Mike Paraskevopoulos on 18/6/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var apiManager = ApiManager()
    @State private var selectedPokemonIndex = 1
    @State var loading = true
    @State private var isAnimating = false
    @State private var showProgress = false
    @State private var searchText = ""
    @State var isImageFront=true
    @State var isShiny=false
    @State var scrollAmount = 0.0
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }
    
    func setup() async {
        await fetchPokemon()
    }
    
    @State var nameIdMap=[String:Int]()
    @State private var animateFlag = true
    
    func fetchPokemon() async {
        await apiManager.fetchPokemon(from: 0, to: 1010)
        for pokemon in apiManager.pokemonList{
            nameIdMap[pokemon.name.capitalized] = pokemon.id
        }
        await pokemonChanged(selectedPokemonIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            loading = false
        }
    }
    
    @State var types=[String]()
    func pokemonChanged(_ id:Int)async{
        self.animateFlag.toggle()
        await apiManager.getPokemonDetails(String(id))
        types = apiManager.pokemonDetails[0].types.map{ (string) -> String in
            return string.type.name
        }
        withAnimation() {
            self.animateFlag.toggle()
        }
    }
    
    func serachAction() {
        print(searchText)
        if let pokemonId = nameIdMap[searchText]{
            selectedPokemonIndex = pokemonId
        }
    }
    
    var body: some View {
        
        ZStack {
            if !loading{
                    ZStack{
                        VStack(spacing: 0){
                            VStack(spacing:0){
                                if animateFlag{
                                    Button {
                                        isImageFront.toggle()
                                    } label: {
                                        AsyncImage(url: URL(string:  getImage(isImageFront,isShiny,String(selectedPokemonIndex))))
                                        { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }.frame(width: 120, height:120).background(.white.opacity(0.3)).cornerRadius(180.0).transition(.scale)
                                        .padding(.top,30)
                                        .scaledToFit()
                                    HStack{
                                        Image(types[0]).resizable().frame(width: 50,height: 25).transition(.backslide)
                                        Spacer()
                                        if types.count > 1{
                                            Image(types[1]).resizable().frame(width: 50,height: 25).transition(.slide)
                                        }
                                    }.padding(.horizontal)
                                }else{
                                    Spacer()
                                    HStack{
                                        Image("openPokeball").resizable().frame(width: 40,height: 30)
                                    }.frame(height: 70).padding(50)
                                }
                            }
                            VStack{
                                
                                Picker("",selection:$selectedPokemonIndex){
                                    ForEach(apiManager.pokemonList){ pok in
                                        HStack{
                                            Image("pokeballSpin").resizable().frame(width: 30,height: 30)
                                            Text(pok.name.capitalized).tag(pok.id).foregroundColor(.black)
                                            Spacer()
                                            Text(pok.pokemonId).foregroundColor(.black)
                                        }
                                    }
                                }.focusBorderHidden().pickerStyle(.wheel).frame(height: 110).clipped()
                                    .onChange(of: selectedPokemonIndex) { tag in  Task{await pokemonChanged(tag)}}
                            }
                        }
                    }
                    .background
                    {Image("pokeballBackground")
                            .resizable()
                            .scaledToFill()
                            .frame(alignment: .center)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                            .aspectRatio(contentMode: .fill)
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

                                               
func getImage(_ isImageFront:Bool , _ isShiny:Bool , _ selectedPokemonIndex:String) -> String{
    return isImageFront
    ? isShiny ?  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/"+selectedPokemonIndex+".png"
    :
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"+selectedPokemonIndex+".png"
    : isShiny ?  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/"+selectedPokemonIndex+".png"
    : "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/"+selectedPokemonIndex+".png"
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
