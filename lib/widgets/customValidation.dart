import 'package:flutter/material.dart';

class Validators {
  // ─── Required ───────────────────────────────────────────────
  static String? required(String? v, {String fieldName = "This field"}) {
    if (v == null || v.trim().isEmpty) return "$fieldName is required";
    return null;
  }

  // ─── Email ──────────────────────────────────────────────────
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v.trim())) return "Enter a valid email address";
    return null;
  }

  // ─── Password ────────────────────────────────────────────────
  static String? password(String? v) {
    if (v == null || v.trim().isEmpty) return "Password is required";
    if (v.length < 6) return "Password must be at least 6 characters";
    if (!RegExp(r'[A-Z]').hasMatch(v)) return "Password must contain an uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(v)) return "Password must contain a lowercase letter";
    if (!RegExp(r'[0-9]').hasMatch(v)) return "Password must contain a number";
    if (!RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:"\\|,.<>/?]').hasMatch(v))
      return "Password must contain a special character";
    return null;
  }

  // ─── Confirm Password ────────────────────────────────────────
static String? Function(String?) confirmPassword(
  TextEditingController confirmCtrl,
  TextEditingController originalCtrl,
) {
  return (String? v) {
    if (v == null || v.trim().isEmpty) return "Please confirm your password";
    if (v.trim() != originalCtrl.text.trim()) return "Passwords do not match";
    return null;
  };
}

  // ─── Name (First / Last / Full) ──────────────────────────────
  static String? name(String? v, {String label = "Name"}) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    if (v.trim().length < 2) return "$label must be at least 2 characters";
    if (v.trim().length > 50) return "$label must be at most 50 characters";
    if (!RegExp(r"^[a-zA-Z\s'\-]+$").hasMatch(v.trim()))
      return "$label can only contain letters, spaces, hyphens, or apostrophes";
    return null;
  }

  // ─── Phone – Pakistan ────────────────────────────────────────
  static String? phonePK(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone number is required";
    final r = RegExp(r'^(03\d{9}|\+92\d{10})$');
    if (!r.hasMatch(v.trim())) return "Enter a valid Pakistani phone number (03xxxxxxxxx or +92xxxxxxxxxx)";
    return null;
  }

  // ─── Phone – International ───────────────────────────────────
  static String? phoneIntl(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone number is required";
    final r = RegExp(r'^\+?[1-9]\d{6,14}$');
    if (!r.hasMatch(v.trim().replaceAll(' ', '')))
      return "Enter a valid phone number";
    return null;
  }

  // ─── Address ─────────────────────────────────────────────────
  static String? address(String? v, {String label = "Address"}) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    if (v.trim().length < 10) return "$label is too short (min 10 characters)";
    if (v.trim().length > 250) return "$label is too long (max 250 characters)";
    return null;
  }

  // ─── City / Country / State ──────────────────────────────────
  static String? city(String? v, {String label = "City"}) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    if (v.trim().length < 2) return "$label must be at least 2 characters";
    if (!RegExp(r"^[a-zA-Z\s'\-]+$").hasMatch(v.trim()))
      return "$label can only contain letters";
    return null;
  }

  // ─── Postal / ZIP Code ───────────────────────────────────────
  static String? postalCode(String? v) {
    if (v == null || v.trim().isEmpty) return "Postal code is required";
    if (!RegExp(r'^\d{4,10}$').hasMatch(v.trim()))
      return "Enter a valid postal code";
    return null;
  }

  // ─── Description / Bio / Notes ───────────────────────────────
  static String? description(String? v, {
    String label = "Description",
    int minLen = 10,
    int maxLen = 500,
  }) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    if (v.trim().length < minLen) return "$label must be at least $minLen characters";
    if (v.trim().length > maxLen) return "$label must be at most $maxLen characters";
    return null;
  }

  // ─── Username ────────────────────────────────────────────────
  static String? username(String? v) {
    if (v == null || v.trim().isEmpty) return "Username is required";
    if (v.trim().length < 3) return "Username must be at least 3 characters";
    if (v.trim().length > 20) return "Username must be at most 20 characters";
    if (!RegExp(r'^[a-zA-Z0-9_\.]+$').hasMatch(v.trim()))
      return "Username can only contain letters, numbers, underscores, or dots";
    return null;
  }

  // ─── CNIC (Pakistan) ─────────────────────────────────────────
  static String? cnic(String? v) {
    if (v == null || v.trim().isEmpty) return "CNIC is required";
    final r = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    if (!r.hasMatch(v.trim())) return "Enter a valid CNIC (xxxxx-xxxxxxx-x)";
    return null;
  }

  // ─── URL ─────────────────────────────────────────────────────
  static String? url(String? v) {
    if (v == null || v.trim().isEmpty) return "URL is required";
    final r = RegExp(
        r'^(https?:\/\/)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
        caseSensitive: false);
    if (!r.hasMatch(v.trim())) return "Enter a valid URL (https://example.com)";
    return null;
  }

  // ─── Age ─────────────────────────────────────────────────────
  static String? age(String? v, {int min = 1, int max = 120}) {
    if (v == null || v.trim().isEmpty) return "Age is required";
    final n = int.tryParse(v.trim());
    if (n == null) return "Enter a valid age";
    if (n < min || n > max) return "Age must be between $min and $max";
    return null;
  }

  // ─── Number (generic) ────────────────────────────────────────
  static String? number(String? v, {
    String label = "Value",
    double? min,
    double? max,
  }) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    final n = double.tryParse(v.trim());
    if (n == null) return "$label must be a valid number";
    if (min != null && n < min) return "$label must be at least $min";
    if (max != null && n > max) return "$label must be at most $max";
    return null;
  }

  // ─── Min Length (generic) ────────────────────────────────────
  static String? minLen(String? v, int len, {String label = "Value"}) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    if (v.trim().length < len) return "$label must be at least $len characters";
    return null;
  }

  // ─── Max Length (generic) ────────────────────────────────────
  static String? maxLen(String? v, int len, {String label = "Value"}) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    if (v.trim().length > len) return "$label must be at most $len characters";
    return null;
  }

  // ─── Combine multiple validators ─────────────────────────────
  static String? compose(String? v, List<String? Function(String?)> validators) {
    for (final fn in validators) {
      final error = fn(v);
      if (error != null) return error;
    }
    return null;
  }
}


/*
required -> Koi bhi field required check
email  -> Proper email format
password  -> 8+ chars, uppercase, lowercase, number, special char
confirmPassword  -> Dono password match
name  -> Letters only, 2–50 chars
phonePK  -> Pakistani number (03x / +92x)
phoneIntl  -> International number
address  -> Min 10, max 250 chars
city  -> Letters only
postalCode  -> 4–10 digits
description  -> Configurable min/max length
username  -> Letters, numbers, _, .
cnic  -> Pakistani CNIC format
url  -> Valid https URL
age  -> Number range check
number  -> Generic number with min/max
minLen / maxLen  -> Generic length validators
compose  -> Multiple validators ek saath chain karo

*/