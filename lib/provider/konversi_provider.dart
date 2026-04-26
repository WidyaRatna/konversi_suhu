import 'package:flutter/foundation.dart';
import '../model/suhu_model.dart';

enum KonversiStatus { initial, success, error }

class KonversiProvider extends ChangeNotifier {
  Suhu _dari = Suhu.celsius;
  Suhu _ke = Suhu.fahrenheit;
  double? _hasil;
  Map<Suhu, double>? _semuaHasil;
  bool _showSemua = false;
  KonversiStatus _status = KonversiStatus.initial;
  String _pesanError = '';

  Suhu get dari => _dari;
  Suhu get ke => _ke;
  double? get hasil => _hasil;
  Map<Suhu, double>? get semuaHasil => _semuaHasil;
  bool get showSemua => _showSemua;
  KonversiStatus get status => _status;
  String get pesanError => _pesanError;

  void setDari(Suhu suhu) {
    _dari = suhu;
    _resetHasil();
    notifyListeners();
  }

  void setKe(Suhu suhu) {
    _ke = suhu;
    _resetHasil();
    notifyListeners();
  }

  void tukar() {
    final temp = _dari;
    _dari = _ke;
    _ke = temp;
    _resetHasil();
    notifyListeners();
  }

  void toggleShowSemua() {
    _showSemua = !_showSemua;
    notifyListeners();
  }

  String? konversi(String inputText) {
    final text = inputText.trim();

    if (text.isEmpty) {
      _status = KonversiStatus.error;
      _pesanError = 'Masukkan nilai suhu terlebih dahulu!';
      notifyListeners();
      return _pesanError;
    }

    final nilai = double.tryParse(text.replaceAll(',', '.'));
    if (nilai == null) {
      _status = KonversiStatus.error;
      _pesanError = 'Nilai tidak valid!';
      notifyListeners();
      return _pesanError;
    }

    if (_dari == Suhu.kelvin && nilai < 0) {
      _status = KonversiStatus.error;
      _pesanError = 'Kelvin tidak bisa negatif!';
      notifyListeners();
      return _pesanError;
    }

    _hasil = KonversiModel.konversi(nilai, _dari, _ke);
    _semuaHasil = KonversiModel.konversiSemua(nilai, _dari);
    _status = KonversiStatus.success;
    _pesanError = '';
    notifyListeners();
    return null;
  }

  void reset() {
    _resetHasil();
    _status = KonversiStatus.initial;
    _pesanError = '';
    _showSemua = false;
    notifyListeners();
  }

  void _resetHasil() {
    _hasil = null;
    _semuaHasil = null;
    _status = KonversiStatus.initial;
  }
}