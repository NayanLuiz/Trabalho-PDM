import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuth? get _firebaseAuth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges =>
      _firebaseAuth?.authStateChanges() ?? const Stream.empty();

  User? get currentUser => _firebaseAuth?.currentUser;

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase ainda não inicializado. Utilize o "Modo Admin Local" para testar.');
    }
    return await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase ainda não inicializado. Utilize o "Modo Admin Local" para testar.');
    }
    return await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase ainda não inicializado. Utilize o "Modo Admin Local" para testar.');
    }
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        if (_firebaseAuth != null) _firebaseAuth!.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {}
  }
}
