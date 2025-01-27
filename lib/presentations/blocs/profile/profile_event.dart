part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileStarted extends ProfileEvent {}

class ProfileLoggedOut extends ProfileEvent {}
