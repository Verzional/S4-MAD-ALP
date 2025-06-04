import Foundation
import SwiftUI
// Removed PencilKit and CoreML imports as they are no longer needed for prompt generation only

class ThemeDrawingViewModel: ObservableObject {
    @Published var theme: String = "" // Will now hold the generated prompt
    @Published var generatedPrompt: String = "Tap 'New Prompt' for a crazy idea!" // Stores the generated prompt
    
    private let adjectives = ["fluffy", "glowing", "ancient", "futuristic", "tiny", "giant", "invisible", "singing", "melting", "whispering"]
        private let nouns = ["robot", "cat", "spaceship", "treehouse", "mountain", "teacup", "dragon", "cloud", "bicycle", "book"]
        private let verbs = ["dancing", "flying", "exploring", "dreaming", "building", "chasing", "discovering", "hiding", "giggling", "floating"]
        private let prepositions = ["on", "under", "in", "near", "behind", "through", "with", "around"]
        private let settings = ["the moon", "a magical forest", "a bustling city", "an underwater cave", "a desert island", "a cloud kingdom", "a forgotten attic", "a giant teacup"]

    // Initialize with a default theme, and set an initial prompt
    init(theme: String = "Crazy Prompt Game") { // Changed default theme name
        generateCrazyPrompt()
    }

    // MARK: - Prompt Generation Function
    func generateCrazyPrompt() {
        // Mix and match words from the arrays to create a prompt
                guard let randomAdjective = adjectives.randomElement(),
                      let randomNoun = nouns.randomElement(),
                      let randomVerb = verbs.randomElement(),
                      let randomPreposition = prepositions.randomElement(),
                      let randomSetting = settings.randomElement() else {
                    self.generatedPrompt = "Error: Could not generate prompt."
                    self.theme = "Error"
                    return
                }

                let prompt = "\(randomAdjective.capitalized) \(randomNoun) \(randomVerb) \(randomPreposition) \(randomSetting)."
                
                DispatchQueue.main.async {
                    self.generatedPrompt = prompt
                    self.theme = prompt // Set theme to the generated prompt
                }
    }
}
