//
//  PuzzleView.swift
//  CrossLift
//
//  Created by Reid Garcia on 3/22/26.
//

import SwiftUI
import PencilKit

// MARK: - Canvas Manager

@Observable
class CanvasManager {
    let canvasView: PKCanvasView
    var currentTool: ToolType = .pen
    var currentColor: UIColor = .systemBlue

    enum ToolType {
        case pen, eraser
    }

    init() {
        canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = PKInkingTool(.pen, color: .systemBlue, width: 2)
        canvasView.isScrollEnabled = false

        // Suppress the "Select All | Insert Space" edit menu
        if #available(iOS 16.0, *) {
            canvasView.interactions
                .filter { $0 is UIEditMenuInteraction }
                .forEach { canvasView.removeInteraction($0) }
        }
    }

    func clear() {
        canvasView.drawing = PKDrawing()
    }

    func undo() {
        canvasView.undoManager?.undo()
    }

    func setColor(_ color: UIColor) {
        currentTool = .pen
        currentColor = color
        canvasView.tool = PKInkingTool(.pen, color: color, width: 2)
    }

    func setEraser() {
        currentTool = .eraser
        canvasView.tool = PKEraserTool(.bitmap)
    }

    /// Applies the current tool settings to any PKCanvasView
    func applyCurrentTool(to canvas: PKCanvasView) {
        switch currentTool {
        case .pen:
            canvas.tool = PKInkingTool(.pen, color: currentColor, width: 2)
        case .eraser:
            canvas.tool = PKEraserTool(.bitmap)
        }
    }
}

// MARK: - Puzzle View

struct PuzzleView: View {
    let image: UIImage
    let onDismiss: () -> Void

    @State private var canvasManager = CanvasManager()
    @State private var magnifierSourcePoint: CGPoint?
    @State private var showMagnifier = false
    @State private var isDraggingMagnifier = false
    @State private var magnifierPanOffset: CGSize = .zero
    @State private var selectedColor: Color = .blue
    @State private var isErasing = false
    // Incremented when drawing changes, to trigger magnifier refresh
    @State private var drawingVersion: Int = 0

    private let colorOptions: [(Color, UIColor, String)] = [
        (.blue, .systemBlue, "Blue"),
        (.red, .systemRed, "Red"),
        (.green, .systemGreen, "Green"),
        (.black, .black, "Black"),
        (.purple, .systemPurple, "Purple"),
        (.orange, .systemOrange, "Orange"),
    ]

