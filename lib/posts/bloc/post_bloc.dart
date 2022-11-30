import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_list_bloc/posts/posts.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

///One optimization we can make is to debounce the Events in order to prevent spamming our API unnecessarily. We can do this by overriding the transform method in our PostBloc.
///We can use the debounce method from the stream_transform package to debounce the PostFetched event by 100 milliseconds.
///This will prevent the PostFetched event from being emitted if another PostFetched event is emitted within 100 milliseconds.
///Passing a transformer to on<PostFetched> allows us to customize how events are processed. ?> Note: Make sure to import package:stream_transform to use the throttle api.
EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    ///droppable meaning, ignore any events added while the stream is processing .
    ///throttle meaning, only emit an event if the previous event was emitted more than the specified duration ago. 100ms de bir önceki eventin emit edilmesinden sonra 100ms geçtiyse eventi emit et.
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched,
        transformer: throttleDroppable(throttleDuration));
  }

  final http.Client httpClient;

  ///Now every time a PostEvent is added, if it is a PostFetched event and there are more posts to fetch, our PostBloc will fetch the next 20 posts.
  Future<void> _onPostFetched(
      PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;

    ///if hasReachdMax is true, then return(meaning, exit from method).
    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();

        ///We should retun the emit() method, because if we are not returning the emit() method, then the emit() method continuesly emitting the state.With return, we are exiting from the method.
        return emit(state.copyWith(
          status: PostStatus.success,
          posts: posts,
          hasReachedMax: false,
        ));
      }

      ///If the state.status is not initial, then we are fetching the next 20 posts.
      ///We are fetching the next 20 posts by passing the state.posts.length as the starting index.
      final posts = await _fetchPosts(state.posts.length);

      ///The API will return an empty array if we try to fetch beyond the maximum number of posts (100), so if we get back an empty array, our bloc will emit the currentState except we will set hasReachedMax to true.
      emit(posts.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: PostStatus.success,

              ///Var olan postları state.posts ile alıyoruz. Yeni gelen postları da addAll(posts) ile alıyoruz. Yeni gelen postları var olan postlara ekliyoruz.
              posts: List.of(state.posts)..addAll(posts),
              hasReachedMax: false,
            ));
    } catch (_) {
      return emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    ///https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2
    final response = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        return Post(
          id: map['id'] as int,
          title: map['title'] as String,
          body: map['body'] as String,
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}

///Throttle:Programlama dünyasında ise Throttling'e en uygun örneklerden birisi, bir oyun geliştirdiğimizi düşünürsek; oyuncunun ateş etmesini zaman bazında sınırlandırma olacaktır.Örneğin her saniyede bir kez ateş etmesini istiyorsak. Throttling sayesinde oyuncu, tuşa saniye'de birden fazla bassa bile sadece bir kez ateş etme fonksiyonu çalışacaktır
///
///Debouncing: En basit haliyle bir tuş olduğunu düşünelim, bastığımızda alarm çalıştırsın, tekrar bastığımızda durdursun, bu basma işleminde bir Debouncing süresi belirlemezsek sistem sapıtarak bir basışta hem alarm'ı aç hem de kapa komutunu aynı anda göndermemize sebep olabilir.
///Basit bir arama çubuğumuz olduğunu düşünelim ve buna bir şey yazdığımızda direk olarak bize sonuçları versin. Bu noktada her harf için sunucuya istek göndermek oldukça maliyetli olacaktır. Debouncing tekniği sayesinde bunu her 1 saniye bir yaptırarak maliyeti oldukça aza düşürebiliriz.Debouncing olmadan sunucuya 5 istek gönderiyorsa debouncing ile 1 istek gönderir.
