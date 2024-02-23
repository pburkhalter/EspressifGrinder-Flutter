class Device {
  String? deviceName;
  String? deviceAddress;
  int? devicePort;
  String? deviceAuthKey;
  bool? deviceInitializedState;
  DateTime? deviceInitializedDate;
  String? deviceProductName;
  String? deviceProductManufacturer;
  String? deviceProductSerial;
  String? grindMode;
  int? singleGrindsDone;
  int? doubleGrindsDone;
  int? singleGrindDuration;
  int? doubleGrindDuration;

  Device({
    this.deviceName,
    this.deviceAddress,
    this.devicePort,
    this.deviceAuthKey,
    this.deviceInitializedState,
    this.deviceInitializedDate,
    this.deviceProductName,
    this.deviceProductManufacturer,
    this.deviceProductSerial,
    this.grindMode,
    this.singleGrindsDone,
    this.doubleGrindsDone,
    this.singleGrindDuration,
    this.doubleGrindDuration,
  });

  Device copyWith({
    String? deviceName,
    String? deviceAddress,
    int? devicePort,
    String? deviceAuthKey,
    bool? deviceInitializedState,
    DateTime? deviceInitializedDate,
    String? deviceProductName,
    String? deviceProductManufacturer,
    String? deviceProductSerial,
    String? grindMode,
    int? singleGrindsDone,
    int? doubleGrindsDone,
    int? singleGrindDuration,
    int? doubleGrindDuration,
  }) {
    return Device(
      deviceName: deviceName ?? this.deviceName,
      deviceAddress: deviceAddress ?? this.deviceAddress,
      devicePort: devicePort ?? this.devicePort,
      deviceAuthKey: deviceAuthKey ?? this.deviceAuthKey,
      deviceInitializedState:
          deviceInitializedState ?? this.deviceInitializedState,
      deviceInitializedDate:
          deviceInitializedDate ?? this.deviceInitializedDate,
      deviceProductName: deviceProductName ?? this.deviceProductName,
      deviceProductManufacturer:
          deviceProductManufacturer ?? this.deviceProductManufacturer,
      deviceProductSerial: deviceProductSerial ?? this.deviceProductSerial,
      grindMode: grindMode ?? this.grindMode,
      singleGrindsDone: singleGrindsDone ?? this.singleGrindsDone,
      doubleGrindsDone: doubleGrindsDone ?? this.doubleGrindsDone,
      singleGrindDuration: singleGrindDuration ?? this.singleGrindDuration,
      doubleGrindDuration: doubleGrindDuration ?? this.doubleGrindDuration,
    );
  }
}
