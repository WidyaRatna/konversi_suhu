import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/konversi_provider.dart';
import '../widget/suhu_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();

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
    final prov = context.read<KonversiProvider>();
    final pesanError = prov.konversi(_inputCtrl.text);
    if (pesanError != null) {
      _showSnackbar(pesanError);
    } else {
      _animCtrl.forward(from: 0);
      FocusScope.of(context).unfocus();
    }
  }

  void _reset() {
    _inputCtrl.clear();
    context.read<KonversiProvider>().reset();
    FocusScope.of(context).unfocus();
  }

  void _showSnackbar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final status = context.select<KonversiProvider, KonversiStatus>(
      (p) => p.status,
    );
    final showSemua = context.select<KonversiProvider, bool>(
      (p) => p.showSemua,
    );
    final semuaHasilAda = context.select<KonversiProvider, bool>(
      (p) => p.semuaHasil != null,
    );

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
            KartuInput(
              inputCtrl: _inputCtrl,
              onKonversi: _konversi,
            ),
            const SizedBox(height: 16),
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
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            if (status == KonversiStatus.success)
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KartuHasilUtama(inputText: _inputCtrl.text),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () =>
                          context.read<KonversiProvider>().toggleShowSemua(),
                      icon: Icon(showSemua
                          ? Icons.expand_less
                          : Icons.expand_more),
                      label: Text(showSemua
                          ? 'Sembunyikan semua satuan'
                          : 'Lihat semua satuan'),
                    ),
                    if (showSemua && semuaHasilAda)
                      const PanelSemuaSatuan(),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const TabelReferensi(),
            const SizedBox(height: 24),
            const PanelRumus(),
          ],
        ),
      ),
    );
  }
}