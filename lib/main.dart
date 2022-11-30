import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list_bloc/app.dart';
import 'package:infinite_list_bloc/simple_bloc_observer.dart';

///we’ve successfully separated our presentation layer from our business logic.
///Our PostsPage has no idea where the Posts are coming from or how they are being retrieved. Conversely, our PostBloc has no idea how the State is being rendered, it simply converts events into states
void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(const App());

  ///EquatableConfig.stringify = kDebugMode; is a constant that affects the output of toString. When in debug mode, equatable's toString method will behave differently than profile and release mode and can use constants like kDebugMode or kReleaseMode to understand if you are running on debug or release.
}
