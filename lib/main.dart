
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jojo/provider/provider.dart';
import 'package:jojo/resources/auth_check.dart';
import 'package:jojo/screens/home_screen.dart';
import 'package:jojo/screens/live_stream/screens/go_live_screen.dart';
import 'package:jojo/screens/login_screen.dart';
import 'package:jojo/screens/sign.dart';
import 'package:jojo/screens/tabs/profile.dart';
import 'package:jojo/screens/tabs/user_profile/user_profile.dart';
import 'package:jojo/models/user_model.dart' as model;
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


  void main() async {

    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await Firebase.initializeApp();

    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
      ),
    ], child: const MyApp()));
    FlutterNativeSplash.remove();
  }


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return

      MaterialApp(
        debugShowCheckedModeBanner: false,
         home:
        FutureBuilder(
          future: AuthMethod()
              .getCurrentUser(FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : null)
              .then((value) {
            if (value != null) {
              Provider.of<UserProvider>(context, listen: false).setUser(
                model.User.fromMap(value),
              );
            }
            return value;
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Container(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: Image.asset('images/Maa.png').image)
                      ),

                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasData) {
              return const HomeScreen();
            }
            return  SignUpScreen();
          },
        ),
        routes: {SignUpScreen.routeName: (context) =>  SignUpScreen(),
          LogInScreen.routeName: (context) => LogInScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          GoLiveScreen.routeName: (context) => const GoLiveScreen(),

          UserProfile.routeName: (context) =>   UserProfile(uuid: "Kuch bhi"),

        },
      );



  }
}

