import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speedodriver/core/auth/auth_controller.dart';
import 'package:speedodriver/screens/auth/login_screen.dart';
import 'package:speedodriver/screens/auth/register_screen.dart';
import 'package:speedodriver/screens/dashboard/home_screen.dart';
import 'package:speedodriver/screens/splash/splash_screen.dart';
import 'package:speedodriver/screens/profile/edit_profile_screen.dart';
import 'package:speedodriver/screens/profile/profile_screen.dart';
import 'package:speedodriver/screens/kyc/kyc_submission_screen.dart';
import 'package:speedodriver/screens/chat/booking_chat_screen.dart';
import 'package:speedodriver/screens/admin/admin_dashboard_screen.dart';
import 'package:speedodriver/screens/vehicle/add_vehicle_screen.dart';
import 'package:speedodriver/screens/wallet/wallet_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final location = state.matchedLocation;

      final isSplash = location == '/splash';
      final isAuth = location == '/login' || location == '/register';

      if (isSplash) return null;

      if (!loggedIn) {
        return isAuth ? null : '/login';
      }

      if (loggedIn && isAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Contacts'))),
      ),
      GoRoute(
        path: '/campaignlist',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Campaign List'))),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Settings'))),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const KycSubmissionScreen(),
      ),
      GoRoute(
        path: '/chat/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingChatScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/add-vehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/ledger',
        builder: (context, state) => const WalletScreen(),
      ),
    ],
  );
});
