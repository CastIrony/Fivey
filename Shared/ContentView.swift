//
//  ContentView.swift
//  Shared
//
//  Created by Joel Bernstein on 8/30/20.
//

import SwiftUI
import WebView

struct ContentView: View {
    @ObservedObject var webViewStore = WebViewStore()

    var body: some View {
        NavigationView {
            WebView(webView: webViewStore.webView)
                .navigationBarTitle(Text(verbatim: webViewStore.webView.title ?? ""), displayMode: .inline)
        }.onAppear {
            self.webViewStore.webView.load(URLRequest(url: URL(string: "https://projects.fivethirtyeight.com/2020-election-forecast/")!))
        }.onOpenURL { url in
            self.webViewStore.webView.load(URLRequest(url: url))
        }.toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: goBack)    { Image(systemName: "chevron.left")  }.disabled(!webViewStore.webView.canGoBack)
                Button(action: goForward) { Image(systemName: "chevron.right") }.disabled(!webViewStore.webView.canGoForward)
            }
        }
    }
  
    func goBack() {
        webViewStore.webView.goBack()
    }
  
    func goForward() {
        webViewStore.webView.goForward()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
