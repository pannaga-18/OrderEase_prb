import 'bill_service.dart';

// Conditional imports
import 'mobile_bill_helper.dart'
    if (dart.library.html) 'web_bill_helper.dart';

BillHelper getBillHelper() {
  return BillHelperImpl();
}
