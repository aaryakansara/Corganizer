import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/io_client.dart' as http;

class GoogleDrive {
  late drive.DriveApi _driveApi;
  late GoogleSignInAccount _currentUser;


  Future<void> init() async {
    final _clientId = '611883163059-6ka6foqusi0agee1j135nm4enpgsjoju.apps.googleusercontent.com';
    final _apiKey = 'AIzaSyBe9KMb-bUh7fAxGjYKfMB40aFsY-SmJ1A';
    _currentUser = (await GoogleSignIn().signIn())!;
    final authHeaders = await _currentUser.authHeaders;
    final client = http.IOClient();
    final authenticator = await auth.clientViaUserConsent(
      auth.ClientId(_clientId),
      <String>[drive.DriveApi.driveScope],
          (String url) async {
        print('Please go to this URL and grant access: $url');
        // Open the URL in a browser and return the authorization code.
        return Future.value();
      },
    );
    _driveApi = drive.DriveApi(authenticator);
  }



  Future<void> createMainFolder() async {
    final folder = drive.File()
      ..name = 'Corganizer'
      ..mimeType = 'application/vnd.google-apps.folder';
    await _driveApi.files.create(
      folder,
      $fields: 'id',
    );
  }
}
