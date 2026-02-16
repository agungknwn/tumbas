import '../models/summaries.dart';
import '../config/constants.dart';
import 'api_service.dart';

class SummariesService {
  final ApiService _api = ApiService();

  // Register get summary service
  Future<Summaries> getSummaries({
    required String userId,
    required String type,
    required String dateString,
  }) async {
    final response = await _api.get(
      ApiConstants.getSummaries(
        userId: userId,
        type: type,
        dateString: dateString,
      ),
    );

    if (response != null) {
      // print("Summaries From JSON: ${Summaries.fromJson(response)}");
      return Summaries.fromJson(response);
    } else {
      throw Exception('Get Summaries failed');
    }
  }
}
