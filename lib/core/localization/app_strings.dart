import 'package:flutter/material.dart';

/// ============================================================================
/// 📖 GUÍA DE FLUJO DE TRABAJO PARA INTERNACIONALIZACIÓN (l10n)
/// ============================================================================
/// Esta aplicación utiliza un sistema de localización personalizado y estático
/// a través de la clase [AppStrings]. Para agregar una nueva traducción de forma
/// segura, siga estos pasos rigurosos:
///
/// 1. REGISTRAR CLAVE EN LOS MAPAS DE IDIOMA:
///    Vaya al mapa estático [_localizedValues] y agregue la nueva clave en los
///    tres idiomas soportados ('es' - Castellano, 'ca' - Catalán, 'en' - Inglés).
///    Ejemplo:
///    ```dart
///    // En 'es' (Castellano):
///    'miNuevaClave': 'Mi texto traducido',
///    // En 'ca' (Catalán):
///    'miNuevaClave': 'El meu text traduït',
///    // En 'en' (Inglés):
///    'miNuevaClave': 'My translated text',
///    ```
///
/// 2. AGREGAR UN GETTER O MÉTODO PÚBLICO:
///    En la sección intermedia de la clase [AppStrings] (donde se definen los getters),
///    agregue un acceso público utilizando el método auxiliar [_text]:
///    * Si el texto es plano:
///      ```dart
///      String get miNuevaClave => _text('miNuevaClave');
///      ```
///    * Si el texto requiere interpolación dinámica (ej. contiene un parámetro `{valor}`):
///      ```dart
///      String get miNuevaClaveRaw => _text('miNuevaClave');
///      String miNuevaClave(String valor) => miNuevaClaveRaw.replaceAll('{valor}', valor);
///      ```
///
/// 3. CONSUMIR EN LA CAPA DE PRESENTACIÓN:
///    Importe este archivo en la vista y consuma la cadena utilizando el BuildContext:
///    ```dart
///    final t = AppStrings.of(context);
///    Text(t.miNuevaClave)
///    ```
///
/// ============================================================================
/// 🔄 FLUJO DE CAMBIO DE IDIOMA DINÁMICO (i18n)
/// ============================================================================
/// El cambio de idioma en caliente de la aplicación se gestiona de la siguiente manera:
/// 1. El widget [LanguageSelectorWidget] renderiza la interfaz del selector. Al
///    pulsar un idioma, llama a `AppSettingsController.setLocale(Locale)`.
/// 2. [AppSettingsController] cambia su estado interno de `locale`, persiste la
///    preferencia en la caché local (`SharedPreferences`) y notifica a los oyentes.
/// 3. Si el usuario está autenticado, el selector también guarda el código de idioma
///    en Firebase Realtime Database bajo el nodo del usuario (`/users/{uid}/preferredLanguage`).
/// 4. El punto de entrada [MyApp] en `app.dart` escucha cambios del controlador
///    y desencadena un rebuild completo del árbol. El `MaterialApp` recibe el nuevo
///    `locale` y reconstruye la instancia de [AppStrings] mediante el delegado
///    [_AppStringsDelegate], cargando dinámicamente las cadenas traducidas desde
///    el mapa [_localizedValues].
/// ============================================================================

