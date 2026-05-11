import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';

class ErrorHandler {
  static String getMessage(dynamic error, AppStrings t) {
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
        default:
          return t.errorLoginGeneric;
      }
    }

    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'already-exists':
          return t.errorAlreadyExists;
        case 'permission-denied':
          return t.errorDomainNotAuthorized;
        case 'invalid-argument':
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
