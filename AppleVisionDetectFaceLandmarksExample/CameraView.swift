//
//  CameraView.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 15/06/25.
//

import SwiftUI

struct CameraView : UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: FacePoseViewModel
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let cameraController = CameraViewController()
        
        cameraController.onPoseDetected = { pose in
                 self.viewModel.facePose = pose
        }
        
        return cameraController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
