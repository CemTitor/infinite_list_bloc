import 'package:equatable/equatable.dart';

///We extend Equatable so that we can compare Posts. Without this, we would need to manually change our class to override equality and hashCode so that we could tell the difference between two Posts objects
class Post extends Equatable {
  final int id;
  final String title;
  final String body;

  const Post({required this.id, required this.title, required this.body});

  ///props methoduyla eğer gelen iki nesnenin herhangi bir propertysi(id,title,body) eşitse sistem, bu iki nesnenin eşit olduğu mesajını verecektir.
  @override
  List<Object> get props => [id, title, body];
}
