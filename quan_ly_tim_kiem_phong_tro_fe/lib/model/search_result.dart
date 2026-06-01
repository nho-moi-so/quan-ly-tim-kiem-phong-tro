import 'post.dart';
import 'apartment.dart';

class SearchResult {
  final List<Post> posts;
  final List<Apartment> apartments;

  SearchResult({
    required this.posts,
    required this.apartments,
  });
}