    var body: some View {
        ZStack {
            PuzzleCanvasView(
                image: image,
                canvasManager: canvasManager,
                onMagnifierGesture: { point, state in
                    switch state {
                    case .began:
                        magnifierSourcePoint = point
                        magnifierPanOffset = .zero
                        showMagnifier = true
                        isDraggingMagnifier = true
                    case .changed:
                        magnifierSourcePoint = point
                        magnifierPanOffset = .zero
                    case .ended:
                        isDraggingMagnifier = false
                    }
                }
            )
            .ignoresSafeArea()

            // Top toolbar
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Label("Back", systemImage: "chevron.left")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Spacer()

                    // Color picker + eraser
                    HStack(spacing: 8) {
                        ForEach(colorOptions, id: \.2) { color, uiColor, _ in
                            Circle()
                                .fill(color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: (selectedColor == color && !isErasing) ? 3 : 0)
                                )
                                .shadow(radius: (selectedColor == color && !isErasing) ? 4 : 0)
                                .onTapGesture {
                                    selectedColor = color
                                    isErasing = false
                                    canvasManager.setColor(uiColor)
                                }
                        }

                        Divider()
                            .frame(height: 24)

                        Image(systemName: "eraser")
                            .font(.title3)
                            .frame(width: 28, height: 28)
                            .foregroundStyle(isErasing ? .white : .primary)
                            .background(isErasing ? Color.accentColor : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .onTapGesture {
                                isErasing = true
                                canvasManager.setEraser()
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()

                    // Reset zoom button
                    Button(action: {
                        NotificationCenter.default.post(name: .resetZoom, object: nil)
                    }) {
                        Label("Fit", systemImage: "arrow.down.right.and.arrow.up.left")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Button(action: { canvasManager.undo() }) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Button(action: { canvasManager.clear() }) {
                        Label("Clear", systemImage: "trash")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()

                Spacer()
            }

            // Magnifier overlay
            if showMagnifier, let sourcePoint = magnifierSourcePoint {
                MagnifierView(
                    image: image,
                    canvasManager: canvasManager,
                    sourcePoint: CGPoint(
                        x: sourcePoint.x + magnifierPanOffset.width,
                        y: sourcePoint.y + magnifierPanOffset.height
                    ),
                    isDragging: isDraggingMagnifier,
                    panOffset: $magnifierPanOffset,
                    drawingVersion: drawingVersion,
                    onDrawingChanged: { drawingVersion += 1 },
                    onDismiss: { showMagnifier = false }
                )
            }
        }
    }
}

// MARK: - Notification for reset zoom

extension Notification.Name {
    static let resetZoom = Notification.Name("CrossLift.resetZoom")
}

// MARK: - Puzzle Canvas (Image + PencilKit overlay)

enum MagnifierGestureState {
    case began, changed, ended
}

struct PuzzleCanvasView: UIViewRepresentable {
    let image: UIImage
    let canvasManager: CanvasManager
    let onMagnifierGesture: (CGPoint, MagnifierGestureState) -> Void

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = context.coordinator
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let containerView = UIView()
        context.coordinator.containerView = containerView

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        context.coordinator.imageView = imageView

        let canvas = canvasManager.canvasView

        // Make all of the canvas's internal gesture recognizers only respond to pencil
        for recognizer in canvas.gestureRecognizers ?? [] {
            recognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.pencil.rawValue)]
        }

        containerView.addSubview(imageView)
        containerView.addSubview(canvas)
        scrollView.addSubview(containerView)

        // Long press + drag gesture for magnifier (finger only)
        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        longPress.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        scrollView.addGestureRecognizer(longPress)

        // Double-tap to quick-zoom
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        scrollView.addGestureRecognizer(doubleTap)

        context.coordinator.scrollView = scrollView
        context.coordinator.image = image
        context.coordinator.canvas = canvasManager.canvasView

        // Listen for reset zoom
        context.coordinator.resetObserver = NotificationCenter.default.addObserver(
            forName: .resetZoom, object: nil, queue: .main
        ) { [weak scrollView] _ in
            guard let scrollView else { return }
            context.coordinator.resetToFit(scrollView: scrollView)
        }

        // Defer initial layout
        let coord = context.coordinator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            coord.performInitialLayoutIfNeeded()
        }

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.layoutContent(in: scrollView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onMagnifierGesture: onMagnifierGesture)
    }

    static func dismantleUIView(_ uiView: UIScrollView, coordinator: Coordinator) {
        if let observer = coordinator.resetObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var containerView: UIView?
        var imageView: UIImageView?
        var scrollView: UIScrollView?
        var canvas: PKCanvasView?
        var image: UIImage?
        var didInitialLayout = false
        var resetObserver: Any?
        let onMagnifierGesture: (CGPoint, MagnifierGestureState) -> Void

        init(onMagnifierGesture: @escaping (CGPoint, MagnifierGestureState) -> Void) {
            self.onMagnifierGesture = onMagnifierGesture
        }

        func layoutContent(in scrollView: UIScrollView) {
            guard let image, let containerView, let imageView, let canvas else { return }
            let size = scrollView.bounds.size
            guard size.width > 0, size.height > 0 else { return }

            let imageSize = image.size
            let fitScale = min(size.width / imageSize.width, size.height / imageSize.height)
            let fittedSize = CGSize(width: imageSize.width * fitScale, height: imageSize.height * fitScale)

            containerView.frame = CGRect(origin: .zero, size: fittedSize)
            imageView.frame = CGRect(origin: .zero, size: fittedSize)
            canvas.frame = CGRect(origin: .zero, size: fittedSize)
            scrollView.contentSize = fittedSize

            centerContent(in: scrollView)
        }

        func centerContent(in scrollView: UIScrollView) {
            guard let containerView else { return }
            let size = scrollView.bounds.size
            let scaledWidth = containerView.frame.width * scrollView.zoomScale
            let scaledHeight = containerView.frame.height * scrollView.zoomScale
            let offsetX = max(0, (size.width - scaledWidth) / 2)
            let offsetY = max(0, (size.height - scaledHeight) / 2)
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }

        func performInitialLayoutIfNeeded() {
            guard !didInitialLayout, let scrollView else { return }
            let size = scrollView.bounds.size
            guard size.width > 0, size.height > 0 else { return }
            didInitialLayout = true
            resetToFit(scrollView: scrollView)
        }

        func resetToFit(scrollView: UIScrollView) {
            scrollView.zoomScale = 1.0
            layoutContent(in: scrollView)
            let inset = scrollView.contentInset
            scrollView.contentOffset = CGPoint(x: -inset.left, y: -inset.top)
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            containerView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContent(in: scrollView)
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let containerView else { return }
            let point = gesture.location(in: containerView)

            switch gesture.state {
            case .began:
                onMagnifierGesture(point, .began)
            case .changed:
                onMagnifierGesture(point, .changed)
            case .ended, .cancelled:
                onMagnifierGesture(point, .ended)
            default:
                break
            }
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }
            if scrollView.zoomScale > scrollView.minimumZoomScale + 0.1 {
                // Zoom out to fit
                resetToFit(scrollView: scrollView)
            } else {
                let point = gesture.location(in: containerView)
                let zoomRect = CGRect(x: point.x - 75, y: point.y - 75, width: 150, height: 150)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
    }
}

