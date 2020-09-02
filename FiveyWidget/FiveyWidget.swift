//
//  FiveyWidget.swift
//  FiveyWidget
//
//  Created by Joel Bernstein on 8/30/20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (FiveyTimelineEntry) -> ()) {
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: Region.jsonURLString[configuration.region.rawValue])!) {
            (data, response, error) in

            guard let data = data else { return }

            do {
                let polls = try JSONDecoder().decode([Poll].self, from: data)

                completion(FiveyTimelineEntry(date: Date(), poll: polls.first, configuration: configuration))
            } catch {
                completion(FiveyTimelineEntry(date: Date(), poll: nil, configuration: configuration))
            }
        }

        dataTask.resume()
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<FiveyTimelineEntry>) -> ()) {
        getSnapshot(for: configuration, in: context) { entry in
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }

    func placeholder(in context: Context) -> FiveyTimelineEntry {
        FiveyTimelineEntry(date: Date(), poll: nil, configuration: ConfigurationIntent())
    }
}

struct FiveyTimelineEntry: TimelineEntry {
    let date: Date
    let poll: Poll?
    let configuration: ConfigurationIntent
}

struct FiveyWidgetEntryView : View {
    
    var entry: FiveyTimelineEntry
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    func percentString(for name: String) -> String {
        let percent = entry.poll?.candidate(named: name)?.dataPoints.first?.winProbability
        return percent == nil ? "--" : String(Int(percent! + 0.5))
    }

    var updatedDateString: String
    {
        guard let date = entry.poll?.updated else { return "--" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 20)
        {
            HStack(spacing: 20) {
                VStack {
                    VStack(spacing: 0) {
                        Text(Region.displayName[entry.configuration.region.rawValue])
                            .font(Font.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)

                        Label(updatedDateString, systemImage: "clock")
                            .font(Font.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(percentString(for: "Biden"))
                        .font(Font.system(size: 45, weight: .bold, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)

                    Text(percentString(for: "Trump"))
                        .font(Font.system(size: 45, weight: .bold, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                }
                
                if widgetFamily != .systemSmall {
                    Color(UIColor.secondarySystemBackground)
                        .overlay(WinProbabilityGraph(poll: entry.poll).padding(.trailing, 8))
                        .clipShape(ContainerRelativeShape())
                }
            }
        }
        .padding()
        .widgetURL(URL(string: Region.linkURLString[entry.configuration.region.rawValue])!)
    }
}

@main
struct FiveyWidget: Widget {
    let kind: String = "FiveyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            FiveyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Fivey")
        .description("iOS 14 widget to show FiveThirtyEight's 2020 election model results.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FiveyWidget_Previews: PreviewProvider {
    static var previews: some View {
        let data = try? Data(contentsOf: Bundle.main.url(forResource: "fixture", withExtension: "json")!)
        let polls = try? JSONDecoder().decode([Poll].self, from: data!)
        
        FiveyWidgetEntryView(entry: FiveyTimelineEntry(date: Date(), poll: polls?.first, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        FiveyWidgetEntryView(entry: FiveyTimelineEntry(date: Date(), poll: polls?.first, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
