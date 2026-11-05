
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/bus.dart';
import '../../models/customer.dart';
import '../../models/level.dart';
import '../../services/game_service.dart';
import '../../services/level_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/customer_queues.dart';
import '../../widgets/game_board.dart';
import '../../widgets/parking_area.dart';

class GamePage extends StatefulWidget {
  final int levelNumber;

  const GamePage({
    super.key,
    this.levelNumber = 1,
  });

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
  bool _savingCompletion = false;

  int _mistakes = 0;
  int _earnedStars = 0;

  @override
  void initState() {
    super.initState();
    _loadLevel(widget.levelNumber);
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
    _savingCompletion = false;
    _mistakes = 0;
    _earnedStars = 0;
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
              _buildStarProgress(),
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

  Widget _buildStarProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: 6),
          const Text(
            'MISTAKES:',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$_mistakes',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          const Text(
            '3 STARS POSSIBLE',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 11,
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
      _registerMistake('Parking is full!');
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
      _registerMistake('The bus exit is blocked!');
      return;
    }

    setState(() {
      _buses.removeAt(busIndex);
      _parkingSlots[freeSlot] = bus;
      _processBoarding();
    });

    _checkLevelCompletion();
  }

  void _registerMistake(String message) {
    setState(() {
      _mistakes++;
    });

    _showMessage('$message Mistakes: $_mistakes');
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

  int _calculateStars() {
    if (_mistakes == 0) {
      return 3;
    }

    if (_mistakes <= 2) {
      return 2;
    }

    return 1;
  }

  void _checkLevelCompletion() {
    final completed = GameService.isLevelComplete(
      remainingBuses: _buses,
      parkingSlots: _parkingSlots,
      queueA: _queueA,
      queueB: _queueB,
    );

    if (!completed || _levelCompleted || _savingCompletion) {
      return;
    }

    _levelCompleted = true;
    _savingCompletion = true;
    _earnedStars = _calculateStars();

    _saveCompletionAndShowDialog();
  }

  Future<void> _saveCompletionAndShowDialog() async {
    try {
      await ProgressService.saveLevelCompletion(
        levelNumber: _level.number,
        stars: _earnedStars,
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Could not save progress: $error');
      }
    }

    if (!mounted) {
      return;
    }

    _savingCompletion = false;
    _showLevelCompletedDialog();
  }

  Widget _buildEarnedStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.star_rounded,
            size: 38,
            color: index < _earnedStars
                ? AppColors.gold
                : AppColors.secondaryText.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEarnedStars(),
              const SizedBox(height: 12),
              Text(
                'You earned $_earnedStars out of 3 stars!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mistakes: $_mistakes',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Great job! All buses and passengers have been cleared.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryText,
                ),
              ),
            ],
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
