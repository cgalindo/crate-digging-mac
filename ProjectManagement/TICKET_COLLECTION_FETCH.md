# Ticket: Collection Fetch Implementation

## Overview
Implement collection fetching logic for `collection.nml` file with bookmark management, version detection, and Core Data synchronization.

## Acceptance Criteria

### 1. Bookmark Management
- [ ] Check for existing bookmark for collection.nml URL
- [ ] If bookmark exists, use it to fetch collection
- [ ] Track last modified date to only process new tracks
- [ ] If no bookmark exists, find collection.nml file and create bookmark

### 2. Native Instruments Folder Access
- [ ] Check if user has granted access to "Native Instruments" folder
- [ ] If no access, request through NSOpenPanel
- [ ] Look for latest Traktor version folder (e.g., "Native Instruments/Traktor 4.1.1")
- [ ] Bookmark the collection.nml file after access is granted

### 3. Version Detection
- [ ] On each launch, check for new Traktor versions
- [ ] Compare current version with saved version
- [ ] Prompt user to switch to new version if available
- [ ] Update bookmark to point to new version's collection.nml

### 4. Core Data Integration
- [ ] Save collection data to Core Data
- [ ] Sync with collection.nml on each launch
- [ ] Use Core Data to populate Collection View
- [ ] Implement incremental updates based on last modified date

## Technical Implementation

### Models

```swift
// Collection metadata for tracking
struct CollectionMetadata: Codable {
    let lastModified: Date
    let version: String
    let filePath: String
    let trackCount: Int
}

// Traktor version info
struct TraktorVersion: Codable, Comparable {
    let version: String
    let path: String
    let collectionPath: String
    
    static func < (lhs: TraktorVersion, rhs: TraktorVersion) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedAscending
    }
}

// Collection fetch result
struct CollectionFetchResult {
    let collection: Collection
    let metadata: CollectionMetadata
    let isIncremental: Bool
    let newTracks: [Track]
    let updatedTracks: [Track]
}
```

### Services

```swift
// Collection fetch service protocol
protocol CollectionFetchServiceProtocol: Sendable {
    func fetchCollection() async throws -> CollectionFetchResult
    func checkForNewVersion() async throws -> TraktorVersion?
    func switchToVersion(_ version: TraktorVersion) async throws
    func getCurrentVersion() async throws -> TraktorVersion?
}

// Traktor version service
protocol TraktorVersionServiceProtocol: Sendable {
    func findLatestVersion() async throws -> TraktorVersion?
    func getAllVersions() async throws -> [TraktorVersion]
    func getVersionFromPath(_ path: String) -> TraktorVersion?
}

// Collection sync service
protocol CollectionSyncServiceProtocol: Sendable {
    func syncWithCoreData(_ result: CollectionFetchResult) async throws
    func getLastSyncDate() async throws -> Date?
    func updateLastSyncDate(_ date: Date) async throws
}
```

### Core Data Models

```swift
// Core Data entity for collection metadata
@objc(CollectionMetadataEntity)
class CollectionMetadataEntity: NSManagedObject {
    @NSManaged var lastModified: Date
    @NSManaged var version: String
    @NSManaged var filePath: String
    @NSManaged var trackCount: Int32
    @NSManaged var lastSyncDate: Date
}

// Core Data entity for tracks
@objc(TrackEntity)
class TrackEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var artist: String
    @NSManaged var album: String?
    @NSManaged var genre: String?
    @NSManaged var bpm: Double
    @NSManaged var key: String?
    @NSManaged var duration: TimeInterval
    @NSManaged var filePath: String
    @NSManaged var fileSize: Int64
    @NSManaged var dateAdded: Date?
    @NSManaged var playCount: Int32
    @NSManaged var rating: Int32
    @NSManaged var comment: String?
    @NSManaged var lastModified: Date
    @NSManaged var collectionMetadata: CollectionMetadataEntity
}
```

### ViewModels

```swift
// Collection fetch view model
@MainActor
class CollectionFetchViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: DisplayableError?
    @Published var currentVersion: TraktorVersion?
    @Published var availableVersions: [TraktorVersion] = []
    @Published var showVersionSelection = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    
    private let collectionFetchService: CollectionFetchServiceProtocol
    private let versionService: TraktorVersionServiceProtocol
    private let syncService: CollectionSyncServiceProtocol
    
    enum SyncStatus {
        case idle, syncing, completed, failed
    }
    
    func fetchCollection() async
    func checkForUpdates() async
    func switchToVersion(_ version: TraktorVersion) async
    func syncWithCoreData() async
}
```

## Implementation Steps

### Step 1: Bookmark Management
1. **Extend BookmarkStore**
   - Add methods for collection.nml bookmark
   - Implement bookmark validation
   - Add bookmark update functionality

2. **Collection Bookmark Service**
   - Create `CollectionBookmarkService`
   - Implement bookmark creation and retrieval
   - Add bookmark validation logic

### Step 2: Traktor Version Detection
1. **Version Service Implementation**
   - Create `TraktorVersionService`
   - Implement folder scanning for Traktor versions
   - Add version comparison logic

2. **Version Selection UI**
   - Create version selection dialog
   - Add version comparison display
   - Implement version switching

