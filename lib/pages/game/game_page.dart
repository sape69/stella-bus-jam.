
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/bus.dart';
import '../../models/customer.dart';
import '../../models/level.dart';
import '../../services/game_completion_service.dart';
import '../../services/game_service.dart';
import '../../services/level_service.dart';
import '../../services/passenger_boarding_service.dart';
import '../../widgets/bus_parking_animation.dart';
import '../../widgets/customer_queues.dart';
import '../../widgets/game_board_section.dart';
import '../../widgets/game_bottom_info.dart';
import '../../widgets/game_dialogs.dart';
import '../../widgets/game_header.dart';
import '../../widgets/parking_area.dart';
import '../../widgets/passenger_animation.dart';

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

  static const Duration _busParkingAnimationDuration =
      Duration(milliseconds: 650);

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

  Map<String, GlobalKey> _boardBusAnchorKeys = {};

  late final AnimationController _passengerAnimationController;
  late final AnimationController _busParkingAnimationController;

  Offset? _passengerStart;
  Offset? _passengerEnd;
  Color? _movingPassengerColor;

  Bus? _animatingBus;
  Offset? _busAnimationStart;
  Offset? _busAnimationEnd;
  Size? _busAnimationStartSize;

  static const Size _busAnimationEndSize = Size(43, 43);

  bool _showMovingPassenger = false;
  bool _showMovingBus = false;

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

    _busParkingAnimationController = AnimationController(
      vsync: this,
      duration: _busParkingAnimationDuration,
    );

    _loadLevel(widget.levelNumber);
  }

  @override
  void dispose() {
    _passengerAnimationController.dispose();
    _busParkingAnimationController.dispose();
    super.dispose();
  }

  void _loadLevel(int levelNumber) {
    _level = LevelService.createLevel(levelNumber);

    _buses = List<Bus>.from(_level.buses);
    _queueA = List<Customer>.from(_level.queueA);
    _queueB = List<Customer>.from(_level.queueB);

    _boardBusAnchorKeys = {
      for (final bus in _buses) bus.id: GlobalKey(),
    };

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

    _showMovingBus = false;
    _animatingBus = null;
    _busAnimationStart = null;
    _busAnimationEnd = null;
    _busAnimationStartSize = null;

    _passengerAnimationController.reset();
    _busParkingAnimationController.reset();
  }

  Future<void> _confirmExitToHome() async {
    if (_boardingInProgress) {
      _showMessage('Please wait until passengers have boarded.');
      return;
    }

    final shouldExit = await GameDialogs.confirmExit(context);

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

    final shouldRestart = await GameDialogs.confirmRestart(context);

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
                  GameHeader(
                    levelNumber: _level.number,
                    passengersLeft: _queueA.length + _queueB.length,
                    busesLeft: _buses.length,
                    mistakes: _mistakes,
                    onBack: _confirmExitToHome,
                    onRestart: _confirmRestart,
                  ),
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
                  GameBoardSection(
                    boardSize: _level.boardSize,
                    buses: _buses,
                    onBusTap: _onBusTap,
                    canBusMove: _canBusMove,
                    busAnchorKeys: _boardBusAnchorKeys,
                  ),
                  const GameBottomInfo(),
                ],
              ),
            ),
            if (_showMovingPassenger)
              PassengerAnimation(
                animation: _passengerAnimationController,
                start: _passengerStart,
                end: _passengerEnd,
                passengerColor: _movingPassengerColor,
              ),
            if (_showMovingBus &&
                _animatingBus != null &&
                _busAnimationStart != null &&
                _busAnimationEnd != null &&
                _busAnimationStartSize != null)
              BusParkingAnimation(
                bus: _animatingBus!,
                animation: _busParkingAnimationController,
                start: _busAnimationStart!,
                end: _busAnimationEnd!,
                startSize: _busAnimationStartSize!,
                endSize: _busAnimationEndSize,
              ),
          ],
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

  Size? _getWidgetSize(GlobalKey key) {
    final widgetContext = key.currentContext;

    if (widgetContext == null) {
      return null;
    }

    final renderObject = widgetContext.findRenderObject();

    if (renderObject is! RenderBox ||
        !renderObject.hasSize) {
      return null;
    }

    return renderObject.size;
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

    final boardAnchorKey = _boardBusAnchorKeys[bus.id];

    if (boardAnchorKey == null) {
      _showMessage('Could not locate the bus on the board.');
      return;
    }

    setState(() {
      _boardingInProgress = true;
    });

    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    final start = _getWidgetCenter(boardAnchorKey);
    final startSize = _getWidgetSize(boardAnchorKey);
    final end = _getWidgetCenter(_busAnchorKeys[freeSlot]);

    if (start == null ||
        startSize == null ||
        end == null) {
      setState(() {
        _boardingInProgress = false;
      });

      _showMessage('Could not measure the bus parking route.');
      return;
    }

    setState(() {
      _buses.removeAt(busIndex);

      _animatingBus = bus;
      _busAnimationStart = start;
      _busAnimationEnd = end;
      _busAnimationStartSize = startSize;

      _showMovingBus = true;
    });

    _busParkingAnimationController.reset();

    try {
      await _busParkingAnimationController.forward().orCancel;
    } on TickerCanceled {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _showMovingBus = false;
      _animatingBus = null;

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

  /// Siirtää matkustajien nousun käsittelyn palvelulle.
  Future<void> _processBoardingAnimated() async {
    await PassengerBoardingService.processBoarding(
      parkingSlots: _parkingSlots,
      queueA: _queueA,
      queueB: _queueB,
      isMounted: () => mounted,
      animatePassenger: _animatePassenger,
      onPassengerBoarded: (action) {
        final slotIndex = action.parkingSlotIndex;

        final queue = action.queue == BoardingQueue.a
            ? _queueA
            : _queueB;

        if (slotIndex < 0 ||
            slotIndex >= _parkingSlots.length ||
            queue.isEmpty ||
            queue.first.id != action.customer.id) {
          return;
        }

        final currentBus = _parkingSlots[slotIndex];

        if (currentBus == null || currentBus.isFull) {
          return;
        }

        setState(() {
          queue.removeAt(0);

          final updatedBus = currentBus.copyWith(
            passengers: currentBus.passengers + 1,
          );

          _parkingSlots[slotIndex] =
              updatedBus.isFull ? null : updatedBus;
        });
      },
    );
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
    _earnedStars = GameCompletionService.calculateStars(_mistakes);

    _saveCompletionAndShowDialog();
  }

  Future<void> _saveCompletionAndShowDialog() async {
    await GameCompletionService.saveAndShowDialog(
      context: context,
      levelNumber: _level.number,
      stars: _earnedStars,
      mistakes: _mistakes,
      onError: () {
        _showMessage('Could not save progress.');
      },
      onNextLevel: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _loadLevel(_level.number + 1);
        });
      },
    );

    if (!mounted) {
      return;
    }

    _savingCompletion = false;
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
