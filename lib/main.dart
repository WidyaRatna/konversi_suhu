import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KonversiSuhuApp());
}

class KonversiSuhuApp extends StatelessWidget {
  const KonversiSuhuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konversi Suhu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────

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
  // Konversi ke Celsius terlebih dahulu lalu ke target
  static double konversi(double nilai, Suhu dari, Suhu ke) {
    if (dari == ke) return nilai;

    // Step 1: ke Celsius
    double celsius = _keCelsius(nilai, dari);

    // Step 2: dari Celsius ke target
    return _dariCelsius(celsius, ke);
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

  /// Kembalikan semua hasil konversi dari satu satuan
  static Map<Suhu, double> konversiSemua(double nilai, Suhu dari) {
    return {for (final s in Suhu.values) s: konversi(nilai, dari, s)};
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  Suhu _dari = Suhu.celsius;
  Suhu _ke = Suhu.fahrenheit;
  double? _hasil;
  Map<Suhu, double>? _semuaHasil;
  bool _showSemua = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _konversi() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) {
      _showSnackbar('Masukkan nilai suhu terlebih dahulu!');
      return;
    }
    final nilai = double.tryParse(text.replaceAll(',', '.'));
    if (nilai == null) {
      _showSnackbar('Nilai tidak valid!');
      return;
    }

    // Validasi Kelvin tidak boleh negatif
    if (_dari == Suhu.kelvin && nilai < 0) {
      _showSnackbar('Kelvin tidak bisa negatif!');
      return;
    }

    setState(() {
      _hasil = KonversiModel.konversi(nilai, _dari, _ke);
      _semuaHasil = KonversiModel.konversiSemua(nilai, _dari);
    });
    _animCtrl.forward(from: 0);
    FocusScope.of(context).unfocus();
  }

  void _tukar() {
    setState(() {
      final temp = _dari;
      _dari = _ke;
      _ke = temp;
      _hasil = null;
      _semuaHasil = null;
      _inputCtrl.clear();
    });
  }

