import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/screens/dashboard_screens/dashboard_bar_chart.dart';
import 'package:service_desk/screens/dashboard_screens/dashboard_bar_one.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return Scaffold(
      backgroundColor: AppColors.borderCardColor,
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: responsive.isDesktop ? 341.w : 341.w * 2,
            child: DashboardBarChart(),
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 5.h, top: 14.h, left: 14.w,),
                child: DashboardBarOne(),
              ),
          ),

        ],
      ),
    );
  }
}
