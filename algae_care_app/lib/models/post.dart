class Post {
  final String id;
  final String author;
  final String content;
  final List<String> imageUrls;
  final List<String> tags;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.author,
    required this.content,
    required this.imageUrls,
    required this.tags,
    required this.createdAt,
    this.likedBy = const [],
    this.comments = const [],
  });
}

class Comment {
  final String user;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.user,
    required this.text,
    required this.createdAt,
  });
} 