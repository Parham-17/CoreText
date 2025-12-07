import SwiftUI

// MARK: - Summary style / tone for the foundation model

enum SummaryTone: String, CaseIterable, Identifiable {
    case balanced
    case scientific
    case concise
    case creative
    case bulletPoints

    var id: Self { self }

    var displayName: String {
        switch self {
        case .balanced:      return "Balanced"
        case .scientific:    return "Scientific"
        case .concise:       return "Concise"
        case .creative:      return "Creative"
        case .bulletPoints:  return "Bullet points"
        }
    }

    /// Instruction you pass to the FM.
    var systemInstruction: String {
        switch self {
        case .balanced:
            return "Write a clear, natural summary with a neutral tone. Keep all key points but avoid being too long or too short."
        case .scientific:
            return "Write a precise, formal summary using scientific or academic language. Emphasize definitions, data and logical structure."
        case .concise:
            return "Write the shortest possible summary that still preserves the core meaning. Avoid extra adjectives and side notes."
        case .creative:
            return "Write an engaging, narrative-style summary with a friendly tone and light storytelling, while keeping the main facts."
        case .bulletPoints:
            return "Write the summary as a list of structured bullet points, grouped logically, with no long paragraphs."
        }
    }
}

// MARK: - Save actions shown in the menu

enum SaveAction: String, CaseIterable, Identifiable {
    case asFile
    case asPlainText
    case asMarkdown

    var id: Self { self }

    var title: String {
        switch self {
        case .asFile:      return "Save as file"
        case .asPlainText: return "Copy as text"
        case .asMarkdown:  return "Save as Markdown"
        }
    }

    var subtitle: String {
        switch self {
        case .asFile:      return "Export a document you can share or store."
        case .asPlainText: return "Copy the summary to the clipboard."
        case .asMarkdown:  return "Keep headings, lists and formatting."
        }
    }

    var systemImage: String {
        switch self {
        case .asFile:      return "doc.badge.arrow.down"
        case .asPlainText: return "doc.on.doc"
        case .asMarkdown:  return "number"
        }
    }
}

// MARK: - HOME VIEW

struct HomeView: View {
    @State private var inputText: String = ""

    // hero text breathing
    @State private var isPulsing: Bool = false

    // text style
    @State private var selectedTone: SummaryTone = .balanced
    @State private var showToneSheet: Bool = false
    @State private var toneIconBounce: Bool = false

    // save menu
    @State private var saveIconBounce: Bool = false
    @State private var lastSaveAction: SaveAction?

    // file export
    @State private var exportItem: FileExportItem?

    // Namespace for glass effect IDs (top toolbar button + bottom menu)
    @Namespace private var glassNamespace

    // focus for the bottom bar text field
    @FocusState private var isInputFocused: Bool

    // bottom-bar highlight animation
    @State private var isHighlighting: Bool = false

    // Siri-style boom glow
    @State private var boomOpacity: Double = 0

    // summarization state
    @StateObject private var summaryViewModel = SummaryViewModel()
    @State private var showErrorAlert: Bool = false

    // toast for “copied”
    @State private var copyToastOpacity: Double = 0

    // rotation for loading hourglass
    @State private var loadingRotation: Double = 0

    // full-screen summary
    @State private var isShowingFullSummary: Bool = false

    // side-effect service (clipboard + file export + related haptics)
    private let actionsService = SummaryActionsService()

    // MARK: - Tone-based tint for the whole UI

