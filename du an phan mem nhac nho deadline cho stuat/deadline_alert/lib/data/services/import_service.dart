import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ImportService {
  Future<List<Map<String, dynamic>>> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      if (path.endsWith('.csv')) {
        return _parseCsv(path);
      } else if (path.endsWith('.xlsx')) {
        return _parseExcel(path);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _parseCsv(String path) async {
    final input = File(path).openRead();
    final fields = await input.transform(const CsvToListConverter()).toList();
    // Assuming first row is header
    List<Map<String, dynamic>> data = [];
    if (fields.length > 1) {
      final header = fields[0].map((e) => e.toString()).toList();
      for (int i = 1; i < fields.length; i++) {
        Map<String, dynamic> row = {};
        for (int j = 0; j < header.length; j++) {
          row[header[j]] = fields[i][j];
        }
        data.add(row);
      }
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> _parseExcel(String path) async {
    var bytes = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<Map<String, dynamic>> data = [];
    
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet != null && sheet.rows.isNotEmpty) {
        var header = sheet.rows[0].map((e) => e?.value?.toString() ?? '').toList();
        for (int i = 1; i < sheet.rows.length; i++) {
          Map<String, dynamic> row = {};
          for (int j = 0; j < header.length; j++) {
            if (j < sheet.rows[i].length) {
              row[header[j]] = sheet.rows[i][j]?.value;
            }
          }
          data.add(row);
        }
      }
    }
    return data;
  }
}
