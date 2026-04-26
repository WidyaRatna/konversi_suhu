enum Suhu {
  celsius('Celsius', '°C'),
  fahrenheit('Fahrenheit', '°F'),
  kelvin('Kelvin', 'K'),
  reamur('Réaumur', '°Ré');

  final String nama;
  final String simbol;
  const Suhu(this.nama, this.simbol);
}

class KonversiModel {
  static double konversi(double nilai, Suhu dari, Suhu ke) {
    if (dari == ke) return nilai;
    return _dariCelsius(_keCelsius(nilai, dari), ke);
  }

  static double _keCelsius(double nilai, Suhu dari) {
    switch (dari) {
      case Suhu.celsius:
        return nilai;
      case Suhu.fahrenheit:
        return (nilai - 32) * 5 / 9;
      case Suhu.kelvin:
        return nilai - 273.15;
      case Suhu.reamur:
        return nilai * 5 / 4;
    }
  }

  static double _dariCelsius(double celsius, Suhu ke) {
    switch (ke) {
      case Suhu.celsius:
        return celsius;
      case Suhu.fahrenheit:
        return celsius * 9 / 5 + 32;
      case Suhu.kelvin:
        return celsius + 273.15;
      case Suhu.reamur:
        return celsius * 4 / 5;
    }
  }

  static Map<Suhu, double> konversiSemua(double nilai, Suhu dari) {
    return {for (final s in Suhu.values) s: konversi(nilai, dari, s)};
  }
}