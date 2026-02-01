import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Home page: shows user from Cubit state; load profile (API) and sign out via Cubit.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthError) {
            return Center(child: Text(state.message));
          }
          if (state is AuthSuccess) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${state.user.id}'),
                  Text('Email: ${state.user.email}'),
                  if (state.user.displayName != null)
                    Text('Name: ${state.user.displayName}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AuthCubit>().loadUserProfile(),
                    child: const Text('Load profile (API)'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Not signed in'));
        },
      ),
    );
  }
}
