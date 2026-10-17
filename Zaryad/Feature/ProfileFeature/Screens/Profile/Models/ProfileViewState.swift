//
//  ProfileViewState.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum ProfileViewState: Equatable {
    case guest, authenticating, user(ProfileUIModel)
}
