import '../../../model/search_criteria.dart';
import '../../../model/search_result.dart';
import '../../../service/guest/search_service.dart';

class SearchController {
  final SearchService _searchService = SearchService();

  Future<SearchResult> search(
    SearchCriteria criteria,
  ) async {

    return await _searchService.search(criteria);
  }
}