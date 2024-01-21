import 'package:kfc_russia_api/kfc_russia_api.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

Future<void> saveJson(String fileName, dynamic data) async {
  const apiDirectoryName = 'api_responses';
  await Directory(apiDirectoryName).create();
  File file = File('$apiDirectoryName/$fileName.json');
  await file.writeAsString(jsonEncode(data));
}

void main() {
  group('KFC Russia', () {
    test('getApiPostData()', () async {
      final data = KFC.getApiPostData();
      expect(data['device']['storeId'], isEmpty);
      expect(
          data['device']['deviceId'],
          matches(
              r'^(\d|[a-f]){8}-(\d|[a-f]){4}-(\d|[a-f]){4}-(\d|[a-f]){4}-(\d|[a-f]){12}$'));
      await saveJson('getApiPostData()', data);
    });
    test('getApiPostData(restaurantId)', () async {
      final data = KFC.getApiPostData(restaurantId: '123456');
      expect(data['device']['storeId'], '123456');
      expect(
          data['device']['deviceId'],
          matches(
              r'^(\d|[a-f]){8}-(\d|[a-f]){4}-(\d|[a-f]){4}-(\d|[a-f]){4}-(\d|[a-f]){12}$'));
      await saveJson('getApiPostData(restaurantId)', data);
    });
    test('getApiPostData(deviceId)', () async {
      final data =
          KFC.getApiPostData(deviceId: '12345678-1234-1234-1234-12345678abcd');
      expect(data['device']['storeId'], isEmpty);
      expect(data['device']['deviceId'],
          contains('12345678-1234-1234-1234-12345678abcd'));
      await saveJson('getApiPostData(deviceId)', data);
    });
    test('getApiPostData(invalidDeviceId)', () async {
      expect(
          () => KFC.getApiPostData(
              deviceId: '12345678-1234-1234-1234-12345678abcdef'),
          throwsException);
    });

    test('getConfig()', () async {
      final data = (await KFC.getConfig()).data;
      expect(data, allOf(isNotNull, isNotEmpty));
      await saveJson('getConfig()', data);
    });
    test('getConfigs()', () async {
      final data = (await KFC.getConfigs()).data;
      expect(data, allOf(isNotNull, isNotEmpty));
      await saveJson('getConfigs()', data);
    });

    test('getAssetsStoreUrl()', () async {
      final data = await KFC.getAssetsStoreUrl();
      expect(data, isNotEmpty);
      await saveJson('getAssetsStoreUrl()', data);
    });
    test('getAssetsStoreUrl(config)', () async {
      final data = await KFC.getAssetsStoreUrl(await KFC.getConfig());
      expect(data, isNotEmpty);
      await saveJson('getAssetsStoreUrl(config)', data);
    });
    test('getAssetsStoreUrl(invalidConfig)', () async {
      expect(() async => await KFC.getAssetsStoreUrl(await KFC.getCities()),
          throwsException);
    });

    test('getDefaultCityId()', () async {
      final data = await KFC.getDefaultCityId();
      expect(data, isNotEmpty);
      await saveJson('getDefaultCityId()', data);
    });
    test('getDefaultCityId(config)', () async {
      final data = await KFC.getDefaultCityId(await KFC.getConfig());
      expect(data, isNotEmpty);
      await saveJson('getDefaultCityId(config)', data);
    });
    test('getDefaultCityId(invalidConfig)', () async {
      expect(() async => await KFC.getDefaultCityId(await KFC.getCities()),
          throwsException);
    });

    test('getDefaultRestaurantId()', () async {
      final data = await KFC.getDefaultRestaurantId();
      expect(data, isNotEmpty);
      await saveJson('getDefaultRestaurantId()', data);
    });
    test('getDefaultRestaurantId(cities, cityId)', () async {
      final data = await KFC.getDefaultRestaurantId(
          cities: await KFC.getCities(), cityId: await KFC.getDefaultCityId());
      expect(data, isNotEmpty);
      await saveJson('getDefaultRestaurantId(cities, cityId)', data);
    });
    test('getDefaultRestaurantId(invalidCities, invalidCityId)', () async {
      expect(
          () async => await KFC.getDefaultRestaurantId(
              cities: await KFC.getConfig(), cityId: ''),
          throwsException);
    });

    test('getRestaurants()', () async {
      final data = (await KFC.getRestaurants()).data;
      expect(data, isNotEmpty);
      await saveJson('getRestaurants()', data);
    });

    test('getCities()', () async {
      final data = (await KFC.getCities()).data;
      expect(data, isNotEmpty);
      await saveJson('getCities()', data);
    });

    test('getNewsUrl()', () async {
      final data = await KFC.getNewsUrl();
      expect(
          data,
          matches(
              r'^https:\/\/api\.prod\.digital\.uni\.rest\/api\/content\/api\/v1\/content\/\d{1,}\/mobile\/mobile_app_news$'));
      await saveJson('getNewsUrl()', data);
    });
    test('getNewsUrl(restaurantId)', () async {
      final data = await KFC.getNewsUrl('00000000');
      expect(
          data,
          contains(
              'https://api.prod.digital.uni.rest/api/content/api/v1/content/00000000/mobile/mobile_app_news'));
      await saveJson('getNewsUrl(restaurantId)', data);
    });
    test('getNewsUrl(invalidRestaurantId)', () async {
      expect(() async => await KFC.getNewsUrl(''), throwsException);
    });

    test('getNews()', () async {
      final data = (await KFC.getNews()).data;
      expect(data, isNotEmpty);
      await saveJson('getNews()', data);
    });
    test('getNews(restaurantId)', () async {
      final data = (await KFC.getNews(await KFC.getDefaultRestaurantId())).data;
      expect(data, isNotEmpty);
      await saveJson('getNews(restaurantId)', data);
    });
    test('getNews(invalidRestaurantId)', () async {
      expect(() async => await KFC.getNews('00000000'), throwsException);
    });

    test('getMenu()', () async {
      final data = (await KFC.getMenu()).data;
      expect(data, isNotEmpty);
      await saveJson('getMenu()', data);
    });
    test('getMenu(restaurantId)', () async {
      final data = (await KFC.getMenu(await KFC.getDefaultRestaurantId())).data;
      expect(data, isNotEmpty);
      await saveJson('getMenu(restaurantId)', data);
    });
    test('getMenu(invalidRestaurantId)', () async {
      expect(() async => await KFC.getMenu('00000000'), throwsException);
    });

    test('getMenuHash()', () async {
      final data = (await KFC.getMenuHash()).data;
      expect(data, isNotEmpty);
      await saveJson('getMenuHash()', data);
    });
    test('getMenuHash(restaurantId)', () async {
      final data =
          (await KFC.getMenuHash(await KFC.getDefaultRestaurantId())).data;
      expect(data, isNotEmpty);
      await saveJson('getMenuHash(restaurantId)', data);
    });
    test('getMenuHash(invalidRestaurantId)', () async {
      expect(() async => await KFC.getMenuHash('00000000'), throwsException);
    });

    test('getMenuStopList()', () async {
      final data = (await KFC.getMenuStopList()).data;
      expect(data, isNotEmpty);
      await saveJson('getMenuStopList()', data);
    });
    test('getMenuStopList(restaurantId)', () async {
      final data =
          (await KFC.getMenuStopList(await KFC.getDefaultRestaurantId())).data;
      expect(data, isNotEmpty);
      await saveJson('getMenuStopList(restaurantId)', data);
    });
    test('getMenuStopList(invalidRestaurantId)', () async {
      expect(() async => await KFC.getMenuStopList(''), throwsException);
    });

    test('getImageUrl()', () async {
      final data = await KFC.getImageUrl('x4cgabjodewsayh66od8v8s8j92s');
      expect(data, isNotEmpty);
      await saveJson('getImageUrl()', data);
    });
    test('getImageUrl(assetsStoreUrl)', () async {
      final data = await KFC.getImageUrl('x4cgabjodewsayh66od8v8s8j92s',
          assetsStoreUrl: await KFC.getAssetsStoreUrl());
      expect(data, isNotEmpty);
      await saveJson('getImageUrl(assetsStoreUrl)', data);
    });
    test('getImageUrl(imageSize)', () async {
      List<String> imagesUrls = [];
      for (int i = 1; i < 5; i++) {
        final data =
            await KFC.getImageUrl('x4cgabjodewsayh66od8v8s8j92s', imageSize: i);
        expect(data, isNotEmpty);
        imagesUrls.add(data);
      }
      await saveJson('getImageUrl(imageSize)', imagesUrls);
    });
  });
}
