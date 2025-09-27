# CrateDigging Feature Plan

## Overview
CrateDigging is a macOS application for managing Native Instruments Traktor collections, crates, and mix history. The app follows MVVM architecture with SwiftUI and focuses on modifying Traktor NML files.

## Current Architecture
- **Framework**: SwiftUI with MVVM pattern
- **Dependencies**: XMLCoder, CrateFoundation (custom package)
- **File Access**: Security-scoped bookmarks for Traktor folder access
- **Current Features**: Basic navigation structure with Collection, Crates, and Mixes views

---

## Feature 1: Collection Management

### Core Functionality
- **Fetch collection from collection.nml file**
- **Filter and search collection**
- **Add track to existing crate**
- **Look for duplicates and resolve**

### Technical Implementation

#### Models
```swift
// Enhanced Track model to match NML structure
struct Track: Identifiable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let album: String?
    let genre: String?
    let bpm: Double?
    let key: String?
    let duration: TimeInterval?
    let filePath: String
    let fileSize: Int64?
    let dateAdded: Date?
    let playCount: Int?
    let rating: Int?
    let comment: String?
    let artwork: Data?
}

// Collection model
struct Collection: Codable {
    let tracks: [Track]
    let playlists: [Playlist]
    let crates: [Crate]
    let lastModified: Date
}

// Enhanced filter options
struct CollectionFilterOptions: Equatable {
    var searchText: String = ""
    var selectedGenres: Set<String> = []
    var bpmRange: ClosedRange<Double> = 60...200
    var keyFilter: String? = nil
    var dateRange: ClosedRange<Date>? = nil
    var ratingFilter: Int? = nil
    var isActive: Bool {
        !searchText.isEmpty || !selectedGenres.isEmpty || 
        bpmRange != 60...200 || keyFilter != nil || 
        dateRange != nil || ratingFilter != nil
    }
}
```

#### Services
```swift
// Collection service protocol
protocol CollectionServiceProtocol: Sendable {
    func loadCollection(from url: URL) async throws -> Collection
    func saveCollection(_ collection: Collection, to url: URL) async throws
    func findDuplicates(in tracks: [Track]) -> [DuplicateGroup]
    func resolveDuplicates(_ duplicates: [DuplicateGroup], strategy: DuplicateResolutionStrategy) -> [Track]
}

// NML parser service
protocol NMLParserServiceProtocol: Sendable {
    func parseCollection(from data: Data) throws -> Collection
    func serializeCollection(_ collection: Collection) throws -> Data
}

// Duplicate detection service
protocol DuplicateDetectionServiceProtocol: Sendable {
    func findDuplicates(in tracks: [Track]) -> [DuplicateGroup]
    func calculateSimilarity(_ track1: Track, _ track2: Track) -> Double
}
```

#### ViewModels
```swift
// Collection view model
@MainActor
class CollectionViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var filteredTracks: [Track] = []
    @Published var filterOptions = CollectionFilterOptions()
    @Published var duplicates: [DuplicateGroup] = []
    @Published var isLoading = false
    @Published var error: DisplayableError?
    
    private let collectionService: CollectionServiceProtocol
    private let duplicateService: DuplicateDetectionServiceProtocol
    
    func loadCollection() async
    func applyFilters()
    func findDuplicates() async
    func resolveDuplicates(_ duplicates: [DuplicateGroup], strategy: DuplicateResolutionStrategy) async
    func addTrackToCrate(_ track: Track, crateId: UUID) async
}
```

#### Views
- `CollectionView` - Main collection display with grid/list toggle
- `TrackCardView` - Individual track display (already exists, needs enhancement)
- `CollectionFilterView` - Advanced filtering interface
- `DuplicateResolutionView` - Duplicate detection and resolution UI
- `TrackDetailView` - Detailed track information

### Implementation Checklist
- [ ] Create enhanced Track model with NML-compatible properties
- [ ] Implement NMLParserService for reading/writing collection.nml
- [ ] Create CollectionService for collection management operations
- [ ] Implement DuplicateDetectionService with multiple algorithms
- [ ] Build CollectionViewModel with filtering and search
- [ ] Enhance CollectionView with advanced filtering UI
- [ ] Create DuplicateResolutionView for handling duplicates
- [ ] Add track-to-crate functionality
- [ ] Implement search with multiple criteria (title, artist, genre, etc.)
- [ ] Add sorting options (BPM, key, date added, rating, etc.)
- [ ] Create unit tests for all services
- [ ] Add integration tests for NML parsing

