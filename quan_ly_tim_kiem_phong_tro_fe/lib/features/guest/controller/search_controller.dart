import '../../../model/search_criteria.dart';
import '../../../model/apartment.dart';
import '../../../service/guest/search_service.dart';

class SearchController {
  final SearchService _searchService = SearchService();

  Future<List<Apartment>> search(SearchCriteria criteria) {
    return _searchService.search(criteria);
  }
}
