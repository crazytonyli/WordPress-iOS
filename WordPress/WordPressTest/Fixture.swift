import Foundation
import CoreData

typealias JSONObject = Dictionary<String, AnyObject>

/// A type representing a file in the unit test bundle
protocol FileFixture {

    /// Name of the file in unit test bundle
    var fileName: String { get }

}

/// A type representing a JSON file in the unit test bundle
protocol JSONFileFixture: FileFixture {
}

extension JSONFileFixture {

    /// Load the file as JSON dictionary.
    ///
    /// - Returns: A dictionary representing the file content.
    func jsonObject() throws -> JSONObject {
        return try Fixtures.jsonObject(fromFile: fileName)
    }

}

extension FileFixture where Self: RawRepresentable, Self.RawValue: StringProtocol {
    var fileName: String {
        return String(rawValue)
    }
}

/// A type representing a `NSManagedObject` subclass which can be loaded from a file in the unit test bundle.
protocol ManagedObjectFixture: JSONFileFixture {

    /// The `NSManagedObject` subclass represented by the file.
    associatedtype Model: NSManagedObject

}

extension ManagedObjectFixture {


    /// Loads the JSON file contents into a new `NSManagedObject` instance.
    ///
    /// - Parameters:
    ///   - context: The managed object context to use
    /// - Returns: A new instance with property values of the JSON file.
    func insertInto(_ context: NSManagedObjectContext) throws -> Model {
        let model = Model.init(context: context)
        for (key, value) in try jsonObject() {
            model.setValue(value, forKey: key)
        }
        return model
    }

}

/// A namespace for test fixtures.
enum Fixtures {

    /// Loads the specified json file and returns a dictionary representing it.
    ///
    /// - Parameter fileName: The full name of the json file to load.
    /// - Returns: A dictionary representing the contents of the json file.
    ///
    static func jsonObject(fromFile fileName: String) throws -> JSONObject {
        let url = Bundle(for: BundleFinder.self).url(forResource: fileName, withExtension: nil)
        let content = try Data(contentsOf: XCTUnwrap(url))
        let result = try JSONSerialization.jsonObject(with: content, options: [.mutableContainers, .mutableLeaves])
        return try XCTUnwrap(result as? JSONObject)
    }

}

/// Class for finding test bundle
private final class BundleFinder {
    // Empty
}
