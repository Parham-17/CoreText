# CoreText
 is an offline, on-device summarization app designed for users who value privacy, clarity, and speed.
Powered by Apple’s Foundation Models running locally on the device, BLOB never sends text to external servers — your words stay 100% yours.

The interface uses the new iOS 26 Liquid Glass design system, with floating elements, glassy effects, and a dynamic multicolor animated blob at the center of the experience.

## Features

### 🔒 Private by Design

All summaries run entirely on-device using Apple’s on-device LLM.

No network requests, logging, or text transmission.

### ✨ Multiple Summary Styles (Tones)

Choose the tone that fits your context:

Balanced – Neutral and clear

Scientific – Academic, dense, terminology-aware

Concise – Minimal, ultra-short

Creative – Narrative, smooth, friendly

Bullet Points – Structured, easy to scan

### 🪄 Animated Liquid Blob

Dynamic color-shifting orb inspired by iOS 26 motion.

Pulses subtly during idle states.

Bounces when a summary is complete.

Glows when processing.

### ⌨️ Smart Input Field

Expands when focused

Hides summaries when typing.

Liquid-glass highlight ring animation.

### 🧩 Attachments Menu

Camera Scan (future)

Import from Files (future)

Fully glass-morphed popover like native iOS menus.

### 📄 Save & Export Options

Copy plain text

Export as .txt

Save as Markdown .md

Smooth glass morph transitions from save icon

### 🎧 Haptics & Sound Design

Subtle feedback on success

Optional completion sound effect

### So Basically:

SwiftUI (iOS 26)

Liquid Glass system components

Foundation Model Sessions (On-Device)

Custom blob animation shaders

Combine / Async-await architecture

AVFoundation for audio cues

ShareLink / FileExport APIs

# How It Works

1️⃣ User pastes or types text
2️⃣ Selects a tone
3️⃣ Presses Summarize

— The on-device model reads the text
— A tailored prompt is sent internally
— A summary is generated entirely offline
— The blob animates to indicate completion

# Why This App Exists

Most summarization tools rely on cloud LLMs, requiring your text to be uploaded, processed, and stored elsewhere.
CoreText is different.
Additionally, based on the user's needs and context, the summarization style can vary. IN one word: Customization!

### It is built for:

- Students handling sensitive notes

- Professionals with confidential documents

- Researchers dealing with scientific papers

- Journalists working offline

- Anyone who values privacy and speed

Your data belongs to you, not the servers!

# Roadmap

## 🚀 Coming Soon

Camera Document Scanner (VisionKit)

OCR-to-summary pipeline

More AI assistance features on the expanded summary view

More custom tones

Export as PDF

Widget + App Shortcut

Multiple Languages

And many more!

## 🛠️ Planned Improvements

Better UI and UX

Faster and more accurate results

More accessibility features
