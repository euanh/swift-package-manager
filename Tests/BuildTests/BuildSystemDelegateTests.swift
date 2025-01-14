//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SPMTestSupport
import XCTest

import var TSCBasic.localFileSystem

final class BuildSystemDelegateTests: XCTestCase {
    func testDoNotFilterLinkerDiagnostics() throws {
        try fixture(name: "Miscellaneous/DoNotFilterLinkerDiagnostics") { fixturePath in
            #if !os(macOS)
            // These linker diagnostics are only produced on macOS.
            try XCTSkipIf(true, "test is only supported on macOS")
            #endif
            let (fullLog, _) = try executeSwiftBuild(fixturePath)
            XCTAssertTrue(fullLog.contains("ld: warning: ignoring duplicate libraries: '-lz'"), "log didn't contain expected linker diagnostics")
        }
    }

    func testFilterNonFatalCodesignMessages() throws {
        // Note: we can re-use the `TestableExe` fixture here since we just need an executable.
        try fixture(name: "Miscellaneous/TestableExe") { fixturePath in
            _ = try executeSwiftBuild(fixturePath)
            let execPath = fixturePath.appending(components: ".build", "debug", "TestableExe1")
            XCTAssertTrue(localFileSystem.exists(execPath), "executable not found at '\(execPath)'")
            try localFileSystem.removeFileTree(execPath)
            let (fullLog, _) = try executeSwiftBuild(fixturePath)
            XCTAssertFalse(fullLog.contains("replacing existing signature"), "log contained non-fatal codesigning messages")
        }
    }
}