---

## Feature 2: Crate Management

### Core Functionality
- **Crate/playlist management**
- **Fetch existing playlists from collection.nml file**
- **Create new crates and add them to collection.nml file**
- **Update crates by adding tracks, removing tracks, and reordering tracks**
- **Delete crates which removes them from the collection.nml file**

### Technical Implementation

#### Models
```swift
// Crate model
struct Crate: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String?
    let tracks: [Track]
    let dateCreated: Date
    let dateModified: Date
    let color: String? // For UI theming
    let isSmartCrate: Bool
    let smartCrateRules: [SmartCrateRule]?
}

// Smart crate rules for automatic track inclusion
struct SmartCrateRule: Codable {
    let property: TrackProperty
    let operator: ComparisonOperator
    let value: String
    let isAnd: Bool // true for AND, false for OR
}

enum TrackProperty: String, CaseIterable, Codable {
    case title, artist, album, genre, bpm, key, rating, dateAdded
}

enum ComparisonOperator: String, CaseIterable, Codable {
    case equals, contains, greaterThan, lessThan, between
}

// Crate operations
enum CrateOperation {
    case addTracks([Track])
    case removeTracks([UUID])
    case reorderTracks([UUID])
    case updateMetadata(name: String, description: String?)
    case delete
}
```

#### Services
```swift
// Crate service protocol
protocol CrateServiceProtocol: Sendable {
    func loadCrates(from collection: Collection) -> [Crate]
    func createCrate(_ crate: Crate, in collection: inout Collection) async throws
    func updateCrate(_ crateId: UUID, operation: CrateOperation, in collection: inout Collection) async throws
    func deleteCrate(_ crateId: UUID, from collection: inout Collection) async throws
    func reorderCrates(_ crateIds: [UUID], in collection: inout Collection) async throws
}

// Smart crate service
protocol SmartCrateServiceProtocol: Sendable {
    func evaluateSmartCrate(_ crate: Crate, against tracks: [Track]) -> [Track]
    func validateSmartCrateRules(_ rules: [SmartCrateRule]) -> Bool
}
```

#### ViewModels
```swift
// Crates view model
@MainActor
class CratesViewModel: ObservableObject {
    @Published var crates: [Crate] = []
    @Published var selectedCrate: Crate?
    @Published var isCreatingCrate = false
    @Published var isEditingCrate = false
    @Published var isLoading = false
    @Published var error: DisplayableError?
    
    private let crateService: CrateServiceProtocol
    private let smartCrateService: SmartCrateServiceProtocol
    
    func loadCrates() async
    func createCrate(_ crate: Crate) async
    func updateCrate(_ crateId: UUID, operation: CrateOperation) async
    func deleteCrate(_ crateId: UUID) async
    func reorderCrates(_ crateIds: [UUID]) async
    func selectCrate(_ crate: Crate)
}

// Crate detail view model
@MainActor
class CrateDetailViewModel: ObservableObject {
    @Published var crate: Crate
    @Published var availableTracks: [Track] = []
    @Published var isEditing = false
    @Published var searchText = ""
    @Published var error: DisplayableError?
    
    private let crateService: CrateServiceProtocol
    
    func addTracks(_ tracks: [Track]) async
    func removeTracks(_ trackIds: [UUID]) async
    func reorderTracks(_ trackIds: [UUID]) async
    func updateCrateMetadata(name: String, description: String?) async
}
```

#### Views
- `CratesView` - Main crates list (already exists, needs enhancement)
- `CrateDetailView` - Individual crate management
- `CreateCrateView` - New crate creation
- `EditCrateView` - Crate editing interface
- `SmartCrateRuleView` - Smart crate rule configuration
- `CrateTrackListView` - Track management within crates
- `CrateReorderView` - Drag-and-drop reordering interface

