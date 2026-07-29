class LiveActivityPushRegistration {
  const LiveActivityPushRegistration({
    required this.activityId,
    required this.sessionId,
    required this.pushToken,
    required this.apnsEnvironment,
    required this.bundleId,
    required this.metadata,
  });

  final String activityId;
  final String sessionId;
  final String pushToken;
  final String apnsEnvironment;
  final String bundleId;
  final Map<String, dynamic> metadata;

  factory LiveActivityPushRegistration.fromPlatformMap(
    Map<dynamic, dynamic> map,
  ) {
    const reservedKeys = {
      'activityId',
      'sessionId',
      'pushToken',
      'apnsEnvironment',
      'bundleId',
    };
    return LiveActivityPushRegistration(
      activityId: map['activityId']?.toString() ?? '',
      sessionId: map['sessionId']?.toString() ?? '',
      pushToken: map['pushToken']?.toString() ?? '',
      apnsEnvironment: map['apnsEnvironment']?.toString() ?? 'production',
      bundleId: map['bundleId']?.toString() ?? '',
      metadata: {
        for (final entry in map.entries)
          if (!reservedKeys.contains(entry.key))
            entry.key.toString(): entry.value,
      },
    );
  }

  bool get isValid =>
      activityId.isNotEmpty && pushToken.isNotEmpty && bundleId.isNotEmpty;

  Map<String, dynamic> toFirestore() => {
    'activityId': activityId,
    'sessionId': sessionId,
    'pushToken': pushToken,
    'apnsEnvironment': apnsEnvironment,
    'bundleId': bundleId,
    ...metadata,
  };
}
