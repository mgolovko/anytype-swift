
import Foundation

struct SlashMenuComparator {
    private let predicate: (String) -> Bool
    private let result: SlashMenuItemFilterMatch
    
    static func match(data: SlashMenuItemDisplayData, string: String) -> SlashMenuItemFilterMatch? {
        let lowecasedTitle = data.title.lowercased()
        let subtitle = data.subtitle?.lowercased()
        let comparators = [
            SlashMenuComparator(
                predicate: { lowecasedTitle == $0 },
                result: .fullTitle
            ),
            SlashMenuComparator(
                predicate: { lowecasedTitle.contains($0) },
                result: .titleSubstring
            ),
            SlashMenuComparator(
                predicate: { subtitle == $0 },
                result: .fullSubtitle
            ),
            SlashMenuComparator(
                predicate: { subtitle?.contains($0) ?? false },
                result: .subtitleSubstring
            )
        ]
        
        return comparators.first { $0.predicate(string.lowercased()) }?.result
    }
}
