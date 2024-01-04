import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GlobalUtils {
  // static const idOffset = 100000;
  static final dateFormat = DateFormat('yyyy-MM-dd');
  static final timeFormat = DateFormat('hh:mm a');

  static final _numberFormat =
      NumberFormat("#,##0.00", Get.locale?.languageCode ?? "en");
  static String getMoney(money) {
    var formatedString = _numberFormat.format(money);
    return '$formatedString '; // this end space just to show the 0 in print properly
  }
}
