import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/languages/english/english.dart';
import 'package:haircutmen_user_app/config/languages/russia/russia.dart' hide english;
import 'package:haircutmen_user_app/config/languages/serbia/serbias.dart';

class Language extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    // "en_US": english,
    "en": english,
    'ru': russian,
    'sr': serbian,
  };
}