import 'package:flutter/material.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class AlertHistoryModel {
  final String id;
  final String title;
  final String date;
  final String address;
  final String duration;
  final bool hasVideo;
  final bool hasAudio;
  final String thumbnail;

  const AlertHistoryModel({
    required this.id,
    required this.title,
    required this.date,
    required this.address,
    required this.duration,
    required this.hasVideo,
    required this.hasAudio,
    required this.thumbnail,
  });
}

class AlertsProvider extends ChangeNotifier {
  // Tabs: 0 = Active, 1 = History
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  void selectTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }


  // History Filter
  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // History list matching the design
  final List<AlertHistoryModel> _alertHistoryItems = const [
    AlertHistoryModel(
      id: '1',
      title: 'SOS Alert',
      date: 'Today, 10:32 AM',
      address: '1200 Park Ave,\nNew York, NY 10028,\nUSA',
      duration: '02:45',
      hasVideo: true,
      hasAudio: true,
      thumbnail: ImageAssets.historyVideoThumbnail,
    ),
    AlertHistoryModel(
      id: '2',
      title: 'SOS Alert',
      date: '10.02.2026',
      address: '1200 Park Ave,\nNew York, NY 10028,\nUSA',
      duration: '02:45',
      hasVideo: true,
      hasAudio: true,
      thumbnail: ImageAssets.historyVideoThumbnail,
    ),
    AlertHistoryModel(
      id: '3',
      title: 'SOS Alert',
      date: '10.02.2026',
      address: '1200 Park Ave,\nNew York, NY 10028,\nUSA',
      duration: '02:45',
      hasVideo: true,
      hasAudio: true,
      thumbnail: ImageAssets.historyVideoThumbnail,
    ),
    AlertHistoryModel(
      id: '4',
      title: 'SOS Alert',
      date: '10.02.2026',
      address: '1200 Park Ave,\nNew York, NY 10028,\nUSA',
      duration: '02:45',
      hasVideo: true,
      hasAudio: true,
      thumbnail: ImageAssets.historyVideoThumbnail,
    ),
    AlertHistoryModel(
      id: '5',
      title: 'SOS Alert',
      date: '10.02.2026',
      address: '1200 Park Ave,\nNew York, NY 10028,\nUSA',
      duration: '02:45',
      hasVideo: true,
      hasAudio: true,
      thumbnail: ImageAssets.historyVideoThumbnail,
    ),
  ];

  List<AlertHistoryModel> get historyAlerts => _alertHistoryItems;
}
