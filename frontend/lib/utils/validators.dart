class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Masukkan email yang valid';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama pengguna harus diisi';
    }

    if (value.length < 3) {
      return 'Nama pengguna minimal 3 karakter';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }

    if (value != password) {
      return 'Password tidak cocok';
    }

    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Usia harus diisi';
    }

    final age = int.tryParse(value);
    if (age == null || age <= 0) {
      return 'Masukkan usia yang valid';
    }

    return null;
  }

  // Validate Weight
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Berat badan harus diisi';
    }

    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Masukkan berat badan yang valid';
    }

    return null;
  }

  // Validate Height
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tinggi badan harus diisi';
    }

    final height = double.tryParse(value);
    if (height == null || height <= 0) {
      return 'Masukkan tinggi badan yang valid';
    }

    return null;
  }

  // Validate Trimester
  static String? validateTrimester(String? value) {
    if (value == null || value.isEmpty) {
      return 'Trimester harus diisi';
    }

    final trimester = int.tryParse(value);
    if (trimester == null || trimester < 1 || trimester > 3) {
      return 'Masukkan trimester yang valid (1-3)';
    }

    return null;
  }
}
