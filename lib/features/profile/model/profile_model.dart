class ProfileModel {
  final String name;
  final String email;
  final String dob;
  final String tob;
  final String cityId;
  final City? city;
  final double tz;
  final String gender;
  final GuestProfile? guestProfile;

  ProfileModel({
    required this.name,
    required this.email,
    required this.dob,
    required this.tob,
    required this.cityId,
    this.city,
    required this.tz,
    required this.gender,
    this.guestProfile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
  //   var item;
  // try {
  //   var obj = json;
  //   print('jayson: ${obj.toString()}');
    // if (json['data'] != null) {
    //   print('Data is not null');
    // }
    // if (json['data']['item'] is Map<String, dynamic>) {
    //   print('Wrong Type');
    // }

  //   item = (json['data'] != null && json['data']['item'] is Map<String, dynamic>)
  //       ? json['data']['item'] as Map<String, dynamic>
  //       : {"What": "The"};
  // } catch (e) {
  //   item = {"hello": "world"};
  //   print('Err: $e');
  // }

  //   print('item : ${item.toString()}');

    return ProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      dob: json['dob'] ?? '',
      tob: json['tob'] ?? '',
      cityId: json['city_id'] ?? '',
      city: json['city'] is Map<String, dynamic> ? City.fromJson(json['city']) : null,
      tz: (json['tz'] is num) ? (json['tz'] as num).toDouble() : 0.0,  // ✅ Convert `tz` safely
      gender: json['gender'] ?? '',

      guestProfile: json['guest_profile'] is Map<String, dynamic>
          ? GuestProfile.fromJson(json['guest_profile'])
          : null,
    );
  }
}

// City Model
class City {
  final String id;
  final String cityAscii;
  final String lat;
  final String lng;
  final String country;
  final String iso2;
  final String iso3;
  final String cityId;

  City({
    required this.id,
    required this.cityAscii,
    required this.lat,
    required this.lng,
    required this.country,
    required this.iso2,
    required this.iso3,
    required this.cityId,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'] ?? '',
      cityAscii: json['city_ascii'] ?? '',
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      country: json['country'] ?? '',
      iso2: json['iso2'] ?? '',
      iso3: json['iso3'] ?? '',
      cityId: json['city_id'] ?? '',
    );
  }
}

// Guest Profile Model
class GuestProfile {
  final String basicDescription;
  final String luckyColor;
  final String luckyGem;
  final String luckyNumber;
  final int rashiId;
  final String rashiName;
  final String compatibilityDescription;

  GuestProfile({
    required this.basicDescription,
    required this.luckyColor,
    required this.luckyGem,
    required this.luckyNumber,
    required this.rashiId,
    required this.rashiName,
    required this.compatibilityDescription,
  });

  factory GuestProfile.fromJson(Map<String, dynamic> json) {
    return GuestProfile(
      basicDescription: json['basic_description'] ?? '',
      luckyColor: json['lucky_color'] ?? '',
      luckyGem: json['lucky_gem'] ?? '',
      luckyNumber: json['lucky_number'] ?? '',
      rashiId: json['rashi_id'] ?? 0,
      rashiName: json['rashi_name'] ?? '',
      compatibilityDescription: json['compatibility_description'] ?? '',
    );
  }
}