### Step 3: Collection Fetching
1. **Collection Fetch Service**
   - Create `CollectionFetchService`
   - Implement incremental fetching logic
   - Add last modified date tracking

2. **NML Parser Enhancement**
   - Extend existing parser for incremental updates
   - Add metadata extraction
   - Implement change detection

### Step 4: Core Data Integration
1. **Core Data Setup**
   - Create data model with TrackEntity and CollectionMetadataEntity
   - Implement Core Data stack
   - Add migration support

2. **Sync Service**
   - Create `CollectionSyncService`
   - Implement bidirectional sync
   - Add conflict resolution

### Step 5: UI Integration
1. **Collection View Updates**
   - Update CollectionView to use Core Data
   - Add sync status indicators
   - Implement progress tracking

2. **Settings Integration**
   - Add version management settings
   - Create sync preferences
   - Add manual sync controls

## File Structure

```
CrateDigging/
├── Core/
│   ├── Services/
│   │   ├── CollectionFetch/
│   │   │   ├── CollectionFetchService.swift
│   │   │   ├── CollectionFetchServiceProtocol.swift
│   │   │   └── CollectionBookmarkService.swift
│   │   ├── TraktorVersion/
│   │   │   ├── TraktorVersionService.swift
│   │   │   └── TraktorVersionServiceProtocol.swift
│   │   └── CollectionSync/
│   │       ├── CollectionSyncService.swift
│   │       └── CollectionSyncServiceProtocol.swift
│   ├── Data/
│   │   ├── CoreData/
│   │   │   ├── CrateDigging.xcdatamodeld
│   │   │   ├── CoreDataStack.swift
│   │   │   └── CoreDataManager.swift
│   │   └── Models/
│   │       ├── CollectionMetadata.swift
│   │       ├── TraktorVersion.swift
│   │       └── CollectionFetchResult.swift
│   └── ViewModels/
│       └── CollectionFetchViewModel.swift
└── Features/
    └── Collection/
        ├── View/
        │   └── CollectionView/
        │       ├── CollectionView.swift (updated)
        │       └── CollectionView+ViewModel.swift (updated)
        └── ViewModels/
            └── CollectionViewModel.swift (updated)
```

## Testing Strategy

### Unit Tests
- [ ] Bookmark creation and retrieval
- [ ] Version detection and comparison
- [ ] Incremental collection fetching
- [ ] Core Data sync operations
- [ ] Error handling scenarios

### Integration Tests
- [ ] End-to-end collection fetch
- [ ] Version switching workflow
- [ ] Core Data persistence
- [ ] Bookmark validation

### UI Tests
- [ ] Collection loading workflow
- [ ] Version selection dialog
- [ ] Sync status indicators
- [ ] Error handling UI

## Error Handling

### Common Scenarios
- [ ] Bookmark becomes stale
- [ ] Collection.nml file not found
- [ ] Permission denied
- [ ] Network issues (if applicable)
- [ ] Core Data corruption
- [ ] Version conflict resolution

### Recovery Strategies
- [ ] Automatic bookmark refresh
- [ ] Fallback to file picker
- [ ] Core Data reset option
- [ ] Manual sync trigger
- [ ] Version rollback option

## Performance Considerations

### Optimization Targets
- [ ] Initial collection load: <3 seconds
- [ ] Incremental sync: <1 second
- [ ] Version detection: <500ms
- [ ] Core Data queries: <100ms
- [ ] Memory usage: <200MB for 10k tracks

### Implementation Strategies
- [ ] Lazy loading for large collections
- [ ] Background processing for sync
- [ ] Caching for version information
- [ ] Batch operations for Core Data
- [ ] Progress indicators for long operations

## Dependencies

### External
- [ ] Core Data framework
- [ ] Foundation framework
- [ ] AppKit framework (for NSOpenPanel)

### Internal
- [ ] Existing BookmarkStore
- [ ] NML Parser
- [ ] FolderService
- [ ] DisplayableError utility

## Success Metrics

### Functional
- [ ] Successfully fetch collection from bookmarked location
- [ ] Detect and switch to new Traktor versions
- [ ] Sync collection with Core Data
- [ ] Handle incremental updates correctly
- [ ] Maintain bookmark integrity

### Performance
- [ ] Initial load completes in <3 seconds
- [ ] Incremental sync completes in <1 second
- [ ] Version detection completes in <500ms
- [ ] Memory usage stays under 200MB
- [ ] No memory leaks during sync operations

### Reliability
- [ ] 99% success rate for collection fetching
- [ ] Graceful handling of all error scenarios
- [ ] Data integrity maintained during sync
- [ ] Bookmark validation works correctly
- [ ] Version switching preserves data

## Future Enhancements

### Phase 2
- [ ] Automatic background sync
- [ ] Conflict resolution UI
- [ ] Sync history and logs
- [ ] Performance analytics
- [ ] Advanced error recovery

### Phase 3
- [ ] Multi-collection support
- [ ] Cloud sync integration
- [ ] Real-time collaboration
- [ ] Advanced versioning
- [ ] Backup and restore

## Notes

- This ticket builds upon the existing BookmarkStore and FolderService
- Core Data integration should be designed for future scalability
- Version detection should be extensible for future Traktor versions
- Error handling should provide clear user feedback
- Performance optimization is critical for large collections
