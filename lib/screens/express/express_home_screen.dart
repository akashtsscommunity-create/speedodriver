import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/google_location.dart';
import '../../widgets/time_picker_dialog.dart';
import 'edit_location_screen.dart';
import '../../state/supabase_providers.dart';

class Stop {
  final int id;
  GoogleLocation? location;
  bool showReceiverDetails;
  String receiverName;
  String receiverPhone;

  Stop({
    required this.id,
    this.location,
    this.showReceiverDetails = false,
    this.receiverName = '',
    this.receiverPhone = '',
  });
}

class VehicleType {
  final String name;
  final String capacity;
  final IconData icon;
  final int basePrice;

  VehicleType({
    required this.name,
    required this.capacity,
    required this.icon,
    required this.basePrice,
  });
}

class ExpressHomeScreen extends ConsumerStatefulWidget {
  const ExpressHomeScreen({super.key});

  @override
  ConsumerState<ExpressHomeScreen> createState() => _ExpressHomeScreenState();
}

class _ExpressHomeScreenState extends ConsumerState<ExpressHomeScreen> {
  String selectedCategory = 'Household or Personal Goods';
  bool scheduleLater = false;
  List<Stop> stops = [];
  GoogleLocation? source;
  DateTime? scheduledTime;
  
  bool showSenderDetails = false;
  VehicleType? selectedVehicle;

  final Color primaryOrange = const Color(0xFFF05C14);
  final Color greenColor = const Color(0xFF00A651);
  final Color lightOrange = const Color(0xFFFFF7F2);

  final List<String> categories = [
    'Household or Personal Goods',
    'General Commercial Material',
    'E-commerce',
    'Construction',
    'Fragile',
    'More'
  ];

  final List<VehicleType> vehicleTypes = [
    VehicleType(name: '3W', capacity: 'Up to 500 kg', icon: Icons.electric_rickshaw, basePrice: 545),
    VehicleType(name: 'Mini', capacity: 'Up to 1000 kg', icon: Icons.local_shipping, basePrice: 663),
    VehicleType(name: 'Pickup', capacity: 'Up to 3000 kg', icon: Icons.airport_shuttle, basePrice: 759),
    VehicleType(name: '4T', capacity: '4 Ton', icon: Icons.local_shipping, basePrice: 1519),
    VehicleType(name: '7T', capacity: '7 Ton', icon: Icons.local_shipping, basePrice: 1702),
  ];

  @override
  void initState() {
    super.initState();
    stops = [Stop(id: 1)];
    selectedVehicle = vehicleTypes[0];
  }

