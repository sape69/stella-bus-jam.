
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../pages/game/game_page.dart';
import '../../services/progress_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _unlockedLevel = 1;
  int _totalStars = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final results = await Future.wait<int>([
        ProgressService.getUnlockedLevel(),
        ProgressService.getTotalStars(),
      ]);

      if (!mounted) return;

      setState(() {
        _unlockedLevel = results[0];
        _totalStars = results[1];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openLevel(int levelNumber) async {
    if (levelNumber > _unlockedLevel) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GamePage(levelNumber: levelNumber),
      ),
    );

    if (mounted) {
      await _loadProgress();
    }
  }

  Future<void> _openLevelSelection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LevelSelectionPage(
          unlockedLevel: _unlockedLevel,
          onLevelSelected: _openLevel,
        ),
      ),
    );

    if (mounted) {
      await _loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.purple,
                ),
              )
            : RefreshIndicator(
                color: AppColors.purple,
                backgroundColor: AppColors.card,
                onRefresh: _loadProgress,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildHero(),
                      const SizedBox(height: 24),
                      _buildProgressCards(),
                      const SizedBox(height: 28),
                      _buildPlayButton(),
                      const SizedBox(height: 14),
                      _buildLevelsButton(),
                      const SizedBox(height: 28),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.6),
            ),
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: AppColors.pink,
            size: 29,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STELLA',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'BUS JAM',
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadProgress,
          tooltip: 'Refresh progress',
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pink.withValues(alpha: 0.65),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: AppColors.pink,
              size: 66,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'WELCOME TO STELLA BUS JAM!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Help the buses find their way out, '
            'pick up all passengers and collect stars!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards() {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.gold,
            value: '$_totalStars',
            label: 'TOTAL STARS',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            icon: Icons.lock_open_rounded,
            iconColor: AppColors.pink,
            value: '$_unlockedLevel',
            label: 'UNLOCKED LEVEL',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.boardBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 27,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => _openLevel(_unlockedLevel),
        icon: const Icon(
          Icons.play_arrow_rounded,
          size: 30,
        ),
        label: Text(
          'PLAY LEVEL $_unlockedLevel',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelsButton() {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _openLevelSelection,
        icon: const Icon(Icons.grid_view_rounded),
        label: const Text(
          'SELECT LEVEL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pink,
          side: const BorderSide(
            color: AppColors.purple,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Icon(
          Icons.pets_rounded,
          color: AppColors.purple,
          size: 22,
        ),
        SizedBox(height: 7),
        Text(
          'Made with love and a little bit of Stella magic',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class LevelSelectionPage extends StatelessWidget {
  final int unlockedLevel;
  final ValueChanged<int> onLevelSelected;

  const LevelSelectionPage({
    super.key,
    required this.unlockedLevel,
    required this.onLevelSelected,
  });

  static const int _visibleLevelCount = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        title: const Text(
          'SELECT LEVEL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_open_rounded,
                  color: AppColors.pink,
                ),
                const SizedBox(width: 8),
                Text(
                  '$unlockedLevel / $_visibleLevelCount levels unlocked',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _visibleLevelCount,
              itemBuilder: (context, index) {
                final levelNumber = index + 1;
                final isUnlocked = levelNumber <= unlockedLevel;

                return _LevelTile(
                  levelNumber: levelNumber,
                  isUnlocked: isUnlocked,
                  onTap: isUnlocked
                      ? () {
                          Navigator.of(context).pop();
                          onLevelSelected(levelNumber);
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.levelNumber,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: ProgressService.getStarsForLevel(levelNumber),
      builder: (context, snapshot) {
        final stars = snapshot.data ?? 0;

        return Material(
          color: isUnlocked ? AppColors.card : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? AppColors.purple.withValues(alpha: 0.65)
                      : AppColors.boardBorder.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isUnlocked)
                    Text(
                      '$levelNumber',
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  else
                    const Icon(
                      Icons.lock_rounded,
                      color: AppColors.secondaryText,
                      size: 23,
                    ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: index < stars
                            ? AppColors.gold
                            : AppColors.secondaryText.withValues(
                                alpha: 0.22,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
