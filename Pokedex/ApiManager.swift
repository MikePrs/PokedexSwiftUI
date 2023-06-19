//
//  ApiManager.swift
//  Pokedex
//
//  Created by Mike Paraskevopoulos on 18/6/23.
//

import Foundation
class ApiManager:ObservableObject {
    @Published var pokemonList = [Pokemon]()
    func fetchPokemon(from:Int,to:Int)async{
            do {
                let url = URL(string: "https://pokeapi.co/api/v2/pokemon/?offset="+String(from)+"&limit="+String(to))!
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedData = try JSONDecoder().decode(PokemonList.self, from: data)
                print(String(decodedData.results[0].url.split(separator: "/").last!))
                DispatchQueue.main.async {
                    self.pokemonList = (decodedData.results)
                }
            } catch {
                print("Error fetching data: \(error)")
            }
    }
}



struct PokemonList : Codable{
    var results:[Pokemon]
}
struct Pokemon:Codable,Identifiable{
    var name:String
    var url:String
    var id:Int{
        return Int(url.split(separator: "/").last!)!
    }
    var pokemonId:String{
        return String(format:"%03d", id)
    }
}

