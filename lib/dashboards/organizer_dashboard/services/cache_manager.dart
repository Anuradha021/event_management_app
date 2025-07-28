class CacheManager {
  // Singleton pattern
  static final CacheManager _instance = CacheManager._internal();//private constructor to  initialize the singleton.

  factory CacheManager() => _instance;

  CacheManager._internal();//private constructor

  // In-memory cache store
  final Map<String, List<Map<String, dynamic>>> _cache = {};


  void save(String key, List<Map<String, dynamic>> data) {
    _cache[key] = data;
  }

  List<Map<String, dynamic>>? get(String key) {
    return _cache[key];
  }
  void clear(String key) {
    _cache.remove(key);
  }

  void clearAll() {
    _cache.clear();
  }
}