/// [AppStrings] centraliza y expone todos los textos e internacionalización (l10n)
/// de la aplicación en Castellano (español), Catalán e Inglés.
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
      'appTheme': 'Tema de la aplicación',
      'themeLight': 'Claro',
      'themeDark': 'Oscuro',
      'themeSystem': 'Sistema',
      'language': 'Idioma',
      'spanish': 'Español',
      'catalan': 'Catalán',
      'english': 'Inglés',
      'publishedObjects': 'Objetos publicados',
      'futureOptions': 'Opciones futuras de la aplicación',
      'welcome': 'Bienvenido a ULF',
      'preview': 'Vista previa',
      'welcomeDescription':
      'Aquí aparecerán próximamente los objetos perdidos y encontrados del campus.',

      // 🔹 Categorías
      'accessories': 'Accesorios',
      'clothes': 'Ropa',
      'devices': 'Dispositivos',
      'wallets': 'Carteras',
      'keys': 'Llaves',
      'bags': 'Bolsas y Mochilas',
      'study': 'Material de Estudio',
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
      'errorLoginGeneric': 'Por favor, verifica tus credenciales e inténtalo de nuevo.',
      'errorUserNotFound': 'No hemos encontrado ninguna cuenta con este correo. Por favor, regístrate.',
      'errorWrongPassword': 'La contraseña no es correcta. Por favor, comprueba que esté bien escrita.',
      'errorInvalidEmail': 'El formato del correo no es válido. Por favor, usa uno correcto.',
      'errorUserDisabled': 'Esta cuenta ha sido deshabilitada. Por favor, contacta con soporte.',
      'errorTooManyRequests': 'Demasiados intentos. Por favor, espera unos minutos antes de reintentar.',
      'errorUnexpected': 'Ha ocurrido un error inesperado. Por favor, inténtalo más tarde.',
      'registerSuccessMessage': 'Registro exitoso. Por favor, verifica tu correo antes de entrar (revisa SPAM).',
      'errorAlreadyExists': 'Este correo ya está registrado. Por favor, intenta iniciar sesión.',
      'errorDomainNotAuthorized': 'Dominio no autorizado. Por favor, usa el correo @uab.cat.',
      'errorInvalidArgument': 'Datos inválidos. Por favor, revisa el formulario.',
      'errorUnavailable': 'Servidor fuera de línea. Por favor, inténtalo en unos minutos.',
      'errorConnection': 'Error de conexión. Por favor, comprueba tu acceso a internet.',
      'errorWeakPassword': 'La contraseña es demasiado débil. Por favor, usa una más compleja.',
      'errorNetworkFailed': 'Error de red. Por favor, comprueba tu conexión e inténtalo de nuevo.',
      'alreadyHaveAccount': '¿Ya tienes cuenta? ',
      'loginLink': 'Inicia sesión',
      'welcomeTagline': 'Encuentra tus objetos perdidos\nen el campus universitario',
      'emailHint': 'Ej: 1234567@uab.cat',
      'passwordHint': 'Ej: ••••••••',
      'confirmPasswordHint': 'Repite tu contraseña',
      'nameHint': 'Ej: Elena Nito',
      'logoutTitle': '¿Cerrar sesión?',
      'logoutConfirmation': '¿Estás seguro de que quieres salir de ULF?',
      'cancel': 'Cancelar',
      'logout': 'Cerrar sesión',
      'reportFound': 'He encontrado algo',
      'reportLost': 'He perdido algo',
      'report': 'Reportar',
      'searchHint': 'Buscar objetos...',
      'recentObjects': 'Objetos recientes',
      'noObjectsIn': 'No hay objetos todavía en {center}',
      'noObjectsFound': 'No se encontraron objetos.',
      'noObjectsFoundForTitle': 'No se encontraron objetos para {title}.',
      'campusLocationDetail': 'Cerdanyola del Vallès, Barcelona',
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
      'camera': 'Cámara',
      'gallery': 'Galería',
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
      'dateLabel': 'Fecha',
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
      'statusSearching': 'Buscando',
      'statusMatched': 'Posible coincidencia',
      'statusReturned': 'Devuelto',
      'statusInProcess': 'En proceso',
      'possible_match_badge': 'Posible coincidencia',
      'possible_match_detail_banner': 'Esta publicación tiene una posible coincidencia con otro objeto.',
      'sendError': 'Error al enviar mensaje',
      'noMessagesYetDetail': 'Todavía no hay mensajes.',
      'typeMessageHint': 'Escribe un mensaje...',
      'editPostTitleLost': 'Editar petición',
      'editPostTitleFound': 'Editar objeto',
      'titleLabel': 'Título',
      'descriptionLabel': 'Descripción',
      'locationLabel': 'Ubicación',
      'saveChanges': 'Guardar cambios',
      'deletePost': 'Eliminar publicación',
      'deleteConfirmationTitle': 'Eliminar publicación',
      'deleteConfirmationMessage': '¿Seguro que quieres eliminar esta publicación?',
      'updateSuccess': 'Publicación actualizada correctamente.',
      'profile_updated_success': 'Perfil actualizado correctamente.',
      'deleteSuccess': 'Publicación eliminada.',
      'errorSaving': 'Error al guardar',
      'errorDeleting': 'Error al eliminar',
      'mustLogin': 'Debes iniciar sesión para ver tus publicaciones.',
      'sessionExpired': 'Tu sesión ha caducado por seguridad después de 14 días. Por favor, inicia sesión de nuevo.',
      'optional': '(Opcional)',
      'recommended': '(Recomendable)',
      'unsupportedFormat': 'Formato no soportado. Usa JPG o PNG.',
      'editPhotoSuccess': 'Foto de perfil actualizada.',
      'uabAcronym': 'UAB',
      'lostAndFound': 'Lost & Found',
      'chatStarted': 'Conversación iniciada',
      'errorImageUpload': 'Error al subir la imagen. Inténtalo de nuevo.',
      'locationOptional': 'Ubicación (Opcional)',
      'gpsLocation': 'GPS Actual',
      'mapLocation': 'Seleccionar en Mapa',
      'outsideBoundsError': 'Estás fuera del perímetro permitido para el centro {center}',
      'centerLocationError': 'No se pudo cargar la ubicación del centro',
      'error_location_outside_center': 'La ubicación debe estar dentro del recinto del centro.',
      'error_location_outside_recinct': 'La ubicación está fuera del recinto universitario permitido.',
      'post_published_success': '¡Publicación creada con éxito!',
      'post_edited_success': 'Publicación editada con éxito.',
      'post_deleted_success': 'Publicación eliminada con éxito.',
      'imageMessage': '📷 Imagen',
      'matcherTitle': '¡Posibles coincidencias!',
      'matcherSubtitle': 'Hemos encontrado objetos similares en el sistema. ¿Es alguno de estos?',
      'matcherViewButton': 'Ver detalle',
      'matcherIgnoreButton': 'Ignorar y publicar',
      'notifications_title': 'Notificaciones',
      'no_notifications': 'No tienes notificaciones nuevas.',
      'all_notifications_read': 'Todas las notificaciones marcadas como leídas.',
      'mark_all_as_read': 'Marcar todo como leído',
      'default_notification_title': 'Alerta ULF',
      'time_minutes_ago_singular': 'hace {count} minuto',
      'time_minutes_ago_plural': 'hace {count} minutos',
      'time_hours_ago_singular': 'hace {count} hora',
      'time_hours_ago_plural': 'hace {count} horas',
      'settings_push_toggle': 'Recibir notificaciones push',
      'settings_push_desc': 'Avisos de mensajes y coincidencias.',
      'customerSupport': 'Atención al Cliente',
      'supportHelpText': 'Si necesitas ayuda, puedes contactar con nosotros a través de los siguientes medios:',
      'email': 'Correo Electrónico',
      'phone': 'Teléfono',
      'close': 'Cerrar',
      'termsAndConditions': 'Términos y Condiciones',
      'privacyPolicy': 'Política de Privacidad',
      'acceptTermsPrefix': 'Acepto los ',
      'acceptPrivacyPrefix': 'Acepto la ',
      'legalLoadError': 'No se pudo cargar el documento legal. Por favor, inténtelo de nuevo más tarde.',
      'legalUpdateRequiredTitle': 'Actualización de Políticas',
      'legalUpdateRequiredDesc': 'Para continuar usando UniLost & Found, por favor lee y acepta nuestros nuevos Términos y Condiciones y la Política de Privacidad.',
      'acceptAndContinue': 'Aceptar y continuar',
      'termsErrorNotAccepted': 'Debes aceptar los Términos y la Política de Privacidad para continuar.',
      'legalUnavailable': 'El documento legal no se encuentra disponible en este momento.',
      'chat_status_deleted': 'Este objeto ha sido eliminado.',
      'chat_status_resolved': 'Este objeto ha sido devuelto.',
      'recentSort': 'Recientes',
      'proximitySort': 'Cercanía',
      'locationPermissionDenied': 'Permiso de ubicación denegado. No se puede ordenar por cercanía.',
      'faqsLink': 'Preguntas Frecuentes',
    },
    'ca': {
      'appName': 'UniLost & Found',
      'home': 'Inici',
      'chats': 'Xats',
      'profile': 'Perfil',
      'settings': 'Configuració',
      'darkMode': 'Mode fosc',
      'appTheme': 'Tema de l\'aplicació',
      'themeLight': 'Clar',
      'themeDark': 'Fosc',
      'themeSystem': 'Sistema',
      'language': 'Idioma',
      'spanish': 'Espanyol',
      'catalan': 'Català',
      'english': 'Anglès',
      'publishedObjects': 'Objectes publicats',
      'futureOptions': 'Opcions futures de l’aplicació',
      'welcome': 'Benvingut a ULF',
      'preview': 'Vista prèvia',
      'welcomeDescription':
      'Aquí apareixeran pròximament els objectes perduts i trobats del campus.',

      // 🔹 Categorías
      'accessories': 'Accessoris',
      'clothes': 'Roba',
      'devices': 'Dispositius',
      'wallets': 'Carteres',
      'keys': 'Claus',
      'bags': 'Bosses i Motxilles',
      'study': 'Material d’Estudi',
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
      'errorLoginGeneric': 'Si us plau, verifica les teves credencials i torna-ho a provar.',
      'errorUserNotFound': 'No hem trobat cap compte amb aquest correu. Si us plau, registra’t.',
      'errorWrongPassword': 'La contrasenya no és correcta. Si us plau, comprova que estigui ben escrita.',
      'errorInvalidEmail': 'El format del correu no és vàlid. Si us plau, utilitza’n un de correcte.',
      'errorUserDisabled': 'Aquest compte ha estat deshabilitat. Si us plau, contacta amb suport.',
      'errorTooManyRequests': 'Masses intents. Si us plau, espera uns minuts abans de tornar-ho a provar.',
      'errorUnexpected': 'S’ha produït un error inesperat. Si us plau, torna-ho a provar més tard.',
      'registerSuccessMessage': 'Registre correcte. Si us plau, verifica el teu correu abans d’entrar (revisa SPAM).',
      'errorAlreadyExists': 'Aquest correu ja està registrat. Si us plau, prova d’iniciar la sessió.',
      'errorDomainNotAuthorized': 'Domini no autoritzat. Si us plau, utilitza el correu @uab.cat.',
      'errorInvalidArgument': 'Dades invàlides. Si us plau, revisa el formulari.',
      'errorUnavailable': 'Servidor fora de línia. Si us plau, torna-ho a provar en uns minuts.',
      'errorConnection': 'Error de connexió. Si us plau, comprova el teu accés a internet.',
      'errorWeakPassword': 'La contrasenya és massa feble. Si us plau, utilitza’n una de més complexa.',
      'errorNetworkFailed': 'Error de xarxa. Si us plau, comprova la teva connexió i torna-ho a provar.',
      'alreadyHaveAccount': 'Ja tens compte? ',
      'loginLink': 'Inicia la sessió',
      'welcomeTagline': 'Troba els teus objectes perduts\nal campus universitari',
      'emailHint': 'Ex: 1234567@uab.cat',
      'passwordHint': 'Ex: ••••••••',
      'confirmPasswordHint': 'Repeteix la contrasenya',
      'nameHint': 'Ex: Santi Amén',
      'logoutTitle': 'Tancar la sessió?',
      'logoutConfirmation': 'Estàs segur que vols sortir de ULF?',
      'cancel': 'Cancel·lar',
      'logout': 'Tancar sessió',
      'reportFound': 'He trobat alguna cosa',
      'reportLost': 'He perdut alguna cosa',
      'report': 'Reportar',
      'searchHint': 'Cercar objectes...',
      'recentObjects': 'Objectes recents',
      'noObjectsIn': 'Encara no hi ha objectes a {center}',
      'noObjectsFound': 'No s’han trobat objectes.',
      'noObjectsFoundForTitle': 'No s’han trobat objectes per a {title}.',
      'campusLocationDetail': 'Cerdanyola del Vallès, Barcelona',
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
      'camera': 'Càmera',
      'gallery': 'Galeria',
      'basicInfo': 'Informació bàsica',
      'objectTitleLabel': 'Títol de l’objecte',
      'objectTitleHint': 'ex: Clauer de la UAB',
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
      'dateLabel': 'Data',
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
      'statusSearching': 'Buscant',
      'statusMatched': 'Possible coincidència',
      'statusReturned': 'Retornat',
      'statusInProcess': 'En procés',
      'possible_match_badge': 'Possible coincidència',
      'possible_match_detail_banner': 'Aquesta publicació té una possible coincidència amb un altre objecte.',
      'sendError': 'Error en enviar el missatge',
      'noMessagesYetDetail': 'Encara no hi ha missatges.',
      'typeMessageHint': 'Escriu un missatge...',
      'editPostTitleLost': 'Editar petició',
      'editPostTitleFound': 'Editar objecte',
      'titleLabel': 'Títol',
      'descriptionLabel': 'Descripció',
      'locationLabel': 'Ubicació',
      'saveChanges': 'Desar canvis',
      'deletePost': 'Eliminar publicació',
      'deleteConfirmationTitle': 'Eliminar publicació',
      'deleteConfirmationMessage': 'Segur que vols eliminar aquesta publicació?',
      'updateSuccess': 'Publicació actualitzada correctament.',
      'profile_updated_success': 'Perfil actualitzat correctament.',
      'deleteSuccess': 'Publicació eliminada.',
      'errorSaving': 'Error en desar',
      'errorDeleting': 'Error en eliminar',
      'mustLogin': 'Has d’iniciar la sessió per veure les teves publicacions.',
      'sessionExpired': 'La teva sessió ha caducat per seguretat després de 14 dies. Si us plau, inicia la sessió de nou.',
      'optional': '(Opcional)',
      'recommended': '(Recomanable)',
      'unsupportedFormat': 'Format no suportat. Usa JPG o PNG.',
      'editPhotoSuccess': 'Foto de perfil actualitzada.',
      'uabAcronym': 'UAB',
      'lostAndFound': 'Lost & Found',
      'chatStarted': 'Conversa iniciada',
      'errorImageUpload': 'Error en pujar la imatge. Torna-ho a provar.',
      'locationOptional': 'Ubicació (Opcional)',
      'gpsLocation': 'GPS Actual',
      'mapLocation': 'Seleccionar en Mapa',
      'outsideBoundsError': 'Estàs fora del perímetre permès per al centre {center}',
      'centerLocationError': "No s'ha pogut carregar la ubicació del centre",
      'error_location_outside_center': "La ubicació ha d'estar dins del recinte del centre.",
      'error_location_outside_recinct': "La ubicació està fora del recinte universitari permès.",
      'post_published_success': '¡Publicació creada amb èxit!',
      'post_edited_success': 'Publicació editada amb èxit.',
      'post_deleted_success': 'Publicació eliminada amb èxit.',
      'imageMessage': '📷 Imatge',
      'matcherTitle': 'Possibles coincidències!',
      'matcherSubtitle': "Hem trobat objectes similars al sistema. És algun d'aquests?",
      'matcherViewButton': 'Veure detall',
      'matcherIgnoreButton': 'Ignorar i publicar',
      'notifications_title': 'Notificacions',
      'no_notifications': 'No tens cap notificació nova.',
      'all_notifications_read': 'Totes les notificacions marcades com a llegides.',
      'mark_all_as_read': 'Marcar-ho tot com a llegit',
      'default_notification_title': 'Alerta ULF',
      'time_minutes_ago_singular': 'fa {count} minut',
      'time_minutes_ago_plural': 'fa {count} minuts',
      'time_hours_ago_singular': 'fa {count} hora',
      'time_hours_ago_plural': 'fa {count} hores',
      'settings_push_toggle': 'Rebre notificacions push',
      'settings_push_desc': 'Avisos de missatges i coincidències.',
      'customerSupport': 'Atenció al Client',
      'supportHelpText': 'Si necessites ajuda, pots contactar amb nosaltres a través dels següents mitjans:',
      'email': 'Correu Electrònic',
      'phone': 'Telèfon',
      'close': 'Tancar',
      'termsAndConditions': 'Termes i Condicions',
      'privacyPolicy': 'Política de Privacitat',
      'acceptTermsPrefix': 'Accepto els ',
      'acceptPrivacyPrefix': 'Accepto la ',
      'legalLoadError': 'No s\'ha pogut carregar el document legal. Si us puau, torneu-ho a provar més tard.',
      'legalUpdateRequiredTitle': 'Actualització de Polítiques',
      'legalUpdateRequiredDesc': 'Per continuar utilitzant UniLost & Found, si us plau llegeix i accepta els nostres nous Termes i Condicions i la Política de Privacitat.',
      'acceptAndContinue': 'Acceptar i continuar',
      'termsErrorNotAccepted': 'Has d\'acceptar els Termes i la Política de Privacitat per continuar.',
      'legalUnavailable': 'El document legal no es troba disponible en aquest moment.',
      'chat_status_deleted': 'Aquest objecte ha estat eliminat.',
      'chat_status_resolved': 'Aquest objecte ha estat retornat.',
      'recentSort': 'Recents',
      'proximitySort': 'Proximitat',
      'locationPermissionDenied': 'Permís d\'ubicació denegat. No es pot ordenar per proximitat.',
      'faqsLink': 'Preguntes Freqüents',
    },
    'en': {
      'appName': 'UniLost & Found',
      'home': 'Home',
      'chats': 'Chats',
      'profile': 'Profile',
      'settings': 'Settings',
      'darkMode': 'Dark mode',
      'appTheme': 'Application theme',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'language': 'Language',
      'spanish': 'Spanish',
      'catalan': 'Catalan',
      'english': 'English',
      'publishedObjects': 'Published items',
      'futureOptions': 'Future app options',
      'welcome': 'Welcome to ULF',
      'preview': 'Preview',
      'welcomeDescription':
      'Lost and found campus objects will appear here soon.',

      // 🔹 Categorías
      'accessories': 'Accessories',
      'clothes': 'Clothes',
      'devices': 'Devices',
      'wallets': 'Wallets',
      'keys': 'Keys',
      'bags': 'Bags and Backpacks',
      'study': 'Study Material',
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
      'errorLoginGeneric': 'Please verify your credentials and try again.',
      'errorUserNotFound': 'We could not find any account with this email. Please sign up.',
      'errorWrongPassword': 'The password is incorrect. Please check that it is spelled correctly.',
      'errorInvalidEmail': 'The email format is invalid. Please use a correct one.',
      'errorUserDisabled': 'This account has been disabled. Please contact support.',
      'errorTooManyRequests': 'Too many attempts. Please wait a few minutes before trying again.',
      'errorUnexpected': 'An unexpected error occurred. Please try again later.',
      'registerSuccessMessage': 'Registration successful. Please verify your email before logging in (check SPAM).',
      'errorAlreadyExists': 'This email is already registered. Please try logging in.',
      'errorDomainNotAuthorized': 'Unauthorized domain. Please use your @uab.cat email.',
      'errorInvalidArgument': 'Invalid data. Please check the form.',
      'errorUnavailable': 'Server offline. Please try again in a few minutes.',
      'errorConnection': 'Connection error. Please check your internet access.',
      'errorWeakPassword': 'The password is too weak. Please use a more complex one.',
      'errorNetworkFailed': 'Network error. Please check your connection and try again.',
      'alreadyHaveAccount': 'Already have an account? ',
      'loginLink': 'Log in',
      'welcomeTagline': 'Find your lost items\non the university campus',
      'emailHint': 'e.g. 1234567@uab.cat',
      'passwordHint': 'e.g. ••••••••',
      'confirmPasswordHint': 'Repeat your password',
      'nameHint': 'e.g. Justin Case',
      'logoutTitle': 'Log out?',
      'logoutConfirmation': 'Are you sure you want to exit ULF?',
      'cancel': 'Cancel',
      'logout': 'Log out',
      'reportFound': 'I found something',
      'reportLost': 'I lost something',
      'report': 'Report',
      'searchHint': 'Search items...',
      'recentObjects': 'Recent items',
      'noObjectsIn': 'No items yet in {center}',
      'noObjectsFound': 'No items found.',
      'noObjectsFoundForTitle': 'No items found for {title}.',
      'campusLocationDetail': 'Cerdanyola del Vallès, Barcelona',
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
      'camera': 'Camera',
      'gallery': 'Gallery',
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
      'dateLabel': 'Date',
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
      'statusSearching': 'Searching',
      'statusMatched': 'Possible match',
      'statusReturned': 'Returned',
      'statusInProcess': 'In process',
      'possible_match_badge': 'Possible match',
      'possible_match_detail_banner': 'This post has a possible match with another item.',
      'sendError': 'Error sending message',
      'noMessagesYetDetail': 'No messages yet.',
      'typeMessageHint': 'Type a message...',
      'editPostTitleLost': 'Edit request',
      'editPostTitleFound': 'Edit item',
      'titleLabel': 'Title',
      'descriptionLabel': 'Description',
      'locationLabel': 'Location',
      'saveChanges': 'Save changes',
      'deletePost': 'Delete publication',
      'deleteConfirmationTitle': 'Delete publication',
      'deleteConfirmationMessage': 'Are you sure you want to delete this publication?',
      'updateSuccess': 'Publication updated successfully.',
      'profile_updated_success': 'Profile updated successfully.',
      'deleteSuccess': 'Publication deleted.',
      'errorSaving': 'Error saving',
      'errorDeleting': 'Error deleting',
      'mustLogin': 'You must log in to see your posts.',
      'sessionExpired': 'Your session has expired for security after 14 days. Please log in again.',
      'optional': '(Optional)',
      'recommended': '(Recommended)',
      'unsupportedFormat': 'Unsupported format. Use JPG or PNG.',
      'editPhotoSuccess': 'Profile picture updated.',
      'uabAcronym': 'UAB',
      'lostAndFound': 'Lost & Found',
      'chatStarted': 'Chat started',
      'errorImageUpload': 'Error uploading image. Please try again.',
      'locationOptional': 'Location (Optional)',
      'gpsLocation': 'Current GPS',
      'mapLocation': 'Select on Map',
      'outsideBoundsError': 'You are outside the allowed perimeter for center {center}',
      'centerLocationError': 'Could not load center location',
      'error_location_outside_center': "Location must be within the center's premises.",
      'error_location_outside_recinct': 'The location is outside the allowed university recinct.',
      'post_published_success': 'Post published successfully!',
      'post_edited_success': 'Post edited successfully.',
      'post_deleted_success': 'Post deleted successfully.',
      'imageMessage': '📷 Image',
      'matcherTitle': 'Potential matches!',
      'matcherSubtitle': 'We found similar items in the system. Is it one of these?',
      'matcherViewButton': 'View detail',
      'matcherIgnoreButton': 'Ignore and publish',
      'notifications_title': 'Notifications',
      'no_notifications': 'No new notifications.',
      'all_notifications_read': 'All notifications marked as read.',
      'mark_all_as_read': 'Mark all as read',
      'default_notification_title': 'ULF Alert',
      'time_minutes_ago_singular': '{count} minute ago',
      'time_minutes_ago_plural': '{count} minutes ago',
      'time_hours_ago_singular': '{count} hour ago',
      'time_hours_ago_plural': '{count} hours ago',
      'settings_push_toggle': 'Receive push notifications',
      'settings_push_desc': 'Messages and matches.',
      'customerSupport': 'Customer Support',
      'supportHelpText': 'If you need help, you can contact us through the following channels:',
      'email': 'Email',
      'phone': 'Phone',
      'close': 'Close',
      'termsAndConditions': 'Terms and Conditions',
      'privacyPolicy': 'Privacy Policy',
      'acceptTermsPrefix': 'I accept the ',
      'acceptPrivacyPrefix': 'I accept the ',
      'legalLoadError': 'Could not load the legal document. Please try again later.',
      'legalUpdateRequiredTitle': 'Policy Update',
      'legalUpdateRequiredDesc': 'To continue using UniLost & Found, please read and accept our new Terms and Conditions and Privacy Policy.',
      'acceptAndContinue': 'Accept and continue',
      'termsErrorNotAccepted': 'You must accept the Terms and Privacy Policy to continue.',
      'legalUnavailable': 'The legal document is not available at this moment.',
      'chat_status_deleted': 'This item has been deleted.',
      'chat_status_resolved': 'This item has been returned.',
      'recentSort': 'Recent',
      'proximitySort': 'Proximity',
      'locationPermissionDenied': 'Location permission denied. Cannot sort by proximity.',
      'faqsLink': 'FAQs',
    },
  };

  String get appName => _text('appName');
  String get home => _text('home');
  String get chats => _text('chats');
  String get profile => _text('profile');
  String get settings => _text('settings');
  String get darkMode => _text('darkMode');
  String get appTheme => _text('appTheme');
  String get themeLight => _text('themeLight');
  String get themeDark => _text('themeDark');
  String get themeSystem => _text('themeSystem');
  String get language => _text('language');
  String get spanish => _text('spanish');
  String get catalan => _text('catalan');
  String get english => _text('english');
  String get publishedObjects => _text('publishedObjects');
  String get futureOptions => _text('futureOptions');
  String get welcome => _text('welcome');
  String get preview => _text('preview');
  String get welcomeDescription => _text('welcomeDescription');

  // 🔹 Getters categorías
  String get accessories => _text('accessories');
  String get clothes => _text('clothes');
  String get devices => _text('devices');
  String get wallets => _text('wallets');
  String get keys => _text('keys');
  String get bags => _text('bags');
  String get study => _text('study');
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
  String get errorWeakPassword => _text('errorWeakPassword');
  String get errorNetworkFailed => _text('errorNetworkFailed');
  String get alreadyHaveAccount => _text('alreadyHaveAccount');
  String get loginLink => _text('loginLink');
  String get welcomeTagline => _text('welcomeTagline');
  String get emailHint => _text('emailHint');
  String get passwordHint => _text('passwordHint');
  String get confirmPasswordHint => _text('confirmPasswordHint');
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
  String get noObjectsInRaw => _text('noObjectsIn');
  String noObjectsIn(String center) => noObjectsInRaw.replaceAll('{center}', center);
  String get noObjectsFound => _text('noObjectsFound');
  String get campusLocationDetail => _text('campusLocationDetail');
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
  String get camera => _text('camera');
  String get gallery => _text('gallery');
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
  String get dateLabel => _text('dateLabel');
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
  String get statusSearching => _text('statusSearching');
  String get statusMatched => _text('statusMatched');
  String get statusReturned => _text('statusReturned');
  String get statusInProcess => _text('statusInProcess');
  String get possibleMatchBadge => _text('possible_match_badge');
  String get possibleMatchDetailBanner => _text('possible_match_detail_banner');
  String get sendError => _text('sendError');
  String get noMessagesYetDetail => _text('noMessagesYetDetail');
  String get typeMessageHint => _text('typeMessageHint');
  String get editPostTitleLost => _text('editPostTitleLost');
  String get editPostTitleFound => _text('editPostTitleFound');
  String get titleLabel => _text('titleLabel');
  String get descriptionLabel => _text('descriptionLabel');
  String get locationLabel => _text('locationLabel');
  String get saveChanges => _text('saveChanges');
  String get deletePost => _text('deletePost');
  String get deleteConfirmationTitle => _text('deleteConfirmationTitle');
  String get deleteConfirmationMessage => _text('deleteConfirmationMessage');
  String get updateSuccess => _text('updateSuccess');
  String get profileUpdatedSuccess => _text('profile_updated_success');
  String get deleteSuccess => _text('deleteSuccess');
  String get errorSaving => _text('errorSaving');
  String get errorDeleting => _text('errorDeleting');
  String get mustLogin => _text('mustLogin');
  String get sessionExpired => _text('sessionExpired');
  String get optional => _text('optional');
  String get recommended => _text('recommended');
  String get unsupportedFormat => _text('unsupportedFormat');
  String get editPhotoSuccess => _text('editPhotoSuccess');
  String get uabAcronym => _text('uabAcronym');
  String get lostAndFound => _text('lostAndFound');
  String get chatStarted => _text('chatStarted');
  String get errorImageUpload => _text('errorImageUpload');
  String get locationOptional => _text('locationOptional');
  String get gpsLocation => _text('gpsLocation');
  String get mapLocation => _text('mapLocation');
  String get outsideBoundsErrorRaw => _text('outsideBoundsError');
  String outsideBoundsError(String center) => outsideBoundsErrorRaw.replaceAll('{center}', center);
  String get centerLocationError => _text('centerLocationError');
  String get errorLocationOutsideCenter => _text('error_location_outside_center');
  String get errorLocationOutsideRecinct => _text('error_location_outside_recinct');
  String get emailNotVerified => _text('emailNotVerified');
  String get postPublishedSuccess => _text('post_published_success');
  String get postEditedSuccess => _text('post_edited_success');
  String get postDeletedSuccess => _text('post_deleted_success');
  String get imageMessage => _text('imageMessage');
  String get matcherTitle => _text('matcherTitle');
  String get matcherSubtitle => _text('matcherSubtitle');
  String get matcherViewButton => _text('matcherViewButton');
  String get matcherIgnoreButton => _text('matcherIgnoreButton');

  String get noObjectsFoundForTitleRaw => _text('noObjectsFoundForTitle');
  String noObjectsFoundForTitle(String title) => noObjectsFoundForTitleRaw.replaceAll('{title}', title);

  String get notificationsTitle => _text('notifications_title');
  String get noNotifications => _text('no_notifications');
  String get allNotificationsRead => _text('all_notifications_read');
  String get markAllAsRead => _text('mark_all_as_read');
  String get defaultNotificationTitle => _text('default_notification_title');
  String get settingsPushToggle => _text('settings_push_toggle');
  String get settingsPushDesc => _text('settings_push_desc');
  String get customerSupport => _text('customerSupport');
  String get supportHelpText => _text('supportHelpText');
  String get email => _text('email');
  String get phone => _text('phone');
  String get close => _text('close');
  String get termsAndConditions => _text('termsAndConditions');
  String get privacyPolicy => _text('privacyPolicy');
  String get acceptTermsPrefix => _text('acceptTermsPrefix');
  String get acceptPrivacyPrefix => _text('acceptPrivacyPrefix');
  String get legalLoadError => _text('legalLoadError');
  String get legalUpdateRequiredTitle => _text('legalUpdateRequiredTitle');
  String get legalUpdateRequiredDesc => _text('legalUpdateRequiredDesc');
  String get acceptAndContinue => _text('acceptAndContinue');
  String get termsErrorNotAccepted => _text('termsErrorNotAccepted');
  String get legalUnavailable => _text('legalUnavailable');
  String get chatStatusDeleted => _text('chat_status_deleted');
  String get chatStatusResolved => _text('chat_status_resolved');
  String get recentSort => _text('recentSort');
  String get proximitySort => _text('proximitySort');
  String get locationPermissionDenied => _text('locationPermissionDenied');
  String get faqsLink => _text('faqsLink');

  String minutesAgo(int count) {
    final key = count == 1
        ? 'time_minutes_ago_singular'
        : 'time_minutes_ago_plural';
    return _text(key).replaceAll('{count}', count.toString());
  }

  String hoursAgo(int count) {
    final key = count == 1
        ? 'time_hours_ago_singular'
        : 'time_hours_ago_plural';
    return _text(key).replaceAll('{count}', count.toString());
  }

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
