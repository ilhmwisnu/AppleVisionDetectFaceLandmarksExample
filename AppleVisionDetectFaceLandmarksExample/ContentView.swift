//
//  ContentView.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 15/06/25.
//

import SwiftUI

struct ContentView: View {

    @StateObject var poseVM = FacePoseViewModel()



    var body: some View {
        ZStack {
            CameraView(
                viewModel: poseVM
            ).ignoresSafeArea(edges: .all)

            

            VStack {
                Text("Hello, World!")
                Text("Hello, World!")
                Text("Hello, World!")
            }
            .font(.largeTitle)
            .foregroundColor(.black)

        }
    }
}

#Preview {
    ContentView()
}
