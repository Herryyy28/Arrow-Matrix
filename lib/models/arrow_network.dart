import 'dart:collection';
import 'arrow_direction.dart';

/// Represents a single node in a connected arrow network.
class ArrowNode {
  final String id;
  final int row;
  final int col;
  final ArrowDirection direction;
  final int length;
  final List<ArrowDirection>? pathPattern;
  final List<String> connectsToIds;
  final List<String> dependsOnIds;
  final bool isBranch;
  final bool isMerge;

  const ArrowNode({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    this.pathPattern,
    this.length = 1,
    this.connectsToIds = const [],
    this.dependsOnIds = const [],
    this.isBranch = false,
    this.isMerge = false,
  });

  List<ArrowDirection> get effectivePathPattern => pathPattern ?? [direction];

  ArrowNode copyWith({
    String? id,
    int? row,
    int? col,
    ArrowDirection? direction,
    List<ArrowDirection>? pathPattern,
    int? length,
    List<String>? connectsToIds,
    List<String>? dependsOnIds,
    bool? isBranch,
    bool? isMerge,
  }) {
    return ArrowNode(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      direction: direction ?? this.direction,
      pathPattern: pathPattern ?? this.pathPattern,
      length: length ?? this.length,
      connectsToIds: connectsToIds ?? List.from(this.connectsToIds),
      dependsOnIds: dependsOnIds ?? List.from(this.dependsOnIds),
      isBranch: isBranch ?? this.isBranch,
      isMerge: isMerge ?? this.isMerge,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'direction': direction.name,
        'pathPattern': pathPattern?.map((d) => d.name).toList(),
        'length': length,
        'connectsToIds': connectsToIds,
        'dependsOnIds': dependsOnIds,
        'isBranch': isBranch,
        'isMerge': isMerge,
      };

  factory ArrowNode.fromJson(Map<String, dynamic> json) => ArrowNode(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        direction: ArrowDirection.values.firstWhere(
          (e) => e.name == json['direction'],
          orElse: () => ArrowDirection.up,
        ),
        pathPattern: (json['pathPattern'] as List<dynamic>?)
            ?.map((e) => ArrowDirection.fromString(e as String))
            .toList(),
        length: (json['length'] as int?) ?? 1,
        connectsToIds: (json['connectsToIds'] as List<dynamic>?)?.cast<String>() ?? [],
        dependsOnIds: (json['dependsOnIds'] as List<dynamic>?)?.cast<String>() ?? [],
        isBranch: (json['isBranch'] as bool?) ?? false,
        isMerge: (json['isMerge'] as bool?) ?? false,
      );
}

/// Explicit directed dependency graph for arrow network puzzles.
class DependencyGraph {
  /// Adjacency list: node -> list of nodes that depend on it.
  final Map<String, List<String>> _adjacency = {};
  /// Reverse adjacency list: node -> list of nodes it depends on.
  final Map<String, List<String>> _dependencies = {};

  DependencyGraph();

  void addNode(String id) {
    _adjacency.putIfAbsent(id, () => []);
    _dependencies.putIfAbsent(id, () => []);
  }

  void addEdge(String fromId, String toId) {
    addNode(fromId);
    addNode(toId);
    if (!_adjacency[fromId]!.contains(toId)) {
      _adjacency[fromId]!.add(toId);
    }
    if (!_dependencies[toId]!.contains(fromId)) {
      _dependencies[toId]!.add(fromId);
    }
  }

  List<String> getDependentsOf(String nodeId) => _adjacency[nodeId] ?? [];
  List<String> getDependenciesOf(String nodeId) => _dependencies[nodeId] ?? [];

  /// Detects if the graph contains any circular dependency deadlock.
  bool hasCycle() {
    final visited = <String, bool>{};
    final recStack = <String, bool>{};

    for (final node in _adjacency.keys) {
      if (_isCyclicUtil(node, visited, recStack)) {
        return true;
      }
    }
    return false;
  }

