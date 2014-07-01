library rollbar.map_util;

Map<String, Object> deepMerge(Map<String, Object> first, Map<String, Object> second) {
  var result = {};
  new List()..addAll(first.keys)..addAll(second.keys)..forEach((key) {
    if (first.containsKey(key) && !second.containsKey(key)) {
      result[key] = first[key];
    } else if (!first.containsKey(key) && second.containsKey(key)) {
      result[key] = second[key];
    } else {
      if (first[key] is Iterable && second[key] is Iterable) {
        result[key] = new List()..addAll(first[key])..addAll(second[key]);
      } else if (first[key] is Map && second[key] is Map) {
        result[key] = deepMerge(first[key], second[key]);
      } else {
        result[key] = second[key];
      }
    }
  });
  return result;
}