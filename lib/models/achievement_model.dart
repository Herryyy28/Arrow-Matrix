import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<AchievementModel> allAchievements = [
    AchievementModel(
      id: 'first_step',
      title: 'First Step',
      description: 'Clear your very first puzzle level.',
      icon: Icons.flag_rounded,
    ),
    AchievementModel(
      id: 'levels_10',
      title: 'Getting Started',
      description: 'Complete 10 levels in Classic mode.',
      icon: Icons.filter_1_rounded,
    ),
    AchievementModel(
      id: 'levels_25',
      title: 'Puzzle Apprentice',
      description: 'Reach and solve 25 levels.',
      icon: Icons.filter_2_rounded,
    ),
    AchievementModel(
      id: 'levels_50',
      title: 'Mind Strategist',
      description: 'Conquer 50 arrow puzzles.',
      icon: Icons.psychology_rounded,
    ),
    AchievementModel(
      id: 'levels_100',
      title: 'Centurion Solver',
      description: 'Complete 100 levels!',
      icon: Icons.workspace_premium_rounded,
    ),
    AchievementModel(
      id: 'perfect_run',
      title: 'Flawless Mind',
      description: 'Complete a level with zero mistakes.',
      icon: Icons.star_rounded,
    ),
    AchievementModel(
      id: 'perfect_10',
      title: 'Precision Master',
      description: 'Achieve 10 perfect zero-mistake runs.',
      icon: Icons.auto_awesome_rounded,
    ),
    AchievementModel(
      id: 'streak_7',
      title: '7-Day Streak',
      description: 'Play daily challenge 7 days in a row.',
      icon: Icons.local_fire_department_rounded,
    ),
    AchievementModel(
      id: 'streak_30',
      title: '30-Day Legend',
      description: 'Maintain a 30-day streak.',
      icon: Icons.whatshot_rounded,
    ),
    AchievementModel(
      id: 'master_world',
      title: 'Master World',
      description: 'Unlock and reach the Master World.',
      icon: Icons.military_tech_rounded,
    ),
  ];
}