  bool _isCyclicUtil(
    String node,
    Map<String, bool> visited,
    Map<String, bool> recStack,
  ) {
    if (recStack[node] == true) return true;
    if (visited[node] == true) return false;

    visited[node] = true;
    recStack[node] = true;

    for (final neighbor in _adjacency[node] ?? []) {
      if (_isCyclicUtil(neighbor, visited, recStack)) {
        return true;
      }
    }

    recStack[node] = false;
    return false;
  }

  /// Calculates topological dependency depth of the graph.
  int calculateDepth() {
    int maxDepth = 0;
    final inDegree = <String, int>{};

    for (final node in _adjacency.keys) {
      inDegree[node] = _dependencies[node]?.length ?? 0;
    }

    final queue = Queue<MapEntry<String, int>>();
    for (final entry in inDegree.entries) {
      if (entry.value == 0) {
        queue.add(MapEntry(entry.key, 1));
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final node = current.key;
      final depth = current.value;
      if (depth > maxDepth) maxDepth = depth;

      for (final neighbor in _adjacency[node] ?? []) {
        inDegree[neighbor] = (inDegree[neighbor] ?? 1) - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(MapEntry(neighbor, depth + 1));
        }
      }
    }

    return maxDepth;
  }
}

/// High-level Arrow Network representing interconnected arrow paths and dependencies.
class ArrowNetwork {
  final List<ArrowNode> nodes;
  final DependencyGraph graph;
  final int chainDepth;
  final int branchCount;
  final int crossingCount;
  final String? startArrowId;
  final String? keyArrowId;
  final double coverageRatio;
  final String patternFamily;

  ArrowNetwork({
    required this.nodes,
    required this.graph,
    this.chainDepth = 1,
    this.branchCount = 0,
    this.crossingCount = 0,
    this.startArrowId,
    this.keyArrowId,
    this.coverageRatio = 0.80,
    this.patternFamily = 'packed',
  });

  factory ArrowNetwork.fromNodeList(
    List<ArrowNode> nodes, {
    String? startArrowId,
    String? keyArrowId,
    double coverageRatio = 0.80,
    String patternFamily = 'packed',
  }) {
    final graph = DependencyGraph();
    int branchCount = 0;
    int mergeCount = 0;

    for (final node in nodes) {
      graph.addNode(node.id);
      if (node.connectsToIds.length > 1 || node.isBranch) branchCount++;
      if (node.dependsOnIds.length > 1 || node.isMerge) mergeCount++;

      for (final targetId in node.connectsToIds) {
        graph.addEdge(node.id, targetId);
      }
      for (final sourceId in node.dependsOnIds) {
        graph.addEdge(sourceId, node.id);
      }
    }

    final depth = graph.calculateDepth();

    return ArrowNetwork(
      nodes: nodes,
      graph: graph,
      chainDepth: depth,
      branchCount: branchCount,
      crossingCount: mergeCount,
      startArrowId: startArrowId ?? (nodes.isNotEmpty ? nodes.first.id : null),
      keyArrowId: keyArrowId ?? (nodes.isNotEmpty ? nodes.last.id : null),
      coverageRatio: coverageRatio,
      patternFamily: patternFamily,
    );
  }

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'chainDepth': chainDepth,
        'branchCount': branchCount,
        'crossingCount': crossingCount,
        'startArrowId': startArrowId,
        'keyArrowId': keyArrowId,
        'coverageRatio': coverageRatio,
        'patternFamily': patternFamily,
      };

  factory ArrowNetwork.fromJson(Map<String, dynamic> json) {
    final nodeList = (json['nodes'] as List<dynamic>?)
            ?.map((e) => ArrowNode.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ArrowNetwork.fromNodeList(
      nodeList,
      startArrowId: json['startArrowId'] as String?,
      keyArrowId: json['keyArrowId'] as String?,
      coverageRatio: (json['coverageRatio'] as num?)?.toDouble() ?? 0.80,
      patternFamily: (json['patternFamily'] as String?) ?? 'packed',
    );
  }
}
