import 'package:flutter/material.dart';

import '../services/scheduler_service.dart';

class JzStatelessWidget extends StatelessWidget {
  const JzStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    schedulerService.currentContext = context;
    return Container();
  }
}
