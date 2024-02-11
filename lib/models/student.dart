class Student {
  final String name;
  final String classRoom;
  final String address;
  final String phone;
  final String email;
  final String schoolJoinedAt;
  final int rollNumber;
  final String parentsName;
  final String mothersName;
  final String dob;
  final bool isAlumni;
  final bool isActive;
  final String avatar; // Added avatar field

  Student({
    required this.name,
    required this.classRoom,
    required this.address,
    required this.phone,
    required this.email,
    required this.schoolJoinedAt,
    required this.rollNumber,
    required this.parentsName,
    required this.mothersName,
    required this.dob,
    required this.isAlumni,
    required this.isActive,
    required this.avatar, // Added avatar field
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'] ?? '',
      classRoom: map['classRoom'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      schoolJoinedAt: map['schoolJoinedAt'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      parentsName: map['parentsName'] ?? '',
      mothersName: map['mothersName'] ?? '',
      dob: map['dob'] ?? '',
      isAlumni: map['isAlumni'] ?? false,
      isActive: map['isActive'] ?? false,
      avatar: map['avatar'] ?? '', // Added avatar field
    );
  }
}
