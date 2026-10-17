//
//  RatingPopup.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI

/// Попап оцінки в стилі App Store: зірки в рядок (тап або свайп по них), «Скасувати» / «Надіслати».
struct RatingPopup: View {
    var title: String = "Оцініть станцію"
    var message: String = "Торкніться зірки, щоб поставити оцінку. Станція збережеться в обраному."
    let onSubmit: (Int) -> Void
    let onClose: () -> Void

    @State private var rating = 0
    @State private var isVisible = false

    private let starsCount = 5
    private let starSize: CGFloat = 32
    private let starWidth: CGFloat = 40
    private let starSpacing: CGFloat = 4

    var body: some View {
        ZStack {
            Color.black
                .opacity(isVisible ? 0.3 : 0)
                .ignoresSafeArea()

            card
                .scaleEffect(isVisible ? 1 : 1.15)
                .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.3)) { isVisible = true }
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                stars
                    .padding(.top, 12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            HStack(spacing: 0) {
                Button("Скасувати") {
                    close()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                Button {
                    let rate = rating
                    close { onSubmit(rate) }
                } label: {
                    Text("Надіслати")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .disabled(rating == 0)
            }
            .frame(height: 46)
        }
        .frame(width: 290)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
    }

    private var stars: some View {
        HStack(spacing: starSpacing) {
            ForEach(1...starsCount, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: starSize))
                    .foregroundStyle(.orange)
                    .frame(width: starWidth)
                    .scaleEffect(index == rating ? 1.15 : 1)
                    .animation(.spring(duration: 0.2), value: rating)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { rating = star(at: $0.location.x) }
        )
        .sensoryFeedback(.selection, trigger: rating)
        .accessibilityElement()
        .accessibilityLabel("Оцінка")
        .accessibilityValue(rating == 0 ? "не вибрано" : "\(rating) з \(starsCount)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(rating + 1, starsCount)
            case .decrement: rating = max(rating - 1, 1)
            @unknown default: break
            }
        }
    }

    /// Номер зірки (1…5) під точкою `x` в рядку зірок.
    private func star(at x: CGFloat) -> Int {
        let step = starWidth + starSpacing
        return min(max(Int(x / step) + 1, 1), starsCount)
    }

    private func close(then action: (() -> Void)? = nil) {
        withAnimation(.easeIn(duration: 0.15)) {
            isVisible = false
        } completion: {
            action?()
            onClose()
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
        RatingPopup(onSubmit: { _ in }, onClose: {})
    }
}
#endif
