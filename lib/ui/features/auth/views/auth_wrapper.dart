import 'package:flutter/material.dart';

import '../../home/views/home_view.dart';
import '../view_models/auth_view_model.dart';
import 'login_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, required this.viewModel});

  final AuthViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.currentUser != null) {
          return HomeView(viewModel: viewModel);
        }
        return LoginView(viewModel: viewModel);
      },
    );
  }
}
