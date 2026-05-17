import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';

class ErrorHandler {
  static String getMessage(dynamic error, AppStrings t) {
    // Interceptar de forma robusta cualquier error de límites geográficos del backend
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('out-of-bounds-location') || 
        errorString.contains('out-of-bounds') || 
        (errorString.contains('outside') && errorString.contains('bounds'))) {
      return t.errorLocationOutsideRecinct;
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return t.errorUserNotFound;
        case 'wrong-password':
          return t.errorWrongPassword;
        case 'invalid-email':
          return t.errorInvalidEmail;
        case 'user-disabled':
          return t.errorUserDisabled;
        case 'too-many-requests':
          return t.errorTooManyRequests;
        case 'email-already-in-use':
          return t.errorAlreadyExists;
        case 'weak-password':
          return t.errorWeakPassword;
        case 'network-request-failed':
          return t.errorNetworkFailed;
        default:
          return t.errorLoginGeneric;
      }
    }

    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'out-of-bounds-location':
        case 'out-of-bounds':
          return t.errorLocationOutsideRecinct;
        case 'already-exists':
          return t.errorAlreadyExists;
        case 'permission-denied':
          return t.errorDomainNotAuthorized;
        case 'invalid-argument':
          if (error.message?.toLowerCase().contains('out-of-bounds') == true ||
              error.details?.toString().toLowerCase().contains('out-of-bounds') == true) {
            return t.errorLocationOutsideRecinct;
          }
          return t.errorInvalidArgument;
        case 'unavailable':
          return t.errorUnavailable;
        default:
          return t.errorUnexpected;
      }
    }

    // Default error message
    return t.errorUnexpected;
  }
}
