import 'package:equatable/equatable.dart';

sealed class OnBoardingEvent extends Equatable{}

class OnBoardingNext extends OnBoardingEvent {
  @override
  List<Object?> get props => [];
}