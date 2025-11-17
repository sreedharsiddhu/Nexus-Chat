import SwiftUI

struct SettingsView: View {
    @Binding var settings: ChatSettings
    @Binding var showingPicker: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Wallpaper")) {
                    Button {
                        showingPicker = true
                    } label: {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.largeTitle)
                            Text("Choose from Gallery")
                        }
                        .frame(width: 160, height: 100)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.vertical, 6)
                    }
                }

                Section(header: Text("Appearance")) {
                    Toggle("Blur Background", isOn: $settings.blurEnabled)
                        .onChange(of: settings.blurEnabled) { _, _ in
                            Persistence.saveSettings(settings)
                        }

                    Picker("Theme", selection: $settings.themeMode) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    .onChange(of: settings.themeMode) { _, _ in
                        Persistence.saveSettings(settings)
                    }

                    HStack {
                        Text("Font Size")
                        Slider(value: $settings.fontSize, in: 13...20, step: 1) {
                            Text("Font Size")
                        }
                        .onChange(of: settings.fontSize) { _, _ in
                            Persistence.saveSettings(settings)
                        }
                        Text("\(Int(settings.fontSize))")
                    }
                }

                Section(header: Text("Chat Bubbles")) {
                    ColorPicker("Your bubble", selection: Binding(
                        get: { Color(hex: settings.userBubbleHex) },
                        set: {
                            settings.userBubbleHex = $0.toHex() ?? settings.userBubbleHex
                            Persistence.saveSettings(settings)
                        })
                    )
                    ColorPicker("AI bubble", selection: Binding(
                        get: { Color(hex: settings.aiBubbleHex) },
                        set: {
                            settings.aiBubbleHex = $0.toHex() ?? settings.aiBubbleHex
                            Persistence.saveSettings(settings)
                        })
                    )
                }

                Section {
                    Button("Clear Chat History", role: .destructive) {
                        UserDefaults.standard.removeObject(forKey: PersKeys.conversations)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
