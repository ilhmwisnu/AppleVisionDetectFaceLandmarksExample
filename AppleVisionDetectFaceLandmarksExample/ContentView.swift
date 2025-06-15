//
//  ContentView.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 15/06/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CameraView().ignoresSafeArea(edges: .all)
    }
}

#Preview {
    ContentView()
}
