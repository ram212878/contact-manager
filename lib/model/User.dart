class User {
  int? id;
  String? name;
  String? contact;
  String? image;

  userMap() {
    var mapping = <String, dynamic>{};
    mapping['id'] = id ?? null;
    mapping['name'] = name!;
    mapping['contact'] = contact!;
    mapping['image'] = image!;
    return mapping;
  }
}
