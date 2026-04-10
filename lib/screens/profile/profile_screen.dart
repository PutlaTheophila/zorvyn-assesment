import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_state.dart';
import '../../blocs/theme/theme_event.dart';
import '../../core/constants/app_colors.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final profileBg = AppColors.adaptiveBackground(context);
    final profileCardBg = AppColors.adaptiveCard(context);
    final profileTextPrimary = AppColors.adaptiveText(context);
    final profileTextSecondary = AppColors.adaptiveSecondaryText(context);

    return Scaffold(
      backgroundColor: profileBg,
      appBar: AppBar(
        backgroundColor: profileBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            color: profileTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(child: Text('Not logged in', style: TextStyle(color: profileTextPrimary)));
          }

          final user = state.user;
          final userInitial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Profile Header - Professional Redesign
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  decoration: BoxDecoration(
                    color: profileBg,
                  ),
                  child: Column(
                    children: [
                      // Avatar with Premium Border
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                userInitial,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.income,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: profileBg,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Name & Verification Badge
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: profileTextPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Email with more subtle text
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: profileTextSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Edit button - Refined minimalist style
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeaderAction(
                            context,
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            textColor: profileTextPrimary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildHeaderAction(
                            context,
                            icon: Icons.share_outlined,
                            label: 'Share',
                            textColor: profileTextPrimary,
                            onTap: () {
                              // Share functionality
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Information
                _buildSection(
                  context,
                  title: 'Account Information',
                  titleColor: profileTextPrimary,
                  cardColor: profileCardBg,
                  children: [
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: 'Full Name',
                      value: user.name,
                      color: profileTextPrimary,
                      valueColor: profileTextPrimary,
                      secondaryTextColor: profileTextSecondary,
                    ),
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      value: user.email,
                      color: profileTextPrimary,
                      valueColor: profileTextPrimary,
                      secondaryTextColor: profileTextSecondary,
                    ),
                    _buildInfoTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Member Since',
                      value: _formatDate(user.createdAt),
                      color: profileTextSecondary,
                      valueColor: profileTextPrimary,
                      secondaryTextColor: profileTextSecondary,
                    ),
                  ],
                ),
                 const SizedBox(height: 16),
 
                 // Appearance (Theme toggle)
                 _buildSection(
                   context,
                   title: 'Appearance',
                   titleColor: profileTextPrimary,
                   cardColor: profileCardBg,
                   children: [
                     BlocBuilder<ThemeBloc, ThemeState>(
                       builder: (context, themeState) {
                         final isDark = themeState.themeMode == ThemeMode.dark;
                         return Theme(
                           data: ThemeData.dark().copyWith(
                             colorScheme: const ColorScheme.dark(
                               primary: AppColors.primary,
                             ),
                           ),
                           child: SwitchListTile(
                             secondary: Container(
                               width: 48,
                               height: 48,
                               decoration: BoxDecoration(
                                 color: (isDark ? Colors.amber : Colors.blue).withValues(alpha: 0.12),
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Icon(
                                 isDark ? Icons.dark_mode : Icons.light_mode,
                                 color: isDark ? Colors.amber : Colors.blue,
                               ),
                             ),
                             title: Text(
                               'Dark Mode',
                               style: TextStyle(
                                 fontSize: 15,
                                 fontWeight: FontWeight.w600,
                                 color: profileTextPrimary,
                               ),
                             ),
                             subtitle: Text(
                               isDark ? 'Dark theme enabled' : 'Light theme enabled',
                               style: TextStyle(fontSize: 13, color: profileTextSecondary),
                             ),
                             value: isDark,
                             onChanged: (value) {
                               context.read<ThemeBloc>().add(const ToggleTheme());
                             },
                             contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                           ),
                         );
                       },
                     ),
                   ],
                 ),
                 const SizedBox(height: 16),
 
                 // Settings & Privacy
                _buildSection(
                  context,
                  title: 'Settings & Privacy',
                  titleColor: profileTextPrimary,
                  cardColor: profileCardBg,
                  children: [
                    _buildActionTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      color: profileTextPrimary,
                      textColor: profileTextPrimary,
                      secondaryTextColor: profileTextSecondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      context,
                      icon: Icons.security_outlined,
                      title: 'Security',
                      subtitle: 'Password and authentication',
                      color: profileTextPrimary,
                      textColor: profileTextPrimary,
                      secondaryTextColor: profileTextSecondary,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        );
                      },
                    ),
                    _buildActionTile(
                      context,
                      iconWidget: SvgPicture.asset(
                        'assets/svg/notifications-light.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          profileTextPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      color: profileTextPrimary,
                      textColor: profileTextPrimary,
                      secondaryTextColor: profileTextSecondary,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Danger Zone
                _buildSection(
                  context,
                  title: 'Account Actions',
                  titleColor: profileTextPrimary,
                  cardColor: profileCardBg,
                  children: [
                    _buildActionTile(
                      context,
                      icon: Icons.logout,
                      title: 'Sign Out',
                      subtitle: 'Log out of your account',
                      color: AppColors.error,
                      textColor: AppColors.error,
                      secondaryTextColor: profileTextSecondary,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children, required Color titleColor, required Color cardColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color valueColor,
    required Color secondaryTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: iconWidget ?? Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: secondaryTextColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, {required IconData icon, required String label, required Color textColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: TextStyle(color: isDark ? Colors.white : AppColors.darkText)),
        content: Text('Are you sure you want to sign out?', style: TextStyle(color: isDark ? Colors.white70 : AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
