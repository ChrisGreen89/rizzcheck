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
          // Re-apply the custom theme definition
          const defaultColorScheme = ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF00A9B7), // Tealish
            onPrimary: Colors.white,
            secondary: Color(0xFFFFC857), // Yellowish
            onSecondary: Colors.black87,
            error: Color(0xFFE53935), // Red
            onError: Colors.white,
            surface: Color(0xFFF0F4F8), // Light grey-blue
            onSurface: Color(0xFF333333), // Dark grey
            surfaceContainerHighest: Color(0xFFFFFFFF), // White for cards
            onSurfaceVariant: Color(0xFF555555), // Medium grey
          );

          final baseTextTheme = GoogleFonts.nunitoTextTheme();
          final customTextTheme = baseTextTheme.copyWith(
            // Apply default display/body colors first based on default theme
            displayLarge: baseTextTheme.displayLarge
                ?.copyWith(color: defaultColorScheme.onSurface),
            displayMedium: baseTextTheme.displayMedium
                ?.copyWith(color: defaultColorScheme.onSurface),
            displaySmall: baseTextTheme.displaySmall
                ?.copyWith(color: defaultColorScheme.onSurface),
            headlineLarge: baseTextTheme.headlineLarge?.copyWith(
                color: defaultColorScheme.onSurface), // Explicit dark
            headlineMedium: baseTextTheme.headlineMedium?.copyWith(
                color: defaultColorScheme.onSurface), // Explicit dark
            headlineSmall: baseTextTheme.headlineSmall?.copyWith(
                color: defaultColorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20), // AppBar Title - KEEP WHITE
            titleLarge: baseTextTheme.titleLarge?.copyWith(
                color: defaultColorScheme.onSurface), // Explicit dark
            titleMedium: baseTextTheme.titleMedium?.copyWith(
                color: defaultColorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16), // Task Titles - Dark
            titleSmall: baseTextTheme.titleSmall
                ?.copyWith(color: defaultColorScheme.onSurfaceVariant),
            bodyLarge: baseTextTheme.bodyLarge
                ?.copyWith(color: defaultColorScheme.onSurface),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(
                color: defaultColorScheme
                    .onSurfaceVariant), // Task Descriptions - Medium Grey
            bodySmall: baseTextTheme.bodySmall
                ?.copyWith(color: defaultColorScheme.onSurfaceVariant),
            labelLarge: baseTextTheme.labelLarge?.copyWith(
                color: defaultColorScheme
                    .onPrimary), // Button text? - White on Primary
            labelMedium: baseTextTheme.labelMedium
                ?.copyWith(color: defaultColorScheme.onSurfaceVariant),
            labelSmall: baseTextTheme.labelSmall
                ?.copyWith(color: defaultColorScheme.onSurfaceVariant),
          );

          return MaterialApp(
            title: 'Boygiene',
            theme: ThemeData(
              // Apply the custom theme components
              colorScheme: defaultColorScheme,
              textTheme: customTextTheme,
              scaffoldBackgroundColor: defaultColorScheme.surface,
              appBarTheme: AppBarTheme(
                backgroundColor: defaultColorScheme.primary,
                foregroundColor: defaultColorScheme.onPrimary,
                elevation: 0, // Flat appbar look
                centerTitle: false, // Align title to the left
                titleTextStyle:
                    customTextTheme.headlineSmall, // Use defined style
              ),
              cardTheme: CardTheme(
                elevation: 0, // Flat card look
                color:
                    defaultColorScheme.surfaceContainerHighest, // White cards
                margin:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12.0), // Slightly more rounded
                ),
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return defaultColorScheme.primary;
                  }
                  // Use a subtle grey when unchecked
                  return defaultColorScheme.onSurface.withOpacity(0.1);
                }),
                checkColor: MaterialStateProperty.all(
                    defaultColorScheme.onPrimary), // White check
                side: BorderSide(
                  // Define border color when unchecked
                  color: defaultColorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: defaultColorScheme
                        .secondary, // Use secondary color for buttons
                    foregroundColor:
                        defaultColorScheme.onSecondary, // Text color on buttons
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    textStyle: customTextTheme.labelLarge
                        ?.copyWith(color: defaultColorScheme.onSecondary)),
              ),
              dividerTheme: DividerThemeData(
                color: defaultColorScheme.onSurface.withOpacity(0.1),
                space: 1,
                thickness: 1,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: defaultColorScheme.surfaceContainerHighest,
                selectedItemColor: defaultColorScheme.primary,
                unselectedItemColor:
                    defaultColorScheme.onSurface.withOpacity(0.6),
                elevation: 4, // Give it a slight shadow
              ),
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
