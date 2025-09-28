class UserModel {
  final String name;
  final String email;
  final String cityId;
  final String dob;
  final String tob;
  final bool isLogin; // Ensure it's a boolean
  final double tz; // Ensure it's a double
  final String gender;

  UserModel({
    required this.name,
    required this.email,
    required this.cityId,
    required this.dob,
    required this.tob,
     this.isLogin= false,
    required this.tz,
    required this.gender
    
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "city_id": cityId,
      "dob": dob,
      "tob": tob,
      "is_login": isLogin, // Send correct boolean value
      "tz": tz, // Ensure it's a double, not a string
      "gender": gender,
    };
  }
}