// MARK: - Magnifier View

struct MagnifierView: View {
    let image: UIImage
    let canvasManager: CanvasManager
    let sourcePoint: CGPoint
    let isDragging: Bool
    @Binding var panOffset: CGSize
    let drawingVersion: Int
    let onDrawingChanged: () -> Void
    let onDismiss: () -> Void

    @GestureState private var dragTranslation: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(isDragging ? 0.15 : 0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if !isDragging { onDismiss() }
                    }

                VStack {
                    MagnifiedCanvasView(
                        image: image,
                        canvasManager: canvasManager,
                        sourcePoint: CGPoint(
                            x: sourcePoint.x - dragTranslation.width * 0.5,
                            y: sourcePoint.y - dragTranslation.height * 0.5
                        ),
                        drawingVersion: drawingVersion,
                        onDrawingChanged: onDrawingChanged
                    )
                    .frame(
                        width: geo.size.width - 60,
                        height: min(geo.size.height * 0.45, 500)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white, lineWidth: 3)
                    )
                    .shadow(radius: 20)
                    .contentShape(Rectangle())
                    .gesture(
                        isDragging ? nil :
                        DragGesture()
                            .updating($dragTranslation) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                panOffset.width -= value.translation.width * 0.5
                                panOffset.height -= value.translation.height * 0.5
                            }
                    )
                    .padding(.top, 60)

                    if !isDragging {
                        Button("Dismiss") {
                            onDismiss()
                        }
                        .padding(.top, 12)
                        .foregroundStyle(.white)
                        .font(.title3)
                    }

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Magnified Canvas (image + drawing overlay + drawable PKCanvasView)

struct MagnifiedCanvasView: UIViewRepresentable {
    let image: UIImage
    let canvasManager: CanvasManager
    let sourcePoint: CGPoint
    let drawingVersion: Int
    let onDrawingChanged: () -> Void

    // The region of the original image we're showing
    static let regionWidth: CGFloat = 300
    static let regionHeight: CGFloat = 180
    static let renderScale: CGFloat = 3

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.clipsToBounds = true

        // Background image view (shows the magnified region)
        let bgImageView = UIImageView()
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.clipsToBounds = true
        container.addSubview(bgImageView)
        context.coordinator.bgImageView = bgImageView

