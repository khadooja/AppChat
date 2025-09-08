import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/widget/user_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUserName = '';
  File? _userImageFile;
  var _isuploading = false;
  void _submit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid || (_isLogin && _userImageFile == null)) {
      return;
    }

    try {
      setState(() {
        _isuploading = true;
      });
      if (_isLogin) {
        final UserCredential userCredential =
            await _firebase.signInWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);
      } else {
        final UserCredential userCredential =
            await _firebase.createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);
        final Reference storageref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredential.user!.uid}.jpg');
        await storageref.putFile(_userImageFile!);
        final imageUrl = await storageref.getDownloadURL();
        await userCredential.user!.updatePhotoURL(imageUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _enteredUserName,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
        ),
      );
    }
    setState(() {
      _isuploading = false;
    });
    _formKey.currentState?.save();
    // print('Email: $_enteredEmail, Password: $_enteredPassword');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 100, bottom: 20),
                width: 200,
                height: 150,
                child: Icon(
                  Icons.chat_bubble,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePiker(
                                onimagePickFn: (pickedImage) {
                                  _userImageFile = pickedImage;
                                },
                              ),
                            const SizedBox(height: 12),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                autocorrect: true,
                                textCapitalization: TextCapitalization.words,
                                validator: (value) =>
                                    value != null && value.length < 4
                                        ? 'Please enter at least 4 characters.'
                                        : null,
                                onSaved: (newValue) =>
                                    _enteredUserName = newValue!,
                              ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Email Address'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              onSaved: (newValue) => _enteredEmail = newValue!,
                              validator: (value) =>
                                  value != null && !value.contains('@')
                                      ? 'Please enter a valid email address.'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              onSaved: (newValue) =>
                                  _enteredPassword = newValue!,
                              validator: (value) => value != null &&
                                      value.length < 6
                                  ? 'Password must be at least 6 characters long.'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            if (_isuploading) const CircularProgressIndicator(),
                            if (!_isuploading)
                              ElevatedButton(
                                onPressed: _submit,
                                child: Text(_isLogin ? 'Login' : 'Sign Up'),
                              ),
                            if (!_isuploading)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create Account'
                                      : 'I already have an account')),
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
