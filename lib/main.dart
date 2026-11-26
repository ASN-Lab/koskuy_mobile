import 'package:flutter/material.dart';
import 'package:koskuy_mobile/screens/home_screen.dart';
import 'package:koskuy_mobile/screens/kos_list_screen.dart';
import 'package:koskuy_mobile/screens/thrift_list_screen.dart';
import 'package:koskuy_mobile/screens/profile_screen.dart';
import 'package:koskuy_mobile/screens/booking_history_screen.dart';
import 'package:koskuy_mobile/screens/notification_screen.dart';
import 'package:koskuy_mobile/screens/login_screen.dart';
import 'package:koskuy_mobile/screens/register_screen.dart';
import 'package:koskuy_mobile/screens/chat_screen.dart';
import 'package:koskuy_mobile/screens/payment_screen.dart';
import 'package:koskuy_mobile/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosKuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              recipientId: args['recipientId'],
              recipientName: args['recipientName'],
            ),
          );
        }
        if (settings.name == '/payment') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PaymentScreen(
              type: args['type'],
              id: args['id'],
              title: args['title'],
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/notifications': (context) => const NotificationScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data != null ? const MainScreen() : const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    setState(() {
      _role = role;
      _loading = false;
    });
  }

  List<Widget> get _pages {
    switch (_role) {
      case 'owner':
        return const <Widget>[
          HomeScreen(),
          KosListScreen(),
          NotificationScreen(),
          ProfileScreen(),
        ];
      case 'seller':
        return const <Widget>[
          HomeScreen(),
          ThriftListScreen(),
          NotificationScreen(),
          ProfileScreen(),
        ];
      default:
        return const <Widget>[
          HomeScreen(),
          KosListScreen(),
          ThriftListScreen(),
          BookingHistoryScreen(),
          NotificationScreen(),
          ProfileScreen(),
        ];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    switch (_role) {
      case 'owner':
        return const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Kos'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
      case 'seller':
        return const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Thrift'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
      default:
        return const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Kos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Thrift'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Booking Saya'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_selectedIndex >= _pages.length) _selectedIndex = 0;

    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: BottomNavigationBar(
            items: _navItems,
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: const Color(0xFF94A3B8),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
    );
  }
}
