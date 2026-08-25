import 'package:flutter/material.dart';
import 'package:garlic/view/screens/home_screen.dart';
import 'package:garlic/view/screens/interview_form_screen.dart';
import 'package:garlic/view/screens/interview_list_screen.dart';
import 'package:garlic/view/screens/login_screen.dart';
import 'package:garlic/view/screens/parcel_list_screen.dart';
import 'package:garlic/view/screens/parcel_map_screen.dart';
import 'package:garlic/view/screens/parcel_survey_screen.dart';
import 'package:garlic/view/screens/splash_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '마늘양파 현장조사',
      locale: const Locale('ko', 'KR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6B4F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F6B4F),
          foregroundColor: Colors.white,
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case LoginScreen.routeName:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case HomeScreen.routeName:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case InterviewListScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const InterviewListScreen(),
            );
          case InterviewFormScreen.routeName:
            final uuid = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => InterviewFormScreen(surveyUuid: uuid),
            );
          case ParcelListScreen.routeName:
            return MaterialPageRoute(builder: (_) => const ParcelListScreen());
          case ParcelMapScreen.routeName:
            return MaterialPageRoute(builder: (_) => const ParcelMapScreen());
          case ParcelSurveyScreen.routeName:
            final args = settings.arguments as ParcelSurveyArgs;
            return MaterialPageRoute(
              builder: (_) => ParcelSurveyScreen(args: args),
            );
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}

class ParcelSurveyArgs {
  final String parcelId;
  final String? surveyUuid;
  final String? address;

  ParcelSurveyArgs({
    required this.parcelId,
    this.surveyUuid,
    this.address,
  });
}
