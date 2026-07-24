enum ExperienceType { event, activity }

enum ItemType { ticket, session }

ExperienceType _expType(String s) {
  return ExperienceType.values.firstWhere((e) => e.name == s);
}

ItemType _itemType(String s) {
  return ItemType.values.firstWhere((e) => e.name == s);
}

class Experience {
  String id, status, organizerId;
  ExperienceType type;
  BasicInfo basicInfo;
  Location location;
  ExperienceDetails details;
  List<ExperienceItem> items;
  CheckoutConfig? checkoutConfig;
  Metadata? metadata;
  Experience({
    required this.id,
    required this.type,
    required this.status,
    required this.organizerId,
    required this.basicInfo,
    required this.location,
    required this.details,
    required this.items,
    this.checkoutConfig,
    this.metadata,
  });
  factory Experience.fromJson(Map<String, dynamic> j) => Experience(
    id: j["id"],
    type: _expType(j["type"]),
    status: j["status"],
    organizerId: j["organizerId"],
    basicInfo: BasicInfo.fromJson(j["basicInfo"]),
    location: Location.fromJson(j["location"]),
    details: ExperienceDetails.fromJson(j["details"]),
    items: (j["items"] as List).map((e) => ExperienceItem.fromJson(e)).toList(),
    checkoutConfig: j["checkoutConfig"] == null
        ? null
        : CheckoutConfig.fromJson(j["checkoutConfig"]),
    metadata: j["metadata"] == null ? null : Metadata.fromJson(j["metadata"]),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type.name,
    "status": status,
    "organizerId": organizerId,
    "basicInfo": basicInfo.toJson(),
    "location": location.toJson(),
    "details": details.toJson(),
    "items": items.map((e) => e.toJson()).toList(),
    "checkoutConfig": checkoutConfig?.toJson(),
    "metadata": metadata?.toJson(),
  };

  void operator [](int other) {}
}

class BasicInfo {
  String title, slug, description, category;
  Media media;
  List<String> tags;
  BasicInfo({
    required this.title,
    required this.slug,
    required this.description,
    required this.category,
    required this.media,
    required this.tags,
  });
  factory BasicInfo.fromJson(Map<String, dynamic> j) => BasicInfo(
    title: j["title"],
    slug: j["slug"],
    description: j["description"],
    category: j["category"],
    media: Media.fromJson(j["media"]),
    tags: List<String>.from(j["tags"] ?? []),
  );
  Map<String, dynamic> toJson() => {
    "title": title,
    "slug": slug,
    "description": description,
    "category": category,
    "media": media.toJson(),
    "tags": tags,
  };
}

class Media {
  String thumbnail, banner;
  Media({required this.thumbnail, required this.banner});
  factory Media.fromJson(Map<String, dynamic> j) =>
      Media(thumbnail: j["thumbnail"], banner: j["banner"]);
  Map<String, dynamic> toJson() => {"thumbnail": thumbnail, "banner": banner};
}

class Location {
  String mode;
  PhysicalLocation? physical;
  VirtualLocation? virtual;
  Location({required this.mode, this.physical, this.virtual});
  factory Location.fromJson(Map<String, dynamic> j) => Location(
    mode: j["mode"],
    physical: j["physical"] == null
        ? null
        : PhysicalLocation.fromJson(j["physical"]),
    virtual: j["virtual"] == null
        ? null
        : VirtualLocation.fromJson(j["virtual"]),
  );
  Map<String, dynamic> toJson() => {
    "mode": mode,
    "physical": physical?.toJson(),
    "virtual": virtual?.toJson(),
  };
}

class PhysicalLocation {
  String venue, address, city, country;
  Coordinate coordinates;
  PhysicalLocation({
    required this.venue,
    required this.address,
    required this.city,
    required this.country,
    required this.coordinates,
  });
  factory PhysicalLocation.fromJson(Map<String, dynamic> j) => PhysicalLocation(
    venue: j["venue"],
    address: j["address"],
    city: j["city"],
    country: j["country"],
    coordinates: Coordinate.fromJson(j["coordinates"]),
  );
  Map<String, dynamic> toJson() => {
    "venue": venue,
    "address": address,
    "city": city,
    "country": country,
    "coordinates": coordinates.toJson(),
  };
}

