import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logger_wrapper.dart';

class AppLocalizations {
  static late AppLocalizations instance;
  static const Map<String, (Locale, String)> availableLocales = {
    'af': (Locale('af'), 'Afrikaans'),
    'am': (Locale('am'), '(amharic) አማርኛ'),
    'ar': (Locale('ar'), '(al arabiya) العربية'),
    'as': (Locale('as'), '(asamiya) অসমীয়া'),
    'az': (Locale('az'), '(azərbaycan) Azərbaycan dili'),
    'be': (Locale('be'), 'Беларуская (Bielaruskaja)'),
    'bg': (Locale('bg'), 'Български (Bălgarski)'),
    'bn': (Locale('bn'), 'বাংলা (baɛṅlā)'),
    'bs': (Locale('bs'), 'Bosanski'),
    'ca': (Locale('ca'), 'Català'),
    'cs': (Locale('cs'), 'Čeština'),
    'cy': (Locale('cy'), 'Cymraeg'),
    'da': (Locale('da'), 'Dansk'),
    'de': (Locale('de'), 'Deutsch'),
    'el': (Locale('el'), 'Ελληνικά (Elliniká)'),
    'en': (Locale('en'), 'English'),
    'es': (Locale('es'), 'Español'),
    'et': (Locale('et'), 'Eesti keel'),
    'eu': (Locale('eu'), 'Euskara'),
    'fa': (Locale('fa'), '(fārsī) فارسى'),
    'fi': (Locale('fi'), 'Suomi'),
    'fil': (Locale('fil'), 'Wikang Filipino'),
    'fr': (Locale('fr'), 'Français'),
    'gl': (Locale('gl'), 'Galego'),
    'gu': (Locale('gu'), 'ગુજરાતી (gujarātī)'),
    'gsw': (Locale('gsw'), 'Swiss German Alemannic Alsatian'),
    // 'ha': (Locale('ha'), '(ḥawsa) حَوْسَ'), presently not supported by GlobalMaterialLocalizations / https://api.flutter.dev/flutter/flutter_localizations/kMaterialSupportedLanguages.html
    'he': (Locale('he'), '(ivrit) עברית'),
    'hi': (Locale('hi'), 'हिन्दी (hindī)'),
    'hr': (Locale('hr'), 'Hrvatski'),
    'hu': (Locale('hu'), 'Magyar'),
    'hy': (Locale('hy'), 'Հայերեն (Hayeren)'),
    'id': (Locale('id'), 'Bahasa Indonesia'),
    'is': (Locale('is'), 'Íslenska'),
    'it': (Locale('it'), 'Italiano'),
    'ja': (Locale('ja'), '日本語 (nihongo)'),
    'ka': (Locale('ka'), 'ქართული (k’art’uli)'),
    'kk': (Locale('kk'), 'Қазақ тілі (Qazaq tili)'),
    'km': (Locale('km'), 'ភាសាខ្មែរ (phéasa khmae)'),
    'kn': (Locale('kn'), 'ಕನ್ನಡ (kannaḍa)'),
    'ko': (Locale('ko'), '한국어 [韓國語] (han-guk-eo)'),
    'ky': (Locale('ky'), 'Кыргызча (Kyrgyzcha)'),
    'lo': (Locale('lo'), 'ພາສາລາວ (phasa lao)'),
    'lt': (Locale('lt'), 'Lietuvių kalba'),
    'lv': (Locale('lv'), 'Latviešu valoda'),
    'mk': (Locale('mk'), 'Македонски (Makedonski)'),
    'ml': (Locale('ml'), 'മലയാളം (malayāḷaṁ)'),
    'mn': (Locale('mn'), 'Монгол (Mongol)'),
    'mr': (Locale('mr'), 'मराठी (marāṭhī)'),
    'ms': (Locale('ms'), 'Bahasa Melayu'),
    'my': (Locale('my'), 'မြန်မာဘာသာ (mranma bhasa)'),
    'nb': (Locale('nb'), 'Norsk Bokmål'),
    'ne': (Locale('ne'), 'नेपाली (Nēpālī)'),
    'nl': (Locale('nl'), 'Nederlands'),
    'or': (Locale('or'), 'ଓଡ଼ିଆ (ōṛiā)'),
    'pa': (Locale('pa'), 'ਪੰਜਾਬੀ'),
    'pl': (Locale('pl'), 'Polski'),
    'ps': (Locale('ps'), '(paṣhto) پښتو'),
    'pt': (Locale('pt'), 'Português'),
    'ro': (Locale('ro'), 'Română'),
    'ru': (Locale('ru'), 'Русский'),
    'si': (Locale('si'), 'සිංහල (siṁhala)'),
    'sk': (Locale('sk'), 'Slovenčina'),
    'sl': (Locale('sl'), 'Slovenščina'),
    'sq': (Locale('sq'), 'Shqipja'),
    'sr': (Locale('sr'), 'Српски (Srpski)'),
    'sv': (Locale('sv'), 'Svenska'),
    'sw': (Locale('sw'), 'Kiswahili'),
    'ta': (Locale('ta'), 'தமிழ் (Tamiḻ)'),
    'te': (Locale('te'), 'తెలుగు (telugu)'),
    'th': (Locale('th'), 'ภาษาไทย (paasaa-tai)'),
    'tl': (Locale('tl'), 'Wikang Tagalog'),
    'tr': (Locale('tr'), 'Türkçe'),
    'uk': (Locale('uk'), 'Українська (Ukrajins’ka)'),
    'ur': (Locale('ur'), '(urdū) اردو'),
    'uz': (Locale('uz'), 'O‘zbek'),
    'vi': (Locale('vi'), 'Tiếng Việt'),
    'zh': (Locale('zh', 'Hans'), '简体中文 (Jiǎntǐ zhōngwén)'),
    'zh_Hant': (Locale('zh', 'Hant'), '繁體中文 (Fántǐ zhōngwén)'),
    'zu': (Locale('zu'), 'isiZulu'),
  };

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  final Locale fallbackLocale = const Locale('en');
  Locale locale;
  late Map<String, String> _localizedStrings;
  late Map<String, String> _fallbackLocalizedStrings;

