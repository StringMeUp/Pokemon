//
//  PokemonWidget.swift
//  PokemonWidget
//
//  Created by Samir Ramic on 28.05.26.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    var randomPokemon: Pokemon {
        var results: [Pokemon] = []
        do {
            results = try PersistenceController.shared.container.viewContext.fetch(Pokemon.fetchRequest())
        } catch {
            print("Error occured while fetach \(error)")
        }
        
        if let randomPokemon = results.randomElement() {
            return randomPokemon
        }
        
        return PersistenceController.previewPokemon
    }
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry.placeholder
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 10 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset * 5, to: currentDate)!
            
            let entry = SimpleEntry(date: .now, name: randomPokemon.name!, types: randomPokemon.types!, sprite: randomPokemon.spriteImage)
            
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let types: [String]
    let sprite: Image
    
    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "Bulbasaur",
            types: ["grass", "poison"],
            sprite: Image(.bulbasaur))
    }
    
    static var placeholder2: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "mew",
            types: ["psychic"],
            sprite: Image(.mew))
    }
}

struct PokemonWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    var entry: Provider.Entry
    var pokemonImage: some View {
        entry.sprite
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .shadow(color: .black, radius: 6)
    }
    var typesView: some View {
        ForEach(entry.types, id: \.self){ type in
            Text(type.description.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding(.horizontal, 13)
                .padding(.vertical, 5)
                .background(
                    Color(
                        type.description.capitalized
                    )
                )
                .clipShape(.capsule)
                .shadow(radius: 3)
        }
    }
    
    var body: some View {
        switch widgetSize {
        case .systemMedium:
            HStack{
                pokemonImage
                Spacer()
                VStack(alignment: .leading){
                    Text(entry.name.capitalized)
                        .font(.headline)
                    HStack{
                        typesView
                    }
                }.layoutPriority(1)
                Spacer()
            }
        case .systemLarge:
            ZStack{
                pokemonImage
                
                VStack(alignment:.leading) {
                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    HStack {
                        Spacer()
                        typesView
                    }
                }
            }
        default:
            pokemonImage
        }
    }
}

struct PokemonWidget: Widget {
    let kind: String = "PokemonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PokemonWidgetEntryView(entry: entry)
                    .foregroundStyle(.black)
                    .containerBackground(Color(entry.types[0].capitalized), for: .widget)
                
            } else {
                PokemonWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Pokemon")
        .description("See a random pokemon!")
    }
}

#Preview(as: .systemSmall) {
    PokemonWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemMedium) {
    PokemonWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemLarge) {
    PokemonWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}
