import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/app_router.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/screens/widgets/auth_widget.dart';


import '../blocs/auth_blocs/auth_bloc.dart';
import '../blocs/auth_blocs/auth_event.dart';
import '../blocs/auth_blocs/auth_state.dart';
import '../packeges/custom_title_bar.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return Scaffold(
      body: Column(
        children: [
          CustomTitleBar(),
          Expanded(
            child: Stack(
              children: [
                SizedBox.expand(
                  child: Image.asset("assets/image/wallpaper.png", fit:BoxFit.cover)
                ),
                Padding(
                  padding: EdgeInsets.only(right: responsive.isDesktop ? 21.h : 0),
                  child: Center(
                    child: AuthWidget(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 13.w, right: 16.h),
                    child: Text("Powered by Intelectsoft",style: GoogleFonts.poppins(
                      color: AppColors.hintTextColor,
                      fontSize: 10.sp.clamp(10, 30),
                      fontWeight: FontWeight.w300
                    ),),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