  Future<void> _selectScheduleTime() async {
    final result = await showDialog<TimePickerDialogResult>(
      context: context,
      builder: (context) => const CustomTimePickerDialog(),
    );
    if (result != null) {
      setState(() {
        scheduledTime = result.untilUtc.toLocal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineSection(),
                const Divider(height: 1),
                _buildVehicleSection(),
                const Divider(height: 1),
                _buildCategorySection(),
                _buildScheduleToggle(),
                _buildBottomSummary(),
              ],
            ),
          ),
          _buildActiveDeliveries(),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTimelineItem(
            isFirst: true,
            isLast: false,
            dotColor: greenColor,
            location: source,
            label: "Pickup",
            onTap: () async {
              final loc = await Navigator.push<GoogleLocation>(
                context,
                MaterialPageRoute(builder: (_) => EditLocationScreen(initialValue: source?.areaDetails ?? "", mode: 1)),
              );
              if (loc != null) setState(() => source = loc);
            },
            onClear: () => setState(() => source = null),
            showDetails: showSenderDetails,
            onToggleDetails: () => setState(() => showSenderDetails = !showSenderDetails),
            detailsText: "Sender is someone else?",
          ),
          
          _buildAddStopTimelineItem(),

          ...stops.asMap().entries.map((entry) {
            final index = entry.key;
            final stop = entry.value;
            final isLast = index == stops.length - 1;
            return _buildTimelineItem(
              isFirst: false,
              isLast: isLast,
              dotColor: isLast ? primaryOrange : Colors.grey[400]!,
              location: stop.location,
              label: isLast ? "Drop-off" : "Stop ${index + 1}",
              onTap: () async {
                final loc = await Navigator.push<GoogleLocation>(
                  context,
                  MaterialPageRoute(builder: (_) => EditLocationScreen(initialValue: stop.location?.areaDetails ?? "", mode: 2)),
                );
                if (loc != null) setState(() => stop.location = loc);
              },
              onClear: () {
                if (stops.length > 1) {
                  setState(() => stops.removeAt(index));
                } else {
                  setState(() => stop.location = null);
                }
              },
              showDetails: stop.showReceiverDetails,
              onToggleDetails: () => setState(() => stop.showReceiverDetails = !stop.showReceiverDetails),
              detailsText: "Receiver is someone else?",
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isFirst,
    required bool isLast,
    required Color dotColor,
    required GoogleLocation? location,
    required String label,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required bool showDetails,
    required VoidCallback onToggleDetails,
    required String detailsText,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1, color: Colors.grey[300]),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onTap,
                            child: Text(
                              location?.areaDetails ?? label,
                              style: TextStyle(
                                fontSize: 13,
                                color: location == null ? Colors.grey[500] : Colors.black87,
                                fontWeight: location == null ? FontWeight.normal : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (location != null)
                          GestureDetector(
                            onTap: onClear,
                            child: Icon(Icons.cancel, size: 18, color: Colors.grey[300]),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onToggleDetails,
                    child: Row(
                      children: [
                        Icon(Icons.people_outline, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          detailsText,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  if (showDetails)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Name",
                                isDense: true,
                                border: UnderlineInputBorder(),
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Phone",
                                isDense: true,
                                border: UnderlineInputBorder(),
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                              style: const TextStyle(fontSize: 12),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStopTimelineItem() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Expanded(child: Container(width: 1, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => stops.insert(0, Stop(id: DateTime.now().millisecondsSinceEpoch))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.add, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text("Add a stop", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Select Vehicle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("7.4 km", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                padding: const EdgeInsets.only(right: 12),
                itemCount: vehicleTypes.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicleTypes[index];
                  final isSelected = selectedVehicle == vehicle;
                  return GestureDetector(
                    onTap: () => setState(() => selectedVehicle = vehicle),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? lightOrange : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(vehicle.icon, color: primaryOrange, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(vehicle.capacity, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              ],
                            ),
                          ),
                          Text("₹${vehicle.basePrice}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What are you sending?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? primaryOrange : Colors.grey[300]!, width: isSelected ? 1.5 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? primaryOrange : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (cat == "More") ...[
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? primaryOrange : Colors.grey[600]),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          const Expanded(child: Text("Schedule Later", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Switch(
            value: scheduleLater,
            onChanged: (val) {
              setState(() => scheduleLater = val);
              if (val) _selectScheduleTime();
            },
            activeColor: primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    final price = selectedVehicle?.basePrice ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 16, color: greenColor),
                  const SizedBox(width: 4),
                  Text("Pay Online", style: TextStyle(color: greenColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 2),
              Text("₹$price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("incl. GST", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              if (source == null || stops.any((s) => s.location == null)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select all locations')),
                );
                return;
              }

              try {
                final calculatedPrice = await ref.read(supabaseRepoProvider).calculatePrice(
                      7400, 
                      selectedCategory,
                    );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking Confirmed! Est: ₹${(calculatedPrice / 100).toStringAsFixed(2)}'),
                      backgroundColor: greenColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Pay ₹$price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveries() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              const Text("Active Deliveries", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.local_shipping, color: Colors.grey[300], size: 32),
                ),
                const SizedBox(height: 16),
                const Text("No active deliveries", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Book a delivery to get started", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
