import 'package:doist/onBoarding/data/models/on_boarding_model.dart';
import 'package:doist/onBoarding/view_model/on_boarding_events.dart';
import 'package:doist/onBoarding/view_model/on_boarding_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc()
    : super(OnBoardingInitial(index: 0, modelList: OnBoardingModel.modelList)) {
    on<OnBoardingNext>((event, emit) {
      if (state.index < state.modelList.length - 1) {
        emit(
          OnBoardingUpdateState(
            index: state.index + 1,
            modelList: state.modelList,
          ),
        );
      } else if (state.index == state.modelList.length - 1) {
        emit(
          OnBoardingUpdateState(index: state.index, modelList: state.modelList),
        );
      }
    });
  }
}
