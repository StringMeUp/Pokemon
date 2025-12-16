//
//  StatsView.swift
//  Po-ke-mon
//
//  Created by Samir Ramic on 16.12.25.
//

import SwiftUI
import CoreData
import Charts

struct StatsView: View {
    
    var pokemon: Pokemon

    var body: some View {
        Chart(pokemon.stats){ stat in
            BarMark(
                x: .value("Value", stat.value),
                y: .value("Stat", stat.name)
            ).annotation(position: .trailing) {
                Text("\(stat.value)")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 200)
        .padding(.horizontal)
        .foregroundStyle(pokemon.typeColor)
        .chartXScale(domain: 0...pokemon.highestStat.value+10)
    }
}

#Preview {
    StatsView(pokemon: PersistenceController.previewPokemon)
}
