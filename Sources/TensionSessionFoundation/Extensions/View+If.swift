//
//  View+If.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/25/26.
//

import SwiftUI

public extension View {

    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        apply transform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }

    @ViewBuilder
    func `if`<TrueContent: View>(
        _ condition: Bool,
        @ViewBuilder _ transform: (Self) -> TrueContent
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

