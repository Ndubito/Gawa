class AppUser {
  final String uid;
  final String? email;
  final String? phone;

  AppUser({required this.uid,  this.email, this.phone});


  //convert app user to json
  Map<String, dynamic> toJson(){
    return{
      'uid': uid,
      'email': email,
      'phone':phone,
    };
  }

  //convert Json to App user
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(uid: json["uid"], email: json["email"], phone: json['phone']);
  }
}