        // Drawing canvas overlay for the magnifier
        let magnifierCanvas = PKCanvasView()
        magnifierCanvas.backgroundColor = .clear
        magnifierCanvas.isOpaque = false
        magnifierCanvas.drawingPolicy = .pencilOnly
        magnifierCanvas.isScrollEnabled = false
        magnifierCanvas.delegate = context.coordinator
        canvasManager.applyCurrentTool(to: magnifierCanvas)

        container.addSubview(magnifierCanvas)
        context.coordinator.magnifierCanvas = magnifierCanvas
        context.coordinator.canvasManager = canvasManager
        context.coordinator.image = image
        context.coordinator.onDrawingChanged = onDrawingChanged

        return container
    }

    func updateUIView(_ container: UIView, context: Context) {
        let coord = context.coordinator
        coord.sourcePoint = sourcePoint
        coord.image = image

        let bounds = container.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        coord.bgImageView?.frame = bounds
        coord.magnifierCanvas?.frame = bounds

        // Apply current tool to magnifier canvas
        if let mc = coord.magnifierCanvas {
            canvasManager.applyCurrentTool(to: mc)
        }

        // Render the magnified background
        coord.bgImageView?.image = coord.renderBackground(viewSize: bounds.size)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var bgImageView: UIImageView?
        var magnifierCanvas: PKCanvasView?
        var canvasManager: CanvasManager?
        var image: UIImage?
        var sourcePoint: CGPoint = .zero
        var onDrawingChanged: (() -> Void)?
        private var isTransferring = false

        func renderBackground(viewSize: CGSize) -> UIImage? {
            guard let image, let mainCanvas = canvasManager?.canvasView else { return nil }
            let canvasFrame = mainCanvas.frame
            guard canvasFrame.width > 0, canvasFrame.height > 0 else { return nil }

            let rw = MagnifiedCanvasView.regionWidth
            let rh = MagnifiedCanvasView.regionHeight
            let cropRect = CGRect(
                x: sourcePoint.x - rw / 2,
                y: sourcePoint.y - rh / 2,
                width: rw,
                height: rh
            )

            let scale = MagnifiedCanvasView.renderScale
            let rendererSize = CGSize(width: rw * scale, height: rh * scale)
            let renderer = UIGraphicsImageRenderer(size: rendererSize)
            return renderer.image { ctx in
                ctx.cgContext.scaleBy(x: scale, y: scale)
                ctx.cgContext.translateBy(x: -cropRect.origin.x, y: -cropRect.origin.y)
                image.draw(in: CGRect(origin: .zero, size: canvasFrame.size))
                let drawingImage = mainCanvas.drawing.image(from: mainCanvas.bounds, scale: 3.0)
                drawingImage.draw(in: CGRect(origin: .zero, size: canvasFrame.size))
            }
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !isTransferring else { return }
            guard let canvasManager, let magnifierCanvas else { return }

            let mainCanvas = canvasManager.canvasView
            let mainFrame = mainCanvas.frame
            guard mainFrame.width > 0, mainFrame.height > 0 else { return }

            let magBounds = magnifierCanvas.bounds
            guard magBounds.width > 0, magBounds.height > 0 else { return }

            let rw = MagnifiedCanvasView.regionWidth
            let rh = MagnifiedCanvasView.regionHeight

            // Transform from magnifier coordinates to main canvas coordinates
            let scaleX = rw / magBounds.width
            let scaleY = rh / magBounds.height
            let offsetX = sourcePoint.x - rw / 2
            let offsetY = sourcePoint.y - rh / 2

            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                .translatedBy(x: offsetX / scaleX, y: offsetY / scaleY)

            let transformedDrawing = magnifierCanvas.drawing.transformed(using: transform)

            // Merge into main canvas
            isTransferring = true
            var combined = mainCanvas.drawing
            combined.append(transformedDrawing)
            mainCanvas.drawing = combined

            // Clear the magnifier canvas
            magnifierCanvas.drawing = PKDrawing()
            isTransferring = false

            // Refresh the background to show the new strokes
            if let bgImageView, magBounds.width > 0 {
                bgImageView.image = renderBackground(viewSize: magBounds.size)
            }

            onDrawingChanged?()
        }
    }
}
