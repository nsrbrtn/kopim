import 'dart:io';

bool isNetworkSocketException(Object error) => error is SocketException;
