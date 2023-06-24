//
//  ApiManager.swift
//  Pokedex
//
//  Created by Mike Paraskevopoulos on 18/6/23.
//

import Foundation
class ApiManager:ObservableObject {
    @Published var pokemonList = [Pokemon]()
    @Published var pokemonDetails = [PokemonDetails]()
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
    
    func getPokemonDetails(_ id:String) async {
            do {
                let url = URL(string: "https://pokeapi.co/api/v2/pokemon/"+id)!
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedData = try JSONDecoder().decode(PokemonDetails.self, from: data)
                DispatchQueue.main.async {
                    self.pokemonDetails=[]
                    self.pokemonDetails.append(decodedData)
                }
            } catch {
                print("Error fetching data: \(error)")
            }
    }
}
