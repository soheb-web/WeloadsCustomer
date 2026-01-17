import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/controller/getProfileController.dart';
import 'AllIndia/AllIndiaParselListModel.dart';


class AllIndiaDeliveryHistory extends ConsumerStatefulWidget {
  const AllIndiaDeliveryHistory({super.key});

  @override
  ConsumerState<AllIndiaDeliveryHistory> createState() => _AllIndiaDeliveryHistoryState();
}

class _AllIndiaDeliveryHistoryState extends ConsumerState<AllIndiaDeliveryHistory> {
  @override
  Widget build(BuildContext context) {
    final asyncBookings = ref.watch(getAllIndiaController);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Packer Mover History",
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
        backgroundColor: const Color(0xFF006970),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: asyncBookings.when(
        data: (response) {
          if (response.error == true || response.data == null || response.data!.isEmpty) {
            return _buildEmptyState();
          }

          final bookings = response.data!;

          return RefreshIndicator(
            color: const Color(0xFF006970),
            onRefresh: () => ref.refresh(getAllIndiaController.future),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(bookings[index]);
              },
            ),
          );
        },
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 72, color: Colors.red.shade400),
                const SizedBox(height: 20),
                Text(
                  "Failed to load bookings",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(getAllIndiaController),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF006970),
                    side: const BorderSide(color: Color(0xFF006970)),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006970)),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(DatumAllIndia booking) {
    final statusColor = _getStatusColor(booking.status);

    final pickupLoc = booking.pickup?.location?.trim().isNotEmpty == true
        ? booking.pickup!.location!
        : "Location not specified";

    final dropoffLoc = booking.dropoff?.location?.trim().isNotEmpty == true
        ? booking.dropoff!.location!
        : "Location not specified";

    final String txDisplay = booking.txId?.isNotEmpty == true
        ? booking.txId!
        : (booking.id != null && booking.id!.length >= 8
        ? booking.id!.substring(booking.id!.length - 8)
        : "—");

    String formattedDate = "—";
    if (booking.createdAt != null && booking.createdAt! > 1000000000) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(booking.createdAt!);
        formattedDate =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      } catch (_) {}
    }

    final itemsSummary = _buildItemsSummary(booking.product ?? []);

    final pickupFloor = booking.pickup?.florNo ?? 0;
    final dropoffFloor = booking.dropoff?.florNo ?? 0;
    final serviceAvailable = booking.pickup?.serviceListAvailable ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: detail screen later
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Booking • $txDisplay",
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Placed on $formattedDate",
                          style: TextStyle(fontSize: 12.8, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      (booking.status?.name ?? "UNKNOWN").toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.7),
              const SizedBox(height: 16),

              // Pickup
              _LocationRow(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF006970),
                title: "Pickup",
                address: pickupLoc,
                floor: pickupFloor,
              ),

              const SizedBox(height: 20),

              // Dropoff
              _LocationRow(
                icon: Icons.flag_outlined,
                iconColor: Colors.red.shade700,
                title: "Drop-off",
                address: dropoffLoc,
                floor: dropoffFloor,
              ),

              if (itemsSummary.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(height: 1, thickness: 0.7),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Items",
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            itemsSummary,
                            style: const TextStyle(fontSize: 14.5, height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoChip(
                    icon: Icons.local_shipping_outlined,
                    label: serviceAvailable ? "Service Available" : "Availability Check Required",
                    color: serviceAvailable ? const Color(0xFF006970) : Colors.orange.shade800,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildItemsSummary(List<Product> products) {
    if (products.isEmpty) return "No items listed";

    final Map<String, int> countMap = {};

    for (final p in products) {
      final name = (p.item ?? "Unknown item").trim();
      countMap[name] = (countMap[name] ?? 0) + (p.quantity ?? 1);
    }

    return countMap.entries.map((e) {
      return e.value > 1 ? "${e.value} × ${e.key}" : e.key;
    }).join(" • ");
  }

  Color _getStatusColor(Status? status) {
    switch (status) {
      case Status.pending:
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              "No All-India Bookings",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your inter-city or all-India packer & mover bookings will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for location rows
class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String address;
  final int floor;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.address,
    required this.floor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14.5, height: 1.3, fontWeight: FontWeight.w500),
              ),
              if (floor > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.stairs, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      "$floor${floor == 1 ? 'st' : floor == 2 ? 'nd' : floor == 3 ? 'rd' : 'th'} Floor",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF006970);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: chipColor, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}