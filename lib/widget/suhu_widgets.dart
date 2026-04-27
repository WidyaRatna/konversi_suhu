import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/suhu_model.dart';
import '../provider/konversi_provider.dart';

class KartuInput extends StatelessWidget {
  final TextEditingController inputCtrl;
  final VoidCallback onKonversi;

  const KartuInput({
    super.key,
    required this.inputCtrl,
    required this.onKonversi,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prov = context.watch<KonversiProvider>();

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
            TextField(
              controller: inputCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Nilai',
                hintText: 'Contoh: 100',
                prefixIcon: const Icon(Icons.thermostat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                isDense: true,
              ),
              onSubmitted: (_) => onKonversi(),
            ),
            const SizedBox(height: 16),

            // ── Dropdown Dari (full width) ─────────────────────
            _SuhuDropdown(
              label: 'Dari',
              nilai: prov.dari,
              onChanged: (v) =>
                  context.read<KonversiProvider>().setDari(v!),
            ),

            // ── Tombol Tukar (tengah) ─────────────────────────
            Center(
              child: IconButton.filled(
                onPressed: () {
                  inputCtrl.clear();
                  context.read<KonversiProvider>().tukar();
                },
                icon: const Icon(Icons.swap_vert),
                tooltip: 'Tukar',
                style: IconButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                ),
              ),
            ),

            // ── Dropdown Ke (full width) ──────────────────────
            _SuhuDropdown(
              label: 'Ke',
              nilai: prov.ke,
              onChanged: (v) =>
                  context.read<KonversiProvider>().setKe(v!),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuhuDropdown extends StatelessWidget {
  final String label;
  final Suhu nilai;
  final void Function(Suhu?) onChanged;

  const _SuhuDropdown({
    required this.label,
    required this.nilai,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Suhu>(
      initialValue: nilai,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: Suhu.values
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(
                  '${s.nama} (${s.simbol})',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class KartuHasilUtama extends StatelessWidget {
  final String inputText;

  const KartuHasilUtama({super.key, required this.inputText});

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    String s = v.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prov = context.watch<KonversiProvider>();
    final input = double.tryParse(inputText.replaceAll(',', '.')) ?? 0;

    return Card(
      color: cs.primaryContainer,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            Text(
              '${_fmt(input)} ${prov.dari.simbol}  =',
              style: TextStyle(
                fontSize: 16,
                color: cs.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_fmt(prov.hasil!)} ${prov.ke.simbol}',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prov.ke.nama,
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
}

class PanelSemuaSatuan extends StatelessWidget {
  const PanelSemuaSatuan({super.key});

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    String s = v.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prov = context.watch<KonversiProvider>();

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
              final val = prov.semuaHasil![s]!;
              final isAktif = s == prov.ke;
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
                        Text(s.nama,
                            style: TextStyle(
                                fontWeight: isAktif
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ],
                    ),
                    Text(
                      '${_fmt(val)} ${s.simbol}',
                      style: TextStyle(
                        fontWeight:
                            isAktif ? FontWeight.bold : FontWeight.normal,
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
}

class TabelReferensi extends StatelessWidget {
  const TabelReferensi({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            Row(children: [
              Icon(Icons.table_chart, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text('Tabel Referensi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: cs.primary)),
            ]),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                    cs.primaryContainer.withValues(alpha: 0.5)),
                columnSpacing: 16,
                columns: const [
                  DataColumn(
                      label: Text('Kondisi',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('°C',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('°F',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('K',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('°Ré',
                          style: TextStyle(fontWeight: FontWeight.bold))),
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
}

class PanelRumus extends StatelessWidget {
  const PanelRumus({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const rumus = [
      ('°C → °F', '(°C × 9/5) + 32'),
      ('°C → K', '°C + 273.15'),
      ('°C → °Ré', '°C × 4/5'),
      ('°F → °C', '(°F − 32) × 5/9'),
      ('°F → K', '(°F − 32) × 5/9 + 273.15'),
      ('°F → °Ré', '(°F − 32) × 4/9'),
      ('K → °C', 'K − 273.15'),
      ('K → °F', '(K − 273.15) × 9/5 + 32'),
      ('K → °Ré', '(K − 273.15) × 4/5'),
      ('°Ré → °C', '°Ré × 5/4'),
      ('°Ré → °F', '°Ré × 9/4 + 32'),
      ('°Ré → K', '°Ré × 5/4 + 273.15'),
    ];

    Widget chip(String judul, String formula) => Container(
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
              Text(judul,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: cs.primary)),
              const SizedBox(height: 3),
              Text(formula,
                  style: TextStyle(fontSize: 12, color: cs.onSurface)),
            ],
          ),
        );

    final rows = <Widget>[];
    for (int i = 0; i < rumus.length; i += 2) {
      rows.add(Row(children: [
        Expanded(child: chip(rumus[i].$1, rumus[i].$2)),
        const SizedBox(width: 8),
        if (i + 1 < rumus.length)
          Expanded(child: chip(rumus[i + 1].$1, rumus[i + 1].$2))
        else
          const Spacer(),
      ]));
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
            Row(children: [
              Icon(Icons.functions, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text('Rumus Konversi (Lengkap)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: cs.primary)),
            ]),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }
}