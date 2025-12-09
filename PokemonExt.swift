//
//  PokemonExt.swift
//  Po-ke-mon
//
//  Created by Samir Ramic on 09.12.25.
//

import Foundation
import SwiftUI

extension Pokemon {
    var background: ImageResource {
        switch types![0] {
        case "rock", "ground", "steel", "figthing", "ghost", "dark", "psychic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case "ice":
                .ice
        case "water":
                .water
        default:
                .normalgrasselectricpoisonfairy
        }
    }
    
    var typeColor: Color {
        Color(self.types![0].capitalized)
    }
    
    var stats: [Stat] {
        [
            Stat(id: 1, type: "HP", value: hp)
            Stat(id: 2, type: "Attack", value: attack)
            Stat(id: 3, type: "Defense", value: defense)
            Stat(id: 4, type: "Special Attack", value: specialAttack)
            Stat(id: 5, type: "Special Defense", value: specialDefense)
            Stat(id: 6, type: "Speed", value: speed)
        ]
    }
    
    var highestStat: Stat {
        stats.max { $0.value < $1.value }!
    }
}

struct Stat: Identifiable {
    let id: Int,
        let type: String,
        let value: Int16
}
