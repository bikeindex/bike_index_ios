//
//  MockFailureTests.swift
//  UnitTests
//
//  Created by Jack on 09/29/26.
//

import Testing

/// A deliberately-failing Swift Testing suite used to verify the CI retry
/// mechanism end-to-end. A Swift Testing failure must be re-run at the
/// whole-suite level, because a function-level `-only-testing` selector for a
/// Swift Testing test silently runs zero tests.
///
/// ⚠️ This test always fails. It is a verification canary — delete this file
/// before merging the branch.
struct MockFailureTests {

    @Test func test_mock_failure() {
        #expect(false, "mock failure")
    }

}
