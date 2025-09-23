import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/menu_app_controller.dart';
import '../../features/home/presentation/screens/homescreen.dart';
import '../../responsive.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            const Expanded(
              flex: 5,
              child: HomeScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
