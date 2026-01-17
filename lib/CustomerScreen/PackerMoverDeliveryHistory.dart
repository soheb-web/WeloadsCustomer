import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/controller/getProfileController.dart'; // ← probably not needed here
import 'AllIndia/parcelListModel.dart'; // ← contains ParcelResponseListModel, ListElementParcel, etc.

class PackerMoverDeliveryHistory extends ConsumerStatefulWidget {
  const PackerMoverDeliveryHistory({super.key});

  @override
  ConsumerState<PackerMoverDeliveryHistory> createState() => _PackerMoverDeliveryHistoryState();
}

class _PackerMoverDeliveryHistoryState extends ConsumerState<PackerMoverDeliveryHistory> {
  @override
  Widget build(BuildContext context) {
    final asyncParcelList = ref.watch(getParcelListController);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "All India Parcel History",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: const Color(0xFF006970),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: asyncParcelList.when(
        data: (response) {
          if (response.error == true ||
              response.data == null ||
              response.data!.list == null ||
              response.data!.list!.isEmpty) {
            return _buildEmptyState();
          }

          final parcels = response.data!.list!;

          return RefreshIndicator(
            color: const Color(0xFF006970),
            onRefresh: () => ref.refresh(getParcelListController.future),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: parcels.length,
              itemBuilder: (context, index) {
                final parcel = parcels[index];
                return _buildParcelCard(parcel);
              },
            ),
          );
        },
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  "Something went wrong",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(getParcelListController),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
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

  Widget _buildParcelCard(ListElementParcel parcel) {
    final statusColor = _getStatusColor(parcel.status);

    final pickupLoc = parcel.pickup?.location ?? "Not specified";
    final dropoffLoc = parcel.dropoff?.location ?? "Not specified";

    final String txDisplay = parcel.txId?.isNotEmpty == true
        ? parcel.txId!
        : (parcel.id != null ? parcel.id!.substring(0, parcel.id!.length.clamp(0, 10)) : "—");

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: open detail screen
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ParcelDetailScreen(parcel: parcel)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "TXID: $txDisplay",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      parcel.status!.toUpperCase() ?? "UNKNOWN",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24, thickness: 0.8),

              // Pickup
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: const Color(0xFF006970), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pickup",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          pickupLoc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Dropoff
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Drop-off",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dropoffLoc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24, thickness: 0.8),

              // Chips row
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoChip(
                    icon: Icons.warehouse_outlined,
                    label: parcel.parcelSize?.toUpperCase() ?? "—",
                  ),
                  _InfoChip(
                    icon: Icons.monitor_weight_outlined,
                    label: parcel.weight != null ? "${parcel.weight!.value ?? "?"} ${parcel.weight!.unit ?? "kg"}" : "—",
                  ),
                  _InfoChip(
                    icon: Icons.currency_rupee_rounded,
                    label: "₹${parcel.amount ?? 0}",
                    color: const Color(0xFF006970),
                  ),
                ],
              ),

              if (parcel.goodsType != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 17, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      "Goods: ${parcel.goodsType!.toUpperCase()}",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              if (parcel.insuranceRequired == true) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.security, size: 17, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      "Insurance included",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'delivered':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              "No deliveries yet",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your parcel history will appear here once you have active or completed deliveries.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
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
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.w600,
              fontSize: 13.2,
            ),
          ),
        ],
      ),
    );
  }
}