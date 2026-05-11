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

      // 🔹 Categorías
      'keys': 'Llaves',
      'wallets': 'Carteras',
      'devices': 'Dispositivos',
      'phones': 'Móviles',
      'clothes': 'Ropa',
      'bottles': 'Botellas',
      'others': 'Otros',

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
      'dontHaveAccount': '¿No tienes cuenta? ',
      'signUpLink': 'Regístrate',
      'verifyEmailMessage': 'Debes verificar tu cuenta para acceder. Revisa tu correo.',
      'errorLoginGeneric': 'Error al iniciar sesión',
      'errorUserNotFound': 'No existe ningún usuario con este correo.',
      'errorWrongPassword': 'Contraseña incorrecta.',
      'errorInvalidEmail': 'El formato del correo no es válido.',
      'errorUserDisabled': 'Esta cuenta ha sido deshabilitada.',
      'errorTooManyRequests': 'Demasiados intentos. Inténtalo más tarde.',
      'errorUnexpected': 'Ha ocurrido un error inesperado.',
      'registerSuccessMessage': 'Registro exitoso. Por favor, verifica tu correo antes de entrar (revisa SPAM).',
      'errorAlreadyExists': 'Este correo ya está registrado. Intenta iniciar sesión.',
      'errorDomainNotAuthorized': 'Dominio no autorizado. Usa el correo @uab.cat.',
      'errorInvalidArgument': 'Datos inválidos. Revisa el formulario.',
      'errorUnavailable': 'Servidor fuera de línea. Inténtalo más tarde.',
      'errorConnection': 'Error de conexión.',
      'alreadyHaveAccount': '¿Ya tienes cuenta? ',
      'loginLink': 'Inicia sesión',
      'welcomeTagline': 'Encuentra tus objetos perdidos\nen el campus universitario',
      'emailHint': 'ej: 1234567@uab.cat',
      'nameHint': 'ej: Juan Pérez',
      'logoutTitle': '¿Cerrar sesión?',
      'logoutConfirmation': '¿Estás seguro de que quieres salir de ULF?',
      'cancel': 'Cancelar',
      'logout': 'Cerrar sesión',
      'reportFound': 'He encontrado algo',
      'reportLost': 'He perdido algo',
      'report': 'Reportar',
      'searchHint': 'Buscar objetos...',
      'recentObjects': 'Objetos recientes',
      'noObjectsIn': 'No hay objetos todavía en ',
      'noObjectsFound': 'No se encontraron objetos.',
      'lostStatus': 'PERDIDO',
      'foundStatus': 'ENCONTRADO',
      'defaultItemTitle': 'Objeto',
      'loading': 'Cargando...',
      'studentRole': 'Estudiante',
      'adminRole': 'Administrador',
      'defaultUserName': 'Usuario',
      'myActivity': 'Mi actividad',
      'myFindings': 'Mis hallazgos',
      'myLosses': 'Mis pérdidas',
      'settingsTitle': 'Ajustes',
      'editNameTitle': 'Editar nombre',
      'newNameLabel': 'Nuevo nombre',
      'save': 'Guardar',
      'messages': 'Mensajes',
      'mustLoginForChats': 'Debes iniciar sesión para ver tus chats.',
      'noMessagesYet': 'Sin mensajes todavía',
      'noChatsYet': 'No tienes mensajes todavía',
      'reportFoundTitle': 'Reportar hallazgo',
      'reportLostTitle': 'Reportar pérdida',
      'objectPhoto': 'Foto del objeto',
      'tapToTakePhoto': 'Toca para tomar una foto',
      'basicInfo': 'Información básica',
      'objectTitleLabel': 'Título del objeto',
      'objectTitleHint': 'Ej: Llavero de la UAB',
      'fieldRequired': 'Campo obligatorio',
      'category': 'Categoría',
      'descriptionDetails': 'Descripción y detalles',
      'descriptionHint': 'Describe el objeto y dónde lo encontraste...',
      'locationAndDate': 'Ubicación y fecha',
      'getCurrentLocation': 'Obtener ubicación actual',
      'locationObtained': 'Ubicación obtenida ✓',
      'locationError': 'No se pudo obtener la ubicación',
      'selectDate': 'Seleccionar fecha',
      'publishButton': 'Publicar anuncio',
      'selectCategoryAndDate': 'Selecciona categoría y fecha',
      'sessionError': 'Sesión no iniciada',
      'publishSuccessFound': '¡Objeto encontrado publicado!',
      'publishSuccessLost': '¡Alerta de pérdida publicada!',
      'publishError': 'Error al publicar',
      'loginRequiredToContact': 'Debes iniciar sesión para contactar.',
      'verifyEmailToChat': 'Debes verificar tu correo institucional antes de poder abrir un chat.',
      'cannotOpenChat': 'No se puede abrir el chat de este objeto.',
      'cannotChatSelf': 'No puedes abrir un chat contigo mismo.',
      'chatRecoverError': 'El chat no se pudo recuperar de la base de datos.',
      'chatOpenError': 'Error al abrir chat',
      'description': 'Descripción',
      'noDescription': 'Sin descripción',
      'location': 'Ubicación',
      'campusUab': 'UAB - Campus',
      'currentStatus': 'Estado actual',
      'openingChat': 'Abriendo chat...',
      'contactOwner': 'Contactar con el dueño',
      'statusMatched': 'Encontrado',
      'statusReturned': 'Devuelto',
      'statusInProcess': 'En proceso',
      'sendError': 'Error al enviar mensaje',
      'noMessagesYetDetail': 'Todavía no hay mensajes.',
      'typeMessageHint': 'Escribe un mensaje...',
      'editPostTitleLost': 'Editar petición',
      'editPostTitleFound': 'Editar objeto',
      'titleLabel': 'Título',
      'descriptionLabel': 'Descripción',
      'saveChanges': 'Guardar cambios',
      'deletePost': 'Eliminar publicación',
      'deleteConfirmationTitle': 'Eliminar publicación',
      'deleteConfirmationMessage': '¿Seguro que quieres eliminar esta publicación?',
      'updateSuccess': 'Publicación actualizada correctamente.',
      'deleteSuccess': 'Publicación eliminada.',
      'errorSaving': 'Error al guardar',
      'errorDeleting': 'Error al eliminar',
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

      // 🔹 Categorías
      'keys': 'Claus',
      'wallets': 'Carteres',
      'devices': 'Dispositius',
      'phones': 'Mòbils',
      'clothes': 'Roba',
      'bottles': 'Ampolles',
      'others': 'Altres',

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
      'dontHaveAccount': 'No tens compte? ',
      'signUpLink': 'Registra’t',
      'verifyEmailMessage': 'Has de verificar el teu compte per accedir. Revisa el teu correu.',
      'errorLoginGeneric': 'Error en iniciar la sessió',
      'errorUserNotFound': 'No existeix cap usuari amb aquest correu.',
      'errorWrongPassword': 'Contrasenya incorrecta.',
      'errorInvalidEmail': 'El format del correu no és vàlid.',
      'errorUserDisabled': 'Aquest compte ha estat deshabilitat.',
      'errorTooManyRequests': 'Masses intents. Torna-ho a provar més tard.',
      'errorUnexpected': 'S’ha produït un error inesperat.',
      'registerSuccessMessage': 'Registre correcte. Si us plau, verifica el teu correu abans d’entrar (revisa SPAM).',
      'errorAlreadyExists': 'Aquest correu ya està registrat. Prova d’iniciar la sessió.',
      'errorDomainNotAuthorized': 'Domini no autoritzat. Utilitza el correu @uab.cat.',
      'errorInvalidArgument': 'Dades invàlides. Revisa el formulari.',
      'errorUnavailable': 'Servidor fora de línia. Torna-ho a provar més tard.',
      'errorConnection': 'Error de connexió.',
      'alreadyHaveAccount': 'Ja tens compte? ',
      'loginLink': 'Inicia la sessió',
      'welcomeTagline': 'Troba els teus objectes perduts\nal campus universitari',
      'emailHint': 'ex: 1234567@uab.cat',
      'nameHint': 'ex: Joan Peris',
      'logoutTitle': 'Tancar la sessió?',
      'logoutConfirmation': 'Estàs segur que vols sortir de ULF?',
      'cancel': 'Cancel·lar',
      'logout': 'Tancar sessió',
      'reportFound': 'He trobat alguna cosa',
      'reportLost': 'He perdut alguna cosa',
      'report': 'Reportar',
      'searchHint': 'Cercar objectes...',
      'recentObjects': 'Objectes recents',
      'noObjectsIn': 'Encara no hi ha objectes a ',
      'noObjectsFound': 'No s’han trobat objectes.',
      'lostStatus': 'PERDUT',
      'foundStatus': 'TROBAT',
      'defaultItemTitle': 'Objecte',
      'loading': 'Carregant...',
      'studentRole': 'Estudiant',
      'adminRole': 'Administrador',
      'defaultUserName': 'Usuari',
      'myActivity': 'La meva activitat',
      'myFindings': 'Els meus trobats',
      'myLosses': 'Els meus perduts',
      'settingsTitle': 'Ajustos',
      'editNameTitle': 'Editar nom',
      'newNameLabel': 'Nou nom',
      'save': 'Desar',
      'messages': 'Missatges',
      'mustLoginForChats': 'Has d’iniciar la sessió per veure els teus xats.',
      'noMessagesYet': 'Sense missatges encara',
      'noChatsYet': 'Encara no tens missatges',
      'reportFoundTitle': 'Reportar troballa',
      'reportLostTitle': 'Reportar pèrdua',
      'objectPhoto': 'Foto de l’objecte',
      'tapToTakePhoto': 'Toca per fer una foto',
      'basicInfo': 'Informació bàsica',
      'objectTitleLabel': 'Títol de l’objecte',
      'objectTitleHint': 'ex: Llaver de la UAB',
      'fieldRequired': 'Camp obligatori',
      'category': 'Categoria',
      'descriptionDetails': 'Descripció i detalls',
      'descriptionHint': 'Descriu l’objecte i on l’has trobat...',
      'locationAndDate': 'Ubicació i data',
      'getCurrentLocation': 'Obtenir ubicació actual',
      'locationObtained': 'Ubicació obtinguda ✓',
      'locationError': 'No s’ha pogut obtenir la ubicació',
      'selectDate': 'Seleccionar data',
      'publishButton': 'Publicar anunci',
      'selectCategoryAndDate': 'Selecciona categoria i data',
      'sessionError': 'Sessió no iniciada',
      'publishSuccessFound': '¡Objecte trobat publicat!',
      'publishSuccessLost': '¡Alerta de pèrdua publicada!',
      'publishError': 'Error al publicar',
      'loginRequiredToContact': 'Has d’iniciar la sessió per contactar.',
      'verifyEmailToChat': 'Has de verificar el teu correu institucional abans de poder obrir un xat.',
      'cannotOpenChat': 'No es pot obrir el xat d’aquest objecte.',
      'cannotChatSelf': 'No pots obrir un xat amb tu mateix.',
      'chatRecoverError': 'El xat no s’ha pogut recuperar de la base de dades.',
      'chatOpenError': 'Error en obrir el xat',
      'description': 'Descripció',
      'noDescription': 'Sense descripció',
      'location': 'Ubicació',
      'campusUab': 'UAB - Campus',
      'currentStatus': 'Estat actual',
      'openingChat': 'Obrint xat...',
      'contactOwner': 'Contactar amb el propietari',
      'statusMatched': 'Trobat',
      'statusReturned': 'Retornat',
      'statusInProcess': 'En procés',
      'sendError': 'Error en enviar el missatge',
      'noMessagesYetDetail': 'Encara no hi ha missatges.',
      'typeMessageHint': 'Escriu un missatge...',
      'editPostTitleLost': 'Editar petició',
      'editPostTitleFound': 'Editar objecte',
      'titleLabel': 'Títol',
      'descriptionLabel': 'Descripció',
      'saveChanges': 'Desar canvis',
      'deletePost': 'Eliminar publicació',
      'deleteConfirmationTitle': 'Eliminar publicació',
      'deleteConfirmationMessage': 'Segur que vols eliminar aquesta publicació?',
      'updateSuccess': 'Publicació actualitzada correctament.',
      'deleteSuccess': 'Publicació eliminada.',
      'errorSaving': 'Error en desar',
      'errorDeleting': 'Error en eliminar',
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

      // 🔹 Categorías
      'keys': 'Keys',
      'wallets': 'Wallets',
      'devices': 'Devices',
      'phones': 'Phones',
      'clothes': 'Clothes',
      'bottles': 'Bottles',
      'others': 'Others',

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
      'dontHaveAccount': 'Don’t have an account? ',
      'signUpLink': 'Sign up',
      'verifyEmailMessage': 'You must verify your account to access. Check your email.',
      'errorLoginGeneric': 'Error logging in',
      'errorUserNotFound': 'No user exists with this email.',
      'errorWrongPassword': 'Wrong password.',
      'errorInvalidEmail': 'The email format is invalid.',
      'errorUserDisabled': 'This account has been disabled.',
      'errorTooManyRequests': 'Too many attempts. Try again later.',
      'errorUnexpected': 'An unexpected error occurred.',
      'registerSuccessMessage': 'Registration successful. Please verify your email before logging in (check SPAM).',
      'errorAlreadyExists': 'This email is already registered. Try logging in.',
      'errorDomainNotAuthorized': 'Unauthorized domain. Use your @uab.cat email.',
      'errorInvalidArgument': 'Invalid data. Please check the form.',
      'errorUnavailable': 'Server offline. Please try again later.',
      'errorConnection': 'Connection error.',
      'alreadyHaveAccount': 'Already have an account? ',
      'loginLink': 'Log in',
      'welcomeTagline': 'Find your lost items\non the university campus',
      'emailHint': 'ex: 1234567@uab.cat',
      'nameHint': 'ex: John Doe',
      'logoutTitle': 'Log out?',
      'logoutConfirmation': 'Are you sure you want to exit ULF?',
      'cancel': 'Cancel',
      'logout': 'Log out',
      'reportFound': 'I found something',
      'reportLost': 'I lost something',
      'report': 'Report',
      'searchHint': 'Search items...',
      'recentObjects': 'Recent items',
      'noObjectsIn': 'No items yet in ',
      'noObjectsFound': 'No items found.',
      'lostStatus': 'LOST',
      'foundStatus': 'FOUND',
      'defaultItemTitle': 'Item',
      'loading': 'Loading...',
      'studentRole': 'Student',
      'adminRole': 'Administrator',
      'defaultUserName': 'User',
      'myActivity': 'My activity',
      'myFindings': 'My findings',
      'myLosses': 'My losses',
      'settingsTitle': 'Settings',
      'editNameTitle': 'Edit name',
      'newNameLabel': 'New name',
      'save': 'Save',
      'messages': 'Messages',
      'mustLoginForChats': 'You must log in to see your chats.',
      'noMessagesYet': 'No messages yet',
      'noChatsYet': 'You have no messages yet',
      'reportFoundTitle': 'Report finding',
      'reportLostTitle': 'Report loss',
      'objectPhoto': 'Object photo',
      'tapToTakePhoto': 'Tap to take a photo',
      'basicInfo': 'Basic info',
      'objectTitleLabel': 'Object title',
      'objectTitleHint': 'ex: UAB keychain',
      'fieldRequired': 'Required field',
      'category': 'Category',
      'descriptionDetails': 'Description and details',
      'descriptionHint': 'Describe the object and where you found it...',
      'locationAndDate': 'Location and date',
      'getCurrentLocation': 'Get current location',
      'locationObtained': 'Location obtained ✓',
      'locationError': 'Could not get location',
      'selectDate': 'Select date',
      'publishButton': 'Publish ad',
      'selectCategoryAndDate': 'Select category and date',
      'sessionError': 'Session not started',
      'publishSuccessFound': '¡Found object published!',
      'publishSuccessLost': '¡Loss alert published!',
      'publishError': 'Error publishing',
      'loginRequiredToContact': 'You must log in to contact.',
      'verifyEmailToChat': 'You must verify your institutional email before opening a chat.',
      'cannotOpenChat': 'Cannot open the chat for this object.',
      'cannotChatSelf': 'You cannot open a chat with yourself.',
      'chatRecoverError': 'Chat could not be recovered from the database.',
      'chatOpenError': 'Error opening chat',
      'description': 'Description',
      'noDescription': 'No description',
      'location': 'Location',
      'campusUab': 'UAB - Campus',
      'currentStatus': 'Current status',
      'openingChat': 'Opening chat...',
      'contactOwner': 'Contact owner',
      'statusMatched': 'Found',
      'statusReturned': 'Returned',
      'statusInProcess': 'In process',
      'sendError': 'Error sending message',
      'noMessagesYetDetail': 'No messages yet.',
      'typeMessageHint': 'Type a message...',
      'editPostTitleLost': 'Edit request',
      'editPostTitleFound': 'Edit item',
      'titleLabel': 'Title',
      'descriptionLabel': 'Description',
      'saveChanges': 'Save changes',
      'deletePost': 'Delete publication',
      'deleteConfirmationTitle': 'Delete publication',
      'deleteConfirmationMessage': 'Are you sure you want to delete this publication?',
      'updateSuccess': 'Publication updated successfully.',
      'deleteSuccess': 'Publication deleted.',
      'errorSaving': 'Error saving',
      'errorDeleting': 'Error deleting',
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

  // 🔹 Getters categorías
  String get keys => _text('keys');
  String get wallets => _text('wallets');
  String get devices => _text('devices');
  String get phones => _text('phones');
  String get clothes => _text('clothes');
  String get bottles => _text('bottles');
  String get others => _text('others');

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

  String get dontHaveAccount => _text('dontHaveAccount');
  String get signUpLink => _text('signUpLink');
  String get verifyEmailMessage => _text('verifyEmailMessage');
  String get errorLoginGeneric => _text('errorLoginGeneric');
  String get errorUserNotFound => _text('errorUserNotFound');
  String get errorWrongPassword => _text('errorWrongPassword');
  String get errorInvalidEmail => _text('errorInvalidEmail');
  String get errorUserDisabled => _text('errorUserDisabled');
  String get errorTooManyRequests => _text('errorTooManyRequests');
  String get errorUnexpected => _text('errorUnexpected');

  String get registerSuccessMessage => _text('registerSuccessMessage');
  String get errorAlreadyExists => _text('errorAlreadyExists');
  String get errorDomainNotAuthorized => _text('errorDomainNotAuthorized');
  String get errorInvalidArgument => _text('errorInvalidArgument');
  String get errorUnavailable => _text('errorUnavailable');
  String get errorConnection => _text('errorConnection');
  String get alreadyHaveAccount => _text('alreadyHaveAccount');
  String get loginLink => _text('loginLink');
  String get welcomeTagline => _text('welcomeTagline');
  String get emailHint => _text('emailHint');
  String get nameHint => _text('nameHint');
  String get logoutTitle => _text('logoutTitle');
  String get logoutConfirmation => _text('logoutConfirmation');
  String get cancel => _text('cancel');
  String get logout => _text('logout');
  String get reportFound => _text('reportFound');
  String get reportLost => _text('reportLost');
  String get report => _text('report');
  String get searchHint => _text('searchHint');
  String get recentObjects => _text('recentObjects');
  String get noObjectsIn => _text('noObjectsIn');
  String get noObjectsFound => _text('noObjectsFound');
  String get lostStatus => _text('lostStatus');
  String get foundStatus => _text('foundStatus');
  String get defaultItemTitle => _text('defaultItemTitle');
  String get loading => _text('loading');
  String get studentRole => _text('studentRole');
  String get adminRole => _text('adminRole');
  String get defaultUserName => _text('defaultUserName');
  String get myActivity => _text('myActivity');
  String get myFindings => _text('myFindings');
  String get myLosses => _text('myLosses');
  String get settingsTitle => _text('settingsTitle');
  String get editNameTitle => _text('editNameTitle');
  String get newNameLabel => _text('newNameLabel');
  String get save => _text('save');
  String get messages => _text('messages');
  String get mustLoginForChats => _text('mustLoginForChats');
  String get noMessagesYet => _text('noMessagesYet');
  String get noChatsYet => _text('noChatsYet');
  String get reportFoundTitle => _text('reportFoundTitle');
  String get reportLostTitle => _text('reportLostTitle');
  String get objectPhoto => _text('objectPhoto');
  String get tapToTakePhoto => _text('tapToTakePhoto');
  String get basicInfo => _text('basicInfo');
  String get objectTitleLabel => _text('objectTitleLabel');
  String get objectTitleHint => _text('objectTitleHint');
  String get fieldRequired => _text('fieldRequired');
  String get category => _text('category');
  String get descriptionDetails => _text('descriptionDetails');
  String get descriptionHint => _text('descriptionHint');
  String get locationAndDate => _text('locationAndDate');
  String get getCurrentLocation => _text('getCurrentLocation');
  String get locationObtained => _text('locationObtained');
  String get locationError => _text('locationError');
  String get selectDate => _text('selectDate');
  String get publishButton => _text('publishButton');
  String get selectCategoryAndDate => _text('selectCategoryAndDate');
  String get sessionError => _text('sessionError');
  String get publishSuccessFound => _text('publishSuccessFound');
  String get publishSuccessLost => _text('publishSuccessLost');
  String get publishError => _text('publishError');
  String get loginRequiredToContact => _text('loginRequiredToContact');
  String get verifyEmailToChat => _text('verifyEmailToChat');
  String get cannotOpenChat => _text('cannotOpenChat');
  String get cannotChatSelf => _text('cannotChatSelf');
  String get chatRecoverError => _text('chatRecoverError');
  String get chatOpenError => _text('chatOpenError');
  String get description => _text('description');
  String get noDescription => _text('noDescription');
  String get location => _text('location');
  String get campusUab => _text('campusUab');
  String get currentStatus => _text('currentStatus');
  String get openingChat => _text('openingChat');
  String get contactOwner => _text('contactOwner');
  String get statusMatched => _text('statusMatched');
  String get statusReturned => _text('statusReturned');
  String get statusInProcess => _text('statusInProcess');
  String get sendError => _text('sendError');
  String get noMessagesYetDetail => _text('noMessagesYetDetail');
  String get typeMessageHint => _text('typeMessageHint');
  String get editPostTitleLost => _text('editPostTitleLost');
  String get editPostTitleFound => _text('editPostTitleFound');
  String get titleLabel => _text('titleLabel');
  String get descriptionLabel => _text('descriptionLabel');
  String get saveChanges => _text('saveChanges');
  String get deletePost => _text('deletePost');
  String get deleteConfirmationTitle => _text('deleteConfirmationTitle');
  String get deleteConfirmationMessage => _text('deleteConfirmationMessage');
  String get updateSuccess => _text('updateSuccess');
  String get deleteSuccess => _text('deleteSuccess');
  String get errorSaving => _text('errorSaving');
  String get errorDeleting => _text('errorDeleting');

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