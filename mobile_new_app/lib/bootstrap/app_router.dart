import 'package:go_router/go_router.dart';

import 'home_page.dart';

/// The host app aggregates the routes each feature module exposes. Until
/// the first module exists, it holds only the host placeholder home route.
/// Global guards (`redirect` + `refreshListenable`) arrive with the
/// authentication module.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'app.home',
      builder: (_, _) => const HomePage(),
    ),
    // ...[module]ModuleRoutes, as modules are created.
  ],
);