class Coordinate {
  double latitude, longitude;
  Coordinate({required this.latitude, required this.longitude});
  factory Coordinate.fromJson(Map<String, dynamic> j) => Coordinate(
    latitude: (j["latitude"] as num).toDouble(),
    longitude: (j["longitude"] as num).toDouble(),
  );
  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class VirtualLocation {
  String url;
  VirtualLocation({required this.url});
  factory VirtualLocation.fromJson(Map<String, dynamic> j) =>
      VirtualLocation(url: j["url"]);
  Map<String, dynamic> toJson() => {"url": url};
}

class ExperienceDetails {
  Schedule? schedule;
  List<Agenda> agenda;
  String? instructor;
  Recurrence? recurrence;
  ExperienceDetails({
    this.schedule,
    this.agenda = const [],
    this.instructor,
    this.recurrence,
  });
  factory ExperienceDetails.fromJson(Map<String, dynamic> j) =>
      ExperienceDetails(
        schedule: j["schedule"] == null
            ? null
            : Schedule.fromJson(j["schedule"]),
        agenda: (j["agenda"] as List? ?? [])
            .map((e) => Agenda.fromJson(e))
            .toList(),
        instructor: j["instructor"],
        recurrence: j["recurrence"] == null
            ? null
            : Recurrence.fromJson(j["recurrence"]),
      );
  Map<String, dynamic> toJson() => {
    "schedule": schedule?.toJson(),
    "agenda": agenda.map((e) => e.toJson()).toList(),
    "instructor": instructor,
    "recurrence": recurrence?.toJson(),
  };
}

class Schedule {
  String timezone;
  DateTime? startDate, endDate;
  Schedule({required this.timezone, this.startDate, this.endDate});
  factory Schedule.fromJson(Map<String, dynamic> j) => Schedule(
    timezone: j["timezone"],
    startDate: j["startDate"] == null ? null : DateTime.parse(j["startDate"]),
    endDate: j["endDate"] == null ? null : DateTime.parse(j["endDate"]),
  );
  Map<String, dynamic> toJson() => {
    "timezone": timezone,
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
  };
}

class Agenda {
  String id, title, speaker;
  DateTime startAt, endAt;
  Agenda({
    required this.id,
    required this.title,
    required this.speaker,
    required this.startAt,
    required this.endAt,
  });
  factory Agenda.fromJson(Map<String, dynamic> j) => Agenda(
    id: j["id"],
    title: j["title"],
    speaker: j["speaker"],
    startAt: DateTime.parse(j["startAt"]),
    endAt: DateTime.parse(j["endAt"]),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "speaker": speaker,
    "startAt": startAt.toIso8601String(),
    "endAt": endAt.toIso8601String(),
  };
}

class Recurrence {
  String rule;
  Recurrence({required this.rule});
  factory Recurrence.fromJson(Map<String, dynamic> j) =>
      Recurrence(rule: j["rule"]);
  Map<String, dynamic> toJson() => {"rule": rule};
}

class ExperienceItem {
  String id, name;
  ItemType type;
  String? description;
  int price, quota, available;
  ItemSchedule? schedule;
  ExperienceItem({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.price,
    required this.quota,
    required this.available,
    this.schedule,
  });
  factory ExperienceItem.fromJson(Map<String, dynamic> j) => ExperienceItem(
    id: j["id"],
    type: _itemType(j["type"]),
    name: j["name"],
    description: j["description"],
    price: j["price"],
    quota: j["quota"],
    available: j["available"],
    schedule: j["schedule"] == null
        ? null
        : ItemSchedule.fromJson(j["schedule"]),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type.name,
    "name": name,
    "description": description,
    "price": price,
    "quota": quota,
    "available": available,
    "schedule": schedule?.toJson(),
  };
}

class ItemSchedule {
  DateTime startAt, endAt;
  ItemSchedule({required this.startAt, required this.endAt});
  factory ItemSchedule.fromJson(Map<String, dynamic> j) => ItemSchedule(
    startAt: DateTime.parse(j["startAt"]),
    endAt: DateTime.parse(j["endAt"]),
  );
  Map<String, dynamic> toJson() => {
    "startAt": startAt.toIso8601String(),
    "endAt": endAt.toIso8601String(),
  };
}

class CheckoutConfig {
  Registration registration;
  Payment payment;
  Attendance attendance;
  CheckoutConfig({
    required this.registration,
    required this.payment,
    required this.attendance,
  });
  factory CheckoutConfig.fromJson(Map<String, dynamic> j) => CheckoutConfig(
    registration: Registration.fromJson(j["registration"]),
    payment: Payment.fromJson(j["payment"]),
    attendance: Attendance.fromJson(j["attendance"]),
  );
  Map<String, dynamic> toJson() => {
    "registration": registration.toJson(),
    "payment": payment.toJson(),
    "attendance": attendance.toJson(),
  };
}

class Registration {
  bool enabled, approvalRequired, requireLogin;
  List<CustomQuestion> customQuestions;
  Registration({
    required this.enabled,
    required this.approvalRequired,
    required this.requireLogin,
    required this.customQuestions,
  });
  factory Registration.fromJson(Map<String, dynamic> j) => Registration(
    enabled: j["enabled"],
    approvalRequired: j["approvalRequired"],
    requireLogin: j["requireLogin"],
    customQuestions: (j["customQuestions"] as List)
        .map((e) => CustomQuestion.fromJson(e))
        .toList(),
  );
  Map<String, dynamic> toJson() => {
    "enabled": enabled,
    "approvalRequired": approvalRequired,
    "requireLogin": requireLogin,
    "customQuestions": customQuestions.map((e) => e.toJson()).toList(),
  };
}

class CustomQuestion {
  String label, type;
  bool requiredField;
  CustomQuestion({
    required this.label,
    required this.type,
    required this.requiredField,
  });
  factory CustomQuestion.fromJson(Map<String, dynamic> j) => CustomQuestion(
    label: j["label"],
    type: j["type"],
    requiredField: j["required"],
  );
  Map<String, dynamic> toJson() => {
    "label": label,
    "type": type,
    "required": requiredField,
  };
}

class Payment {
  bool enabled;
  List<String> methods;
  Payment({required this.enabled, required this.methods});
  factory Payment.fromJson(Map<String, dynamic> j) =>
      Payment(enabled: j["enabled"], methods: List<String>.from(j["methods"]));
  Map<String, dynamic> toJson() => {"enabled": enabled, "methods": methods};
}

class Attendance {
  String method;
  Attendance({required this.method});
  factory Attendance.fromJson(Map<String, dynamic> j) =>
      Attendance(method: j["method"]);
  Map<String, dynamic> toJson() => {"method": method};
}

class Metadata {
  bool isFeatured;
  String themeColor;
  Metadata({required this.isFeatured, required this.themeColor});
  factory Metadata.fromJson(Map<String, dynamic> j) =>
      Metadata(isFeatured: j["isFeatured"], themeColor: j["themeColor"]);
  Map<String, dynamic> toJson() => {
    "isFeatured": isFeatured,
    "themeColor": themeColor,
  };
}
