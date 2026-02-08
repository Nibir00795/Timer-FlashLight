# iOS SwiftUI Coding Standards & Guidelines

## Table of Contents
1. [Architecture Pattern](#architecture-pattern)
2. [Naming Conventions](#naming-conventions)
3. [Project Structure](#project-structure)
4. [MVVM Implementation Rules](#mvvm-implementation-rules)
5. [State Management](#state-management)
6. [View Composition](#view-composition)
7. [Error Handling](#error-handling)
8. [Code Style](#code-style)
9. [File Organization](#file-organization)
10. [Testing Guidelines](#testing-guidelines)

## Architecture Pattern

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
Models → ViewModels → Views
   ↓         ↓          ↓
Data    Business    UI Layer
       Logic &
       State
```

### Why MVVM?
- **Separation of Concerns**: Business logic is separated from UI
- **Testability**: ViewModels can be unit tested independently
- **Reusability**: ViewModels can be reused across different views
- **Maintainability**: Clear structure makes code easier to maintain and scale

## Naming Conventions

### Views
- Use `*View` suffix
- Use PascalCase
- Examples: `ContentView`, `TimerView`, `SettingsView`

### ViewModels
- Use `*ViewModel` suffix
- Use PascalCase
- Examples: `TimerViewModel`, `SettingsViewModel`

### Models
- Use descriptive nouns
- Use PascalCase
- Examples: `TimerSettings`, `UserPreferences`, `FlashlightState`

### Services
- Use `*Service` suffix
- Use PascalCase
- Examples: `TimerService`, `NotificationService`

### Properties & Variables
- Use camelCase
- Be descriptive
- Boolean properties should be questions: `isEnabled`, `hasCompleted`
- Examples: `timerDuration`, `isTimerRunning`, `flashlightBrightness`

### Functions
- Use camelCase
- Use verb phrases for actions: `startTimer()`, `stopTimer()`, `updateSettings()`
- Use noun phrases for computed properties: `currentTime`, `remainingTime`

### Constants
- Use camelCase for file-scoped constants
- Use `static let` for type constants
- Examples: `defaultTimerDuration`, `maxBrightness`

## Project Structure

```
Timer FlashLight/
├── App/
│   └── Timer_FlashLightApp.swift          # App entry point
├── Views/
│   ├── ContentView.swift                  # Main views
│   └── [Feature]View.swift                # Feature-specific views
├── ViewModels/
│   └── [Feature]ViewModel.swift           # ViewModels for views
├── Models/
│   └── [Model].swift                      # Data models
├── Services/
│   └── [Service].swift                    # Business logic services
├── Utilities/
│   ├── Extensions/
│   │   └── [Type]+Extensions.swift        # Type extensions
│   ├── Constants/
│   │   └── AppConstants.swift             # App-wide constants
│   └── Helpers/
│       └── [Helper].swift                 # Helper functions
└── Resources/
    └── Assets.xcassets/                   # Images, colors, etc.
```

### Organization Principles
1. **One file per type** - Each View, ViewModel, Model, Service should be in its own file
2. **Group by feature** - When the app grows, consider grouping by feature:
   ```
   Features/
   ├── Timer/
   │   ├── TimerView.swift
   │   ├── TimerViewModel.swift
   │   └── TimerModel.swift
   └── Settings/
       ├── SettingsView.swift
       └── SettingsViewModel.swift
   ```
3. **Utilities are shared** - Extensions, constants, and helpers are shared across features

## MVVM Implementation Rules

### ViewModels

**Responsibilities:**
- Manage view state using `@Published` properties
- Handle business logic
- Coordinate with services
- Transform model data for views

**Rules:**
- Must inherit from `ObservableObject`
- Use `@Published` for properties that trigger view updates
- Keep ViewModels focused on a single view's needs
- Do NOT import SwiftUI in ViewModels (keep them platform-independent)
- Keep ViewModels testable by avoiding direct UI dependencies

**Example:**
```swift
import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var timeRemaining: TimeInterval = 0
    
    private let timerService: TimerService
    
    init(timerService: TimerService) {
        self.timerService = timerService
    }
    
    func startTimer() {
        // Business logic here
    }
}
```

### Views

**Responsibilities:**
- Define UI structure and layout
- Display data from ViewModels
- Send user actions to ViewModels
- Compose smaller views for reusability

**Rules:**
- Keep views thin and declarative
- Read state from ViewModels using `@StateObject` or `@ObservedObject`
- Send actions to ViewModels via method calls
- Extract complex UI into separate view components
- Use `@ViewBuilder` for conditional view composition
- Prefer composition over large monolithic views

**Example:**
```swift
import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel(timerService: TimerService())
    
    var body: some View {
        VStack {
            Text("\(viewModel.timeRemaining)")
            Button("Start") {
                viewModel.startTimer()
            }
        }
    }
}
```

### Models

**Responsibilities:**
- Represent data structures
- Define domain entities
- Handle data persistence when needed

**Rules:**
- Keep models simple and focused on data
- Make models `Codable` when persistence is needed
- Do NOT include business logic in models
- Use structs for value types, classes only when reference semantics are needed
- Consider using `Identifiable` for collections

**Example:**
```swift
struct TimerSettings: Codable, Identifiable {
    let id: UUID
    var duration: TimeInterval
    var isRepeating: Bool
}
```

### Services

**Responsibilities:**
- Encapsulate business logic
- Handle external dependencies (APIs, databases, etc.)
- Provide reusable functionality

**Rules:**
- Use protocols for services to enable testing
- Keep services focused on a single responsibility
- Make services injectable into ViewModels
- Handle errors appropriately

**Example:**
```swift
protocol TimerServiceProtocol {
    func startTimer(duration: TimeInterval, completion: @escaping () -> Void)
    func stopTimer()
}

class TimerService: TimerServiceProtocol {
    private var timer: Timer?
    
    func startTimer(duration: TimeInterval, completion: @escaping () -> Void) {
        // Implementation
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
```

## State Management

### Property Wrappers

**@State**
- Use for view-local, simple state
- Value types (Int, String, Bool, etc.)
- Example: `@State private var isPresented: Bool = false`

**@StateObject**
- Use for view-owned ViewModels
- Ensures the object is created and retained by the view
- Example: `@StateObject private var viewModel = TimerViewModel()`

**@ObservedObject**
- Use for ViewModels passed to child views
- Does NOT own the object (parent view owns it)
- Example: `@ObservedObject var viewModel: TimerViewModel`

**@EnvironmentObject**
- Use for app-wide shared state
- Injected at the root level
- Example: `@EnvironmentObject var appState: AppState`

**@Binding**
- Use to create two-way bindings
- Share state between parent and child views
- Example: `@Binding var isEnabled: Bool`

**@Published**
- Use in ViewModels for properties that trigger view updates
- Only works inside `ObservableObject` classes
- Example: `@Published var isRunning: Bool = false`

### State Management Best Practices

1. **Minimize @State usage** - Prefer ViewModels for complex state
2. **Use @StateObject for view-owned ViewModels** - Prevents recreation
3. **Use @ObservedObject for passed ViewModels** - Avoids unnecessary ownership
4. **Keep state as low as possible** - Lift state only when needed
5. **Avoid @EnvironmentObject for everything** - Use only for truly app-wide state

## View Composition

### Principles

1. **Break down complex views** - Extract logical sections into separate views
2. **Create reusable components** - Build a library of reusable view components
3. **Use ViewBuilder for conditional UI** - Keep view code clean
4. **Extract modifiers** - Create custom view modifiers for repeated styling

### Example: View Composition

```swift
// Bad: Monolithic view
struct ContentView: View {
    var body: some View {
        VStack {
            // 200 lines of UI code
        }
    }
}

// Good: Composed view
struct ContentView: View {
    var body: some View {
        VStack {
            HeaderView()
            TimerSection()
            SettingsSection()
        }
    }
}
```

### Custom View Modifiers

Create reusable modifiers for common styling:

```swift
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}
```

## Error Handling

### Error Types

1. **Use Swift's Error protocol** - Create custom error types
2. **Use Result types** - For async operations that can fail
3. **Handle errors in ViewModels** - Not in Views

### Example Error Handling

```swift
enum TimerError: Error {
    case invalidDuration
    case timerAlreadyRunning
    case timerNotRunning
}

class TimerViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    func startTimer(duration: TimeInterval) {
        guard duration > 0 else {
            errorMessage = "Invalid duration"
            return
        }
        // Start timer
    }
}
```

### Error Display

```swift
struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some View {
        VStack {
            // Content
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}
```

## Code Style

### Formatting

1. **Indentation**: Use 4 spaces (Xcode default)
2. **Line length**: Keep lines under 120 characters when possible
3. **Spacing**: Use blank lines to separate logical sections
4. **Braces**: Opening braces on the same line (Swift standard)

### Comments

1. **Document complex logic** - Explain WHY, not WHAT
2. **Use MARK comments** - Organize code sections:
   ```swift
   // MARK: - Properties
   // MARK: - Initialization
   // MARK: - Public Methods
   // MARK: - Private Methods
   ```
3. **Avoid unnecessary comments** - Self-documenting code is better

### Code Organization

Organize code within files in this order:

1. **Imports**
2. **Type declaration**
3. **MARK: - Properties** (public, then private)
4. **MARK: - Initialization**
5. **MARK: - Public Methods**
6. **MARK: - Private Methods**
7. **MARK: - Extensions** (if any)

## File Organization

### File Naming

- **One type per file** - Each struct, class, enum in its own file
- **File name matches type name** - `TimerView.swift` contains `TimerView`
- **Group related extensions** - `String+Extensions.swift` for String extensions

### File Headers

Include file header comments:

```swift
//
//  TimerView.swift
//  Timer FlashLight
//
//  Created by [Your Name] on [Date].
//
```

### Previews

Include previews for views:

```swift
#Preview {
    TimerView()
        .preferredColorScheme(.dark)
}
```

## Testing Guidelines

### Unit Tests

1. **Test ViewModels** - Business logic should be fully tested
2. **Test Services** - All service methods should have tests
3. **Use dependency injection** - Mock services for testing
4. **Test error cases** - Don't just test happy paths

### Example Unit Test

```swift
import XCTest
@testable import Timer_FlashLight

class TimerViewModelTests: XCTestCase {
    var viewModel: TimerViewModel!
    var mockService: MockTimerService!
    
    override func setUp() {
        mockService = MockTimerService()
        viewModel = TimerViewModel(timerService: mockService)
    }
    
    func testStartTimer() {
        viewModel.startTimer()
        XCTAssertTrue(viewModel.isRunning)
        XCTAssertTrue(mockService.startTimerCalled)
    }
}
```

### UI Tests

1. **Test critical user flows** - Main user journeys
2. **Test edge cases** - Error handling, boundary conditions
3. **Keep tests maintainable** - Use Page Object pattern for complex UIs

### Test Organization

```
Timer FlashLightTests/
├── ViewModels/
│   └── TimerViewModelTests.swift
├── Services/
│   └── TimerServiceTests.swift
└── Models/
    └── TimerSettingsTests.swift
```

## Additional Best Practices

### Dependency Injection

1. **Inject dependencies** - Don't create dependencies inside ViewModels
2. **Use protocols** - Define protocols for services
3. **Make testing easier** - Mock implementations for tests

### Async Operations

1. **Use async/await** - Prefer modern concurrency
2. **Update UI on main thread** - Use `@MainActor` or `DispatchQueue.main`
3. **Handle cancellation** - Support task cancellation

### Performance

1. **Lazy loading** - Use `LazyVStack`/`LazyHStack` for large lists
2. **Minimize view updates** - Only use `@Published` for necessary properties
3. **Optimize images** - Use appropriate image formats and sizes

### Accessibility

1. **Add labels** - Use `.accessibilityLabel()` for images and icons (REQUIRED for all icons)
2. **Support Dynamic Type** - Use system fonts and scalable layouts
3. **Test with VoiceOver** - Ensure app is accessible
4. **Icon Accessibility** - All icons from Figma must include descriptive accessibility labels

### Localization

1. **Use String catalogs** - Xcode 15+ String Catalogs
2. **Avoid hardcoded strings** - Use `NSLocalizedString` or String catalogs
3. **Test in different languages** - Ensure UI layouts work for all languages

## Icon Usage Rules

### Icon Source Requirements

**CRITICAL: All icons MUST come from Figma design and be added to the Assets.xcassets catalog.**

1. **No SF Symbols** - Do NOT use `Image(systemName:)` or SF Symbols
2. **Use Asset Icons Only** - All icons must be exported from Figma and added to Assets.xcassets
3. **Naming Convention** - Icon asset names should match Figma layer names (e.g., `ic_brightness`, `ic_menu`, `ic_power`)
4. **Accessibility** - All icons must have `.accessibilityLabel()` for VoiceOver support

### Icon Usage Example

```swift
// ✅ CORRECT: Use asset icons from Figma
Image("ic_brightness")
    .resizable()
    .renderingMode(.template)
    .foregroundColor(AppTheme.Colors.textPrimary)
    .frame(width: AppConstants.IconSize.brightness, height: AppConstants.IconSize.brightness)
    .accessibilityLabel("Brightness")

// ❌ WRONG: Do NOT use SF Symbols
Image(systemName: "sun.max")  // NOT ALLOWED
```

## Design Tokens & Icon Sizes

### Device-Specific Icon Sizes

All icon sizes are defined in `AppConstants.IconSize` and should be used consistently throughout the app:

```swift
struct IconSize {
    static let battery: CGFloat = 16.0 // Battery icon height
    static let batteryWidth: CGFloat = 11.0 // Battery icon width
    static let menu: CGFloat = 32.0 // Menu icon size
    static let premium: CGFloat = 24.0 // Premium/crown icon size
    static let timerCircle: CGFloat = 24.0 // Timer circle icon size
    static let bottomIcon: CGFloat = 56.0 // Bottom nav icons (clock, phone)
    static let sosButton: CGFloat = 80.0 // SOS button size
    static let powerButton: CGFloat = 120.0 // Power button size
}
```

### Layout Spacing Constants

All layout spacing values are defined in `AppConstants.Layout`:

```swift
struct Layout {
    // Top section
    static let upgradeButtonTopSpacing: CGFloat = 18.0 // Upgrade btn to safe area top
    static let batteryLeftSpacing: CGFloat = 40.0 // Battery to left edge
    static let menuRightSpacing: CGFloat = 40.0 // Menu btn to right edge
    
    // SOS button
    static let sosButtonTopSpacing: CGFloat = 46.0 // SOS btn top to upgrade btn bottom
    
    // Bottom section
    static let bottomNavTopSpacing: CGFloat = 80.0 // Bottom nav to bottom safe area
    static let bottomNavHorizontalSpacing: CGFloat = 40.0 // Bottom nav to left/right edges
    static let bottomNavInternalSpacing: CGFloat = 16.0 // Spacing between bottom nav items
    static let timerIconSpacing: CGFloat = 8.0 // Spacing between circle icon and timer text
}
```

**Note:** These values match the Figma design specifications and should be maintained for design consistency.

## Revision History

- Version 1.0 - Initial coding standards and guidelines
- Version 1.1 - Added design tokens and icon sizes documentation
- Version 1.2 - Added icon usage rules requiring all icons from Figma (no SF Symbols)
