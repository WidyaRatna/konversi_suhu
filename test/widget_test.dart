import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:konversi_suhu/main.dart';

void main() {
  // ── Unit Test: Model Konversi ──────────────────────────────
  group('KonversiModel', () {
    test('Celsius ke Fahrenheit', () {
      expect(KonversiModel.konversi(0, Suhu.celsius, Suhu.fahrenheit), 32.0);
      expect(KonversiModel.konversi(100, Suhu.celsius, Suhu.fahrenheit), 212.0);
      expect(KonversiModel.konversi(-40, Suhu.celsius, Suhu.fahrenheit), -40.0);
    });

    test('Fahrenheit ke Celsius', () {
      expect(KonversiModel.konversi(32, Suhu.fahrenheit, Suhu.celsius), 0.0);
      expect(KonversiModel.konversi(212, Suhu.fahrenheit, Suhu.celsius), 100.0);
    });

    test('Celsius ke Kelvin', () {
      expect(KonversiModel.konversi(0, Suhu.celsius, Suhu.kelvin), 273.15);
      expect(KonversiModel.konversi(100, Suhu.celsius, Suhu.kelvin), 373.15);
    });

    test('Kelvin ke Celsius', () {
      expect(KonversiModel.konversi(273.15, Suhu.kelvin, Suhu.celsius), 0.0);
    });

    test('Celsius ke Réaumur', () {
      expect(KonversiModel.konversi(100, Suhu.celsius, Suhu.reamur), 80.0);
      expect(KonversiModel.konversi(0, Suhu.celsius, Suhu.reamur), 0.0);
    });

    test('Satuan sama tidak berubah', () {
      expect(KonversiModel.konversi(37, Suhu.celsius, Suhu.celsius), 37.0);
    });

    test('konversiSemua menghasilkan 4 satuan', () {
      final hasil = KonversiModel.konversiSemua(100, Suhu.celsius);
      expect(hasil.length, 4);
      expect(hasil[Suhu.celsius], 100.0);
      expect(hasil[Suhu.fahrenheit], 212.0);
      expect(hasil[Suhu.kelvin], 373.15);
      expect(hasil[Suhu.reamur], 80.0);
    });
  });

  // ── Widget Test: UI ────────────────────────────────────────
  group('HomeScreen UI', () {
    testWidgets('Menampilkan judul AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(const KonversiSuhuApp());
      expect(find.text('Konversi Suhu'), findsOneWidget);
    });

    testWidgets('Terdapat field input suhu', (WidgetTester tester) async {
      await tester.pumpWidget(const KonversiSuhuApp());
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Terdapat tombol KONVERSI', (WidgetTester tester) async {
      await tester.pumpWidget(const KonversiSuhuApp());
      expect(find.text('KONVERSI'), findsOneWidget);
    });

    testWidgets('Input kosong menampilkan snackbar peringatan',
        (WidgetTester tester) async {
      await tester.pumpWidget(const KonversiSuhuApp());
      await tester.tap(find.text('KONVERSI'));
      await tester.pump();
      expect(find.text('Masukkan nilai suhu terlebih dahulu!'), findsOneWidget);
    });

    testWidgets('Konversi 100°C menampilkan 212°F',
        (WidgetTester tester) async {
      await tester.pumpWidget(const KonversiSuhuApp());

      // Masukkan nilai
      await tester.enterText(find.byType(TextField), '100');

      // Pastikan dropdown "Dari" = Celsius, "Ke" = Fahrenheit (default)
      await tester.tap(find.text('KONVERSI'));
      await tester.pumpAndSettle();

      expect(find.textContaining('212'), findsWidgets);
    });

    testWidgets('Tombol reset membersihkan input', (WidgetTester tester) async {
      await tester.pumpWidget(const KonversiSuhuApp());

      await tester.enterText(find.byType(TextField), '100');
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text, '');
    });
  });
}