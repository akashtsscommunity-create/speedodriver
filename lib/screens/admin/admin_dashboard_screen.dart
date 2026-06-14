import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/supabase_providers.dart';
import '../../core/theme/app_colors.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveDeliveries = ref.watch(liveDeliveriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Lite Dashboard'),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: liveDeliveries.when(
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return const Center(child: Text('No live deliveries found.'));
          }
          return ListView.builder(
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final delivery = deliveries[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Booking ID: ${delivery['booking_id']}'),
                  subtitle: Text('Status: ${delivery['status']}\nVehicle: ${delivery['vehicle_type']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to details or map view
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unauthorized or Error: $e')),
      ),
    );
  }
}
