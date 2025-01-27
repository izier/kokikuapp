import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc() : super(ProfileLoading()) {
    on<ProfileStarted>((event, emit) async {
      emit(ProfileLoading());

      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(ProfileNoInternet());
        return;
      }

      try {
        // Wait for the authStateChanges stream to emit a value
        final user = await _auth.authStateChanges().first;
        if (user == null) {
          emit(ProfileUnauthenticated());
        } else {
          emit(ProfileAuthenticated(user));
        }
      } catch (e) {
        emit(ProfileError('Failed to load profile'));
      }
    });

    on<ProfileLoggedOut>((event, emit) async {
      try {
        await _auth.signOut();
        emit(ProfileUnauthenticated());
      } catch (e) {
        emit(ProfileError('Failed to log out'));
      }
    });
  }
}
