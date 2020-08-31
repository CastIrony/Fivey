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
    func placeholder(in context: Context) -> FiveyTimelineEntry {
        FiveyTimelineEntry(date: Date(), poll: nil, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (FiveyTimelineEntry) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: URL(string: "https://projects.fivethirtyeight.com/2020-election-forecast/us_timeseries.json")!)
        {
            (data, response, error) in

            guard let data = data else { return }

            do
            {
                let polls = try JSONDecoder().decode([Poll].self, from: data)

                completion(FiveyTimelineEntry(date: Date(), poll: polls.first, configuration: configuration))
            }
            catch
            {
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
}

struct FiveyTimelineEntry: TimelineEntry {
    let date: Date
    let poll: Poll?
    let configuration: ConfigurationIntent
}

struct FiveyWidgetEntryView : View {
    
    var entry: FiveyTimelineEntry

    var bidenPercent: String? {
        let biden = entry.poll?.candidates.filter { $0.candidate == "Biden" }.first
        let percent = biden?.dates.first?.winprob
        return percent == nil ? nil : String(Int(percent! + 0.5))
    }

    var trumpPercent: String? {
        let trump = entry.poll?.candidates.filter { $0.candidate == "Trump" }.first
        let percent = trump?.dates.first?.winprob
        return percent == nil ? nil : String(Int(percent! + 0.5))
    }

    var body: some View {
        VStack {
            Text(bidenPercent ?? "--")
                .font(Font.system(size: 55, weight: .bold, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.blue)

            Text(trumpPercent ?? "--")
                .font(Font.system(size: 55, weight: .bold, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.red)
        }
    }
}

@main
struct FiveyWidget: Widget {
    let kind: String = "FiveyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            FiveyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct FiveyWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        let biden = Candidate(candidate: "Biden", dates: [ DataPoint(date: "", winprob: 60) ])
        let trump = Candidate(candidate: "Trump", dates: [ DataPoint(date: "", winprob: 40) ])

        FiveyWidgetEntryView(entry: FiveyTimelineEntry(date: Date(), poll: Poll(type: "", state: "", candidates: [ trump, biden ]), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
