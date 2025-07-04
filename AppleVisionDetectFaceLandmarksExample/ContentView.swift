//
//  ContentView.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 15/06/25.
//

import SwiftUI

struct ContentView: View {

    @StateObject var poseVM = FacePoseViewModel()
    
    var threshold: CGFloat = 20.0
    
    

    func yawDirection() -> String? {

        guard let yaw = poseVM.facePose?.yaw else {
            return nil
        }
        
        if yaw > threshold {
            return "Left"
        } else if yaw < -threshold {
            return "Right"
        }
        
        return nil
    }
    
    func pitchDirection() -> String? {
        
        guard let pitch = poseVM.facePose?.pitch else {
            return nil
        }
        
        if pitch > threshold {
            return "Down"
        } else if pitch < -threshold {
            return "Up"
        }
        
        return nil
    }
    
    func rollDirection() -> String? {
        
        guard let roll = poseVM.facePose?.roll else {
            return nil
        }
        
        if roll > (90 + threshold) {
            return "Right"
        } else if roll < (90 - threshold) {
            return "Left"
        }
        
        return nil
    }

    var body: some View {
        ZStack {
            CameraView(
                viewModel: poseVM
            ).ignoresSafeArea(edges: .all)
            
            VStack {
                HStack(spacing: 8) {
                    
                    if (rollDirection() != nil) {
                        PoseText(text:"Roll: \(rollDirection()!) ")
                    }
                    
                    if (pitchDirection() != nil) {
                        PoseText(text: "Pitch: \(pitchDirection()!) ")
                    }
                    
                    if (yawDirection() != nil) {
                        PoseText(text: "Yaw: \(yawDirection()!) ")
                    }
                }
                Spacer()
            }
            .padding(.horizontal,16)
            .padding(.top,64)

        }
    }
}

#Preview {
    ContentView()
}
