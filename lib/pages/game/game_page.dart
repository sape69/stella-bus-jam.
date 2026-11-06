
import 'dart:async';
import 'dart:math' as math;

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

class _GamePageState extends State<GamePage>
    with TickerProviderStateMixin {
  static const Duration _boardingDelay =
      Duration(milliseconds: 450);

  static const Duration _passengerAnimationDuration =
      Duration(milliseconds: 550);

  static const double _passengerAnimationArc = 55;

  late Level _level;

  late List<Bus> _buses;
  late List<Customer> _queueA;
  late List<Customer> _queueB;
  late List<Bus?> _parkingSlots;

  final int _unlockedExtraSlots = 0;

  final GlobalKey _overlayKey = GlobalKey();

  final GlobalKey _queueAFirstCustomerKey = GlobalKey();
  final GlobalKey _queueBFirstCustomerKey = GlobalKey();

  final List<GlobalKey> _busAnchorKeys =
      List.generate(5, (_) => GlobalKey());

  late final AnimationController _passengerAnimationController;

  Offset? _passengerStart;
  Offset? _passengerEnd;
  Color? _movingPassengerColor;

  bool _showMovingPassenger = false;

  bool _levelCompleted = false;
  bool _savingCompletion = false;
  bool _boardingInProgress = false;

  int _mistakes = 0;
  int _earnedStars = 0;

  @override
  void initState() {
    super.initState();

    _passengerAnimationController = AnimationController(
      vsync: this,
      duration: _passengerAnimationDuration,
    );

    _loadLevel(widget.levelNumber);
  }

  @override
  void dispose() {
    _passengerAnimationController.dispose();
    super.dispose();
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
    _boardingInProgress = false;
    _mistakes = 0;
    _earnedStars = 0;

    _showMovingPassenger = false;
    _passengerStart = null;
    _passengerEnd = null;
    _movingPassengerColor = null;
    _passengerAnimationController.reset();
  }

  Future<void> _confirmExitToHome() async {
    if (_boardingInProgress) {
      _showMessage('Please wait until passengers have boarded.');
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'EXIT TO HOME?',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to leave this level? '
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
              icon: const Icon(Icons.home_rounded),
              label: const Text('GO HOME'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _restartLevel() {
    if (_boardingInProgress) {
      return;
    }

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
    if (_boardingInProgress) {
      _showMessage('Please wait until passengers have boarded.');
      return;
    }

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
        child: Stack(
          key: _overlayKey,
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildLevelInfo(),
                  _buildStarProgress(),
                  CustomerQueues(
                    queueA: _queueA,
                    queueB: _queueB,
                    queueAFirstCustomerKey:
                        _queueAFirstCustomerKey,
                    queueBFirstCustomerKey:
                        _queueBFirstCustomerKey,
                  ),
                  ParkingArea(
                    parkingSlots: _parkingSlots,
                    unlockedExtraSlots: _unlockedExtraSlots,
                    busAnchorKeys: _busAnchorKeys,
                    onUnlockSlot: _showAdMessage,
                  ),
                  _buildBoardSection(),
                  _buildBottomInfo(),
                ],
              ),
            ),
            if (_showMovingPassenger)
              _buildPassengerAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerAnimation() {
    return AnimatedBuilder(
      animation: _passengerAnimationController,
      builder: (context, child) {
        final progress = Curves.easeInOutCubic.transform(
          _passengerAnimationController.value,
        );

        final start = _passengerStart ?? Offset.zero;
        final end = _passengerEnd ?? Offset.zero;

        final position = Offset.lerp(
          start,
          end,
          progress,
        )!;

        final arc = math.sin(progress * math.pi) *
            _passengerAnimationArc;

        final scale = 1.0 - (progress * 0.12);

        return Positioned(
          left: position.dx - 17,
          top: position.dy - 17 - arc,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _movingPassengerColor ?? AppColors.purple,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (_movingPassengerColor ?? AppColors.purple)
                  .withValues(alpha: 0.55),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Offset? _getWidgetCenter(GlobalKey key) {
    final widgetContext = key.currentContext;
    final overlayContext = _overlayKey.currentContext;

    if (widgetContext == null || overlayContext == null) {
      return null;
    }

    final widgetObject = widgetContext.findRenderObject();
    final overlayObject = overlayContext.findRenderObject();

    if (widgetObject is! RenderBox ||
        overlayObject is! RenderBox ||
        !widgetObject.hasSize ||
        !overlayObject.hasSize) {
      return null;
    }

    final globalCenter = widgetObject.localToGlobal(
      widgetObject.size.center(Offset.zero),
    );

    return overlayObject.globalToLocal(globalCenter);
  }

  Future<void> _animatePassenger(BoardingAction action) async {
    final sourceKey = action.queue == BoardingQueue.a
        ? _queueAFirstCustomerKey
        : _queueBFirstCustomerKey;

    if (action.parkingSlotIndex < 0 ||
        action.parkingSlotIndex >= _busAnchorKeys.length) {
      await Future.delayed(_boardingDelay);
      return;
    }

    // Odotetaan, että bussin pysäköintipaikka on piirretty.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    final start = _getWidgetCenter(sourceKey);
    final end = _getWidgetCenter(
      _busAnchorKeys[action.parkingSlotIndex],
    );

    if (start == null || end == null) {
      await Future.delayed(_boardingDelay);
      return;
    }

    _passengerStart = start;
    _passengerEnd = end;
    _movingPassengerColor = action.customer.color;

    setState(() {
      _showMovingPassenger = true;
    });

    _passengerAnimationController.reset();

    try {
      await _passengerAnimationController.forward().orCancel;
    } on TickerCanceled {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _showMovingPassenger = false;
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _confirmExitToHome,
            tooltip: 'Back to home',
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.purple,
              size: 27,
            ),
          ),
          const Icon(
            Icons.pets,
            color: AppColors.pink,
            size: 30,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'STELLA BUS JAM',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 17,
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
            canBusMove: _canBusMove,
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

  bool _canBusMove(Bus bus) {
    if (_levelCompleted || _boardingInProgress) {
      return false;
    }

    final busExists = _buses.any(
      (item) => item.id == bus.id,
    );

    if (!busExists) {
      return false;
    }

    final freeSlot = GameService.findFreeParkingSlot(
      _parkingSlots,
    );

    if (freeSlot == -1) {
      return false;
    }

    final otherBuses = _buses
        .where((item) => item.id != bus.id)
        .toList();

    return GameService.canBusExit(
      bus: bus,
      otherBuses: otherBuses,
      boardSize: _level.boardSize,
    );
  }

  Future<void> _onBusTap(Bus bus) async {
    if (_levelCompleted || _boardingInProgress) {
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
      _boardingInProgress = true;
      _buses.removeAt(busIndex);
      _parkingSlots[freeSlot] = bus;
    });

    await _processBoardingAnimated();

    if (!mounted) {
      return;
    }

    setState(() {
      _boardingInProgress = false;
    });

    _checkLevelCompletion();
  }

  /// Animoi jokaisen matkustajan jonosta pysäköityyn bussiin.
  /// Matkustaja poistetaan jonosta vasta animaation päätyttyä.
  Future<void> _processBoardingAnimated() async {
    final actions = GameService.createBoardingPlan(
      parkingSlots: _parkingSlots,
      queueA: _queueA,
      queueB: _queueB,
    );

    for (final action in actions) {
      if (!mounted) {
        return;
      }

      final slotIndex = action.parkingSlotIndex;

      if (slotIndex < 0 ||
          slotIndex >= _parkingSlots.length) {
        continue;
      }

      final bus = _parkingSlots[slotIndex];

      if (bus == null || bus.isFull) {
        continue;
      }

      final queue = action.queue == BoardingQueue.a
          ? _queueA
          : _queueB;

      if (queue.isEmpty ||
          queue.first.id != action.customer.id) {
        continue;
      }

      await _animatePassenger(action);

      if (!mounted) {
        return;
      }

      // Varmistetaan vielä animaation jälkeen, että
      // oikea matkustaja ja bussi ovat edelleen paikallaan.
      final currentBus = _parkingSlots[slotIndex];

      final currentQueue = action.queue == BoardingQueue.a
          ? _queueA
          : _queueB;

      if (currentBus == null ||
          currentBus.isFull ||
          currentQueue.isEmpty ||
          currentQueue.first.id != action.customer.id) {
        continue;
      }

      setState(() {
        currentQueue.removeAt(0);

        final updatedBus = currentBus.copyWith(
          passengers: currentBus.passengers + 1,
        );

        _parkingSlots[slotIndex] =
            updatedBus.isFull ? null : updatedBus;
      });

      await Future.delayed(
        const Duration(milliseconds: 120),
      );
    }
  }

  void _registerMistake(String message) {
    if (_boardingInProgress) {
      return;
    }

    setState(() {
      _mistakes++;
    });

    _showMessage('$message Mistakes: $_mistakes');
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
