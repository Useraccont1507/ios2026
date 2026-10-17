//
//  AuthView.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import SwiftUI

struct AuthView<VM: PAuthVM>: View {
    @ObservedObject var vm: VM
    @FocusState private var focusedField: Field?

    private enum Field { case name, email, password }

    var body: some View {
        Form {
            Section {
                Picker("Режим", selection: $vm.mode) {
                    ForEach(AuthMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section {
                if vm.mode == .signUp {
                    TextField("Ім'я (необов'язково)", text: $vm.displayName)
                        .textContentType(.name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                }
                TextField("Email", text: $vm.email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                SecureField("Пароль", text: $vm.password)
                    .textContentType(vm.mode == .signUp ? .newPassword : .password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { vm.submit() }
            } footer: {
                if vm.mode == .signUp {
                    Text("Пароль — щонайменше 6 символів.")
                }
            }

            if let error = vm.errorText {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            Section {
                Button {
                    focusedField = nil
                    vm.submit()
                } label: {
                    HStack {
                        Spacer()
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(vm.mode.submitTitle).fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!vm.canSubmit)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
        .navigationTitle(vm.mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: vm.mode)
        .animation(.default, value: vm.errorText)
        .disabled(vm.isLoading)
        .onAppear { focusedField = vm.mode == .signUp ? .name : .email }
    }
}
