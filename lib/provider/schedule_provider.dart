import 'package:flutter_calendar_scheduler/database/drift_database.dart';
import 'package:flutter_calendar_scheduler/model/schedule_model.dart';
import 'package:flutter_calendar_scheduler/repository/schedule_repository.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository repository; // API 요청 로직을 담은 클래스

  DateTime selectedDate = DateTime.utc(
    //선택한 날짜
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<DateTime, List<ScheduleModel>> cache = {}; // 일정 정보를 저장해둘 변수

  ScheduleProvider({
    required this.repository,
  }) : super() {
    getSchedules(date: selectedDate);
  }

  void getSchedules({
    required DateTime date,
  }) async {
    final resp = await repository.getSchedule(date: date); //GET 메서드 보내기

    // 선택한 날짜의 일정들 업데이트하기
    cache.update(date, (value) => resp, ifAbsent: () => resp);
    notifyListeners();
  }

  // getSchedules() 함수 아래에 작성
  void createSchedule({
    required ScheduleModel schedule,
  }) async {
    final targetDate = schedule.date;

    final savedSchedule = await repository.createSchedule(schedule: schedule);

    cache.update(
      targetDate,
      (value) => [
        // 현존하는 캐시 리스트 끝에 새로운 일정 추가
        ...value,
        schedule.copyWith(
          id: savedSchedule,
        ),
      ]..sort(
          (a, b) => a.startTime.compareTo(
            b.startTime,
          ),
        ),
      ifAbsent: () => [schedule],
    );

    notifyListeners();
  }


  //삭제
  void deleteSchedule({
    required DateTime date,
    required String id,
  }) async {
    final resp = await repository.deleteSchedule(id: id);

    cache.update(
      date,
      (value) => value.where((e) => e.id != id).toList(),
      ifAbsent: () => [],
    );
    notifyListeners();
}

}
