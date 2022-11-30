// ignore_for_file: avoid_print

///At this point, we should be able to run our app and everything should work; however, there’s one more thing we can do.
//
/// One added bonus of using the bloc library is that we can have access to all Transitions in one place.
//
/// The change from one state to another is called a Transition. A Transition consists of the current state, the event, and the next state.
///
///Even though in this application we only have one bloc, it's fairly common in larger applications to have many blocs managing different parts of the application's state.
//
/// If we want to be able to do something in response to all Transitions we can simply create our own BlocObserver.

///In practice, you can create different BlocObservers and because every state change is recorded, we are able to very easily instrument our applications and track all user interactions and state changes in one place!
///
import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  ///Now every time a Bloc Transition occurs we can see the transition printed to the console
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}
