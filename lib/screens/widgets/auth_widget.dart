import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/app_router.dart';
import 'package:service_desk/blocs/auth_blocs/auth_bloc.dart';
import 'package:service_desk/blocs/auth_blocs/auth_state.dart';
import 'package:service_desk/const/const_widget_border.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/services/auth_service.dart';

import '../../blocs/auth_blocs/auth_event.dart';
import '../../const/const_colors.dart';
import '../../data_base/repository/dictionaries_repository.dart';
import '../../services/hub_connecter.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authService: AuthService(), userRepository: UserRepository()),
      child: AuthWidgetUI(),
    );
  }
}

class AuthWidgetUI extends StatefulWidget {
  const AuthWidgetUI({super.key});

  @override
  State<AuthWidgetUI> createState() => _AuthWidgetUIState();
}

class _AuthWidgetUIState extends State<AuthWidgetUI> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _buttonFocus = FocusNode();
  bool rememberMe = false;
  bool isLoading = false;
  bool _obscureText = true;
@override
  void initState() {
//  context.read<AuthBloc>().add(CheckAuthStatus());
    super.initState();
  }
  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    _buttonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state){
        if (state is AuthAuthenticated) {
          HubConnecterR.instance.restartConnection();
          DictionariesRepository().loadAll(apiKey: state.token).catchError((e) {
            debugPrint('Failed to load dictionaries: $e');
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.home,
                  (route) => false,
            );
          });
        }
      },

      builder: (context, state) {
        final isError = state is AuthFailure;
        final isLoading = state is AuthLoading;
        return isLoading ?
        CircularProgressIndicator()
            : Container(
          width: responsive.isDesktop ? 406.w : double.infinity,
          height: responsive.isDesktop ? 400.h : double.maxFinite,
          decoration: BoxDecoration(
            color: AppColors.backgroundCardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: BoxBorder.all(color: AppColors.borderCardColor, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10.r,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 24.h, bottom: 40.h),
                  child: Text(
                    "Service Desk",
                    style: GoogleFonts.brunoAceSc(
                      fontSize: 40.sp.clamp(30, 40),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColorOne,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LOGIN LABEL
                    Padding(
                      padding: EdgeInsets.only(left: 21.w),
                      child: Text(
                        "Log in",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp.clamp(12, 24),
                          color: AppColors.textColorOne,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // LOGIN INPUT
                    SizedBox(
                      width: responsive.isDesktop ? 374.w : 1100.w,
                      height: responsive.isDesktop ? 48.h : 48.h,
                      child: TextField(
                        focusNode: _loginFocus,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                        controller: loginController,
                        cursorColor: AppColors.borderCardColor,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundColor,
                          focusColor: AppColors.backgroundColor,
                          hoverColor: AppColors.backgroundColor,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16.h, // отступ сверху/снизу
                            horizontal: 20.w, // отступ слева/справа
                          ),
                          hintText: "Nume de utilizator",
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.hintTextColor,
                            fontSize: 10.sp.clamp(10, 15),
                            fontWeight: FontWeight.w300,
                          ),
                          border: isError ? AppBorder.borderErrorInput : AppBorder.borderTextInput,
                          errorBorder: isError
                              ? AppBorder.borderErrorInput  // 👈 если ошибка — красная рамка
                              : AppBorder.borderTextInput,
                          focusedBorder: isError ? AppBorder.borderErrorInput : AppBorder.borderTextInput,
                          enabledBorder: isError ? AppBorder.borderErrorInput : AppBorder.borderTextInput,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: responsive.isDesktop ? 374.w : 1100.w,
                      height: responsive.isDesktop ? 48.h : 48.h,
                      child: TextField(
                        focusNode: _passwordFocus,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_buttonFocus);
                        },
                        controller: passwordController,
                        cursorColor: AppColors.borderCardColor,
                        textAlign: TextAlign.left,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundColor,
                          focusColor: AppColors.backgroundColor,
                          hoverColor: AppColors.backgroundColor,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16.h, // отступ сверху/снизу
                            horizontal: 20.w, // отступ слева/справа
                          ),
                          hintText: "Parola",
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.hintTextColor,
                            fontSize: 10.sp.clamp(10, 15),
                            fontWeight: FontWeight.w300,
                          ),
                          border: isError ? AppBorder.borderErrorInput : AppBorder.borderTextInput,
                          errorBorder: isError
                              ? AppBorder.borderErrorInput  // 👈 если ошибка — красная рамка
                              : AppBorder.borderTextInput,
                          focusedBorder: isError ? AppBorder.borderErrorInput : AppBorder.borderTextInput,
                          enabledBorder: isError ? AppBorder.borderErrorInput : AppBorder.borderTextInput,
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.w, left: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              checkColor: AppColors.hintTextColor,
                              side: BorderSide(
                                color: AppColors.hintTextColor, // твой цвет
                                width: 2.w,
                              ),
                              // 👇 Цвет заливки когда checked
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.transparent; // цвет когда включён
                                }
                                return Colors.transparent; // цвет когда выключен
                              }),
                              value: rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  rememberMe = !rememberMe;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 8.w,),
                          SizedBox(
                            width: responsive.isDesktop ? 180.w : 460.w,
                            height: responsive.isDesktop ? 16.h : 48.h,
                            child: Text("Reține parola", style: GoogleFonts.poppins(
                              fontSize: 10.sp.clamp(10, 20),
                              fontWeight: FontWeight.w300,
                              color: AppColors.textColorOne
                            ),),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight, // или .center / .centerRight
                child: InkWell(
                  focusNode: _buttonFocus,
                  onTap: () {
                    context.read<AuthBloc>().add(LoginRequested(
                      login: loginController.text,
                      password: passwordController.text,
                        savePass: rememberMe
                    ));
                  },
                  borderRadius: BorderRadius.circular(100.r),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  child: Container(
                    width: responsive.isDesktop ? 179.w : 537.w,
                    height: responsive.isDesktop ? 48.h : 48.h,
                    margin: EdgeInsets.only(right: 16.w, top: 40.h, bottom: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.btColor,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Center(
                      child: Text("Autentificare", style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp.clamp(16, 32),
                        color: AppColors.backgroundCardColor
                      ),),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
