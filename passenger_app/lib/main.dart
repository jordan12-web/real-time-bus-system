import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/auth_controller.dart';
import 'core/exceptions.dart';
import 'models/trip.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignore missing .env at runtime. The app can still boot without environment
    // variables when they are supplied another way.
  }
  runApp(const ProviderScope(child: PassengerApp()));
}

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Passenger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const VerificationScreen(),
    );
  }
}

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  List<Trip> _trips = [];
  String? _tripsError;
  bool _loadingTrips = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _trips = [];
      _tripsError = null;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!success || !mounted) return;
    await _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _loadingTrips = true;
      _tripsError = null;
    });

    try {
      final trips = await ref
          .read(tripRepositoryProvider)
          .listTrips(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _trips = trips;
        _loadingTrips = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _tripsError = error.message;
        _loadingTrips = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _tripsError = error.toString();
        _loadingTrips = false;
      });
    }
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    setState(() {
      _trips = [];
      _tripsError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoggedIn = authState.user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Verification'),
        actions: [
          if (isLoggedIn)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoggedIn
            ? _buildTripsView(authState)
            : _buildLoginForm(authState),
      ),
    );
  }

  Widget _buildLoginForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: authState.isLoading ? null : _login,
          child: authState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Login'),
        ),
        if (authState.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            authState.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _buildTripsView(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Signed in as ${authState.user!.email}'),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _loadingTrips ? null : _loadTrips,
          child: _loadingTrips
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Refresh Trips'),
        ),
        if (_tripsError != null) ...[
          const SizedBox(height: 12),
          Text(
            _tripsError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: _trips.isEmpty
              ? const Center(child: Text('No trips loaded yet.'))
              : ListView.builder(
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return ListTile(
                      title: Text('${trip.routeId} — ${trip.status}'),
                      subtitle: Text(
                        'Departs ${trip.departureTime.toLocal()} · '
                        '${trip.pricePerSeat} ETB/seat',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
