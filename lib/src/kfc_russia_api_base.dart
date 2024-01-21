import 'package:dio/dio.dart';
import 'dart:math';

class KFC {
  static final _httpClient = Dio();

  /// URL for getting information about cities from KFC Russia
  static const citiesUrl =
      'https://api.prod.digital.uni.rest/api/store/v2/store.get_cities';

  /// URL for getting information about restaurants from KFC Russia
  static const restaurantUrl =
      'https://api.prod.digital.uni.rest/api/store/v2/store.get_restaurants?showClosed=true&channel=mobile';

  /// URL for getting information about the menu from KFC Russia
  static const menuUrl =
      'https://api.prod.digital.uni.rest/api/mobilebff/api/v1/menu/menu';

  /// URL for getting information about the stop list of the menu from KFC Russia
  static const menuStopListUrl =
      'https://api.prod.digital.uni.rest/api/menu/api/v1/menu.get_stoplist';

  /// URL for getting configuration information from KFC Russia
  static const configUrl =
      'https://api.prod.digital.uni.rest/api/device/api/v1/device.get_config';

  /// URL for getting all configuration information from KFC Russia
  static const configsUrl =
      'https://api.prod.digital.uni.rest/api/device/api/v1/device.get_configs';

  /// Getting data for a post request to KFC Russia API
  ///
  /// [restaurantId] is ID of KFC Russia restaurant
  /// It maybe is empty string if restaurant is unimportant
  ///
  /// [deviceId] is Google Ad ID
  /// It has mask "ffffffff-ffff-ffff-ffff-ffffffffffff"
  /// If the [deviceId] is not specified, it is generated automatically
  /// If [deviceId] is incorrect, throws [Exception]
  static Map<String, dynamic> getApiPostData(
      {String restaurantId = '', String deviceId = ''}) {
    if (deviceId.isNotEmpty &&
        !RegExp(r'\b(\d|[a-f]){8}-(\d|[a-f]){4}-(\d|[a-f]){4}-(\d|[a-f]){4}-(\d|[a-f]){12}\b')
            .hasMatch(deviceId)) {
      throw Exception('Invalid deviceId');
    }
    if (deviceId.isEmpty) {
      Random random = Random();
      for (var i = 0; i < 36; i++) {
        if ([8, 13, 18, 23].contains(i)) {
          deviceId += '-';
        } else {
          deviceId += random.nextInt(16).toRadixString(16);
        }
      }
    }
    return {
      'version': '1.0',
      'device': {
        'storeId': restaurantId,
        'deviceId': deviceId,
        'deviceType': 'mobile',
      }
    };
  }

  static Response _checkApiResponse(Response response) {
    response.statusCode;
    if (response.data['status'] != 0) {
      throw Exception(response.data['errors'][0]['description']);
    }
    return response;
  }

  /// Getting configuration information from KFC Russia
  static Future<Response> getConfig() async => _checkApiResponse(
      await _httpClient.post(configUrl, data: getApiPostData()));

  /// Getting all configuration information from KFC Russia
  static Future<Response> getConfigs() async => _checkApiResponse(
      await _httpClient.post(configsUrl, data: getApiPostData()));

  static Future<String> _getParametersFromConfig(
    String key, [
    Response? config,
  ]) async {
    config ??= await getConfig();
    final value =
        config.data?['value']?['parameters']?[key]?['value']?.toString();
    if (value == null || value.isEmpty) throw Exception('Value not found');
    return value;
  }

  /// Getting the URL of the KFC Russia assets store from configuration information
  ///
  /// If the [config] is not specified, it is requested automatically
  ///
  /// If assets store URL is not found, throws[Exception]
  static Future<String> getAssetsStoreUrl([
    Response? config,
  ]) async =>
      _getParametersFromConfig('assets_store_url', config);

  /// Getting the default city ID of the KFC Russia from configuration information
  ///
  /// If the [config] is not specified, it is requested automatically
  ///
  /// If default city ID is not found, throws[Exception]
  static Future<String> getDefaultCityId([
    Response? config,
  ]) async =>
      _getParametersFromConfig('default_city_id', config);

