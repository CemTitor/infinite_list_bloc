part of 'post_bloc.dart';

enum PostStatus { initial, success, failure }

class PostState extends Equatable {
  const PostState(
      {this.status = PostStatus.initial,
      this.posts = const <Post>[],
      this.hasReachedMax = false});

  final PostStatus status;
  final List<Post> posts;
  final bool hasReachedMax;

  ///Bu sınıftan üretilen farklı farklı nesnelerin karşılaştırılmasını burdaki parametrelere(status,posts,hasReachedMax) bakarak yapabilirim. Yani sınıftan üretilen nesneleri karşılaştırırken NEYİ BAZ alıcaz.
  @override
  List<Object> get props => [status, posts, hasReachedMax];

  ///Statei güncelleme, yeni bir state objesinin akışa dahil edilmesiyle yapılıyor.
  ///Var olan objenin değiştiğini veya içindeki bazı alanların değiştiğini ,yeni bir nesne üretileceğini copyWith ile belirtiyoruz.
  ///We implemented copyWith so that we can copy an instance of PostSuccess and update zero or more properties conveniently.
  PostState copyWith({
    PostStatus? status,
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return PostState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  String toString() {
    return 'PostState{status: $status, posts: ${posts.length}, hasReachedMax: $hasReachedMax}';
  }
}
