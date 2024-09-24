import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provinces_and_districts_application/districts.dart';
import 'package:provinces_and_districts_application/provinces.dart';

//Veriler her programlama dilinde json formatında kullanılır.
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Province> provinces = [];

  @override
  void initState() {
    super.initState();
    //Aşağıda setstate fonksiyonu çağırdığımız için ekran çizilmeden setstate yapmadığımızı anlamak için burada bir kod yazarak bunu kontrol etmiş oluruz.
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _jsonAnalyze();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100],
        title: Text("İller ve İlçeler"),
      ),
      body: ListView.builder(itemBuilder: _createListItem,itemCount:provinces.length),
    );
  }
  //Bunu normalde en alt kısımda oluşturdu ama biz buildin hemen altına aldık.
  Widget? _createListItem(BuildContext context, int index) {
    //Ben eğer öğelerin içeriği tıkladığımda açılıp kapanmasını istiyorsam ExpansionTile olarak yapılır.
    //Görüntü olarak listTiledan tek farkı öğeler arası boşluğun expansionTileda öğeler arası boşluğu daha fazla
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
        children: provinces[index].districts.map((district){
          return ListTile(
            title: Text(district.name),
          );
        }).toList(),
      ),
    );
  }

  void _jsonAnalyze() async {
    //Json formatını String formatında okuyoruz ve biz bu okuma için rootBundle.loadString kullanıyoruz.
    //String kısmını rootBundle.loadString ne döndürüyor ona baktı ve oan göre yazdı.
    String jsonString =
        await rootBundle.loadString("assets/iller_ilceler.json");
    //Json yapısına en uygun yapı map olduğu için mapa döndürürüz.
    Map<String, dynamic> provincesMap = json.decode(jsonString);

    //Her bir ilin plaka kodlarını dolanmak için
    for (String licensePlateCode in provincesMap.keys) {
      //il map deyip o ilin plaka kodundaki değeri
      //Plaka kodu
      Map<String, dynamic> provinceMap = provincesMap[licensePlateCode];
      //İl ismi
      String provinceName = provinceMap["name"];
      //String mi map mi bunu jsonda verilere bakıp karar veriyoruz iller map içersinde yazıldığı için map içerisine yazarız.
      //İlçe ismi
      Map<String, dynamic> districtsMap = provinceMap["districts"];

      //Mapin içerindeki değerleri listeye çevirme işlemi
      List<District> allDistricts = [];

      for (String districtCode in districtsMap.keys) {
        Map<String, dynamic> districtMap = districtsMap[districtCode];
        String districtName = districtMap["name"];
        District district = District(districtName);
        allDistricts.add(district);
      }

      Province province =
          Province(provinceName, licensePlateCode, allDistricts);
      //Bu şekilde yaptığımızda ekranda bir çıktı alamayız.
      // provinces.add(province);
      //Set state burada çağırırsam for döngüsü içerinde 81 kere setstate yapmış olurum.
      provinces.add(province);
    }
    //Burada setstate yaparsak bütün iller eklendikten sonra bir kere setstate kullanmış oluruz.
    setState(() {});
  }
}