  /// Getting the default restaurant ID of the KFC Russia from cities
  ///
  /// If the [cities] are not specified, they are requested automatically
  /// If information of the city is not found, throws[Exception]
  ///
  /// If the [cityId] is not specified, it is requested automatically
  /// If default restaurant ID by [cityId] is not found, throws[Exception]
  static Future<String> getDefaultRestaurantId({
    Response? cities,
    String? cityId,
  }) async {
    cities ??= await getCities();
    cityId ??= await getDefaultCityId();

    final citiesList = cities.data?['value']?['cities'] as List?;
    if (citiesList == null || citiesList.isEmpty) {
      throw Exception('Cities not found');
    }

    String defaultRestaurantId = '';
    for (Map<String, dynamic> city in cities.data['value']['cities']) {
      if (city['kfcCityId'] == cityId) {
        defaultRestaurantId = city['defaultStore']['id'].toString();
        break;
      }
    }
    if (defaultRestaurantId == 'null' || defaultRestaurantId.isEmpty) {
      throw Exception('Default restaurant not found');
    }
    return defaultRestaurantId;
  }

  /// Getting information about restaurants from KFC Russia
  static Future<Response> getRestaurants() async =>
      _checkApiResponse(await _httpClient.get(restaurantUrl));

  /// Getting information about cities from KFC Russia
  static Future<Response> getCities() async => _checkApiResponse(
      await _httpClient.post(citiesUrl, data: getApiPostData()));

  /// Getting URL for receive KFC Russia news
  ///
  /// If the [restaurantId] is not specified, the default restaurant id is requested automatically
  /// If [restaurantId] is empty, throws[Exception]
  static Future<String> getNewsUrl([String? restaurantId]) async {
    restaurantId ??= await getDefaultRestaurantId();
    if (restaurantId.isEmpty) throw Exception('Empty restaurant Id');
    return 'https://api.prod.digital.uni.rest/api/content/api/v1/content/$restaurantId/mobile/mobile_app_news';
  }

  /// Getting news from KFC Russia
  ///
  /// If the [restaurantId] is not specified, the default restaurant id is requested automatically
  /// If [restaurantId] is empty, throws[Exception]
  static Future<Response> getNews([String? restaurantId]) async =>
      _checkApiResponse(await _httpClient.get(await getNewsUrl(restaurantId)));

  /// Getting the menu from KFC Russia
  ///
  /// If the [restaurantId] is not specified, the default restaurant id is requested automatically
  static Future<Response> getMenu([String? restaurantId]) async {
    restaurantId ??= await getDefaultRestaurantId();
    final response = await _httpClient.post(
      menuUrl,
      data: getApiPostData(restaurantId: restaurantId),
    );
    return _checkApiResponse(response);
  }

  /// Getting the menu hash code from KFC Russia
  ///
  /// If the [restaurantId] is not specified, the default restaurant id is requested automatically
  static Future<Response> getMenuHash([
    String? restaurantId,
  ]) async {
    restaurantId ??= await getDefaultRestaurantId();
    final response = await _httpClient.post('$menuUrl.hash',
        data: getApiPostData(restaurantId: restaurantId));
    return _checkApiResponse(response);
  }

  /// Getting the stop list of the menu from KFC Russia
  ///
  /// If the [restaurantId] is not specified, the default restaurant id is requested automatically
  static Future<Response> getMenuStopList([
    String? restaurantId,
  ]) async {
    restaurantId ??= await getDefaultRestaurantId();
    final response = _checkApiResponse(await _httpClient.post(menuStopListUrl,
        data: getApiPostData(restaurantId: restaurantId)));
    final hashCode = response.data?['value']?['hashCode']?.toString();
    if (hashCode == null || hashCode.isEmpty) {
      throw Exception('HashCode not found');
    }
    return response;
  }

  /// Getting URl for GET request to get images from assets store of KFC Russia
  ///
  /// [imageId] is ID of image in KFC Russia assets store
  ///
  /// [imageSize] is the index of the template size from smaller to larger
  /// [imageSize] must be in the range from 0 to 4 inclusive
  /// If the [imageSize] is not specified or equal to 0, then image has a base size
  ///
  /// If the [assetsStoreUrl] is not specified, it is requested automatically
  static Future<String> getImageUrl(
    String imageId, {
    int imageSize = 0,
    String? assetsStoreUrl,
  }) async {
    assetsStoreUrl ??= await getAssetsStoreUrl();
    const imageSizes = [
      '',
      '153x153/',
      '168x168/',
      '390x390/',
      '810x540/',
    ];
    return '$assetsStoreUrl${imageSizes[imageSize]}$imageId';
  }
}
