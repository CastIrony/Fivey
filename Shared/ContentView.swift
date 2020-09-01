//
//  ContentView.swift
//  Shared
//
//  Created by Joel Bernstein on 8/30/20.
//

import SwiftUI

struct ContentView: View {
    @State var poll: Poll?

    func percentString(for name: String) -> String {
        let percent = poll?.candidate(named: name)?.dataPoints.first?.winProbability
        return percent == nil ? "--" : String(Int(percent! + 0.5))
    }

    var updatedDateString: String {
        guard let date = poll?.updated else { return "--" }
        
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
                        Text("United States")
                            .font(Font.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)

                        Text(updatedDateString)
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

                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .clipShape(ContainerRelativeShape())
            }

            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .clipShape(ContainerRelativeShape())

            Text("Updated \(updatedDateString)")
                .font(Font.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .padding(-10)

        }
            .padding()
            .onAppear {
                let dataTask = URLSession.shared.dataTask(with: URL(string: "https://projects.fivethirtyeight.com/2020-election-forecast/us_timeseries.json")!) {
                    (data, response, error) in

                    guard let data = data else { return }

                    poll = try? JSONDecoder().decode([Poll].self, from: data).first
                }

                dataTask.resume()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
