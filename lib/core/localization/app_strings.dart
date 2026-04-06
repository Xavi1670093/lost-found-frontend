import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static const supportedLocales = [
    Locale('es'),
    Locale('ca'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppStrings> delegate =
  _AppStringsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'appName': 'UniLost & Found',
      'home': 'Inicio',
      'chats': 'Chats',
      'profile': 'Perfil',
      'settings': 'Configuración',
      'darkMode': 'Modo oscuro',
      'language': 'Idioma',
      'spanish': 'Español',
      'catalan': 'Català',
      'english': 'English',
      'publishedObjects': 'Objetos publicados',
      'futureOptions': 'Opciones futuras de la aplicación',
      'userHistory': 'Aquí aparecerá el historial del usuario',
      'welcome': 'Bienvenido a ULF',
      'preview': 'Vista previa',
      'welcomeDescription':
      'Aquí aparecerán próximamente los objetos perdidos y encontrados del campus.',

      'loginTitleAppBar': 'Login',
      'loginTitle': 'Iniciar sesión',
      'loginSubtitle': 'Accede con tu correo institucional de la UAB',
      'uabEmailLabel': 'Correo UAB',
      'loginEmailRequired': 'Introduce tu correo UAB',
      'loginEmailInvalid': 'Debes usar un correo UAB válido (NIU@uab.cat)',
      'passwordLabel': 'Contraseña',
      'passwordRequired': 'Introduce la contraseña',
      'passwordMinLength': 'Mínimo 6 caracteres',
      'loginButton': 'Entrar',
      'goToRegister': '¿No tienes cuenta? Regístrate',

      'registerTitleAppBar': 'Registro',
      'registerTitle': 'Crear cuenta',
      'registerSubtitle': 'Rellena los datos para registrarte',
      'nameLabel': 'Nombre',
      'nameRequired': 'Introduce tu nombre',
      'nameTooShort': 'El nombre es demasiado corto',
      'emailLabel': 'Email',
      'registerEmailMustBeUab': 'Debe ser un correo @uab.cat',
      'registerNiuInvalid': 'El NIU debe tener 7 dígitos',
      'registerPasswordRequired': 'Introduce una contraseña',
      'registerPasswordMinLength':
      'La contraseña debe tener al menos 6 caracteres',
      'confirmPasswordLabel': 'Repetir contraseña',
      'confirmPasswordRequired': 'Repite la contraseña',
      'passwordsDoNotMatch': 'Las contraseñas no coinciden',
      'registerButton': 'Registrarse',
      'registerSuccess': 'Registro completado',
      'goToLogin': '¿Ya tienes cuenta? Inicia sesión',
    },
    'ca': {
      'appName': 'UniLost & Found',
      'home': 'Inici',
      'chats': 'Xats',
      'profile': 'Perfil',
      'settings': 'Configuració',
      'darkMode': 'Mode fosc',
      'language': 'Idioma',
      'spanish': 'Espanyol',
      'catalan': 'Català',
      'english': 'English',
      'publishedObjects': 'Objectes publicats',
      'futureOptions': 'Opcions futures de l’aplicació',
      'userHistory': 'Aquí apareixerà l’historial de l’usuari',
      'welcome': 'Benvingut a ULF',
      'preview': 'Vista prèvia',
      'welcomeDescription':
      'Aquí apareixeran pròximament els objectes perduts i trobats del campus.',

      'loginTitleAppBar': 'Inici de sessió',
      'loginTitle': 'Iniciar sessió',
      'loginSubtitle': 'Accedeix amb el teu correu institucional de la UAB',
      'uabEmailLabel': 'Correu UAB',
      'loginEmailRequired': 'Introdueix el teu correu UAB',
      'loginEmailInvalid': 'Has d’utilitzar un correu UAB vàlid (NIU@uab.cat)',
      'passwordLabel': 'Contrasenya',
      'passwordRequired': 'Introdueix la contrasenya',
      'passwordMinLength': 'Mínim 6 caràcters',
      'loginButton': 'Entrar',
      'goToRegister': 'No tens compte? Registra’t',

      'registerTitleAppBar': 'Registre',
      'registerTitle': 'Crear compte',
      'registerSubtitle': 'Omple les dades per registrar-te',
      'nameLabel': 'Nom',
      'nameRequired': 'Introdueix el teu nom',
      'nameTooShort': 'El nom és massa curt',
      'emailLabel': 'Email',
      'registerEmailMustBeUab': 'Ha de ser un correu @uab.cat',
      'registerNiuInvalid': 'El NIU ha de tenir 7 dígits',
      'registerPasswordRequired': 'Introdueix una contrasenya',
      'registerPasswordMinLength':
      'La contrasenya ha de tenir com a mínim 6 caràcters',
      'confirmPasswordLabel': 'Repetir contrasenya',
      'confirmPasswordRequired': 'Repeteix la contrasenya',
      'passwordsDoNotMatch': 'Les contrasenyes no coincideixen',
      'registerButton': 'Registrar-se',
      'registerSuccess': 'Registre completat',
      'goToLogin': 'Ja tens compte? Inicia sessió',
    },
    'en': {
      'appName': 'UniLost & Found',
      'home': 'Home',
      'chats': 'Chats',
      'profile': 'Profile',
      'settings': 'Settings',
      'darkMode': 'Dark mode',
      'language': 'Language',
      'spanish': 'Spanish',
      'catalan': 'Catalan',
      'english': 'English',
      'publishedObjects': 'Published items',
      'futureOptions': 'Future app options',
      'userHistory': 'User history will appear here',
      'welcome': 'Welcome to ULF',
      'preview': 'Preview',
      'welcomeDescription':
      'Lost and found campus objects will appear here soon.',

      'loginTitleAppBar': 'Login',
      'loginTitle': 'Sign in',
      'loginSubtitle': 'Access with your UAB institutional email',
      'uabEmailLabel': 'UAB email',
      'loginEmailRequired': 'Enter your UAB email',
      'loginEmailInvalid': 'You must use a valid UAB email (NIU@uab.cat)',
      'passwordLabel': 'Password',
      'passwordRequired': 'Enter your password',
      'passwordMinLength': 'Minimum 6 characters',
      'loginButton': 'Log in',
      'goToRegister': 'Don’t have an account? Sign up',

      'registerTitleAppBar': 'Register',
      'registerTitle': 'Create account',
      'registerSubtitle': 'Fill in the data to register',
      'nameLabel': 'Name',
      'nameRequired': 'Enter your name',
      'nameTooShort': 'The name is too short',
      'emailLabel': 'Email',
      'registerEmailMustBeUab': 'It must be a @uab.cat email',
      'registerNiuInvalid': 'The NIU must have 7 digits',
      'registerPasswordRequired': 'Enter a password',
      'registerPasswordMinLength':
      'The password must be at least 6 characters long',
      'confirmPasswordLabel': 'Repeat password',
      'confirmPasswordRequired': 'Repeat the password',
      'passwordsDoNotMatch': 'Passwords do not match',
      'registerButton': 'Sign up',
      'registerSuccess': 'Registration completed',
      'goToLogin': 'Already have an account? Log in',
    },
  };

  String get appName => _text('appName');
  String get home => _text('home');
  String get chats => _text('chats');
  String get profile => _text('profile');
  String get settings => _text('settings');
  String get darkMode => _text('darkMode');
  String get language => _text('language');
  String get spanish => _text('spanish');
  String get catalan => _text('catalan');
  String get english => _text('english');
  String get publishedObjects => _text('publishedObjects');
  String get futureOptions => _text('futureOptions');
  String get userHistory => _text('userHistory');
  String get welcome => _text('welcome');
  String get preview => _text('preview');
  String get welcomeDescription => _text('welcomeDescription');

  String get loginTitleAppBar => _text('loginTitleAppBar');
  String get loginTitle => _text('loginTitle');
  String get loginSubtitle => _text('loginSubtitle');
  String get uabEmailLabel => _text('uabEmailLabel');
  String get loginEmailRequired => _text('loginEmailRequired');
  String get loginEmailInvalid => _text('loginEmailInvalid');
  String get passwordLabel => _text('passwordLabel');
  String get passwordRequired => _text('passwordRequired');
  String get passwordMinLength => _text('passwordMinLength');
  String get loginButton => _text('loginButton');
  String get goToRegister => _text('goToRegister');

  String get registerTitleAppBar => _text('registerTitleAppBar');
  String get registerTitle => _text('registerTitle');
  String get registerSubtitle => _text('registerSubtitle');
  String get nameLabel => _text('nameLabel');
  String get nameRequired => _text('nameRequired');
  String get nameTooShort => _text('nameTooShort');
  String get emailLabel => _text('emailLabel');
  String get registerEmailMustBeUab => _text('registerEmailMustBeUab');
  String get registerNiuInvalid => _text('registerNiuInvalid');
  String get registerPasswordRequired => _text('registerPasswordRequired');
  String get registerPasswordMinLength => _text('registerPasswordMinLength');
  String get confirmPasswordLabel => _text('confirmPasswordLabel');
  String get confirmPasswordRequired => _text('confirmPasswordRequired');
  String get passwordsDoNotMatch => _text('passwordsDoNotMatch');
  String get registerButton => _text('registerButton');
  String get registerSuccess => _text('registerSuccess');
  String get goToLogin => _text('goToLogin');

  String _text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['es']![key]!;
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'ca', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    return AppStrings(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}