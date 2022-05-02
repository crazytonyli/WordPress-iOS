
import Foundation

typealias JSONDictionary = Dictionary<String, AnyObject>

/// A type representing a file in unit test bundle
protocol FixtureFile {

    /// Name of the file in unit test bundle
    var fileName: String { get }

}

extension FixtureFile {
    /// Load the file as JSON dictionary.
    ///
    /// - Returns: A dictionary representing the file content.
    func jsonObject() throws -> JSONDictionary {
        return try Fixture.jsonObject(fromFile: fileName)
    }

}

extension RawRepresentable where RawValue: StringProtocol {
    var fileName: String {
        return String(rawValue)
    }
}

/// A namespace for test fixtures.
enum Fixture {

    /// Loads the specified json file and returns a dictionary representing it.
    ///
    /// - Parameter fileName: The full name of the json file to load.
    /// - Returns: A dictionary representing the contents of the json file.
    ///
    static func jsonObject(fromFile fileName: String) throws -> JSONDictionary {
        let url = Bundle(for: BundleFinder.self).url(forResource: fileName, withExtension: nil)
        let content = try Data(contentsOf: XCTUnwrap(url))
        let result = try JSONSerialization.jsonObject(with: content, options: [.mutableContainers, .mutableLeaves])
        return try XCTUnwrap(result as? JSONDictionary)
    }

}

/// Class for finding test bundle
private final class BundleFinder {
    // Empty
}
