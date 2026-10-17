//
//  ProfileView.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI

struct ProfileView<VM: PProfileVM>: View {
    @ObservedObject var vm: VM

    var body: some View {
        List {
            switch vm.state {
            case .guest:
                guestSections
            case .authenticating:
                EmptyView()
            case .user(let profile):
                userSections(profile)
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if vm.state == .authenticating {
                ProgressView().controlSize(.large)
            }
        }
        .navigationTitle("Профіль")
        .navigationBarTitleDisplayMode(.large)
        .animation(.default, value: vm.state)
    }

    // MARK: - Guest
    @ViewBuilder
    private var guestSections: some View {
        Section {
            VStack(spacing: 14) {
                Image(systemName: "icloud.and.arrow.up")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.blue)
                    .padding(.top, 8)
                Text("Збережіть обране в хмарі")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                Text("Увійдіть, щоб ваші станції, оцінки та нотатки зберігались в акаунті й були доступні на інших пристроях.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    Button {
                        vm.signInTapped()
                    } label: {
                        Text("Увійти").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        vm.signUpTapped()
                    } label: {
                        Text("Створити акаунт").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.large)
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }

        Section("Що дає акаунт") {
            benefit("Обране в хмарі", subtitle: "Firebase Firestore", icon: "star.fill", tint: .orange)
            benefit("Синхронізація", subtitle: "Ті самі станції на всіх пристроях", icon: "arrow.triangle.2.circlepath", tint: .blue)
            benefit("Нічого не загубиться", subtitle: "Оцінки й нотатки переживуть перевстановлення", icon: "lock.shield.fill", tint: .green)
        }
    }

    private func benefit(_ title: String, subtitle: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - User
    @ViewBuilder
    private func userSections(_ profile: ProfileUIModel) -> some View {
        Section {
            HStack(spacing: 14) {
                Text(profile.initials)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Circle()
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.title3.bold())
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }

        Section {
            LabeledContent {
                Text(profile.favoritesText)
            } label: {
                Label("Обране", systemImage: "star.fill")
            }
            LabeledContent {
                Text("Firebase")
            } label: {
                Label("Хмарне сховище", systemImage: "icloud.fill")
            }
        } header: {
            Text("Хмара")
        } footer: {
            Text("Обране зберігається в акаунті й синхронізується між пристроями.")
        }

        Section("Акаунт") {
            LabeledContent("Створено", value: profile.memberSinceText)
        }

        Section {
            Button(role: .destructive) {
                vm.signOutTapped()
            } label: {
                HStack {
                    Text("Вийти")
                    Spacer()
                    if vm.isSigningOut {
                        ProgressView()
                    }
                }
            }
            .disabled(vm.isSigningOut)
            .confirmationDialog(
                "Вийти з акаунта?",
                isPresented: $vm.isSignOutConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button("Вийти", role: .destructive) { vm.confirmSignOut() }
                Button("Скасувати", role: .cancel) {}
            } message: {
                Text("Обране залишиться в хмарі й повернеться після наступного входу.")
            }
        }
    }
}