    private var currentTint: Color {
        switch selectedTone {
        case .balanced:     return .blue            // balanced: blue
        case .scientific:   return .red             // academic: red
        case .concise:      return .cyan            // concise: sky blue
        case .creative:     return .purple
        case .bulletPoints: return .green
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // background that dismisses keyboard
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        if isInputFocused { isInputFocused = false }
                    }

                // Brighter, longer Siri-like glowing border
                RoundedRectangle(cornerRadius: 40)
                    .strokeBorder(
                        AngularGradient(
                            colors: [
                                .purple, .blue, .cyan,
                                .mint, .yellow, .orange, .red, .purple
                            ],
                            center: .center
                        ),
                        lineWidth: 36
                    )
                    .opacity(boomOpacity)
                    .blur(radius: 46)
                    .padding(-32)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // MARK: - BLOB + HERO TEXT
                    ZStack {
                        AnimatedLiquidBlob()

                        Text("Your text stays\nyours.")
                            .font(
                                .system(
                                    size: 24,
                                    weight: .semibold,
                                    design: .rounded
                                ).italic()
                            )
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 24)
                            .opacity(isPulsing ? 1.0 : 0.9)
                            .accessibilityLabel("Hero message: Your text stays yours.")
                    }
                    .frame(width: 260, height: 260)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.4)
                                .repeatForever(autoreverses: true)
                        ) {
                            isPulsing = true
                        }
                    }

                    // MARK: - Inline summary (if exists)
                    if let summary = summaryViewModel.summary {
                        SummaryCardView(
                            summary: summary,
                            tone: selectedTone,
                            originalText: inputText,
                            onNewSession: newSession,
                            onExpand: {
                                isShowingFullSummary = true
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        Spacer(minLength: 40)
                    }

                    // MARK: - BOTTOM INPUT BAR + LIQUID GLASS BUTTONS
                    bottomBar
                        .padding(.horizontal, 14)
                        .padding(.bottom, -10)
                }
                // Smooth insert/remove of the summary card
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.85),
                    value: summaryViewModel.summary != nil
                )

                // MARK: - Copy toast (center-top, very visible)
                if copyToastOpacity > 0.01 {
                    VStack {
                        Spacer().frame(height: 60)
                        HStack {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                                    )
                                    .shadow(radius: 16)
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Copied to clipboard")
                                        .font(.callout.weight(.semibold))
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                            }
                            .fixedSize()
                            Spacer()
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .opacity(copyToastOpacity)
                    .transition(.opacity)
                    .zIndex(5)
                    .accessibilityLabel("Summary copied to clipboard")
                    .accessibilityAddTraits(.isStaticText)
                }
            }

            // MARK: - TOOLBAR (Liquid Glass layer)
            .toolbar {

                // LEFT — Text style / tone (sheet)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        toneIconBounce.toggle()
                        showToneSheet = true
                        Haptics.impact(.light)   // small feedback when opening style picker
                    } label: {
                        Image(systemName: "textformat.alt")
                            .symbolVariant(.fill)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .symbolEffect(.bounce, value: toneIconBounce)
                    .tint(.yellow)
                    .accessibilityLabel("Summary style: \(selectedTone.displayName)")
                    .accessibilityHint("Choose how the summarizer should write your result.")
                }

                // RIGHT — Save menu (real actions)
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SaveAction.allCases) { action in
                            Button {
                                handleSaveAction(action)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: action.systemImage)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(action.title)
                                        Text(action.subtitle)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .disabled(summaryViewModel.summary == nil)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .symbolVariant(.fill)
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 32, height: 32)
                            .glassEffect()
                            .glassEffectID("saveGlass", in: glassNamespace)
                            .opacity(summaryViewModel.summary == nil ? 0.35 : 1.0)
                    }
                    .tint(currentTint)
                    .accessibilityLabel("Save summary")
                    .accessibilityHint("Copy or export the current summary.")
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - TONE SHEET
            .sheet(isPresented: $showToneSheet) {
                ToneSelectionSheet(selectedTone: $selectedTone)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }

            // MARK: - Full-screen summary
            .sheet(isPresented: $isShowingFullSummary) {
                if let summary = summaryViewModel.summary {
                    SummaryDetailView(summary: summary, tone: selectedTone)
                }
            }

            // MARK: - Share sheet for exported files
            .sheet(item: $exportItem) { item in
                ShareSheet(items: [item.url])
            }

            // MARK: - Error alert
            .alert("Something went wrong",
                   isPresented: $showErrorAlert,
                   actions: {
                       Button("OK", role: .cancel) { }
                   },
                   message: {
                       Text(summaryViewModel.errorMessage ?? "Please try again.")
                   })
            // 🔄 Spin hourglass when isLoading changes
            .onChange(of: summaryViewModel.isLoading) { _, isLoading in
                if isLoading {
                    loadingRotation = 0
                    withAnimation(
                        .linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        loadingRotation = 360
                    }
                } else {
                    // reset rotation when finished
                    loadingRotation = 0
                }
            }
        }
    }

    // MARK: - Bottom bar view (Playground-style)

    private var bottomBar: some View {
        HStack(spacing: 8) {

            // TEXT CAPSULE – slimmer, aligned like Playground
            ZStack {
                let shape = RoundedRectangle(
                    cornerRadius: 26,
                    style: .continuous
                )

                // base glass background
                shape
                    .fill(.ultraThinMaterial)

                // moving highlight, tone-based
                highlightingBorder(shape: shape, tint: currentTint)

                HStack(spacing: 8) {
                    if !isInputFocused && inputText.isEmpty {
                        Image(systemName: "text.page")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }

                    TextField("Type or paste it here",
                              text: $inputText,
                              axis: .vertical)
                        .focused($isInputFocused)
                        .lineLimit(isInputFocused ? 4 : 1)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                        .foregroundStyle(.primary)
                        .accessibilityLabel("Input text")
                        .accessibilityHint("Type or paste the text you want to summarize.")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .frame(
                minHeight: isInputFocused ? 44 : 30,
                maxHeight: isInputFocused ? 110 : 52,
                alignment: .center
            )

            // When keyboard is shown => hide buttons so bar can stretch
            if !isInputFocused {

                // ATTACHMENT – Liquid glass MENU with two actions
                Menu {
                    Button {
                        // TODO: Scan with camera
                        Haptics.impact(.light)
                    } label: {
                        Label("Scan with camera", systemImage: "camera.viewfinder")
                    }

                    Button {
                        // TODO: Import from Files
                        Haptics.impact(.light)
                    } label: {
                        Label("Import from files", systemImage: "doc.richtext")
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.18),
                                                  lineWidth: 0.5)
                            )
                            .frame(width: 50, height: 50)
                            .glassEffect()
                            .glassEffectID("attachmentGlass", in: glassNamespace)

                        Image(systemName: "paperclip")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                    }
                }
                .tint(.white)
                .accessibilityLabel("Add content from camera or files")
                .accessibilityHint("Attach text using the camera or file picker.")

                // SUMMARIZE – clear hourglass vs sparkles, using loadingRotation
                Button {
                    runSummary()
                } label: {
                    Group {
                        if summaryViewModel.isLoading {
                            Image(systemName: "hourglass")
                        } else {
                            Image(systemName: "sparkles")
                        }
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 33, height: 33)
                    .rotationEffect(.degrees(loadingRotation))
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(currentTint)
                .disabled(summaryViewModel.isLoading)
                .accessibilityLabel("Summarize")
                .accessibilityHint("Generate a summary of the current text.")
            }
        }
        .padding(.horizontal, 1)
        .animation(.easeInOut(duration: keyboardAnimationDuration), value: isInputFocused)
        .animation(.easeInOut(duration: 0.18), value: inputText)
    }

    // MARK: - Run summarization

    private func runSummary() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isInputFocused = false

        Task {
            await summaryViewModel.summarize(
                text: trimmed,
                tone: selectedTone
            )

            if summaryViewModel.summary != nil {
                // Haptic: summary success
                Haptics.notify(.success)

                // Brighter + longer boom
                withAnimation(.easeOut(duration: 1.0)) {
                    boomOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 1.8).delay(0.7)) {
                    boomOpacity = 0
                }
            }

            if summaryViewModel.errorMessage != nil {
                // Haptic: summary failure
                Haptics.notify(.error)
                showErrorAlert = true
            }
        }
    }

    // MARK: - New session

    private func newSession() {
        // Haptic: medium impact for new session
        Haptics.impact(.medium)

        withAnimation {
            inputText = ""
            summaryViewModel.isLoading = false
            summaryViewModel.summary = nil
            summaryViewModel.errorMessage = nil
            loadingRotation = 0
        }
    }

    // MARK: - Save actions (now using SummaryActionsService)

    private func handleSaveAction(_ action: SaveAction) {
        guard let attributed = summaryViewModel.summary else { return }
        let text = String(attributed.characters)

        switch action {
        case .asPlainText:
            actionsService.copyPlainText(text)

            // UI-only: show glass toast
            withAnimation(.easeOut(duration: 0.25)) {
                copyToastOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.7).delay(1.3)) {
                copyToastOpacity = 0
            }

        case .asFile:
            if let item = actionsService.exportFile(for: text, ext: "txt") {
                exportItem = item
            }

        case .asMarkdown:
            if let item = actionsService.exportFile(for: text, ext: "md") {
                exportItem = item
            }
        }
    }

    // MARK: - Highlight ring like in your preferred version

    @ViewBuilder
    private func highlightingBorder(
        shape: RoundedRectangle,
        tint: Color
    ) -> some View {
        if !isInputFocused && inputText.isEmpty {
            let clearColors: [Color] = Array(repeating: .clear, count: 3)

            shape
                .stroke(
                    tint.gradient,
                    style: .init(
                        lineWidth: 3,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .mask(
                    shape
                        .fill(
                            AngularGradient(
                                colors: clearColors + [.white] + clearColors,
                                center: .center,
                                angle: .degrees(isHighlighting ? 360 : 0)
                            )
                        )
                )
                .padding(-1.5)
                .blur(radius: 2)
                .onAppear {
                    withAnimation(
                        .linear(duration: 2.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        isHighlighting = true
                    }
                }
                .onDisappear {
                    isHighlighting = false
                }
        }
    }

    // Keyboard animation feel
    private var keyboardAnimationDuration: Double {
        if #available(iOS 26, *) {
            return 0.22
        } else {
            return 0.33
        }
    }
}

// MARK: - Tone selection sheet

struct ToneSelectionSheet: View {
    @Binding var selectedTone: SummaryTone

    var body: some View {
        NavigationStack {
            List {
                Section(" Select a text style for your summary") {
                    ForEach(SummaryTone.allCases) { tone in
                        Button {
                            selectedTone = tone
                            Haptics.selection()   // haptic when changing style
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tone.displayName)
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                    Text(tone.systemInstruction)
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                                Spacer()
                                if tone == selectedTone {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .accessibilityLabel("Use \(tone.displayName) style")
                        .accessibilityHint("Changes how the summary will be written.")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.clear)
            .navigationTitle("Text style")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