### Implementation Checklist
- [ ] Create Crate model with smart crate support
- [ ] Implement CrateService for CRUD operations
- [ ] Create SmartCrateService for rule evaluation
- [ ] Build CratesViewModel with full crate management
- [ ] Enhance CratesView with create/edit/delete functionality
- [ ] Create CrateDetailView for individual crate management
- [ ] Implement drag-and-drop reordering for tracks
- [ ] Add smart crate creation and rule configuration
- [ ] Create crate import/export functionality
- [ ] Add crate templates and presets
- [ ] Implement crate search and filtering
- [ ] Add crate statistics (track count, total duration, etc.)
- [ ] Create unit tests for crate operations
- [ ] Add integration tests for NML crate persistence

---

## Feature 3: Mixes Management

### Core Functionality
- **History management**
- **Fetch mix history from "Native Instruments/Traktor/History" folder**
- **Future: Analytics and DJ stats**
- **Future: Suggestions for adding tracks to crates**

### Technical Implementation

#### Models
```swift
// Mix session model
struct MixSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let tracks: [PlayedTrack]
    let transitions: [Transition]
    let metadata: MixMetadata
}

// Played track within a mix
struct PlayedTrack: Identifiable, Codable {
    let id: UUID
    let track: Track
    let startTime: Date
    let endTime: Date
    let volume: Double
    let pitch: Double
    let effects: [Effect]
    let transitionIn: Transition?
    let transitionOut: Transition?
}

// Transition between tracks
struct Transition: Codable {
    let type: TransitionType
    let duration: TimeInterval
    let startTime: Date
    let endTime: Date
    let parameters: [String: Double]
}

enum TransitionType: String, CaseIterable, Codable {
    case crossfade, cut, loop, echo, reverb, filter
}

// Mix metadata
struct MixMetadata: Codable {
    let title: String?
    let description: String?
    let venue: String?
    let event: String?
    let tags: [String]
    let rating: Int?
    let notes: String?
}

// Future: Analytics models
struct MixAnalytics: Codable {
    let totalPlayTime: TimeInterval
    let averageBPM: Double
    let keyDistribution: [String: Int]
    let genreDistribution: [String: Int]
    let transitionTypes: [TransitionType: Int]
    let peakEnergy: Double
    let energyFlow: [Double] // Energy over time
}

// Future: Track suggestions
struct TrackSuggestion: Identifiable, Codable {
    let id: UUID
    let track: Track
    let reason: SuggestionReason
    let confidence: Double
    let suggestedCrate: UUID?
}

enum SuggestionReason: String, CaseIterable, Codable {
    case similarBPM, sameKey, sameGenre, frequentlyPlayedTogether, energyMatch
}
```

#### Services
```swift
// Mix history service
protocol MixHistoryServiceProtocol: Sendable {
    func loadMixHistory(from url: URL) async throws -> [MixSession]
    func saveMixSession(_ session: MixSession, to url: URL) async throws
    func parseTraktorHistoryFile(_ url: URL) async throws -> MixSession
    func getMixHistoryFolder() async throws -> URL
}

// Future: Analytics service
protocol MixAnalyticsServiceProtocol: Sendable {
    func analyzeMix(_ session: MixSession) -> MixAnalytics
    func generateTrackSuggestions(for crate: Crate, basedOn history: [MixSession]) -> [TrackSuggestion]
    func getDJStats(for sessions: [MixSession]) -> DJStats
}

// Future: DJ stats
struct DJStats: Codable {
    let totalMixTime: TimeInterval
    let averageSessionLength: TimeInterval
    let mostPlayedTracks: [Track]
    let favoriteGenres: [String]
    let favoriteKeys: [String]
    let transitionPreferences: [TransitionType: Int]
    let energyProfile: EnergyProfile
}

struct EnergyProfile: Codable {
    let lowEnergy: Double
    let mediumEnergy: Double
    let highEnergy: Double
}
```

#### ViewModels
```swift
// Mixes view model
@MainActor
class MixesViewModel: ObservableObject {
    @Published var mixSessions: [MixSession] = []
    @Published var selectedSession: MixSession?
    @Published var isLoading = false
    @Published var error: DisplayableError?
    @Published var filterOptions = MixFilterOptions()
    
    private let mixHistoryService: MixHistoryServiceProtocol
    private let analyticsService: MixAnalyticsServiceProtocol?
    
    func loadMixHistory() async
    func selectSession(_ session: MixSession)
    func applyFilters()
    func exportSession(_ session: MixSession) async
    func deleteSession(_ session: MixSession) async
}

// Mix detail view model
@MainActor
class MixDetailViewModel: ObservableObject {
    @Published var session: MixSession
    @Published var analytics: MixAnalytics?
    @Published var suggestions: [TrackSuggestion] = []
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    
    private let analyticsService: MixAnalyticsServiceProtocol?
    
    func loadAnalytics() async
    func generateSuggestions() async
    func playSession()
    func pauseSession()
    func seekTo(_ time: TimeInterval)
}
```

