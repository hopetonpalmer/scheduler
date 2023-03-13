import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scheduler/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dart_date/dart_date.dart';




Future<void> main() async {
  //debugRepaintRainbowEnabled = true;
  runApp(
      const MyApp()
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        useInheritedMediaQuery: true,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        theme: ThemeData.dark(useMaterial3: true),
        //darkTheme: ThemeData.dark(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      debugShowCheckedModeBanner: false,
      title: 'Jazmine Scheduler Demo',

        // home: SafeArea(child: sfCalendar())
        // home: SafeArea(child: jzDayView())
        // home: SafeArea(child: jzWeekView())
        //  home: SafeArea(child: Scheduler(view: TimelineView(pages: 5, calendarType: CalendarType.month, intervalMinute: IntervalMinute.min15)))
        home: SafeArea(child: JzScheduler(dataSource: getDataSource(), viewType: CalendarViewType.week,
          schedulerSettings: const SchedulerSettings(
 //           locale: 'Ja_Jp'
/*            headerBackgroundColor: Colors.white,
            headerFontColor: Colors.black,
            timebarFontColor: Colors.black,
              timebarBackgroundColor: Colors.white,
              dividerLineColor: Colors.black,
              locale: 'ja_JP'*/
          ),
          dayViewSettings: const DayViewSettings(
            headerStyleName: 'dayStyle3',
            showMinutes: true,
          ),
          monthViewSettings: const MonthViewSettings(
            showWeekNumber: true,
            headerDayNameFormat: "EEEE"
        ), ))
    );
  }

  SchedulerDataSource getDataSource() {
    SchedulerDataSource result = SchedulerDataSource();
    DateTime today = DateTime.now().startOfDay.addHours(9);
    result.addAppointment(today, const Duration(minutes: 120), "test now", color: Colors.red);
    return result;
    result.addAppointment(today, const Duration(minutes: 80), "test red", color: Colors.red);
    result.addAppointment(today, const Duration(minutes: 180), "test blue", color: Colors.blue);
    result.addAppointment(DateTime(2021,12,14,3,0), const Duration(minutes: 120), "test 1", color: Colors.green);
    result.addAppointment(DateTime(2021,12,14,2,45), const Duration(minutes: 180), "test 5", color: Colors.blue);
    result.addAppointment(DateTime(2021,12,14,5,15), const Duration(minutes: 80), "test 10", color: Colors.red);

   Color color = Colors.green;
    result.addAppointment(DateTime(2021,11,22,8,45), const Duration(minutes: 120), "g1", color: color);
    result.addAppointment(DateTime(2021,11,22,6,00), const Duration(minutes: 250), "g2", color: color);
    result.addAppointment(DateTime(2021,11,22,8,30), const Duration(minutes: 120), "g3", color: color);
    result.addAppointment(DateTime(2021,11,22,9,30), const Duration(minutes: 120), "g4", color: color);
    result.addAppointment(DateTime(2021,11,22,9,17), const Duration(minutes: 140), "g5", color: color);
    result.addAppointment(DateTime(2021,11,22,10,00), const Duration(minutes: 120), "g6", color: color);
    result.addAppointment(DateTime(2021,11,22,8,00), const Duration(minutes: 75), "g7", color: color);

    color = Colors.blue;
    result.addAppointment(DateTime(2021,11,22,8,45), const Duration(minutes: 120), "b1", color: color);
    result.addAppointment(DateTime(2021,11,22,6,00), const Duration(minutes: 250), "b2", color: color);
    result.addAppointment(DateTime(2021,11,22,8,30), const Duration(minutes: 120), "b3", color: color);
    result.addAppointment(DateTime(2021,11,22,9,30), const Duration(minutes: 120), "b4", color: color);
    result.addAppointment(DateTime(2021,11,22,9,17), const Duration(minutes: 140), "b5", color: color);
    result.addAppointment(DateTime(2021,11,22,10,00), const Duration(minutes: 120), "b6", color: color);
    result.addAppointment(DateTime(2021,11,22,8,00), const Duration(minutes: 75), "b7", color: color);

    color = Colors.blueGrey;
    result.addAppointment(DateTime(2021,11,22,8,30), const Duration(minutes: 120), "l1", color: color);
    result.addAppointment(DateTime(2021,11,22,9,30), const Duration(minutes: 120), "l2", color: color);
    result.addAppointment(DateTime(2021,11,22,10,00), const Duration(minutes: 140), "l3", color: color);
    result.addAppointment(DateTime(2021,11,22,10,00), const Duration(minutes: 120),"l5", color: color);

    color = Colors.purple;
    result.addAppointment(DateTime(2021,11,22,8,30), const Duration(minutes: 120), "p1", color: color);
    result.addAppointment(DateTime(2021,11,22,9,15), const Duration(minutes: 120), "p2", color: color);
    result.addAppointment(DateTime(2021,11,22,9,15), const Duration(minutes: 60), "p3", color: color);
    result.addAppointment(DateTime(2021,11,22,9,00), const Duration(minutes: 120), "p4", color: color);
    result.addAppointment(DateTime(2021,11,22,8,00), const Duration(minutes: 75), "p5", color: color);

    color = Colors.orange;
    result.addAppointment(DateTime(2021,11,24,8,30), const Duration(minutes: 120), "1", color: color);
    result.addAppointment(DateTime(2021,11,24,9,30), const Duration(minutes: 120), "2", color: color);
    result.addAppointment(DateTime(2021,11,24,10,00), const Duration(minutes: 140), "3", color: color);
    result.addAppointment(DateTime(2021,11,24,10,00), const Duration(minutes: 120), "4", color: color);
    result.addAppointment(DateTime(2021,11,24,8,00), const Duration(minutes: 75), "5", color: color);

    color = Colors.red;
    result.addAppointment(DateTime(2021,11,26,8,30), const Duration(minutes: 320), "1R", color: color);

    return result;
  }



/*  Widget sfCalendar() {
    return  SfCalendar(view: CalendarView.workWeek, allowViewNavigation: true, timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        nonWorkingDays: <int>[
          DateTime.saturday,
          DateTime.sunday,
        ],
        timeInterval: Duration(minutes: 22),
        timeIntervalHeight: 40,
        timeFormat: 'h:mm',
        dateFormat: 'd',
        dayFormat: 'EE',
        timeRulerSize: 60),
    );
  }*/
}

