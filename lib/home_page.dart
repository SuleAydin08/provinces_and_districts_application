import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provinces_and_districts_application/districts.dart';
import 'package:provinces_and_districts_application/provinces.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Province> provincesMap = [];
  List<Province> provincesList = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //Burdaki amaç bu sayfayı açar açmaz bu verileri get et yani getir demek
    _jsonAnalyzeMap();
    _jsonAnalyzeList();
    // _loadJsonData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100],
        title: Text("İller ve İlçeler"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Map Kullanımı'),
            Tab(text: 'Liste Kullanımı'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProvinceList(provincesMap),
          _buildProvinceList(provincesList),
        ],
      ),
    );
  }

  Widget _buildProvinceList(List<Province> provinces) {
    return ListView.builder(
      itemCount: provinces.length,
      itemBuilder: (context, index) {
        return Card(
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(provinces[index].name),
                Text(provinces[index].licensePlateCode)
              ],
            ),
            leading: Icon(Icons.location_city),
            children: provinces[index].districts.map((district) {
              return ListTile(
                title: Text(district.name),
              );
            }).toList(),
          ),
        );
      },
    );
  }

// //İki json dosyasını aynı anda yüklemek için yaptı
//   void _loadJsonData() async {
//     await Future.wait([_jsonAnalyzeMap(), _jsonAnalyzeList()]);
//   }
//json dosyasını yüklemek zaman alabilen bir işlemdir
//bunu asenkron hale getirmek için future kullanılır.
  Future<void> _jsonAnalyzeMap() async {
    try {
      String jsonString =
          await rootBundle.loadString("assets/iller_ilceler.json");
      Map<String, dynamic> provincesMapData = json.decode(jsonString);

      provincesMap = provincesMapData.entries.map((entry) {
        String provinceName = entry.value['name'];
        Map<String, dynamic> districtsMap = entry.value['districts'];

        List<District> districtObjects =
            districtsMap.entries.map((districtEntry) {
          return District(districtEntry.value['name']);
        }).toList();

        return Province(provinceName, entry.key, districtObjects);
      }).toList();
    } catch (e) {
      print("Error loading map usage JSON: $e");
    }
  }

  Future<void> _jsonAnalyzeList() async {
    try {
      String jsonString =
          await rootBundle.loadString("assets/artvin_rize.json");
      Map<String, dynamic> provincesListData = json.decode(jsonString);

      provincesList = provincesListData.entries.map((entry) {
        String provinceName = entry.value['name'];
        List<String> districtsList =
            List<String>.from(entry.value['districts']);

        List<District> districtObjects = districtsList.map((districtName) {
          return District(districtName);
        }).toList();

        return Province(provinceName, entry.key, districtObjects);
      }).toList();
    } catch (e) {
      print("Error loading list usage JSON: $e");
    }
  }
}
