import 'package:flutter/material.dart';
import 'package:flutter_calendar_scheduler/component/main_calendar.dart';
import 'package:flutter_calendar_scheduler/component/schedule_card.dart';
import 'package:flutter_calendar_scheduler/component/today_banner.dart';
import 'package:flutter_calendar_scheduler/component/schedule_bottom_sheet.dart';
import 'package:flutter_calendar_scheduler/const/colors.dart';
import 'package:provider/provider.dart'; // Provider 불러오기
import 'package:flutter_calendar_scheduler/provider/schedule_provider.dart';


class HomeScreen extends StatelessWidget {
  DateTime selectedDate = DateTime.utc( // 선택된 날짜를 관리할 변수
    DateTime
        .now()
        .year,
    DateTime
        .now()
        .month,
    DateTime
        .now()
        .day,
  );


  @override
  Widget build(BuildContext context) {
    // 프로바이더 변경아 있을 때 마다 build() 함수 재실행
    final provider = context.watch<ScheduleProvider>();
    // 선탹된 날짜 가져오기
    final selectedDate = provider.selectedDate;
    // 선택된 날짜에 해당하는 일정들 가져오기
    final schedules = provider.cache[selectedDate] ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true, // 배경 탭 했을 때 BottomSheet 닫기
            builder: (_) =>
                ScheduleBottomSheet(
                  selectedDate: selectedDate, //선택한 날짜 (selectDate) 넘겨주기
                ),
            // BottomSheet의 높이를  화면의 최대 높이로
            // 정의하고 스크롤 가능하게 변경
            isScrollControlled: true,
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: SafeArea( // 시스템 UI 피해서  UI 구현하기
          child: Column( // 달력과 리스트를 세로로 배치
            children: [
            //  미리 작업해둔 달력 위젯 보여주기
            MainCalendar(
            selectedDate: selectedDate, // 선택된 날짜 전달하기
            //날짜가 선택됐을 때 실행할 함수
            onDaySelected: (selectedDate, focusedDate) =>
              onDaySelected(selectedDate, focusedDate, context),
          ),
          SizedBox(height: 8.0),
          TodayBanner(
              selectedDate: selectedDate,
              count: schedules.length
          ),


          SizedBox(height: 8.0),
          Expanded(
            child : ListView.builder(
          // 리스트에 입력할 값들의 총 개수
          itemCount: schedules.length,
            itemBuilder: (context, index) {
              // 현재 index에 해당하는 일정
              final schedule = schedules[index];
              return Dismissible(
                key: ObjectKey(schedule.id),
                // 밀기방햐야(오른쪽에서 왼쪽으로)
                direction: DismissDirection.startToEnd,
                // 밀기 했을 때 실행할 함수
                onDismissed: (DismissDirection direction) {
                  provider.deleteSchedule(date: selectedDate, id: schedule.id);

                },
                child: Padding( // 좌우로 패딩을 추가해서 UI 개선
                  padding: const EdgeInsets.only(
                      bottom: 8.0, left: 8.0, right: 8.0),
                  child: ScheduleCard(
                    startTime: schedule.startTime,
                    endTime: schedule.endTime,
                    content: schedule.content,
                  ),
                ),
              );
            },
          ),


      ),

      ],
    ),)
    ,
    );
  }

  void onDaySelected(
      DateTime selectedDate,
      DateTime focusedDate,
      BuildContext context,
      ) {
    final provider = context.read<ScheduleProvider>();
    provider.changeSelectedDate(
      date: selectedDate,
    );
    provider.getSchedules(date: selectedDate);
    // 날짜 선택될 때마다 실행할 함수

  }
}