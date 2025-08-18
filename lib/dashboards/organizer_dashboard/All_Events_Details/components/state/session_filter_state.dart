import 'package:flutter/material.dart';
import '../services/session_data_service.dart';


class SessionFilterState extends ChangeNotifier {
  String? _selectedZoneId;
  String? _selectedTrackId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  bool _isLoading = false;


  String? get selectedZoneId => _selectedZoneId;
  String? get selectedTrackId => _selectedTrackId;
  List<Map<String, dynamic>> get zones => _zones;
  List<Map<String, dynamic>> get tracks => _tracks;
  bool get isLoading => _isLoading;
  bool get canCreateSession => _selectedZoneId != null && _selectedTrackId != null;


  Future<void> initialize(String eventId) async {
    _setLoading(true);
    try {
      _zones = await SessionPanelService.loadZones(eventId);
      _selectedZoneId = 'default';
      _selectedTrackId = 'default';
      _tracks = [];
      notifyListeners();
    } catch (e) {
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  Future<void> onZoneChanged(String eventId, String? zoneId) async {
    _selectedZoneId = zoneId;
    _selectedTrackId = null;
    _tracks.clear();
    notifyListeners();

    if (zoneId != null && zoneId != 'default') {
      try {
        _tracks = await SessionPanelService.loadTracks(eventId, zoneId);
        if (_tracks.isNotEmpty) {
          _selectedTrackId = _tracks.first['id'];
        }
      } catch (e) {
       
      }
    } else if (zoneId == 'default') {
      _selectedTrackId = 'default';
    }
    notifyListeners();//UI Update
  }

  
  void onTrackChanged(String? trackId) {
    _selectedTrackId = trackId;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
