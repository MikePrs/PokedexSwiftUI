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
    @State private var searchText = ""
    @State var isImageFront=true
    @State var isShiny=false
    
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
                NavigationView {
                    ZStack{
                        VStack(spacing: 0){
                            VStack(spacing:0){
//                                HStack{
//                                    Image(systemName: "circle.fill").foregroundColor(.green).padding(.bottom,10).opacity(self.isAnimating ? 1 : 0).animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false),value:isAnimating)
//                                        .onAppear{self.isAnimating = true}
//                                        .onDisappear(){self.isAnimating = false}
//                                    Spacer()
//                                }.padding(.leading,20)
                                HStack{
                                    if animateFlag{
                                        Button {
                                            isShiny.toggle()
                                        } label: {
                                            HStack{
                                                Text(!isShiny ? "Shiny": "Classic").foregroundColor(.black)
                                                    .font(.custom("AmericanTypewriter",fixedSize: 22)).padding(3).padding(.leading,25).padding(.trailing,10)
                                            }.background(!isShiny ? .yellow : .white).roundedCorner(20, corners: [.topRight])
                                        }.transition(.slide)
                                        Spacer()
                                        HStack{
                                            Text("\(apiManager.pokemonList[selectedPokemonIndex-1].name.capitalized)")
                                                .font(.custom("AmericanTypewriter",fixedSize: 22)).padding(3).padding(.leading,25).padding(.trailing,10)
                                        }.transition(.backslide).background(.white).roundedCorner(20, corners: [.bottomLeft])
                                        
                                    }else{
                                        HStack{}.padding(16)
                                    }
                                }
                                
                                if animateFlag{
                                    Button {
                                        isImageFront.toggle()
                                    } label: {
                                        AsyncImage(url: URL(string:  getImage(isImageFront,isShiny,String(selectedPokemonIndex))))
                                        { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }.frame(minWidth: 200, minHeight: 200).background(.white.opacity(0.3)).cornerRadius(180.0).transition(.scale)
                                            .scaledToFit()
                                    }
                                    HStack{
                                        Image(types[0]).resizable().frame(width: 90,height: 35).transition(.backslide)
                                        Spacer()
                                        if types.count > 1{
                                            Image(types[1]).resizable().frame(width: 90,height: 35).transition(.slide)
                                        }
                                    }.padding(.horizontal).padding(.bottom)
                                }else{
                                    Spacer()
                                    Image("openPokeball").resizable().frame(width: 80,height: 55).padding(50)
                                }
                                Spacer()
                            }
                            VStack{
                                Spacer()
                                Picker("",selection:$selectedPokemonIndex){
                                    ForEach(apiManager.pokemonList){ pok in
                                        HStack{
                                            Image("pokeballSpin").resizable().frame(width: 30,height: 30)
                                            Text(pok.name.capitalized).tag(pok.id)
                                            Spacer()
                                            Text(pok.pokemonId)
                                        }
                                    }
                                }.pickerStyle(.wheel)
                                    .onChange(of: selectedPokemonIndex) { tag in  Task{await pokemonChanged(tag)}}
                                Spacer()
                            }
                        }
                    }.background {Image("pokeballBackground")
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0)
                            .edgesIgnoringSafeArea(.all)
                            .ignoresSafeArea(.all)
                    }
                }
                .searchable(text: $searchText)
                .onSubmit(of: .search, serachAction)
                .disableAutocorrection(true)
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
