import 'package:doist/onBoarding/data/models/on_boarding_model.dart';
import 'package:equatable/equatable.dart';

sealed class OnBoardingState extends Equatable {
  final int index;
  final List<OnBoardingModel> modelList;

  const OnBoardingState({required this.index, required this.modelList});
}

class OnBoardingInitial extends OnBoardingState {
  const OnBoardingInitial({required super.index, required super.modelList});

  @override
  List<Object?> get props => [index, modelList];
}

class OnBoardingUpdateState extends OnBoardingState {
  const OnBoardingUpdateState({required super.index, required super.modelList});
  
  @override
  List<Object?> get props => [index, modelList];
}
