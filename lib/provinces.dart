import 'package:provinces_and_districts_application/districts.dart';

class Province {
  String name;
  String licensePlateCode;
  List<District> districts;

  Province(this.name,this.licensePlateCode,this.districts);
}