  void _reset() {
    setState(() {
      _inputCtrl.clear();
      _hasil = null;
      _semuaHasil = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _showSnackbar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatAngka(double nilai) {
    if (nilai == nilai.truncateToDouble()) {
      return nilai.toStringAsFixed(0);
    }
    // Hapus trailing zero
    String s = nilai.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Row(
          children: [
            Icon(Icons.thermostat, size: 24),
            SizedBox(width: 8),
            Text(
              'Konversi Suhu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Kartu Input ──────────────────────────────
            _buildKartuInput(cs, isDark),
            const SizedBox(height: 16),

            // ── Tombol Konversi ───────────────────────────
            ElevatedButton.icon(
              onPressed: _konversi,
              icon: const Icon(Icons.calculate),
              label: const Text(
                'KONVERSI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Hasil ────────────────────────────────────
            if (_hasil != null)
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildKartuHasil(cs),
                    const SizedBox(height: 12),

                    // Toggle semua hasil
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showSemua = !_showSemua),
                      icon: Icon(
                        _showSemua
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      label: Text(
                        _showSemua
                            ? 'Sembunyikan semua satuan'
                            : 'Lihat semua satuan',
                      ),
                    ),

                    if (_showSemua && _semuaHasil != null)
                      _buildSemuaHasil(cs),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            // ── Tabel Referensi ───────────────────────────
            _buildTabelReferensi(cs, isDark),
            const SizedBox(height: 24),
            // ── Rumus ─────────────────────────────────────
            _buildRumus(cs, isDark),
          ],
        ),
      ),
    );
  }

  // ── Widget Kartu Input ────────────────────────────────────
  Widget _buildKartuInput(ColorScheme cs, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan Nilai & Pilih Satuan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 14),

            // Input field
            TextField(
              controller: _inputCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*[.,]?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Nilai Suhu',
                hintText: 'Contoh: 100',
                prefixIcon: const Icon(Icons.thermostat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onSubmitted: (_) => _konversi(),
            ),
            const SizedBox(height: 16),

            // Dari & Ke dengan tombol tukar
            Row(
              children: [
                Expanded(child: _buildDropdown('Dari', _dari, (v) {
                  setState(() {
                    _dari = v!;
                    _hasil = null;
                    _semuaHasil = null;
                  });
                })),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _tukar,
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Tukar',
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown('Ke', _ke, (v) {
                  setState(() {
                    _ke = v!;
                    _hasil = null;
                    _semuaHasil = null;
                  });
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    Suhu nilai,
    void Function(Suhu?) onChanged,
  ) {
    return DropdownButtonFormField<Suhu>(
      initialValue: nilai,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: Suhu.values
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text('${s.nama} (${s.simbol})',
                    style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ── Kartu Hasil Utama ─────────────────────────────────────
  Widget _buildKartuHasil(ColorScheme cs) {
    final input = double.tryParse(_inputCtrl.text.replaceAll(',', '.')) ?? 0;
    return Card(
      color: cs.primaryContainer,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            Text(
              '${_formatAngka(input)} ${_dari.simbol}  =',
              style: TextStyle(
                fontSize: 16,
                color: cs.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatAngka(_hasil!)} ${_ke.simbol}',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _ke.nama,
              style: TextStyle(
                fontSize: 14,
                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Semua Satuan ──────────────────────────────────────────
  Widget _buildSemuaHasil(ColorScheme cs) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Semua Satuan',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: cs.primary)),
            const Divider(),
            ...Suhu.values.map((s) {
              final val = _semuaHasil![s]!;
              final isAktif = s == _ke;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAktif
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: isAktif ? cs.primary : cs.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.nama,
                          style: TextStyle(
                            fontWeight: isAktif
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_formatAngka(val)} ${s.simbol}',
                      style: TextStyle(
                        fontWeight: isAktif
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isAktif ? cs.primary : null,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Tabel Referensi ───────────────────────────────────────
  Widget _buildTabelReferensi(ColorScheme cs, bool isDark) {
    final data = [
      ['Titik Beku Air', '0', '32', '273.15', '0'],
      ['Suhu Ruangan', '25', '77', '298.15', '20'],
      ['Suhu Tubuh Normal', '37', '98.6', '310.15', '29.6'],
      ['Titik Didih Air', '100', '212', '373.15', '80'],
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tabel Referensi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  cs.primaryContainer.withValues(alpha: 0.5),
                ),
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Kondisi', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('°C', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('°F', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('K', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('°Ré', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: data
                    .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(Text(cell,
                                  style: const TextStyle(fontSize: 13))))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Rumus ─────────────────────────────────────────────────
  Widget _buildRumus(ColorScheme cs, bool isDark) {
    final rumus = [
      // Celsius
      ('°C → °F', '(°C × 9/5) + 32'),
      ('°C → K',  '°C + 273.15'),
      ('°C → °Ré','°C × 4/5'),
      // Fahrenheit
      ('°F → °C', '(°F − 32) × 5/9'),
      ('°F → K',  '(°F − 32) × 5/9 + 273.15'),
      ('°F → °Ré','(°F − 32) × 4/9'),
      // Kelvin
      ('K → °C',  'K − 273.15'),
      ('K → °F',  '(K − 273.15) × 9/5 + 32'),
      ('K → °Ré', '(K − 273.15) × 4/5'),
      // Réaumur
      ('°Ré → °C','°Ré × 5/4'),
      ('°Ré → °F','°Ré × 9/4 + 32'),
      ('°Ré → K', '°Ré × 5/4 + 273.15'),
    ];

    Widget rumusChip(String judul, String formula) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formula,
              style: TextStyle(fontSize: 12, color: cs.onSurface),
            ),
          ],
        ),
      );
    }

    // Kelompokkan per baris: 2 chip per baris
    final List<Widget> rows = [];
    for (int i = 0; i < rumus.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: rumusChip(rumus[i].$1, rumus[i].$2)),
            const SizedBox(width: 8),
            if (i + 1 < rumus.length)
              Expanded(child: rumusChip(rumus[i + 1].$1, rumus[i + 1].$2))
            else
              const Spacer(),
          ],
        ),
      );
      if (i + 2 < rumus.length) rows.add(const SizedBox(height: 8));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.functions, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Rumus Konversi (Lengkap)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }
}