  AppLocalizations(this.locale);
  // make factory
  factory AppLocalizations._init(Locale locale) {
    instance = AppLocalizations(locale);
    return instance;
  }

  Future<void> load() async {
    _localizedStrings = await _loadLocalizedStrings(locale);
    _fallbackLocalizedStrings = {};

    if (locale != fallbackLocale) {
      _fallbackLocalizedStrings = await _loadLocalizedStrings(fallbackLocale);
    }
  }

  String translate(String key, [Map<String, String?>? arguments]) {
    var translation = _localizedStrings[key];
    translation = translation ?? _fallbackLocalizedStrings[key];
    translation = translation ?? '';

    if (arguments == null || arguments.isEmpty) {
      return translation;
    }

    arguments.forEach((argumentKey, value) {
      if (value == null) {
        LoggerWrapper.logWarn(
          'AppLocalizations',
          'translate',
          'Value for "$argumentKey" is null in call of translate(\'$key\')',
        );
        value = '';
      }
      translation = translation!.replaceAll('\$$argumentKey', value);
    });

    return translation ?? '';
  }

  Future<String> _getFilePath(Locale localeToBeLoaded) async {
    switch (localeToBeLoaded.languageCode) {
      case 'bn':
        return 'assets/translations/bn_BD.json';
      case 'nb':
        return 'assets/translations/nb_NO.json';
      default:
        return 'assets/translations/${localeToBeLoaded.languageCode}.json';
    }
  }

  Future<Map<String, String>> _loadLocalizedStrings(
    Locale localeToBeLoaded,
  ) async {
    String jsonString;
    var localizedStrings = <String, String>{};

    try {
      jsonString =
          await rootBundle.loadString(await _getFilePath(localeToBeLoaded));
    } catch (e) {
      LoggerWrapper.logError(
        'AppLocalizations',
        '_loadLocalizedStrings',
        e.toString(),
      );
      return localizedStrings;
    }

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return localizedStrings;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localizations = AppLocalizations._init(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

//TODO go through setup and check for line breaks for all languages
