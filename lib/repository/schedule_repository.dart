import 'dart:async';
import 'dart:io';

import 'package:flutter_calendar_scheduler/model/schedule_model.dart';
import 'package:dio/dio.dart';

class ScheduleRepository {
  final _dio = Dio();

  // 안드로이드에서는 10.0.2.2가 localhost에 해당함
  final _targetUrl =
      'http://${Platform.isAndroid ? '10.0.2.2' : 'localhost'}:3000/schedule';

  //리스트 가져오기
  Future<List<ScheduleModel>> getSchedule({
    required DateTime date,
  }) async {
    final resp = await _dio.get(
      _targetUrl,
      queryParameters: {
        // Query 매개변수
        'date':
            '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      },
    );

    return resp.data // 모델 인스턴스로 데이터 매핑하기
        .map<ScheduleModel>(
          (x) => ScheduleModel.fromJson(
            json: x,
          ),
        )
        .toList();
  }

  //삭제
  Future<String> createSchedule({
    required ScheduleModel schedule,
  }) async {
    final json = schedule.toJson(); //JSON으로 변환
    final resp = await _dio.post(_targetUrl, data: json);

    return resp.data['id'];
  }

  Future<String> deleteSchedule({
    required String id,

  }) async {
    final resp = await _dio.delete(_targetUrl, data: {
      'id': id, // 삭제할 ID값
    });
    return resp.data?['id']; //삭제된 ID값 반환
  }



}
