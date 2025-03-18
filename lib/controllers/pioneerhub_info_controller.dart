import 'package:hive/hive.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/models/pioneerhub_info.dart';
import 'dart:convert';

class PioneerHubInfoController {
  final ApiService apiService;

  PioneerHubInfoController({required this.apiService});

  Future<void> fetchAndSavePioneerHubInfo() async {
    try {
      final response = await apiService.get('/pioneerhub_info.php');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        final pioneerHubInfoList = data.map((item) => PioneerHubInfo.fromJson(item)).toList();
        // Save data to Hive
        var box = Hive.box('pioneerHubInfoBox');
        await box.put('pioneerHubInfo', pioneerHubInfoList);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}