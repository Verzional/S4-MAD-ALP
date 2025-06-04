import Foundation
import PencilKit

class LocalDrawingStorage {

    static let shared = LocalDrawingStorage()
    private let fileManager = FileManager.default

    private var documentsDirectoryURL: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var projectsIndexFileURL: URL {
        return documentsDirectoryURL.appendingPathComponent("projects_index.json")
    }
    
    private var drawingsDirectoryURL: URL {
        let url = documentsDirectoryURL.appendingPathComponent("Drawings")
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }

    // MARK: - Save PKDrawing Data
    func saveDrawingData(_ drawing: PKDrawing, filename: String) -> Bool {
        guard let data = try? JSONEncoder().encode(drawing) else {
            print("Error: Could not encode PKDrawing.")
            return false
        }
        let fileURL = drawingsDirectoryURL.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            print("Drawing data saved to: \(fileURL.path)")
            return true
        } catch {
            print("Error writing drawing data to disk: \(error)")
            return false
        }
    }

    // MARK: - Load PKDrawing Data
    func loadDrawingData(filename: String) -> PKDrawing? {
        let fileURL = drawingsDirectoryURL.appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: fileURL)
            let drawing = try JSONDecoder().decode(PKDrawing.self, from: data)
            return drawing
        } catch {
            print("Error reading drawing data from disk: \(error)")
            return nil
        }
    }
    
    // MARK: - Delete PKDrawing Data
    func deleteDrawingData(filename: String) {
        let fileURL = drawingsDirectoryURL.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Save Project Metadata Index
    func saveProjectsMetadata(_ projectsMetadata: [DrawingProjectMetadata]) {
        do {
            let data = try JSONEncoder().encode(projectsMetadata)
            try data.write(to: projectsIndexFileURL)
            print("Projects index saved.")
        } catch {
            print("Error saving projects index: \(error)")
        }
    }

    // MARK: - Load Project Metadata Index
    func loadProjectsMetadata() -> [DrawingProjectMetadata] {
        do {
            let data = try Data(contentsOf: projectsIndexFileURL)
            let metadataArray = try JSONDecoder().decode([DrawingProjectMetadata].self, from: data)
            return metadataArray
        } catch {
            print("Error loading projects index (or file doesn't exist yet): \(error)")
            return []
        }
    }
}
