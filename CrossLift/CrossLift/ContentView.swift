//
//  ContentView.swift
//  CrossLift
//
//  Created by Reid Garcia on 3/22/26.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var puzzleImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var imagePickerItem: PhotosPickerItem?

    var body: some View {
        if let image = puzzleImage {
            PuzzleView(image: image, onDismiss: { puzzleImage = nil })
        } else {
            HomeView(
                onPickPhoto: { showingImagePicker = true },
                onTakePhoto: { showingCamera = true }
            )
            .photosPicker(isPresented: $showingImagePicker, selection: $imagePickerItem, matching: .images)
            .onChange(of: imagePickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        puzzleImage = uiImage
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { image in
                    puzzleImage = image
                }
            }
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    let onPickPhoto: () -> Void
    let onTakePhoto: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("CrossLift")
                .font(.system(size: 48, weight: .bold, design: .serif))

            Text("Lift a Crossword")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 16) {
                Button(action: onTakePhoto) {
                    Label("Take a Photo", systemImage: "camera")
                        .frame(maxWidth: 300)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: onPickPhoto) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: 300)
                        .padding()
                        .background(.blue.opacity(0.15))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .font(.title3)

            Spacer()
        }
    }
}

// MARK: - Camera View (UIImagePickerController wrapper)

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
