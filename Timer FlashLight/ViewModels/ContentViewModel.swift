//
//  ContentViewModel.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import Foundation
import Combine

/// ViewModel for ContentView following MVVM pattern
/// Manages the state and business logic for the main content view
class ContentViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var greetingText: String = "Hello, world!"
    @Published var isShowingGlobe: Bool = true
    
    // MARK: - Initialization
    
    init() {
        setupInitialState()
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        // Any initial setup logic here
        updateGreeting()
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            greetingText = "Good Morning!"
        case 12..<17:
            greetingText = "Good Afternoon!"
        default:
            greetingText = "Good Evening!"
        }
    }
    
    // MARK: - Public Methods
    
    func toggleGlobe() {
        isShowingGlobe.toggle()
    }
}
