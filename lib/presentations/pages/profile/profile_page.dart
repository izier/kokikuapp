import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/presentations/blocs/profile/profile_bloc.dart';
import 'package:kokiku/presentations/pages/profile/settings_page.dart';
import 'package:kokiku/presentations/widgets/no_internet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Navigate to the settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProfileAuthenticated) {
              final user = state.user;
              return Column(
                children: [
                  Row(
                    children: [
                      // Profile picture
                      ClipOval(
                        child: Image.network(
                          user.photoURL ?? '',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            user.displayName ?? 'John Doe',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Email
                          Text(
                            user.email ?? 'johndoe@example.com',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            } else if (state is ProfileUnauthenticated) {
              return Center(child: Text('Please log in.'));
            } else if (state is ProfileNoInternet) {
              return NoInternetWidget(onRefresh: () =>
                  context.read<ProfileBloc>().add(ProfileStarted()));
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            } else {
              return Center(child: Text('Unknown state.'));
            }
          },
        ),
      ),
    );
  }
}
