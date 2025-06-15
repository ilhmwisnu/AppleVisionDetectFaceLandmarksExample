//
//  CameraView.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 15/06/25.
//

import SwiftUI

struct CameraView : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return CameraViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
