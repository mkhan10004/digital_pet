import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PetScreen(),
    );
  }
}

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final TextEditingController _nameController = TextEditingController();

  String _petName = 'Pip';

  int _happiness = 50;
  int _hunger = 50;
  int _energy = 70;

  bool _gameOver = false;
  bool _hasWon = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;
  Timer? _reactionTimer;

  String _reaction = '';

  bool _isBouncing = false;
  Timer? _bounceTimer;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _gameOver || _hasWon) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_hunger + 5 <= 100) {
          _hunger += 5;
        } else {
          _hunger = 100;
          _happiness = _clampMeter(_happiness - 20);
        }
      });

      _updateOutcome();
    });
  }

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    final nextHunger = _clampMeter(_hunger - 10);

    final happinessChange = nextHunger < 30 ? -20 : 10;

    final nextHappiness = _clampMeter(_happiness + happinessChange);

    final nextEnergy = _clampMeter(_energy + 5);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
      _energy = nextEnergy;
    });

    _showReaction('🍖');
    _bouncePet();
    _updateOutcome();
  }

  void _playPet() {
    if (_gameOver || _hasWon) return;

    if (_energy < 10) {
      setState(() {
        _reaction = '💤';
      });

      _updateOutcome();
      return;
    }

    final nextHappiness = _clampMeter(_happiness + 15);
    final nextHunger = _clampMeter(_hunger + 5);
    final nextEnergy = _clampMeter(_energy - 10);

    setState(() {
      _happiness = nextHappiness;
      _hunger = nextHunger;
      _energy = nextEnergy;
    });

    _showReaction('🎾');
    _bouncePet();
    _updateOutcome();
  }

  void _restPet() {
    if (_gameOver || _hasWon) return;

    final nextEnergy = _clampMeter(_energy + 25);
    final nextHappiness = _clampMeter(_happiness - 5);
    final nextHunger = _clampMeter(_hunger + 5);

    setState(() {
      _energy = nextEnergy;
      _happiness = nextHappiness;
      _hunger = nextHunger;
    });

    _showReaction('💤');
    _updateOutcome();
  }

  void _resetPet() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _reactionTimer?.cancel();
    _bounceTimer?.cancel();

    setState(() {
      _happiness = 50;
      _hunger = 50;
      _energy = 70;

      _gameOver = false;
      _hasWon = false;

      _reaction = '';
      _isBouncing = false;
    });

    _startHungerTimer();
  }

  void _updateOutcome() {
    if (!mounted || _gameOver || _hasWon) return;

    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;

      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;

      if (!mounted || _gameOver || _happiness <= 80) {
        return;
      }

      setState(() {
        _hasWon = true;
      });

      _hungerTimer?.cancel();
    });
  }

  void _showReaction(String reaction) {
    _reactionTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _reaction = reaction;
    });

    _reactionTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      setState(() {
        _reaction = '';
      });
    });
  }

  void _bouncePet() {
    _bounceTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _isBouncing = true;
    });

    _bounceTimer = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;

      setState(() {
        _isBouncing = false;
      });
    });
  }

  void _confirmName() {
    final enteredName = _nameController.text.trim();

    if (enteredName.isEmpty) return;

    setState(() {
      _petName = enteredName;
    });

    _nameController.clear();
  }

  String get _moodLabel {
    if (_gameOver) {
      return 'Game Over';
    }

    if (_hasWon) {
      return 'Best Day Ever!';
    }

    if (_happiness > 70) {
      return 'Happy';
    }

    if (_happiness >= 30) {
      return 'Neutral';
    }

    return 'Unhappy';
  }

  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    }

    if (_happiness >= 30) {
      return Colors.yellow;
    }

    return Colors.red;
  }

  double get _petScale {
    if (_happiness > 70) {
      return 1.06;
    }

    if (_happiness < 30) {
      return 0.94;
    }

    return 1.0;
  }

  String get _petMessage {
    if (_gameOver) {
      return 'I need a rest. Please restart me!';
    }

    if (_hasWon) {
      return 'Best day ever! You took great care of me!';
    }

    if (_hunger > 80) {
      return "I'm starving!";
    }

    if (_energy < 20) {
      return 'So sleepy...';
    }

    if (_happiness <= 30) {
      return 'Play with me?';
    }

    return "Hi, I'm $_petName!";
  }

  Widget _buildMeter({
    required String label,
    required int value,
    required IconData icon,
  }) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$value',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value / 100),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 400),
              builder: (context, progress, child) {
                return LinearProgressIndicator(value: progress, minHeight: 10);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPet() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final scale = _isBouncing ? _petScale * 1.12 : _petScale;

    return AnimatedScale(
      scale: scale,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _moodColor.withOpacity(0.18),
        ),
        child: Center(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(_moodColor, BlendMode.modulate),
            child: const Text('🐶', style: TextStyle(fontSize: 115)),
          ),
        ),
      ),
    );
  }

  Widget _buildReaction() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 250),
      child: Text(
        _reaction,
        key: ValueKey(_reaction),
        style: const TextStyle(fontSize: 42),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final actionsDisabled = _gameOver || _hasWon;

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _petName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: Text(
                  _moodLabel,
                  key: ValueKey(_moodLabel),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _moodColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildPet(),

              const SizedBox(height: 8),

              SizedBox(height: 50, child: _buildReaction()),

              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: Text(
                  _petMessage,
                  key: ValueKey(_petMessage),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17),
                ),
              ),

              const SizedBox(height: 18),

              _buildMeter(
                label: 'Happiness',
                value: _happiness,
                icon: Icons.favorite,
              ),

              _buildMeter(
                label: 'Hunger',
                value: _hunger,
                icon: Icons.restaurant,
              ),

              _buildMeter(label: 'Energy', value: _energy, icon: Icons.bolt),

              const SizedBox(height: 12),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Pet name',
                  hintText: 'Enter a new name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: 'Confirm pet name',
                    icon: const Icon(Icons.check),
                    onPressed: _confirmName,
                  ),
                ),
                onSubmitted: (_) => _confirmName(),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: actionsDisabled ? null : _feedPet,
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Feed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: actionsDisabled ? null : _playPet,
                      icon: const Icon(Icons.sports_tennis),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: actionsDisabled ? null : _restPet,
                      icon: const Icon(Icons.bedtime),
                      label: const Text('Rest'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetPet,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (_gameOver)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.withOpacity(0.12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.warning_rounded, size: 35, color: Colors.red),
                      SizedBox(height: 6),
                      Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hunger reached 100 and happiness was 10 or lower.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              if (_hasWon)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.withOpacity(0.12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.emoji_events, size: 40, color: Colors.green),
                      SizedBox(height: 6),
                      Text(
                        'You Win!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Happiness stayed above 80 for three minutes.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              Text(
                'Mood: ${_moodLabel.toUpperCase()}',
                semanticsLabel: 'Current pet mood is $_moodLabel',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _reactionTimer?.cancel();
    _bounceTimer?.cancel();
    _nameController.dispose();

    super.dispose();
  }
}
