//
//  SwiftUIView.swift
//  teha
//
//  Created by Guest User on 17.01.23.
//

import SwiftUI

struct OnboardingView: View {
    var data: OnboardingData
    
    var body: some View {
        VStack(spacing: 20){
            
            Image(data.image)
                .resizable()
                .scaledToFit()
            
            
            Spacer()
            
            Text(data.text)
                .font(.title)
                .bold()
            
            Spacer()
            
            
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(data: OnboardingData.list.first!)
    }
}
