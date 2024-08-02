//
//  LoadingAnimation.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import Lottie

struct LoadingAnimationView: View {
    var body: some View {
        VStack {
            Group {
                Text("Your book is downloading")
                Text("Enjoy this little dude :)")
            }
            .padding(.top, 10)
            .padding(.horizontal, 40)
            LottieView(animation: .named("loadingAnimation"))
                .playing(loopMode: .loop)
            Spacer()
        }
        .background(.yellow)
    }
}

#Preview {
    LoadingAnimationView()
}

