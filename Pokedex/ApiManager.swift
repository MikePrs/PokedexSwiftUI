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
        for i in from...to{
            do {
                let url = URL(string: "https://pokeapi.co/api/v2/pokemon/"+String(i))!
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedData = try JSONDecoder().decode(Pokemon.self, from: data)
                DispatchQueue.main.async {
                    self.pokemonList.append(decodedData)
                }
                //            if let url = URL(string:"https://pokeapi.co/api/v2/pokemon/"+String(i)){
                //                let session = try await URLSession(configuration: .default)
                //                let task = session.dataTask(with: url){(data , response,error) in
                //                    if error==nil {
                //                        let decoder = JSONDecoder()
                //                        if let safeData = data {
                //                            do{
                //                                let group = DispatchGroup()
                //                                    group.enter()
                //                                let res = try decoder.decode(Pokemon.self, from:safeData)
                //
                //                                DispatchQueue.main.async {
                //                                    self.pokemonList.append(res)
                //                                    group.leave()
                //                                }
                //                                group.notify(queue: .main) {
                //                                    self.pokemonList=self.pokemonList.sorted(by: { $0.id < $1.id })
                //                                }
                //                            }catch{
                //                                print(error)
                //                            }
                //                        }
                //                    }
                //                }
                //                task.resume()
                //                print("end")
                //            }
            } catch {
                print("Error fetching data: \(error)")
            }
            
        }
    }
    
    func getPokemon()->[Pokemon]{
        return pokemonList
    }
}



struct Pokemon : Codable,Identifiable{
    var name:String
    var id:Int
    var sprites:Sprites
    var types:[typeElement]
}

struct Sprites : Codable{
    var front_default:String
    var front_shiny:String
}

struct typeElement : Codable {
    var type:PokemonType
}

struct PokemonType : Codable {
    var name:String
}
