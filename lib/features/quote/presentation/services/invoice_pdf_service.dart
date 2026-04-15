import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/quote_provider.dart';
import 'package:intl/intl.dart';

class InvoicePdfService {
  static Future<String> generateInvoice(QuoteState quote, {String sellerName = 'Cristhian Caicedo'}) async {
    final pdf = pw.Document();
    
    // Use Unicode-capable font
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final pw.TextStyle baseStyle = pw.TextStyle(font: font, fontSize: 9);
    final pw.TextStyle boldStyle = pw.TextStyle(font: fontBold, fontSize: 9, fontWeight: pw.FontWeight.bold);
    
    // Use Spanish for date
    final dateFormatted = DateFormat('d \'de\' MMMM, yyyy', 'es_CO').format(DateTime.now());
    final currency = NumberFormat.simpleCurrency(locale: 'es_CO', decimalDigits: 0, name: '\$');
    
    // Load logo if possible (using placeholder for now or standard text if asset fails)
    pw.ImageProvider? logo;
    try {
      final byteData = await rootBundle.load('assets/Banner IA-01.jpg');
      logo = pw.MemoryImage(byteData.buffer.asUint8List());
    } catch (e) {
      print('Error loading logo for PDF: $e');
    }

    final client = quote.client ?? {};
    final clientName = client['name'] ?? '${client['nombres'] ?? ''} ${client['apellidos'] ?? ''}'.trim();
    final clientCedula = client['cedula'] ?? '';
    final clientAddress = '${client['departamento'] ?? ''}, ${client['ciudad'] ?? ''}, ${client['barrio'] ?? ''}';
    final clientEmail = client['correo'] ?? '';
    final clientPhone = client['celular'] ?? '';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Blue Header Section
            pw.Container(
              height: 100,
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF458AC9), // IA Blue
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                    pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 20),
                    child: pw.Text(
                      'IA FACTURA',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 40,
                        fontWeight: pw.FontWeight.bold,
                        font: fontBold,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 150,
                    height: 100,
                    color: const PdfColor.fromInt(0xFF233F6A), // Darker Blue
                    alignment: pw.Alignment.center,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Total Neto',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 12, font: font),
                        ),
                        pw.Text(
                          currency.format(quote.valorNeto),
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            font: fontBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Info Section: Bill To & Invoice Info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Facturar a:', style: boldStyle),
                      pw.SizedBox(height: 4),
                      pw.Text(clientName.toUpperCase(), style: baseStyle),
                      pw.Text('NIT/CC: $clientCedula', style: baseStyle),
                      pw.Text(clientAddress, style: baseStyle),
                      pw.Text(clientEmail, style: baseStyle),
                      pw.Text(clientPhone, style: baseStyle),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Vendedor: $sellerName', style: baseStyle),
                      pw.Text('Nro. Factura: CF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', style: baseStyle),
                      pw.Text('Fecha: $dateFormatted', style: baseStyle),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Products Table
            pw.Table(
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(6), // Product Name (Descripcion)
                1: const pw.FlexColumnWidth(2), // Price
                2: const pw.FlexColumnWidth(2), // Quantity
                3: const pw.FlexColumnWidth(2), // Total
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF458AC9)),
                  children: [
                    _buildHeaderCell('Descripción', style: boldStyle),
                    _buildHeaderCell('Precio Unit.', style: boldStyle),
                    _buildHeaderCell('Cant.', style: boldStyle),
                    _buildHeaderCell('Total', style: boldStyle),
                  ],
                ),
                // Data rows
                ...quote.items.map((item) {
                  return pw.TableRow(
                    children: [
                      _buildCell(item.descripcion, style: baseStyle),
                      _buildCell(currency.format(item.precioXUnidad), style: baseStyle),
                      _buildCell(item.cantidad.toString(), align: pw.TextAlign.center, style: baseStyle),
                      _buildCell(currency.format(item.precioTotal), align: pw.TextAlign.right, style: baseStyle),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 10),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal Productos: ${currency.format(quote.valMercancia - quote.descuentos - quote.ivaProductos)}', style: baseStyle),
                    pw.Text('IVA Productos: ${currency.format(quote.ivaProductos)}', style: baseStyle),
                    pw.Text('Descuentos: -${currency.format(quote.descuentos)}', style: baseStyle),
                    if (quote.cobraDomicilio) ...[
                      pw.Text('Domicilio: ${currency.format(quote.tarifaDomicilio)}', style: baseStyle),
                      pw.Text('IVA Domicilio (19%): ${currency.format(quote.ivaDomicilio)}', style: baseStyle),
                    ],
                    pw.Divider(color: PdfColors.grey),
                    pw.Text(
                      'TOTAL A PAGAR: ${currency.format(quote.valorNeto)}',
                      style: boldStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 50),
            
            // Footer
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.blue,
                    width: 0.5,
                    style: pw.BorderStyle.dashed,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('Importadoras Asociadas S.A.S', style: baseStyle.copyWith(fontSize: 10)),
                  pw.Text('Dirección: Zona Industrial, Bogotá, Colombia', style: baseStyle.copyWith(fontSize: 10)),
                  pw.Text('Email: soporte@importadorasasociadas.com', style: baseStyle.copyWith(fontSize: 10)),
                  pw.Text('¡Gracias por su preferencia!', style: boldStyle.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save the PDF bytes
    final bytes = await pdf.save();

    // Get the downloads directory
    Directory? downloadsDir;
    if (Platform.isWindows) {
      downloadsDir = await getDownloadsDirectory();
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    if (downloadsDir == null) {
      throw Exception('No se pudo encontrar la carpeta de descargas');
    }

    final fileName = 'Invoice_${clientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${downloadsDir.path}\\$fileName';
    final file = File(filePath);

    await file.writeAsBytes(bytes);
    
    return filePath;
  }

  static pw.Widget _buildHeaderCell(String text, {required pw.TextStyle style}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: pw.Text(
        text,
        style: style.copyWith(
          color: PdfColors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _buildCell(String text, {required pw.TextStyle style, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: pw.Text(
        text,
        style: style.copyWith(fontSize: 9),
        textAlign: align,
      ),
    );
  }
}
