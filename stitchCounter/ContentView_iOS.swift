//
//  ContentView.swift
//  stitchCounter
//
//  Created by Zaq on 8/20/24.
//

import SwiftUI

struct CustomTopButtons_iOS: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 120, height: 120)
            .buttonStyle(.bordered)
            .background(backgroundColor.opacity(0.3))
            .clipShape(Circle())
            .padding([.leading,.trailing], 10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct VariableNumberButton_iOS: View {
    var number: Int
    @Binding var variableNumber: Int
    @Binding var selectedVariableNumber: Int

    var body: some View {
        Button {
            variableNumber = number
            selectedVariableNumber = number
        } label: {
            Text("\(number)")
                .bold()
                .frame(width: 80, height: 80)
                .foregroundColor(selectedVariableNumber == number ? Color.white : Color.blue)
        }
        .buttonStyle(.borderless)
        .background(selectedVariableNumber == number ? Color.blue : Color.gray.opacity(0.3))
        .clipShape(Circle())
    }
}

struct CustomLargeButtons_iOS: ButtonStyle {
    var backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct ContentView_iOS: View {

    @State private var stitchCount: Int = 0
    @State private var variableNumber: Int = 1
    @State private var selectedVariableNumber: Int = 1
    @State private var rowCount: Int = 0
    @State private var rows: [[Int]] = []
    @State private var firstRowAdded: Bool = false
    @State private var hideRows: Bool = false
    @State private var optionsOpened: Bool = false
    @State private var showAlert: Bool = false
    @State private var showHeaderText: Bool = false
    @State private var showRowText: Bool = false
    @State private var lastIndex: Int?

    var showBottomRow: [String] {[
        rows.description,
        showRowText.description
    ]}

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            // Add and subtract buttons
            HStack {
                Button {
                    if stitchCount > variableNumber {
                        stitchCount -= variableNumber
                    } else {
                        stitchCount = 0
                    }
                } label: {
                    Image(systemName: "minus")
                }
                .buttonStyle(CustomTopButtons_iOS(backgroundColor: .red))

                Spacer()
                
                Button {
                    stitchCount += variableNumber
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(CustomTopButtons_iOS(backgroundColor: .green))
            }

            Spacer()

            // Main text/count
            Text("Stitch Count")
                .padding([.top,.bottom], 10)
                .font(.largeTitle)
            Text("\(stitchCount)")
                .font(.largeTitle)

            Spacer()

            // variableNumber selection
            HStack {
                VariableNumberButton_iOS(number: 1, variableNumber: $variableNumber, selectedVariableNumber: $selectedVariableNumber)
                VariableNumberButton_iOS(number: 3, variableNumber: $variableNumber, selectedVariableNumber: $selectedVariableNumber)
                VariableNumberButton_iOS(number: 5, variableNumber: $variableNumber, selectedVariableNumber: $selectedVariableNumber)
                VariableNumberButton_iOS(number: 10, variableNumber: $variableNumber, selectedVariableNumber: $selectedVariableNumber)
            }

            VStack (spacing: 0) {
                // New Row and Options buttons
                HStack (spacing: 5) {
                    Button {
                        addNewRow()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            firstRowAdded = true
                            hideRows = false
                        }
                    } label: {
                        Text("New Row")
                    }
                    .buttonStyle(CustomLargeButtons_iOS(backgroundColor: .blue))
                    .padding(.leading, 5)

                    Button {
                        optionsOpened = true
                    } label: {
                        Text("Options")
                    }
                    .buttonStyle(CustomLargeButtons_iOS(backgroundColor: .green))
                    .padding(.trailing, 5)
                    .confirmationDialog("Options", isPresented: $optionsOpened) {
                        // Options buttons
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if !hideRows {
                                    hideRows = true
                                    showHeaderText = false
                                    showRowText = false
                                } else {
                                    hideRows = false
                                }
                            }
                        } label: {
                            Text(hideRows ? "Show Rows" : "Hide Rows")
                        }

                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if !rows.isEmpty {
                                    rows.removeLast()
                                    if rows.isEmpty {
                                        firstRowAdded = false
                                        showHeaderText = false
                                        showRowText = false
                                    } else {
                                        hideRows = false
                                    }
                                } else {
                                    firstRowAdded = false
                                }
                                if rowCount > 0 {
                                    rowCount -= 1
                                }
                            }
                        } label: {
                            Text("Remove Row")
                        }

                        Button(role: .destructive) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                firstRowAdded = false
                                showHeaderText = false
                                showRowText = false
                                hideRows = false
                                rows.removeAll()
                                rowCount = 0
                                variableNumber = 1
                                selectedVariableNumber = 1
                                stitchCount = 0
                            }
                        } label: {
                            Text("Reset All")
                        }

                        Button("Cancel", role: .cancel) {}
                    }
                }
                .padding([.top, .bottom], 10)


                // Show the bottom section if the rows are not hidden and there is an existing row
                if !hideRows {
                    if firstRowAdded {
                        // Row and Stitches header
                        HStack {
                            if showHeaderText {
                                Text("Row")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding([.top, .bottom])
                                Text("Stitches")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding([.top, .bottom])
                            }
                        }

                        .opacity(showRowText ? 1 : 0)
                        .transition(.opacity)
                        .animation(.easeIn(duration: 0.1), value: showHeaderText)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.leading, .trailing], 5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showHeaderText = true
                            }
                        }

                        // Stitch tracker
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(rows.indices, id: \.self) { index in
                                        Text("\(rows[index][0])")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .id(index)
                                            .padding()
                                            .opacity(showRowText ? 1 : 0)
                                            .animation(.easeIn(duration: 0.3), value: showRowText)

                                        Text("\(rows[index][1])")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding()
                                            .opacity(showRowText ? 1 : 0)
                                            .animation(.easeIn(duration: 0.3), value: showRowText)
                                    }
                                }
                                .padding([.leading, .trailing], 5)
                                .onChange(of: showBottomRow) {
                                    // Scroll to the bottom when rows change
                                    if let lastIndex = rows.indices.last {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            proxy.scrollTo(lastIndex, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 177)
                        .onAppear {
                            // Trigger grid text animation after the view appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    showRowText = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func addNewRow() {
        let newRow = [rowCount + 1, stitchCount]
        rows.append(newRow)
        rowCount += 1

        // Reset the view after new row
        variableNumber = 1
        selectedVariableNumber = 1
        stitchCount = 0
    }
}

#Preview {
    ContentView_iOS()
}