#### Views
- `MixesView` - Main mix history list (already exists, needs enhancement)
- `MixDetailView` - Individual mix session details
- `MixTimelineView` - Visual timeline of mix session
- `MixAnalyticsView` - Analytics and statistics
- `TrackSuggestionsView` - AI-powered track suggestions
- `MixExportView` - Export mix session data
- `MixFilterView` - Filter mix history

### Implementation Checklist
- [ ] Create MixSession and related models
- [ ] Implement MixHistoryService for Traktor history parsing
- [ ] Build MixesViewModel with history management
- [ ] Enhance MixesView with session list and filtering
- [ ] Create MixDetailView with timeline visualization
- [ ] Implement Traktor history file parser
- [ ] Add mix session export functionality
- [ ] Create mix session search and filtering
- [ ] Add mix session statistics display
- [ ] Implement mix session playback (future)
- [ ] Create unit tests for history parsing
- [ ] Add integration tests for Traktor file format

### Future Enhancements (Phase 2)
- [ ] Implement MixAnalyticsService for DJ statistics
- [ ] Create AI-powered track suggestion system
- [ ] Add mix session playback with audio visualization
- [ ] Implement energy analysis and flow visualization
- [ ] Create DJ performance analytics dashboard
- [ ] Add social features for sharing mix sessions
- [ ] Implement automatic crate suggestions based on mix history

---

## Technical Architecture

### Service Layer
- **CollectionService**: Manages collection.nml file operations
- **CrateService**: Handles crate CRUD operations
- **MixHistoryService**: Parses Traktor history files
- **DuplicateDetectionService**: Finds and resolves duplicate tracks
- **SmartCrateService**: Evaluates smart crate rules
- **AnalyticsService**: Generates DJ statistics and suggestions (future)

### Data Layer
- **NMLParser**: XML parsing for Traktor files
- **BookmarkStore**: Security-scoped file access
- **CacheManager**: In-memory caching for performance
- **ExportManager**: Data export functionality

### UI Layer
- **MVVM Architecture**: ViewModels handle business logic
- **SwiftUI Views**: Reactive UI components
- **Navigation**: NavigationSplitView for main interface
- **Modals**: Sheet presentations for detailed views

### Testing Strategy
- **Unit Tests**: Service layer and business logic
- **Integration Tests**: File parsing and persistence
- **UI Tests**: Critical user workflows
- **Performance Tests**: Large collection handling

---

## Implementation Phases

### Phase 1: Core Collection Management (Weeks 1-4)
1. Enhanced Track model and NML parsing
2. Collection loading and display
3. Basic filtering and search
4. Duplicate detection and resolution

### Phase 2: Crate Management (Weeks 5-8)
1. Crate CRUD operations
2. Track management within crates
3. Smart crate functionality
4. Crate import/export

### Phase 3: Mix History (Weeks 9-12)
1. Traktor history parsing
2. Mix session display and management
3. Basic analytics and statistics
4. Export functionality

### Phase 4: Advanced Features (Weeks 13-16)
1. AI-powered track suggestions
2. Advanced analytics dashboard
3. Performance optimizations
4. Advanced filtering and search

---

## Success Metrics
- **Performance**: Load 10,000+ tracks in <2 seconds
- **Reliability**: 99.9% success rate for NML file operations
- **Usability**: Complete common tasks in <3 clicks
- **Accuracy**: 95%+ accuracy in duplicate detection
- **Compatibility**: Support Traktor Pro 3.x NML format

---

## Risk Mitigation
- **File Corruption**: Backup and validation before modifications
- **Performance**: Lazy loading and pagination for large collections
- **Compatibility**: Version detection and format validation
- **Data Loss**: Undo/redo functionality and auto-backup
- **User Experience**: Progressive disclosure and contextual help
