import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Account'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, size: 50, color: AppTheme.textDark),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest User',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phone ?? user?.email ?? '',
                          style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Activity Group
            _buildOptionGroup([
              _buildOption(context, Icons.shopping_bag_outlined, 'Order History', () {
                Navigator.pushNamed(context, '/orders');
              }),
              _buildOption(context, Icons.location_on_outlined, 'Saved Addresses', () {
                final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                addressProvider.fetchSavedAddresses();
                _showSavedAddresses(context);
              }),
              _buildOption(context, Icons.notifications_none, 'Notifications', () {}),
            ]),

            // Info Group
            _buildOptionGroup([
              _buildOption(context, Icons.help_outline, 'Help & Support', () {}),
              _buildOption(context, Icons.info_outline, 'About Us', () {}),
            ]),

            const SizedBox(height: 24),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showSavedAddresses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Consumer<AddressProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                if (provider.savedAddresses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text('No saved addresses yet', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: provider.savedAddresses.length,
                      separatorBuilder: (context, index) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final addr = provider.savedAddresses[index];
                        return _buildAddressItem(context, addr.id!, addr.label, addr.address);
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/checkout'); // Redirect to map for now
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('ADD NEW ADDRESS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, int id, String label, String address) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: Icon(
            label.toLowerCase() == 'home' ? Icons.home_outlined : Icons.work_outline,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 2),
              Text(address, style: const TextStyle(color: AppTheme.textLight, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
          onPressed: () {
            Provider.of<AddressProvider>(context, listen: false).deleteAddress(id);
          },
        ),
      ],
    );
  }

  Widget _buildOptionGroup(List<Widget> options) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: options,
      ),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textDark, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
