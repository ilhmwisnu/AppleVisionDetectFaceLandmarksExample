//
//  FacePoseViewModel.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 16/06/25.
//

import SwiftUI

class FacePoseViewModel: ObservableObject {
    @Published var facePose: FacePose? = nil
}
