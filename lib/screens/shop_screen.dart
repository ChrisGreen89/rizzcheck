import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';
// Remove ModernHeader import
// import '../widgets/modern_header.dart';
// Remove Bubble Background import
// import '../widgets/bubble_background_painter.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static const int driveInCost = 1250; // Define the cost
  static const int battingCageCost = 1500; // Define the cost
  static const int sodaCost = 250; // Define the cost
  static const int screenTimeCost = 250; // Define the cost

  @override
  Widget build(BuildContext context) {
    // Use watch to rebuild when points or purchase status changes
    final pointsService = context.watch<PointsService>();
    final currentPoints = pointsService.points;
    // Calculate affordability
    final bool canAffordDriveIn = currentPoints >= driveInCost;
    final bool canAffordBattingCage = currentPoints >= battingCageCost;
    final bool canAffordSoda = currentPoints >= sodaCost;
    final bool canAffordScreenTime = currentPoints >= screenTimeCost;

    return Scaffold(
      // Re-add AppBar
      appBar: AppBar(
        title: Text('RizzCheck Shop (Points: $currentPoints)'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      // Revert to simple ListView body
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Shop items remain the same
          _buildRewardCard(
            context: context,
            pointsService: pointsService,
            icon: Icons.fastfood,
            iconColor: Colors.redAccent,
            title: 'Inglewood Drive-In Dinner!',
            cost: driveInCost,
            canAfford: canAffordDriveIn,
          ),
          const SizedBox(height: 10),
          _buildRewardCard(
            context: context,
            pointsService: pointsService,
            icon: Icons.sports_baseball,
            iconColor: Colors.brown,
            title: 'Day at the Batting Cages',
            cost: battingCageCost,
            canAfford: canAffordBattingCage,
          ),
          const SizedBox(height: 10),
          _buildRewardCard(
            context: context,
            pointsService: pointsService,
            icon: Icons.local_drink,
            iconColor: Colors.blueAccent,
            title: 'Soda at Dinner',
            cost: sodaCost,
            canAfford: canAffordSoda,
          ),
          const SizedBox(height: 10),
          _buildRewardCard(
            context: context,
            pointsService: pointsService,
            icon: Icons.tv,
            iconColor: Colors.purpleAccent,
            title: '1 Hour of Screen Time',
            cost: screenTimeCost,
            canAfford: canAffordScreenTime,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 10.0),
            child: Text(
              'More Items Coming Soon...',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  // Helper method to build reward cards for consumable items
  Widget _buildRewardCard({
    required BuildContext context,
    required PointsService pointsService,
    required IconData icon,
    required Color iconColor,
    required String title,
    required int cost,
    required bool canAfford,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Price: $cost points'),
        trailing: ElevatedButton(
          onPressed: canAfford
              ? () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Purchase'),
                      content:
                          Text('Spend $cost points for the "$title" reward?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Spend Points'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    bool success = await pointsService.spendPoints(cost);
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('$title Reward Purchased! Let Dad know!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Purchase Failed! Not enough points?')),
                      );
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                canAfford ? Theme.of(context).colorScheme.primary : Colors.grey,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.withOpacity(0.5),
          ),
          child: Text(canAfford ? 'Buy' : 'Locked'),
        ),
      ),
    );
  }
}
