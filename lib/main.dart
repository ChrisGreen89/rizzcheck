import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'providers/hygiene_provider.dart';
import 'services/notification_service.dart';
import 'services/points_service.dart';
import 'screens/home_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services BEFORE runApp
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize PointsService (it loads its own data)
  final PointsService pointsService = PointsService();

  // Run the app, passing initialized services
  runApp(MyApp(
      prefs: prefs,
      notificationService: notificationService,
      pointsService: pointsService));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final NotificationService notificationService;
  final PointsService pointsService;

  const MyApp({
    super.key,
    required this.prefs,
    required this.notificationService,
    required this.pointsService,
  });

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide initialized services
    return MultiProvider(
      providers: [
        // Provide initialized instances directly
        Provider<SharedPreferences>.value(value: prefs),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider<PointsService>.value(value: pointsService),

        // HygieneProvider depends on the others
        ChangeNotifierProvider<HygieneProvider>(
          create: (context) => HygieneProvider(
            context.read<SharedPreferences>(), // Read SharedPreferences
            context.read<NotificationService>(), // Read NotificationService
            context.read<PointsService>(), // Read PointsService
          ),
          // If HygieneProvider needs initialization that depends on context or other providers
          // you might add lazy: false and call an init method here, or handle in constructor.
        ),
      ],
      // Consumer/Selector is no longer needed here for theme
      child: Builder(
        // Use Builder to get context below providers
        builder: (context) {
          // Define a new "pre-teen" light theme
          const lightColorScheme = ColorScheme(
            brightness: Brightness.light,
            primary: Colors.deepOrange, // Vibrant Orange
            onPrimary: Colors.white, // Text on Orange
            secondary: Colors.blue, // Complementary Blue
            onSecondary: Colors.white, // Text on Blue
            error: Colors.redAccent,
            onError: Colors.white,
            surface: Colors.white, // Clean white background
            onSurface: Color(0xFF333333), // Dark Grey text
            surfaceContainerHighest:
                Color(0xFFF5F5F5), // Very light grey for cards/appbar
            onSurfaceVariant: Color(0xFF666666), // Medium Grey text
          );

          final baseTextTheme = GoogleFonts.nunitoTextTheme();
          // Adjust text theme for light background
          final lightTextTheme = baseTextTheme.copyWith(
            displayLarge: baseTextTheme.displayLarge
                ?.copyWith(color: lightColorScheme.onSurface),
            displayMedium: baseTextTheme.displayMedium
                ?.copyWith(color: lightColorScheme.onSurface),
            displaySmall: baseTextTheme.displaySmall
                ?.copyWith(color: lightColorScheme.onSurface),
            headlineLarge: baseTextTheme.headlineLarge
                ?.copyWith(color: lightColorScheme.onSurface),
            headlineMedium: baseTextTheme.headlineMedium
                ?.copyWith(color: lightColorScheme.onSurface),
            headlineSmall: baseTextTheme.headlineSmall?.copyWith(
                color: lightColorScheme.onPrimary, // White text on AppBar
                fontWeight: FontWeight.bold,
                fontSize: 20),
            titleLarge: baseTextTheme.titleLarge?.copyWith(
                color: lightColorScheme.onSurface), // Headers - Dark Grey
            titleMedium: baseTextTheme.titleMedium?.copyWith(
                color: lightColorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16), // Task Titles - Dark Grey
            titleSmall: baseTextTheme.titleSmall
                ?.copyWith(color: lightColorScheme.onSurfaceVariant),
            bodyLarge: baseTextTheme.bodyLarge
                ?.copyWith(color: lightColorScheme.onSurface),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(
                color: lightColorScheme
                    .onSurfaceVariant), // Task Descriptions - Medium Grey
            bodySmall: baseTextTheme.bodySmall
                ?.copyWith(color: lightColorScheme.onSurfaceVariant),
            labelLarge: baseTextTheme.labelLarge?.copyWith(
                color: lightColorScheme
                    .onSecondary), // Button text - White on Blue
            labelMedium: baseTextTheme.labelMedium
                ?.copyWith(color: lightColorScheme.onSurfaceVariant),
            labelSmall: baseTextTheme.labelSmall
                ?.copyWith(color: lightColorScheme.onSurfaceVariant),
          );

          return MaterialApp(
            title: 'RizzCheck',
            theme: ThemeData(
              colorScheme: lightColorScheme,
              textTheme: lightTextTheme,
              scaffoldBackgroundColor: lightColorScheme.surface,
              appBarTheme: AppBarTheme(
                backgroundColor: lightColorScheme.primary, // Orange AppBar BG
                foregroundColor:
                    lightColorScheme.onPrimary, // Icons on App Bar (White)
                elevation: 1, // Give slight elevation back
                shadowColor: Colors.black.withOpacity(0.1),
                centerTitle: false,
                titleTextStyle: lightTextTheme
                    .headlineSmall, // Uses white text defined above
              ),
              cardTheme: CardTheme(
                elevation: 0.5, // Subtle elevation
                color: lightColorScheme
                    .surfaceContainerHighest, // Very light grey cards
                margin:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Less rounded
                  side: BorderSide(
                      color: Colors.black.withOpacity(0.05)), // Subtle border
                ),
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return lightColorScheme.primary; // Orange when checked
                  }
                  return lightColorScheme.onSurface
                      .withOpacity(0.1); // Light grey unchecked box
                }),
                checkColor: MaterialStateProperty.all(
                    lightColorScheme.onPrimary), // White check
                side: BorderSide(
                  // Define border color when unchecked
                  color: lightColorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: lightColorScheme.secondary, // Blue buttons
                    foregroundColor:
                        lightColorScheme.onSecondary, // White text on buttons
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    textStyle: lightTextTheme
                        .labelLarge // Uses white text defined above
                    ),
              ),
              dividerTheme: DividerThemeData(
                color: lightColorScheme.onSurface.withOpacity(0.1),
                space: 1,
                thickness: 1,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: lightColorScheme.surfaceContainerHighest,
                selectedItemColor: lightColorScheme.primary, // Orange selected
                unselectedItemColor:
                    lightColorScheme.onSurface.withOpacity(0.6),
                elevation: 2, // Give it a slight shadow
              ),
              useMaterial3: true,
            ),
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}
