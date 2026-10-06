import 'package:home_widget/home_widget.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const String appGroupId = 'group.deadline_alert';
  static const String androidWidgetName = 'DeadlineWidgetReceiver';

  Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> updateWidgetData(String nextDeadlineTitle, String nextDeadlineDate) async {
    await HomeWidget.saveWidgetData<String>('deadline_title', nextDeadlineTitle);
    await HomeWidget.saveWidgetData<String>('deadline_date', nextDeadlineDate);
    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
    );
  }
}
