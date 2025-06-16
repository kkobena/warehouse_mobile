class User {
  String? login;
  String? firstName;
  String? lastName;
  String? roleName;
  String? abbrName;
  String? password;
  int? id;

  User({
    this.login,
    this.firstName,
    this.lastName,
    this.roleName,
    this.abbrName,
    this.password,
    this.id,
  });
String? get fullName => abbrName;
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      roleName: json['roleName'] as String?,

      /*
      authorities: (json['authorities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet(),*/
      abbrName: json['abbrName'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'login': login,
    'firstName': firstName,
    'lastName': lastName,
    'roleName': roleName,
    //  'authorities': authorities?.toList(),
    'abbrName': abbrName,
    'password': password,
  };
}
