
Map<String, dynamic> toJSON(Map<String, dynamic> map) {
  // Create a new map to store the updated values
  Map<String, dynamic> updatedMap = {};

  map.forEach((key, value) {
    if (value is DateTime) {
      // Convert DateTime value to ISO 8601 string
      updatedMap[key] = value.toIso8601String();
    } else {
      // Keep the original value
      updatedMap[key] = value;
    }
  });

  return updatedMap;
}