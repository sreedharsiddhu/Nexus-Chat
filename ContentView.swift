import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var vm = ChatViewModel()
    @State private var inputText: String = ""
    @State private var showMenu = false
    @State private var showingImagePicker = false
    @State private var showingSettings = false

    @State private var imageToSend: UIImage? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                VStack(spacing: 0) {
                    messagesScroll
                    inputArea
                }
                .overlay(typingIndicatorView, alignment: .bottom)
                if showMenu {
                    overlaySidebar
                }
            }
            .navigationTitle("")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Chat")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { withAnimation { showMenu.toggle() } }) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "paintbrush")
                        }
                        Button(action: { vm.newConversation() }) {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $imageToSend)
                    .onChange(of: imageToSend) { newImage in
                        if let img = newImage {
                            vm.sendImage(img)
                        }
                    }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: $vm.settings, showingPicker: $showingImagePicker)
            }
            .onChange(of: vm.settings.wallpaperImageDataBase64) { _, _ in
                // background refresh happens automatically
            }
        }
        .preferredColorScheme(vm.settings.themeMode == 0 ? nil : (vm.settings.themeMode == 1 ? .light : .dark))
    }

    // MARK: - Background Layer
    private var backgroundLayer: some View {
        Group {
            if let b64 = vm.settings.wallpaperImageDataBase64,
               let data = Data(base64Encoded: b64),
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .opacity(0.4)
                    .blur(radius: vm.settings.blurEnabled ? 8 : 0)
            } else {
                Color(.systemBackground).ignoresSafeArea()
            }
        }
    }

    // MARK: - Messages Scroll
    private var messagesScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    if vm.messages.isEmpty {
                        Text("No messages yet")
                            .foregroundColor(.secondary)
                            .frame(maxHeight: .infinity)
                    } else {
                        ForEach(vm.messages) { message in
                            MessageBubbleView(message: message, settings: vm.settings)
                                .id(message.id)
                        }
                    }
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: vm.messages.count) { _, _ in
                withAnimation {
                    proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button {
                    showingImagePicker = true
                } label: {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 26))
                        .foregroundColor(.secondary)
                }

                TextField("Message...", text: $inputText, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .font(.system(size: vm.settings.fontSize))

                if inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: handleRecordTap) {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                    }
                } else {
                    Button(action: {
                        let m = inputText
                        inputText = ""
                        vm.sendMessage(m)
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    .disabled(vm.isLoading)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            if vm.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("AI is thinking...")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
    }

    private func handleRecordTap() {
        if #available(iOS 17.0, *) {
            let perm = AVAudioApplication.shared.recordPermission
            if perm != .granted {
                AVAudioApplication.requestRecordPermission { _ in }
            }
        } else {
            if AVAudioSession.sharedInstance().recordPermission != .granted {
                AVAudioSession.sharedInstance().requestRecordPermission { _ in }
            }
        }

        do {
            try vm.startRecording()
        } catch {
            print("rec start error", error.localizedDescription)
        }
    }

    // MARK: - Typing Indicator
    private var typingIndicatorView: some View {
        Group {
            if vm.typingIndicator {
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        BouncingDots()
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.trailing, 20)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: vm.typingIndicator)
            } else { EmptyView() }
        }
    }

    // MARK: - Sidebar overlay
    private var overlaySidebar: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
                .onTapGesture { withAnimation { showMenu = false } }
            HStack {
                SidebarView(viewModel: vm, showMenu: $showMenu)
                Spacer()
            }
            .frame(maxWidth: 340)
        }
    }
}
