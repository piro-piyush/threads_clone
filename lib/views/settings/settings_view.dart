import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thread_clone/routes/route_names.dart';
import 'package:thread_clone/services/supabase_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        backgroundColor: Colors.grey[900]!,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Cancel
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Red color for destructive action
            ),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog first
              try {
                // Call Supabase logout
                await SupabaseService.client.auth.signOut();

                // Navigate to login
                Get.offAllNamed(RouteNames.login);
              } catch (e) {
                debugPrint("Logout error: $e");
                Get.snackbar("Error", "Failed to log out ❌");
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900]!,
        title: const Text("About"),
        content: const Text(
          "Threads Clone v1.0.0\n\n"
          "This is a demo app built for learning Flutter and Supabase.\n"
          "All rights reserved © 2026",
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK"))],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Help & Support"),
        backgroundColor: Colors.grey[900]!,
        content: const Text(
          "Need help? You can contact support at:\n\n"
          "support@threads_clone.com\n\n"
          "Or check FAQs for common issues.",
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: SingleChildScrollView(

        child: Column(
          children: [
            /// Account
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.person), title: const Text("Edit Profile"), subtitle: const Text("Update your name, bio, or profile picture"), onTap: () => Get.toNamed(RouteNames.editProfile)),
            ListTile(leading: const Icon(Icons.lock), title: const Text("Change Password"), subtitle: const Text("Update your password"), onTap: () => Get.toNamed(RouteNames.changePassword)),

            /// Privacy & Safety
            const Divider(),
            ListTile(leading: const Icon(Icons.privacy_tip), title: const Text("Privacy Settings"), subtitle: const Text("Manage who can see your posts"), onTap: () => Get.toNamed(RouteNames.privacy)),
            ListTile(leading: const Icon(Icons.notifications), title: const Text("Notifications"), subtitle: const Text("Control notification preferences"), onTap: () => Get.toNamed(RouteNames.notifications)),

            /// Support
            const Divider(),
            ListTile(leading: const Icon(Icons.help_outline), title: const Text("Help & Support"), subtitle: const Text("Get help or report an issue"), onTap: () => _showHelpDialog(context)),
            ListTile(leading: const Icon(Icons.info_outline), title: const Text("About"), subtitle: const Text("Version info and app details"), onTap: () => _showAboutDialog(context)),

            /// Logout
            const Divider(),
            ListTile(leading: const Icon(Icons.exit_to_app), title: const Text("Log Out"), subtitle: const Text("Sign out of your account"), onTap: () => _showLogoutDialog(context)),
          ],
        ),
      ),
    );
  }
}
