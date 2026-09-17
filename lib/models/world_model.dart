import 'package:flutter/material.dart';

class WorldModel {
  final int id;
  final String name;
  final String description;
  final int startLevel;
  final int endLevel;
  final IconData icon;
  final Color primaryColor;

  const WorldModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startLevel,
    required this.endLevel,
    required this.icon,
    required this.primaryColor,
  });

  static const List<WorldModel> allWorlds = [
    WorldModel(
      id: 1,
      name: 'TIER 1: FOUNDATION NETWORKS',
      description: 'Levels 1–50: Direct chains & basic arrow relationships.',
      startLevel: 1,
      endLevel: 50,
      icon: Icons.hub_rounded,
      primaryColor: Colors.teal,
    ),
    WorldModel(
      id: 2,
      name: 'TIER 2: PLANNING NETWORKS',
      description: 'Levels 51–100: Branching paths & forward decision planning.',
      startLevel: 51,
      endLevel: 100,
      icon: Icons.account_tree_rounded,
      primaryColor: Colors.blue,
    ),
    WorldModel(
      id: 3,
      name: 'TIER 3: INTERLOCKING NETWORKS',
      description: 'Levels 101–200: Path crossings & merge points.',
      startLevel: 101,
      endLevel: 200,
      icon: Icons.alt_route_rounded,
      primaryColor: Colors.cyan,
    ),
    WorldModel(
      id: 4,
      name: 'TIER 4: BRANCHING MECHANICS',
      description: 'Levels 201–300: Switch & gate interlocked networks.',
      startLevel: 201,
      endLevel: 300,
      icon: Icons.toggle_on_rounded,
      primaryColor: Colors.indigo,
    ),
    WorldModel(
      id: 5,
      name: 'TIER 5: DEEP DEPENDENCIES',
      description: 'Levels 301–400: Multi-key & lock dependency graphs.',
      startLevel: 301,
      endLevel: 400,
      icon: Icons.key_rounded,
      primaryColor: Colors.purple,
    ),
    WorldModel(
      id: 6,
      name: 'TIER 6: MULTI-STATE NETWORKS',
      description: 'Levels 401–500: Dynamic moving wall network traps.',
      startLevel: 401,
      endLevel: 500,
      icon: Icons.view_quilt_rounded,
      primaryColor: Colors.deepPurple,
    ),
    WorldModel(
      id: 7,
      name: 'TIER 7: ADVANCED MECHANICS',
      description: 'Levels 501–600: Portal-connected multi-layer webs.',
      startLevel: 501,
      endLevel: 600,
      icon: Icons.all_inclusive_rounded,
      primaryColor: Colors.amber,
    ),
    WorldModel(
      id: 8,
      name: 'TIER 8: MULTI-CHAIN NETWORKS',
      description: 'Levels 601–700: Parallel interacting sub-graph chains.',
      startLevel: 601,
      endLevel: 700,
      icon: Icons.grain_rounded,
      primaryColor: Colors.orange,
    ),
    WorldModel(
      id: 9,
      name: 'TIER 9: EXPERT NETWORKS',
      description: 'Levels 701–850: Dense multi-branch interlock topologies.',
      startLevel: 701,
      endLevel: 850,
      icon: Icons.psychology_rounded,
      primaryColor: Colors.deepOrange,
    ),
    WorldModel(
      id: 10,
      name: 'TIER 10: MASTER NETWORKS',
      description: 'Levels 851–1000+: Deepest global board dependency mastery.',
      startLevel: 851,
      endLevel: 1000,
      icon: Icons.workspace_premium_rounded,
      primaryColor: Colors.redAccent,
    ),
  ];

  static WorldModel getWorldForLevel(int levelNumber) {
    for (final world in allWorlds) {
      if (levelNumber >= world.startLevel && levelNumber <= world.endLevel) {
        return world;
      }
    }
    return allWorlds.last;
  }
}
