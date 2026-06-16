import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/admin/screens/feirantes_screen.dart';
import '../../features/admin/screens/create_feirante_screen.dart';
import '../../features/admin/screens/barracas_screen.dart';
import '../../features/admin/screens/relatorios_screen.dart';
import '../../features/feirante/screens/feirante_home_screen.dart';
import '../../features/feirante/screens/produtos_screen.dart';
import '../../features/feirante/screens/create_produto_screen.dart';
import '../../features/feirante/screens/estoque_screen.dart';
import '../../features/feirante/screens/vendas_screen.dart';
import '../../features/feirante/screens/create_venda_screen.dart';
import '../../features/feirante/screens/venda_detalhe_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // Admin
    GoRoute(path: '/admin', builder: (_, __) => const AdminHomeScreen()),
    GoRoute(
        path: '/admin/feirantes',
        builder: (_, __) => const FeirantesScreen()),
    GoRoute(
        path: '/admin/feirantes/novo',
        builder: (_, __) => const CreateFeiranteScreen()),
    GoRoute(
        path: '/admin/barracas',
        builder: (_, __) => const BarracasScreen()),
    GoRoute(
        path: '/admin/relatorios',
        builder: (_, __) => const RelatoriosScreen()),

    // Feirante
    GoRoute(path: '/feirante', builder: (_, __) => const FeiranteHomeScreen()),
    GoRoute(
        path: '/feirante/produtos',
        builder: (_, __) => const ProdutosScreen()),
    GoRoute(
        path: '/feirante/produtos/novo',
        builder: (_, __) => const CreateProdutoScreen()),
    GoRoute(
        path: '/feirante/estoque',
        builder: (_, __) => const EstoqueScreen()),
    GoRoute(
        path: '/feirante/vendas',
        builder: (_, __) => const VendasScreen()),
    GoRoute(
        path: '/feirante/vendas/nova',
        builder: (_, __) => const CreateVendaScreen()),
    GoRoute(
        path: '/feirante/vendas/:id',
        builder: (_, state) =>
            VendaDetalheScreen(vendaId: state.pathParameters['id']!)),
  ],
);
