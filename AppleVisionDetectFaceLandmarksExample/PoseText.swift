//
//  PoseText.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 03/07/25.
//

import SwiftUI

struct PoseText: View {
    
    var text: String = ""
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 999999)
                    .fill(
                        Color.orange
                    )
            )
    }
}

#Preview {
    PoseText()
}
