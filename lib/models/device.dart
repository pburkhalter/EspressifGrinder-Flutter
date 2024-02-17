class Device {
  String deviceName;
  String deviceAddress;
  int devicePort;

  String ?deviceAuthKey;

  bool ?deviceInitializedState;
  DateTime ?deviceInitializedDate;

  String ?deviceProductName;
  String ?deviceProductManufacturer;
  String ?deviceProductSerial;

  String ?grindMode;
  int ?singleGrindsDone;
  int ?doubleGrindsDone;
  int ?singleGrindDuration;
  int ?doubleGrindDuration;

  Device({required this.deviceName, required this.deviceAddress, required this.devicePort});
}
