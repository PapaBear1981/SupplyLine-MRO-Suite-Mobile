# Data Architecture - Remote-First Strategy

## Overview

The SupplyLine MRO Suite Mobile app follows a **remote-first data strategy** to ensure data continuity and consistency with the main system. The app primarily communicates with the remote backend database and only uses local storage as a fallback when connectivity is unavailable.

## Architecture Principles

### 1. Remote-First Approach
- **Primary Data Source**: Remote backend API and database
- **Secondary Data Source**: Local cache (offline fallback only)
- **Data Flow**: Always attempt remote operations first, fallback to local only when necessary

### 2. Data Consistency
- Maintain single source of truth in the remote database
- Local cache serves as read-only fallback for offline scenarios
- All write operations must eventually sync with remote database
- Conflict resolution favors remote data when conflicts occur

### 3. Connectivity Handling
- Continuous network connectivity monitoring
- Graceful degradation when offline
- Automatic sync when connectivity is restored
- Clear user feedback about online/offline status

## Data Flow Patterns

### Read Operations (GET)
```
1. Check network connectivity
2. If ONLINE:
   a. Fetch data from remote API
   b. Update local cache with fresh data
   c. Display data to user
3. If OFFLINE:
   a. Check local cache for data
   b. Display cached data with offline indicator
   c. Show data age/staleness information
```

### Write Operations (POST/PUT/DELETE)
```
1. Check network connectivity
2. If ONLINE:
   a. Send request to remote API
   b. Update local cache on success
   c. Provide immediate user feedback
3. If OFFLINE:
   a. Queue operation for later sync
   b. Update local cache optimistically
   c. Show pending sync indicator
   d. Sync when connectivity restored
```

## Implementation Strategy

### API Service Layer
```dart
class ApiService {
  // Always try remote first
  Future<T> getData<T>(String endpoint) async {
    if (await isOnline()) {
      try {
        final response = await dio.get(endpoint);
        await cacheData(endpoint, response.data);
        return response.data;
      } catch (e) {
        // Fallback to cache on network error
        return await getCachedData(endpoint);
      }
    } else {
      return await getCachedData(endpoint);
    }
  }
}
```

### Cache Management
```dart
class CacheService {
  // Cache with TTL (Time To Live)
  Future<void> cacheData(String key, dynamic data) async {
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': AppConfig.cacheExpiration.inMilliseconds,
    };
    await storage.put(key, cacheItem);
  }
  
  // Check cache validity
  Future<bool> isCacheValid(String key) async {
    final item = await storage.get(key);
    if (item == null) return false;
    
    final timestamp = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
    final ttl = Duration(milliseconds: item['ttl']);
    
    return DateTime.now().difference(timestamp) < ttl;
  }
}
```

### Connectivity Monitoring
```dart
class ConnectivityService {
  Stream<bool> get connectivityStream => 
    Connectivity().onConnectivityChanged.map((result) => 
      result != ConnectivityResult.none);
  
  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

## Data Synchronization

### Sync Queue for Offline Operations
```dart
class SyncQueue {
  // Queue operations when offline
  Future<void> queueOperation(SyncOperation operation) async {
    await storage.add('sync_queue', operation.toJson());
  }
  
  // Process queue when back online
  Future<void> processSyncQueue() async {
    final queue = await storage.get('sync_queue');
    for (final operation in queue) {
      try {
        await executeOperation(operation);
        await removeFromQueue(operation);
      } catch (e) {
        // Handle sync conflicts
        await handleSyncConflict(operation, e);
      }
    }
  }
}
```

### Conflict Resolution Strategy
1. **Server Wins**: Remote data takes precedence in conflicts
2. **Timestamp Comparison**: Use last-modified timestamps when available
3. **User Notification**: Inform users of conflicts and resolution
4. **Manual Resolution**: Allow users to choose in critical conflicts

## Cache Strategy

### What to Cache
- **Tool Data**: Basic tool information, status, location
- **User Data**: Profile information, preferences
- **Static Data**: Categories, locations, user lists
- **Recent Operations**: Last 50 checkout/return operations

### What NOT to Cache
- **Sensitive Data**: Passwords, tokens (except in secure storage)
- **Real-time Data**: Live tool status changes
- **Large Files**: High-resolution images, documents
- **Temporary Data**: Search results, filters

### Cache Invalidation
- **Time-based**: TTL expiration (default: 1 hour)
- **Event-based**: Invalidate on relevant operations
- **Manual**: User-triggered refresh
- **Version-based**: API version changes

## Security Considerations

### Data Protection
- Encrypt sensitive cached data
- Use secure storage for authentication tokens
- Implement proper access controls
- Clear cache on logout

### API Security
- Always use HTTPS for remote communications
- Implement proper authentication headers
- Use certificate pinning for production
- Validate all API responses

## Performance Optimization

### Network Efficiency
- Implement request deduplication
- Use compression for large payloads
- Implement proper retry logic with exponential backoff
- Batch multiple operations when possible

### Cache Efficiency
- Implement LRU (Least Recently Used) cache eviction
- Compress cached data when appropriate
- Use background sync to minimize user wait times
- Implement smart prefetching for predictable data needs

## Monitoring and Analytics

### Key Metrics
- **Network Success Rate**: Percentage of successful API calls
- **Cache Hit Rate**: Percentage of requests served from cache
- **Sync Success Rate**: Percentage of successful offline sync operations
- **Data Freshness**: Average age of cached data when displayed

### Error Tracking
- Network connectivity issues
- API response errors
- Sync conflicts and resolutions
- Cache corruption or invalidation

## Testing Strategy

### Unit Tests
- Test API service with mocked network conditions
- Test cache service with various TTL scenarios
- Test sync queue with different conflict scenarios

### Integration Tests
- Test complete data flow from API to UI
- Test offline/online transitions
- Test sync conflict resolution

### End-to-End Tests
- Test complete user workflows
- Test data consistency across app restarts
- Test performance under various network conditions

This architecture ensures that the mobile app maintains data continuity with the remote system while providing a smooth user experience even in challenging network conditions.
