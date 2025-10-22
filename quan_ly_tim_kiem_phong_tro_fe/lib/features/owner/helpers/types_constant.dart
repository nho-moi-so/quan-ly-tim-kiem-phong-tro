class ApartmentType {
  static const String oneBedroom = '1 Phòng Ngủ';
  static const String twoBedrooms = '2 Phòng Ngủ';
  static const String studio = 'Studio';
  static const String threeBedrooms = '3 Phòng Ngủ';

  static List<String> getAllTypes() {
    return [
      oneBedroom,
      twoBedrooms,
      studio,
      threeBedrooms,
    ];
  }
}
