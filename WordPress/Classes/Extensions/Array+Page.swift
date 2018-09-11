import Foundation

// Array etension to handle Pages on a Page list
//
extension Array where Element == Page {
    /// Return the first index
    var firstIndex: Int {
        return 0
    }

    /// Return the last index
    var lastIndex: Int {
        return isEmpty ? 0 : count - 1
    }

    /// Check if the Array contains a specific Page for a specific `id`
    ///
    /// - Parameter id: Page id
    /// - Returns: If the Page exists or not
    func containsPage(for id: Int?) -> Bool {
        guard let id = id else {
            return false
        }

        return contains { $0.postID?.intValue == id }
    }

    /// A map function where transform closure receives the Element and Array
    ///
    /// - Parameter transform: Closure accepting the Element and the Array
    /// - Returns: An transformed array of Elements
    func map<T>(_ transform: (Element, [Element]) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        forEach {
            result.append(transform($0, self))
        }
        return result
    }

    /// DFS sort where the pagies are hierarchly ordered in a flat list
    ///
    /// - Parameters:
    ///   - parent: A parent Element
    ///   - consideringTopLevel: Force to check if the pages are visually top levels
    /// - Returns: An Array of Elements
    func sort(by parent: Element? = nil, consideringTopLevel: Bool = true) -> [Element] {
        var sortedList: [Element] = []
        let block = { (row: Element) -> Bool in
            return consideringTopLevel ? row.hasVisibleParent : row.parentID?.intValue == parent?.postID?.intValue
        }
        filter(block).forEach {
            sortedList.append($0)
            sortedList.append(contentsOf: sort(by: $0, consideringTopLevel: false))
        }
        return sortedList
    }

    /// Set indexes for a hierarchy list
    ///
    /// - Returns: An Array of Elements
    func hierachyIndexes() -> [Element] {
        var index = 0
        forEach {
            if $0.hasVisibleParent {
                $0.hierarchyIndex = 0
            } else {
                let parentIndex = index - 1
                let parent = self[parentIndex]
                $0.hierarchyIndex = ($0.parentID?.intValue == parent.parentID?.intValue) ? parentIndex : parent.hierarchyIndex + 1
            }

            index += 1
        }

        return self
    }

    /// Remove Elements from a specific index
    ///
    /// - Parameter index: The starting index
    /// - Returns: An Array of Elements
    func remove(from index: Int) -> [Element] {
        if isEmpty || index < firstIndex || index > lastIndex {
            return self
        }

        var left: ArraySlice<Element> = []
        var right: ArraySlice<Element> = []

        switch index {
        case firstIndex:
            right = dropFirst()

        case lastIndex:
            return Array<Element>(dropLast())

        default:
            left = self[0...(index - 1)]
            right = self[(index + 1)...]
        }

        for element in right {
            if element.hasVisibleParent {
                break
            }

            if let index = right.index(of: element) {
                right.remove(at: index)
            }
        }

        return Array(left + right)
    }
}