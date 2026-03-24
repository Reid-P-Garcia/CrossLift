//
//  PuzzleView.swift
//  CrossLift
//
//  Created by Reid Garcia on 3/22/26.
//

import SwiftUI
import PencilKit

// MARK: - No-Edit-Menu PKCanvasView

/// PKCanvasView subclass that aggressively suppresses the "Select All | Insert Space" menu.
/// That menu comes from Scribble (handwriting recognition), edit menus, and text interactions
/// that PencilKit or iOS adds to the canvas.
class CleanCanvasView: PKCanvasView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .lookup)
        builder.remove(menu: .standardEdit)
        builder.remove(menu: .format)
        super.buildMenu(with: builder)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        stripUnwantedInteractions()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        stripUnwantedInteractions()
    }

    private func stripUnwantedInteractions() {
        // Remove edit menus, text interactions, and Scribble interactions
        for interaction in interactions {
            let typeName = String(describing: type(of: interaction))
            if interaction is UIEditMenuInteraction
                || typeName.contains("Scribble")
                || typeName.contains("TextInteraction")
                || typeName.contains("IndirectScribble") {
                removeInteraction(interaction)
            }
        }
    }
}

// MARK: - Canvas Manager

@Observable
class CanvasManager {
    let canvasView: CleanCanvasView
    var currentTool: ToolType = .pen
    var currentColor: UIColor = .systemBlue

    enum ToolType {
        case pen, eraser
    }

    init() {
        canvasView = CleanCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = PKInkingTool(.pen, color: .systemBlue, width: 2)
        canvasView.isScrollEnabled = false
        canvasView.overrideUserInterfaceStyle = .light
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
                MagnifierOverlay(
                    image: image,
                    canvasManager: canvasManager,
                    sourcePoint: CGPoint(
                        x: sourcePoint.x + magnifierPanOffset.width,
                        y: sourcePoint.y + magnifierPanOffset.height
                    ),
                    isDragging: isDraggingMagnifier,
                    panOffset: $magnifierPanOffset,
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
                resetToFit(scrollView: scrollView)
            } else {
                let point = gesture.location(in: containerView)
                let zoomRect = CGRect(x: point.x - 75, y: point.y - 75, width: 150, height: 150)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
    }
}

// MARK: - Magnifier Overlay

struct MagnifierOverlay: View {
    let image: UIImage
    let canvasManager: CanvasManager
    let sourcePoint: CGPoint
    let isDragging: Bool
    @Binding var panOffset: CGSize
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
                    MagnifierCanvasView(
                        image: image,
                        canvasManager: canvasManager,
                        sourcePoint: CGPoint(
                            x: sourcePoint.x - dragTranslation.width * 0.5,
                            y: sourcePoint.y - dragTranslation.height * 0.5
                        )
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

// MARK: - Magnifier Canvas View
//
// Uses a full-size canvas in main-canvas coordinates, zoomed and clipped
// to show the magnified region. Strokes are 1:1 with the main canvas —
// no coordinate transformation needed.

/// Custom clip view that re-lays-out content whenever its bounds change
/// (which happens when SwiftUI assigns the final .frame() size).
class MagnifierClipView: UIView {
    var layoutHandler: ((CGRect) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width > 0 && bounds.height > 0 {
            layoutHandler?(bounds)
        }
    }
}

struct MagnifierCanvasView: UIViewRepresentable {
    let image: UIImage
    let canvasManager: CanvasManager
    let sourcePoint: CGPoint

    func makeUIView(context: Context) -> MagnifierClipView {
        let clipView = MagnifierClipView()
        clipView.clipsToBounds = true

        let contentView = UIView()
        context.coordinator.contentView = contentView

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        context.coordinator.imageView = imageView

        let magCanvas = CleanCanvasView()
        magCanvas.backgroundColor = .clear
        magCanvas.isOpaque = false
        magCanvas.drawingPolicy = .pencilOnly
        magCanvas.isScrollEnabled = false
        magCanvas.overrideUserInterfaceStyle = .light
        magCanvas.delegate = context.coordinator
        context.coordinator.magCanvas = magCanvas
        context.coordinator.canvasManager = canvasManager
        context.coordinator.image = image

        contentView.addSubview(imageView)
        contentView.addSubview(magCanvas)
        clipView.addSubview(contentView)

        // Sync drawing from main canvas once on creation
        magCanvas.drawing = canvasManager.canvasView.drawing

        // Re-layout whenever the clip view gets its real bounds
        let coord = context.coordinator
        clipView.layoutHandler = { [weak coord] bounds in
            coord?.layoutMagnifier(clipBounds: bounds)
        }

        return clipView
    }

    func updateUIView(_ clipView: MagnifierClipView, context: Context) {
        let coord = context.coordinator
        coord.sourcePoint = sourcePoint

        // Apply current tool
        if let mc = coord.magCanvas {
            canvasManager.applyCurrentTool(to: mc)
        }

        // Trigger layout with current bounds
        let clipBounds = clipView.bounds
        if clipBounds.width > 0 && clipBounds.height > 0 {
            coord.layoutMagnifier(clipBounds: clipBounds)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var contentView: UIView?
        var imageView: UIImageView?
        var magCanvas: CleanCanvasView?
        var canvasManager: CanvasManager?
        var image: UIImage?
        var sourcePoint: CGPoint = .zero
        var isTransferring = false
        private var lastSetupBounds: CGRect = .zero

        func layoutMagnifier(clipBounds: CGRect) {
            guard let image, let canvasManager, let contentView, let imageView, let magCanvas else { return }
            guard clipBounds.width > 0, clipBounds.height > 0 else { return }

            // Get the main canvas size
            let mainCanvas = canvasManager.canvasView
            let mainFrame = mainCanvas.frame
            let canvasSize: CGSize
            if mainFrame.width > 0 && mainFrame.height > 0 {
                canvasSize = mainFrame.size
            } else {
                let imageSize = image.size
                let fitScale = min(clipBounds.width / imageSize.width, clipBounds.height / imageSize.height)
                canvasSize = CGSize(width: imageSize.width * fitScale, height: imageSize.height * fitScale)
            }

            // Zoom: a 300pt-wide region fills the clip view
            let regionWidth: CGFloat = 300
            let zoomScale = clipBounds.width / regionWidth

            // Only re-setup subview sizes if clip bounds changed
            if lastSetupBounds.size != clipBounds.size {
                lastSetupBounds = clipBounds

                // Set anchor point to top-left for predictable positioning
                imageView.layer.anchorPoint = .zero
                magCanvas.layer.anchorPoint = .zero

                // Set subviews at original canvas size with scale transform
                imageView.transform = .identity
                imageView.bounds = CGRect(origin: .zero, size: canvasSize)
                imageView.transform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
                imageView.layer.position = .zero

                magCanvas.transform = .identity
                magCanvas.bounds = CGRect(origin: .zero, size: canvasSize)
                magCanvas.transform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
                magCanvas.layer.position = .zero
            }

            // Position content view so sourcePoint is centered in clip view
            let scaledSize = CGSize(width: canvasSize.width * zoomScale, height: canvasSize.height * zoomScale)
            let originX = clipBounds.width / 2 - sourcePoint.x * zoomScale
            let originY = clipBounds.height / 2 - sourcePoint.y * zoomScale

            contentView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: scaledSize)
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !isTransferring else { return }
            guard let canvasManager, let magCanvas else { return }

            isTransferring = true
            canvasManager.canvasView.drawing = magCanvas.drawing
            isTransferring = false
        }
    }
}
