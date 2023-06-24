//
//  PokemonModel.swift
//  Pokedex
//
//  Created by Mike Paraskevopoulos on 24/6/23.
//

import SwiftUI

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



struct PokemonDetails : Codable{
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

