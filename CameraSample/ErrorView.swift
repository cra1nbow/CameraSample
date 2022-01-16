//
//  ErrorView.swift
//  CameraSample
//
//  Created by cra1nbow on 2022/01/16.
//

import SwiftUI

extension AnyTransition {
    static var fadeAndSlide: AnyTransition {
        AnyTransition.opacity.combined(with: .move(edge: .top))
    }
}

struct ErrorView: View {
    var error: Error?
    @State private var shouldShowErrorLabel = false
    
    var body: some View {
        VStack {
            if shouldShowErrorLabel {
                Text(error?.localizedDescription ?? "")
                    .bold()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(Color.red.edgesIgnoringSafeArea(.top))
                    .opacity(error == nil ? 0.0 : 1.0)
                    .animation(.easeInOut, value: 0.25)
                    .transition(.asymmetric(insertion: .fadeAndSlide, removal: .fadeAndSlide))
                Spacer()
            }
            
        }
        .onAppear { self.animateAndDelayWithSeconds(1) { self.shouldShowErrorLabel = true } }
        .onDisappear { self.animateAndDelayWithSeconds(3) { self.shouldShowErrorLabel = false } }
    }
    
    
    func animateAndDelayWithSeconds(_ seconds: TimeInterval, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            withAnimation {
                action()
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: CameraError.cannotAddInput)
    }
}
