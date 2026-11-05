
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/bus.dart';
import '../../models/customer.dart';
import '../../models/level.dart';
import '../../services/game_service.dart';
import '../../services/level_service.dart';
import '../../widgets/customer_queues.dart';
import '../../widgets/game_board.dart';
import '../../widgets/parking_area.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Level _level;

  late List<Bus> _buses;
  late List<Customer> _queueA;
  late List<Customer> _queueB;

  late List<Bus?> _parkingSlots;

  final int _unlockedExtraSlots = 0;

  bool _levelCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadLevel(1);
  }

  void _loadLevel(int levelNumber) {
    _level = LevelService.createLevel(levelNumber);

    _buses = List<Bus>.from(_level.buses);
    _queueA = List<Customer>.from(_level.queueA);
    _queueB = List<Customer>.from(_level.queueB);

    _parkingSlots = List<Bus?>.filled(
      GameService.parkingSlots + _unlockedExtraSlots,
      null,
    );

    _levelCompleted = false;
  }

  void _restartLevel() {
    setState(() {
      _loadLevel(_level.number);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Level restarted!'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _confirmRestart() async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'RESTART LEVEL?',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to start this level again? '
            'Your current progress in this level will be lost.',
            style: TextStyle(
              color: AppColors.primaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('RESTART'),
            ),
          ],
        );
      },
    );

    if (shouldRestart == true && mounted) {
      _restartLevel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildHeader(),
              _buildLevelInfo(),
              CustomerQueues(
                queueA: _queueA,
                queueB: _queueB,
              ),
              ParkingArea(
                parkingSlots: _parkingSlots,
                unlockedExtraSlots: _unlockedExtraSlots,
                onUnlockSlot: _showAdMessage,
              ),
              _buildBoardSection(),
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pets,
            color: AppColors.pink,
            size: 30,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'STELLA BUS JAM',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _confirmRestart,
            tooltip: 'Restart level',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.pink,
              size: 27,
            ),
          ),
          _buildLevelBadge(),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.purple,
        ),
      ),
      child: Text(
        'LEVEL ${_level.number}',
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLevelInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_alt_rounded,
            color: AppColors.pink,
            size: 19,
          ),
          const SizedBox(width: 7),
          Text(
            '${_queueA.length + _queueB.length} PASSENGERS LEFT',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${_buses.length} BUSES LEFT',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 4,
              bottom: 10,
            ),
            child: Text(
              'BUS PUZZLE',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          GameBoard(
            boardSize: _level.boardSize,
            buses: _buses,
            onBusTap: _onBusTap,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.gold,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Guide the buses out and collect the passengers!',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBusTap(Bus bus) {
    if (_levelCompleted) {
      return;
    }

    final busIndex = _buses.indexWhere(
      (item) => item.id == bus.id,
    );

    if (busIndex == -1) {
      return;
    }

    final freeSlot = GameService.findFreeParkingSlot(
      _parkingSlots,
    );

    if (freeSlot == -1) {
      _showMessage('Parking is full!');
      return;
    }

    final otherBuses = _buses
        .where((item) => item.id != bus.id)
        .toList();

    final canExit = GameService.canBusExit(
      bus: bus,
      otherBuses: otherBuses,
      boardSize: _level.boardSize,
    );

    if (!canExit) {
      _showMessage('The bus exit is blocked!');
      return;
    }

    setState(() {
      _buses.removeAt(busIndex);
      _parkingSlots[freeSlot] = bus;
      _processBoarding();
    });

    _checkLevelCompletion();
  }

  void _processBoarding() {
    final result = GameService.processBoarding(
      parkingSlots: _parkingSlots,
      queueA: _queueA,
      queueB: _queueB,
    );

    _parkingSlots = result.parkingSlots;
    _queueA = result.queueA;
    _queueB = result.queueB;
  }

  void _checkLevelCompletion() {
    final completed = GameService.isLevelComplete(
      remainingBuses: _buses,
      parkingSlots: _parkingSlots,
      queueA: _queueA,
      queueB: _queueB,
    );

    if (!completed || _levelCompleted) {
      return;
    }

    _levelCompleted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _showLevelCompletedDialog();
    });
  }

  void _showLevelCompletedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'LEVEL COMPLETED!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Great job! All buses and passengers have been cleared.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                setState(() {
                  _loadLevel(_level.number + 1);
                });
              },
              child: const Text('NEXT LEVEL'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showAdMessage(int slotNumber) {
    _showMessage(
      'Slot $slotNumber: rewarded ad integration will be added later.',
    );
  }
}
