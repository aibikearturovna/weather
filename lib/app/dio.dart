import 'package:api/constans/api.dart';
import 'package:api/constans/colors.dart';
import 'package:api/constans/styles.dart';
import 'package:api/constans/text.dart';
import 'package:api/models/country.dart';
import 'package:api/models/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DemoDio extends StatefulWidget {
  const DemoDio({Key? key}) : super(key: key);

  @override
  State<DemoDio> createState() => _DemoDioState();
}

class _DemoDioState extends State<DemoDio> {
  Weather? weather;

  Future<void> thelocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always &&
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      final res = await dio.get(
        ApiConst.getLocator(lat: position.latitude, lon: position.longitude),
      );
      if (res.statusCode == 200) {
        weather = Weather(
          id: res.data['current']['weather'][0]['id'],
          main: res.data['current']['weather'][0]['main'],
          description: res.data['current']['weather'][0]['description'],
          icon: res.data['current']['weather'][0]['icon'],
          city: res.data['timezone'],
          temp: res.data['current']['temp'],
        );
        setState(() {});
      }
    } else {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      final res = await dio.get(
        ApiConst.getLocator(lat: position.latitude, lon: position.longitude),
      );
      if (res.statusCode == 200) {
        weather = Weather(
          id: res.data['current']['weather'][0]['id'],
          main: res.data['current']['weather'][0]['main'],
          description: res.data['current']['weather'][0]['description'],
          icon: res.data['current']['weather'][0]['icon'],
          city: res.data['timezone'],
          temp: res.data['current']['temp'],
        );
      }
      setState(() {});
    }
  }

  Future<void> fetchData([String? name]) async {
    final dio = Dio();
    await Future.delayed(
      const Duration(seconds: 3),
    );
    final res = await dio.get(ApiConst.address(name ?? 'bishkek'));
    //res = response
    if (res.statusCode == 200) {
      weather = Weather(
        id: res.data['weather'][0]['id'],
        main: res.data['weather'][0]['main'],
        description: res.data['weather'][0]['description'],
        icon: res.data['weather'][0]['icon'],
        city: res.data['name'],
        temp: res.data['main']['temp'],
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppText.title,
          style: TextStyle(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: weather == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/tree.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await thelocation();
                        },
                        iconSize: 40,
                        color: AppColors.white,
                        icon: const Icon(Icons.near_me),
                      ),
                      IconButton(
                        onPressed: () {
                          showBottom();
                        },
                        iconSize: 40,
                        color: AppColors.white,
                        icon: const Icon(Icons.location_city),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 28,
                      ),
                      Text('${(weather!.temp - 273.15).toInt()}',
                          style: AppStyle.temp),
                      //Icon(snapshot.data!.icon)
                      Image.network(
                        ApiConst.getIcon(weather!.icon, 4),
                      )
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FittedBox(
                          child: Text(
                            weather!.description.replaceAll(' ', '\n'),
                            textAlign: TextAlign.end,
                            style: AppStyle.weather,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 280,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: FittedBox(
                          child: Text(
                            weather!.city,
                            style: AppStyle.city,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  void showBottom() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 19, 15, 2),
            border: Border.all(color: AppColors.white),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    setState(() {
                      weather = null;
                    });
                    fetchData(city);
                    Navigator.pop(context);
                  },
                  title: Text(city),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
