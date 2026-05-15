// ============================================================
// Code.gs — Google Apps Script for SkripsiScan
// ============================================================
// SETUP STEPS:
// 1. Open your target Google Sheet
// 2. Extensions → Apps Script
// 3. Paste this entire file, replacing the default content
// 4. Save (Ctrl+S)
// 5. Deploy → New Deployment
//    - Type: Web App
//    - Execute as: Me
//    - Who has access: Anyone
// 6. Click Deploy, copy the Web App URL
// 7. Paste the URL into lib/core/constants/app_constants.dart
// ============================================================

var SHEET_NAME = "SkripsiData";

// Column headers — order must match buildRow() below
var HEADERS = [
  "No",
  "Timestamp",
  "Judul",
  "Nama",
  "NIM",
  "Program Studi",
  "Fakultas",
  "Universitas",
  "Tahun",
  "Scanned At"
];

/**
 * Handles HTTP POST requests from the Flutter app.
 * Accepts both single-record and batch payloads.
 */
function doPost(e) {
  try {
    var body = JSON.parse(e.postData.contents);

    // ── Determine if this is a batch or single record ──
    var records = [];
    if (body.batch && Array.isArray(body.batch)) {
      records = body.batch;
    } else {
      records = [body];
    }

    var sheet = getOrCreateSheet();
    var insertedCount = 0;

    for (var i = 0; i < records.length; i++) {
      var record = records[i];

      // Skip duplicates by NIM (if NIM is present)
      if (record.nim && isDuplicate(sheet, record.nim)) {
        Logger.log("Duplicate NIM skipped: " + record.nim);
        continue;
      }

      appendRow(sheet, record);
      insertedCount++;
    }

    return buildResponse({
      status: "success",
      message: insertedCount + " record(s) saved successfully.",
      inserted: insertedCount,
      skipped: records.length - insertedCount
    });

  } catch (err) {
    Logger.log("doPost error: " + err.toString());
    return buildResponse({ status: "error", message: err.toString() }, 500);
  }
}

/**
 * Handles HTTP GET — useful for testing the endpoint is alive.
 */
function doGet(e) {
  return buildResponse({ status: "ok", message: "SkripsiScan endpoint is running." });
}

// ─── Helper Functions ────────────────────────────────────────────────────────

/**
 * Returns the data sheet, creating it (with headers) if it doesn't exist.
 */
function getOrCreateSheet() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(SHEET_NAME);

  if (!sheet) {
    sheet = ss.insertSheet(SHEET_NAME);
    // Write header row
    sheet.appendRow(HEADERS);
    // Style the header
    var headerRange = sheet.getRange(1, 1, 1, HEADERS.length);
    headerRange.setBackground("#1A56DB");
    headerRange.setFontColor("#FFFFFF");
    headerRange.setFontWeight("bold");
    headerRange.setHorizontalAlignment("center");
    sheet.setFrozenRows(1);

    // Set column widths
    sheet.setColumnWidth(1, 50);   // No
    sheet.setColumnWidth(2, 160);  // Timestamp
    sheet.setColumnWidth(3, 320);  // Judul
    sheet.setColumnWidth(4, 180);  // Nama
    sheet.setColumnWidth(5, 130);  // NIM
    sheet.setColumnWidth(6, 180);  // Program Studi
    sheet.setColumnWidth(7, 160);  // Fakultas
    sheet.setColumnWidth(8, 200);  // Universitas
    sheet.setColumnWidth(9, 80);   // Tahun
    sheet.setColumnWidth(10, 160); // Scanned At
  }

  return sheet;
}

/**
 * Appends a new row for a single thesis record.
 */
function appendRow(sheet, record) {
  var rowNum = sheet.getLastRow(); // last used row (0-indexed header → row 1)
  var seq = rowNum; // auto-increment sequence (header=row1, so seq=lastRow)

  var row = [
    seq,
    new Date(),                            // server timestamp
    record.title    || "",
    record.name     || "",
    record.nim      || "",
    record.major    || "",
    record.faculty  || "",
    record.university || "",
    record.year     || "",
    record.scannedAt || ""
  ];

  sheet.appendRow(row);

  // Alternate row shading
  var newRow = sheet.getLastRow();
  if (newRow % 2 === 0) {
    sheet.getRange(newRow, 1, 1, HEADERS.length).setBackground("#F3F4F6");
  }
}

/**
 * Checks if a NIM already exists in column E (index 5, 1-based).
 */
function isDuplicate(sheet, nim) {
  var lastRow = sheet.getLastRow();
  if (lastRow < 2) return false;

  var nimColumn = sheet.getRange(2, 5, lastRow - 1, 1).getValues();
  for (var i = 0; i < nimColumn.length; i++) {
    if (nimColumn[i][0].toString().trim() === nim.toString().trim()) {
      return true;
    }
  }
  return false;
}

/**
 * Builds a JSON ContentService response.
 */
function buildResponse(obj, statusCode) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
