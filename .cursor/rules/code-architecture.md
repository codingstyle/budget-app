---
description: "Use this rule when creating new files, organizing project structure, adding new features, creating UI components, setting up ViewModels, or when file placement and architecture decisions are needed. Applies to tasks involving project organization, component creation, feature development, and code structure."
alwaysApply: false
---
# Project Architecture

This rule defines the desired architecture for the {ProjectName} project. All new files must follow this structure, and existing files should be progressively reorganized according to this architecture.

## Folder Structure

```
{ProjectName}/
├─ {ProjectName}.xcodeproj
├─ App/
├─ DesignSystem/
│  ├─ Tokens/
│  ├─ Theme/
│  ├─ Components/
│  ├─ Layout/
│  ├─ Modifiers/
│  │
│  ├─ Assets.xcassets
│  │  ├─ Icons/
│  │  │  ├─ ic_check.imageset
│  │  │  ├─ ic_close.imageset
│  │  │  └─ ic_arrow.imageset
│  │  └─ Illustrations/
│  │
│  ├─ Previews/
│  │  └─ DesignSystemPreview.swift # Design system previews
│  │
│  └─ README.md                # Design system documentation
│
├─ Core/
│  ├─ Networking/
│  │
│  ├─ Auth/
│  │
│  ├─ Models/
│  │
│  ├─ Errors/
│  │  └─ AppError.swift        # Application errors
│  │
│  └─ Extensions/
│
├─ Features/
│
├─ Resources/
│  ├─ Assets.xcassets
│  │  ├─ AppIcon.appiconset
│  │  ├─ LaunchImages.imageset   (optionnel)
│  │  └─ Common/
│  │     ├─ logo.imageset
│  │     └─ background.imageset
│  │
│  ├─ Fonts/
│  └─ Localizable.strings      # Localization files
│
├─ SupportingFiles/
│  ├─ Info.plist               # Application configuration
│  └─ {ProjectName}.entitlements # Application entitlements
│
└─ Preview Content/
   └─ Preview Assets.xcassets   # Content for SwiftUI previews
```

## Architecture Principles

### 1. Separation of Concerns
- **App/** : Global configuration, routing, environment
- **DesignSystem/** : Reusable UI components and design tokens
- **Core/** : Shared services, models, extensions
- **Features/** : Business features organized by domain

### 2. Design System
- All UI components must be prefixed with `DS` (Design System)
- Tokens must be centralized in `DesignSystem/Tokens/`
- Theme must be injected via `Environment` to enable dark mode
- Each component must have SwiftUI previews

### 3. Features
- Each feature is isolated in its own folder
- MVVM structure: View + ViewModel (+ State if needed)
- ViewModels must be `@Observable` classes marked with `@MainActor`
- States can be structs or enums depending on needs

### 4. Core
- Shared services (Auth, Networking) in `Core/`
- Data models in `Core/Models/`
- Centralized error handling in `Core/Errors/`
- Reusable extensions in `Core/Extensions/`

### 5. Naming Conventions
- Views : `*View.swift` (e.g., `LoginView.swift`)
- ViewModels : `*ViewModel.swift` (e.g., `LoginViewModel.swift`)
- Services : `*Service.swift` (e.g., `AuthService.swift`)
- Models : Model name (e.g., `User.swift`)
- DS Components : `DS*` (e.g., `DSButton.swift`)
- Tokens : `*Tokens.swift` (e.g., `ColorTokens.swift`)

### 6. File Creation
- When creating a new file, strictly follow this structure
- If a file already exists elsewhere, progressively move it to the correct location
- Do not create files outside this structure without justification

### 7. Imports and Dependencies
- Files in `Features/` can import `DesignSystem/` and `Core/`
- Files in `Core/` must not import `Features/`
- Files in `DesignSystem/` must not import `Features/` or `Core/` (except justified exceptions)

## Progressive Migration

Existing files should be progressively reorganized according to this architecture. When modifying an existing file, check if it should be moved to the new structure.
