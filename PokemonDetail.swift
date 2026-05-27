//
//  PokemonDetail.swift
//  Po-ke-mon
//
//  Created by Samir Ramic on 02.12.25.
//

import CoreData
import SwiftUI

struct PokemonDetail: View {

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var pokemon: Pokemon
    @State private var showShiny: Bool = false

    var body: some View {
        ScrollView {
            pokemonImage(pokemon: pokemon, showShiny: showShiny)

            HStack {
                ForEach(
                    pokemon.types ?? [],
                    id: \.self
                ) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary)
                        .shadow(color: .black, radius: 1)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(
                            Color(
                                type.description.capitalized
                            )
                        )
                        .clipShape(.capsule)
                }

                Spacer()
                Button {
                    pokemon.favorite.toggle()

                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to toggle favorite: \(error)")
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }

            }.padding([.horizontal, .top])

            Text("Stats")
                .foregroundStyle(.primary)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top)

            StatsView(pokemon: pokemon)

        }
        .navigationTitle(pokemon.name?.capitalized ?? "")
        .toolbar {
            ToolbarItem {
                Button {
                    showShiny.toggle()
                } label: {
                    Image(
                        systemName: showShiny
                            ? "wand.and.stars" :
                            "wand.and.stars.inverse"
                    )
                }.tint(showShiny ? .yellow : .primary)
            }
        }
    }
}

func pokemonImage(pokemon: Pokemon, showShiny: Bool) -> some View {
    return ZStack {
        Image(pokemon.background)
            .resizable()
            .scaledToFit()
            .shadow(color: .black, radius: 6)
        
        if pokemon.sprite == nil || pokemon.shiny == nil {
            AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                image
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 50)
                    .shadow(color: .black, radius: 6)
            } placeholder: {
                ProgressView()
            }
        }else{
            (showShiny ? pokemon.sshinnyImage : pokemon.spriteImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(.top, 50)
                .shadow(color: .black, radius: 6)
        }
        AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
            image
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(.top, 50)
                .shadow(color: .black, radius: 6)
        } placeholder: {
            ProgressView()
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetail()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
