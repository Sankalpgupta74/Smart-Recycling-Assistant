import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/report_model.dart';
import '../providers/language_provider.dart';

class ClassifierScreen extends StatefulWidget {
  const ClassifierScreen({super.key});

  @override
  State<ClassifierScreen> createState() => _ClassifierScreenState();
}

class _ClassifierScreenState extends State<ClassifierScreen>
    with TickerProviderStateMixin {
  Interpreter? _interpreter;
  List<String>? _labels;
  List<List<dynamic>>? _binData;
  File? _image;
  final List<File> _imageQueue = [];

  String _resultText = "";
  String _binColor = "";
  String _selectedCity = "Delhi";
  String _selectedCountry = "India";
  String _targetLanguage = "hi";
  String _confidenceText = "";
  String _riskLevel = "";
  String _doText = "";
  String _dontText = "";
  String _ecoTip = "";

  final translator = GoogleTranslator();

  String _lifecycle = "";
  String _action = "";
  String _safety = "";
  String _ocrText = "";
  String _cityDisplay = "Detecting location...";
  String _countryDisplay = "";

  final DatabaseService _dbService = DatabaseService();
  bool _isSyncing = false;
  bool _isBusy = false;
  Position? _currentPosition;


  bool _assetsLoaded = false;

  late AnimationController _resultAnimCtrl;
  late Animation<double> _resultFade;
  late Animation<Offset> _resultSlide;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final Map<String, Map<String, dynamic>> _wasteKnowledgeBase = {
    "biodegradable": {
      "displayName": "Biodegradable Waste",
      "lifecycle": "Compostable / Organic",
      "riskLevel": "Low",
      "binSuggestion": "Green Bin / Wet Waste",
      "disposalInstruction":
          "Dispose in wet waste or compost bin. Suitable for composting if segregated properly.",
      "safetyNote":
          "If left exposed for long periods, it may attract insects, pests, and cause foul odor.",
      "doList": [
        "Dispose separately from dry waste",
        "Use for composting when possible",
        "Keep in sealed biodegradable bags if needed"
      ],
      "dontList": [
        "Do not mix with plastic or metal waste",
        "Do not leave uncovered for long durations",
        "Do not throw in dry recycling bins"
      ],
      "ecoTip":
          "Composting biodegradable waste can reduce landfill load and improve soil health."
    },
    "cardboard": {
      "displayName": "Cardboard",
      "lifecycle": "Recyclable",
      "riskLevel": "Low",
      "binSuggestion": "Blue Bin / Dry Waste",
      "disposalInstruction":
          "Flatten the cardboard and place it in the dry waste or paper recycling bin.",
      "safetyNote":
          "Wet or oil-soaked cardboard may not be recyclable in many local systems.",
      "doList": [
        "Fold or flatten before disposal",
        "Keep clean and dry",
        "Remove plastic tape if possible"
      ],
      "dontList": [
        "Do not recycle if soaked with food or oil",
        "Do not mix with wet waste",
        "Do not burn indoors"
      ],
      "ecoTip":
          "Recycling cardboard helps reduce deforestation and saves manufacturing energy."
    },
    "glass": {
      "displayName": "Glass",
      "lifecycle": "Reusable / Recyclable",
      "riskLevel": "Medium",
      "binSuggestion": "Blue Bin / Glass Collection",
      "disposalInstruction":
          "Rinse the glass item and dispose in the appropriate glass or dry recycling stream.",
      "safetyNote":
          "Broken glass can cause serious cuts and should be handled with extra care.",
      "doList": [
        "Rinse before disposal",
        "Reuse jars and bottles if possible",
        "Wrap broken pieces before discarding"
      ],
      "dontList": [
        "Do not throw broken glass loosely",
        "Do not mix with biodegradable waste",
        "Do not leave shattered pieces exposed"
      ],
      "ecoTip":
          "Glass can often be recycled multiple times without major quality loss."
    },
    "metal": {
      "displayName": "Metal",
      "lifecycle": "Recyclable",
      "riskLevel": "Medium",
      "binSuggestion": "Blue Bin / Dry Waste",
      "disposalInstruction":
          "Clean the metal item if possible and place it in the dry recycling stream.",
      "safetyNote":
          "Sharp metal edges or rusted surfaces may cause cuts or minor injuries.",
      "doList": [
        "Rinse food cans before disposal",
        "Flatten cans if safe to do so",
        "Segregate from wet waste"
      ],
      "dontList": [
        "Do not dispose sharp pieces openly",
        "Do not mix with organic waste",
        "Do not burn or crush hazardous metal containers"
      ],
      "ecoTip":
          "Recycling metal saves raw material extraction and reduces industrial energy usage."
    },
    "paper": {
      "displayName": "Paper",
      "lifecycle": "Recyclable",
      "riskLevel": "Low",
      "binSuggestion": "Blue Bin / Dry Waste",
      "disposalInstruction":
          "Place clean and dry paper in the paper or dry recycling bin.",
      "safetyNote":
          "Paper contaminated with oil, chemicals, or heavy moisture may not be recyclable.",
      "doList": [
        "Keep paper dry",
        "Bundle paper together if possible",
        "Separate from food-contaminated waste"
      ],
      "dontList": [
        "Do not recycle wet or oily paper",
        "Do not mix with wet waste",
        "Do not burn paper waste casually"
      ],
      "ecoTip":
          "Paper recycling helps save trees, water, and energy."
    },
    "plastic": {
      "displayName": "Plastic",
      "lifecycle": "Recyclable (depending on type)",
      "riskLevel": "Low to Medium",
      "binSuggestion": "Blue Bin / Dry Waste",
      "disposalInstruction":
          "Clean the plastic item and place it in the dry waste or recycling bin if accepted locally.",
      "safetyNote":
          "Burning plastic may release harmful fumes and should always be avoided.",
      "doList": [
        "Rinse bottles and containers",
        "Segregate soft and hard plastics if needed",
        "Recycle according to local rules"
      ],
      "dontList": [
        "Do not burn plastic",
        "Do not throw plastic with food waste",
        "Do not litter near drains or open areas"
      ],
      "ecoTip":
          "Reducing single-use plastic is one of the most effective waste prevention habits."
    },
    "trash": {
      "displayName": "Mixed Trash",
      "lifecycle": "General Waste / Non-Recyclable",
      "riskLevel": "Variable",
      "binSuggestion": "Black Bin / General Waste",
      "disposalInstruction":
          "Dispose in general waste if the item cannot be clearly recycled or composted.",
      "safetyNote":
          "Mixed waste may contain hidden sharp, dirty, or hazardous components.",
      "doList": [
        "Check if any part can be separated for recycling",
        "Seal contaminated waste before disposal",
        "Handle mixed waste carefully"
      ],
      "dontList": [
        "Do not assume all trash is harmless",
        "Do not mix potentially hazardous items casually",
        "Do not leave exposed in public areas"
      ],
      "ecoTip":
          "Whenever possible, separate recyclables from mixed trash before disposal."
    },
  };

  @override
  void initState() {
    super.initState();
    _resultAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _resultFade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _resultAnimCtrl, curve: Curves.easeOut));
    _resultSlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _resultAnimCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _initApp();
  }

  @override
  void dispose() {
    _resultAnimCtrl.dispose();
    _pulseCtrl.dispose();
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _initApp() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/waste_v1_final.tflite');

      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((e) => e.trim())
          .toList();

      debugPrint("Loaded labels: ${_labels!.length}");
      debugPrint("Labels: $_labels");

      try {
        final csvData = await rootBundle.loadString('assets/local_bin_rules.csv');
        _binData = const CsvToListConverter().convert(csvData);
      } catch (e) {
        debugPrint("CSV Load error: $e");
      }

      await _detectLocation();

      if (mounted) {
        setState(() => _assetsLoaded = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultText = "Asset Error: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _detectLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFallbackLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setFallbackLocation();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      _currentPosition = position;

      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea ?? "Delhi");
        final country = place.country ?? "India";

        if (mounted) {
          setState(() {
            _selectedCity = _normalizeCity(city);
            _selectedCountry = _normalizeCountry(country);
            _cityDisplay = _selectedCity;
            _countryDisplay = _selectedCountry;
          });
        }
      } else {
        _setFallbackLocation();
      }
    } catch (e) {
      _setFallbackLocation();
    }
  }

  void _setFallbackLocation() {
    if (mounted) {
      setState(() {
        _selectedCity = "Delhi";
        _selectedCountry = "India";
        _cityDisplay = "Delhi";
        _countryDisplay = "India";
      });
    }
  }

  String _normalizeCity(String city) {
    final c = city.toLowerCase();
    if (c.contains("venice")) return "Venice";
    if (c.contains("delhi")) return "Delhi";
    if (c.contains("new york")) return "New York";
    if (c.contains("paris")) return "Paris";
    if (c.contains("tokyo")) return "Tokyo";
    return "Delhi";
  }

  String _normalizeCountry(String country) {
    final c = country.toLowerCase();
    if (c.contains("italy")) return "Italy";
    if (c.contains("india")) return "India";
    if (c.contains("france")) return "France";
    if (c.contains("japan")) return "Japan";
    if (c.contains("united states") || c.contains("usa")) return "USA";
    return "India";
  }

  Future<void> _pickCameraImage() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo == null) return;
    _imageQueue.clear();
    _processNewImage(File(photo.path));
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> photos = await ImagePicker().pickMultiImage();
    if (photos.isEmpty) return;
    _imageQueue.clear();
    _imageQueue.addAll(photos.map((p) => File(p.path)));
    _processNextInQueue();
  }

  void _processNextInQueue() {
    if (_imageQueue.isEmpty) return;
    _processNewImage(_imageQueue.removeAt(0));
  }

  void _processNewImage(File file) async {
    _resultAnimCtrl.reset();
    setState(() {
      _image = file;
      _isBusy = true;
      _binColor = "";
      _ocrText = "";
      _resultText = "";
    });
    try {
      await _processImageFeatures(file);
    } catch (e) {
      debugPrint("Processing Error: $e");
      if (mounted) {
        setState(() {
          _isBusy = false;
          _resultText = "ERROR";
          _binColor = "Red";
          _lifecycle = "N/A";
          _action = "Please try again.";
          _safety = "Model failed to process the image.";
        });
        _resultAnimCtrl.forward();
      }
    }
  }

  Future<void> _processImageFeatures(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      throw Exception("Model or labels not loaded");
    }

    debugPrint("=== STEP 1: Reading image ===");
    final imageBytes = await imageFile.readAsBytes();
    img.Image? decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception("Failed to decode image");
    }

    debugPrint("=== STEP 2: Resizing image ===");
    img.Image resized = img.copyResize(decoded, width: 640, height: 640);

    final Uint8List bytes = resized.getBytes(order: img.ChannelOrder.rgb);

    debugPrint("=== STEP 3: Preparing input ===");
    var input = List.generate(
      1,
      (_) => List.generate(
        640,
        (y) => List.generate(
          640,
          (x) {
            final int offset = (y * 640 + x) * 3;
            return [
              bytes[offset] / 255.0,
              bytes[offset + 1] / 255.0,
              bytes[offset + 2] / 255.0,
            ];
          },
        ),
      ),
    );

    int numClasses = _labels!.length;
    debugPrint("Num classes from labels: $numClasses");

    debugPrint("=== STEP 4: Preparing output ===");
    var output = List.generate(
      1,
      (_) => List.generate(
        4 + numClasses,
        (_) => List.filled(8400, 0.0),
      ),
    );

    debugPrint("=== STEP 5: Running inference ===");
    _interpreter!.run(input, output);
    debugPrint("=== STEP 6: Inference completed ===");

    // YOLO Parsing for MULTIPLE classes
    List<double> classMaxScores = List.filled(numClasses, 0.0);
    for (int a = 0; a < 8400; a++) {
      for (int c = 0; c < numClasses; c++) {
        double score = output[0][c + 4][a];
        if (score > classMaxScores[c]) {
          classMaxScores[c] = score;
        }
      }
    }

    List<Map<String, dynamic>> detectedItems = [];
    for (int c = 0; c < numClasses; c++) {
      if (classMaxScores[c] > 0.20) {
        detectedItems.add({"classIndex": c, "score": classMaxScores[c], "label": _labels![c]});
      }
    }

    detectedItems.sort((a, b) => b["score"].compareTo(a["score"]));

    // Optional: filter out 'trash' if we found more specific items
    if (detectedItems.length > 1) {
      detectedItems.removeWhere((item) => 
        item["label"].toString().toLowerCase() == "trash" || 
        item["label"].toString().toLowerCase() == "dump_site"
      );
    }

    String detectedBin = "Green"; 
    String lifecycle = "UNKNOWN";
    String action = "Try clearer lighting / closer image";
    String safety = "No confident detection found";
    String confidenceLabel = "";
    List<String> mappedLabels = [];
    String baseResultText = "NO DETECTION";

    if (detectedItems.isNotEmpty) {
      for(var item in detectedItems) {
         mappedLabels.add(_mapRawLabelToDomain(item["label"].toString()));
      }
      mappedLabels = mappedLabels.toSet().toList(); // Remove duplicates

      baseResultText = mappedLabels.map((e) => e.replaceAll("_", " ")).join(" & ").toUpperCase();
      lifecycle = "DETECTED";
      action = "Detected ${mappedLabels.length} material(s)";
      
      confidenceLabel = "${(detectedItems.first["score"] * 100).toStringAsFixed(1)}%";
      if (detectedItems.length > 1) {
         confidenceLabel += " (Multi)";
      }
      safety = "Model confidence: $confidenceLabel";
    } else {
      mappedLabels.add("Dump_Site");
      baseResultText = "DUMP SITE";
    }

    debugPrint("=== STEP 7: Detected Items = ${mappedLabels.join(', ')} ===");

    // Instant UI Update for Model Detection
    if (mounted) {
      setState(() {
        _isBusy = false; // Unlock the UI instantly
        _resultText = baseResultText;
        _binColor = detectedBin; 
        _lifecycle = lifecycle;
        _action = action;
        _safety = safety;
        _confidenceText = confidenceLabel;
        _ocrText = "Scanning..."; 
      });
    }

    _resultAnimCtrl.forward();

    // Now securely run background tasks so UI is responsive
    final langCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    if (detectedItems.isNotEmpty) {
      _runBackgroundEnhancements(imageFile, mappedLabels, langCode);
    } else {
      if (mounted) {
        setState(() {
           _ocrText = ""; 
        });
      }
    }
  }

  String _mapRawLabelToDomain(String predictedLabel) {
    String m = predictedLabel.toLowerCase();
    if (m == "biodegradable" || m == "organic") return "Organic_Food";
    if (m == "cardboard" || m == "paper") return "Paper_Cardboard";
    if (m == "glass") return "Glass";
    if (m == "metal") return "Metal";
    if (m == "plastic") return "Plastic";
    if (m == "trash" || m == "dump_site") return "Dump_Site";
    return predictedLabel.replaceAll(" ", "_");
  }

  Future<void> _runBackgroundEnhancements(File imageFile, List<String> mappedMaterials, String langCode) async {
    try {
      debugPrint("--- Background Step 1: Starting OCR ---");
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage).timeout(const Duration(seconds: 5));
      
      String ocrResult = recognizedText.text.replaceAll('\n', ' ');
      debugPrint("OCR Text: $ocrResult");
      debugPrint("--- Background Step 1: OCR Finished ---");
      
      List<String> finalMaterials = _smartOcrOverrideMulti(mappedMaterials, ocrResult);
      await textRecognizer.close();

      debugPrint("--- Background Step 2: Updating UI Multilingual ---");
      debugPrint("City: $_selectedCity, Country: $_selectedCountry");
      await _updateUIMultilingualMulti(finalMaterials, ocrResult, langCode);

    } catch (e) {
      debugPrint("Background Error: $e");
      if (mounted) {
        setState(() {
           _ocrText = "OCR Failed";
        });
      }
    }
  }

  List<String> _smartOcrOverrideMulti(List<String> predictedMaterials, String ocr) {
    final text = ocr.toUpperCase();
    String? ocrMaterial;

    if (text.contains("PET") || text.contains("HDPE") || text.contains("LDPE") || text.contains("PP") || text.contains("PVC")) ocrMaterial = "Plastic";
    else if (text.contains("PAP") || text.contains("CARDBOARD")) ocrMaterial = "Paper_Cardboard";
    else if (text.contains("GLASS") || text.contains("GL 70")) ocrMaterial = "Glass";
    else if (text.contains("ALU") || text.contains("TIN") || text.contains("CAN")) ocrMaterial = "Metal";
    else if (text.contains("BATTERY") || text.contains("PCB") || text.contains("CHARGER") || text.contains("E-WASTE")) ocrMaterial = "Electronic_Waste";
    else if (text.contains("BIOHAZARD") || text.contains("SYRINGE") || text.contains("MEDICAL")) ocrMaterial = "Medical_Waste";
    
    List<String> finalMaterials = List.from(predictedMaterials);
    if (ocrMaterial != null && !finalMaterials.contains(ocrMaterial)) {
      finalMaterials.insert(0, ocrMaterial);
    }
    return finalMaterials;
  }

  String _extractBaseBinColor(String binStr) {
    String lower = binStr.toLowerCase();
    if (lower.contains("blue")) return "Blue";
    if (lower.contains("green")) return "Green";
    if (lower.contains("yellow")) return "Yellow";
    if (lower.contains("brown")) return "Brown";
    if (lower.contains("red")) return "Red";
    if (lower.contains("black")) return "Black";
    return binStr;
  }

  Future<void> _updateUIMultilingualMulti(List<String> materials, String ocrStr, String langCode) async {
    if (materials.isEmpty) return;

    List<Map<String, dynamic>> multiData = [];

    for (var material in materials) {
      final key = material.toLowerCase().trim();
      final data = _wasteKnowledgeBase[key] ?? _wasteKnowledgeBase["trash"]!;

      String displayName = data["displayName"];
      String lifecycle = data["lifecycle"];
      String riskLevel = data["riskLevel"];
      String bin = data["binSuggestion"];
      String disposalInstruction = data["disposalInstruction"];
      String safetyNote = data["safetyNote"];
      List<String> doList = List<String>.from(data["doList"]);
      List<String> dontList = List<String>.from(data["dontList"]);
      String ecoTip = data["ecoTip"];

      if (_binData != null) {
        for (var i = 1; i < _binData!.length; i++) {
          final row = _binData![i];

          if (row[0].toString().trim().toLowerCase() == _selectedCity.toLowerCase() &&
              row[1].toString().trim().toLowerCase() == _selectedCountry.toLowerCase() &&
              row[2].toString().trim().toLowerCase() == material.toLowerCase()) {
            bin = row[3].toString();
            disposalInstruction = "${data["disposalInstruction"]} ${row[4].toString()}";
            break;
          }
        }
      }

      multiData.add({
        "material": material,
        "displayName": displayName,
        "lifecycle": lifecycle,
        "riskLevel": riskLevel,
        "bin": bin,
        "disposalInstruction": disposalInstruction,
        "safetyNote": safetyNote,
        "doList": doList,
        "dontList": dontList,
        "ecoTip": ecoTip,
      });
    }

    String resDisplayName = "";
    String resLifecycle = "";
    String resRiskLevel = "";
    String resBin = "";
    String resInstruction = "";
    String resSafety = "";
    String resDoText = "";
    String resDontText = "";
    String resEcoTip = "";

    if (multiData.length == 1) {
      var d = multiData.first;
      resDisplayName = d["displayName"];
      resLifecycle = d["lifecycle"];
      resRiskLevel = d["riskLevel"];
      resBin = d["bin"];
      resInstruction = d["disposalInstruction"];
      resSafety = d["safetyNote"];
      resDoText = (d["doList"] as List<String>).map((e) => "• $e").join("\n");
      resDontText = (d["dontList"] as List<String>).map((e) => "• $e").join("\n");
      resEcoTip = d["ecoTip"];
    } else {
      var firstBinColor = _extractBaseBinColor(multiData.first["bin"]);
      bool sameBins = multiData.every((d) => _extractBaseBinColor(d["bin"]) == firstBinColor);

      resDisplayName = multiData.map((d) => d["displayName"]).join(" & ");

      if (sameBins) {
        resBin = multiData.first["bin"];
        resLifecycle = "MULTIPLE (SAME BIN)";
        resRiskLevel = "Variable";
        resInstruction = "All items belong to the same bin.\n" + multiData.first["disposalInstruction"];
        resSafety = "Ensure proper handling for each item.";
        resDoText = "• Group them together\n• Follow general recycling steps";
        resDontText = "• Do not mix with wet waste if they are dry recyclables";
        resEcoTip = "Even though they share a bin, keep them as clean as possible.";
      } else {
        resBin = "Mixed Separately";
        resLifecycle = "REQUIRES SORTING";
        resRiskLevel = "High (Cross-contamination)";

        List<String> instList = [];
        for (var d in multiData) {
          instList.add("• ${d["displayName"]} ➔ ${d["bin"]}");
        }
        resInstruction = "Please separate these items:\n" + instList.join("\n");
        resSafety = "Mixed items can contaminate recycling streams.";
        resDoText = "• Sort items by material type\n• Use appropriate separate bins";
        resDontText = "• DO NOT throw them all in the same bin\n• Do not contaminate clean recyclables";
        resEcoTip = "Taking a moment to sort your waste drastically improves recycling efficiency!";
      }
    }

    if (langCode != "en") {
      try {
        resDisplayName = (await translator.translate(resDisplayName, to: langCode)).text;
        resLifecycle = (await translator.translate(resLifecycle, to: langCode)).text;
        resRiskLevel = (await translator.translate(resRiskLevel, to: langCode)).text;
        resBin = (await translator.translate(resBin, to: langCode)).text;
        resInstruction = (await translator.translate(resInstruction, to: langCode)).text;
        resSafety = (await translator.translate(resSafety, to: langCode)).text;
        resDoText = (await translator.translate(resDoText, to: langCode)).text;
        resDontText = (await translator.translate(resDontText, to: langCode)).text;
        resEcoTip = (await translator.translate(resEcoTip, to: langCode)).text;
      } catch (e) {
        debugPrint("Translation Error: $e");
      }
    }

    if (mounted) {
      setState(() {
        _resultText = resDisplayName.toUpperCase();
        _binColor = resBin;
        _lifecycle = resLifecycle;
        _action = resInstruction;
        _safety = resSafety;
        _riskLevel = resRiskLevel;
        _doText = resDoText;
        _dontText = resDontText;
        _ecoTip = resEcoTip;
        _ocrText = ocrStr;
      });
    }
  }

  Color _getBinAccentColor() {
    String b = _binColor.toLowerCase();
    if (b.contains("blue")) return const Color(0xFF42A5F5);
    if (b.contains("green")) return const Color(0xFF66BB6A);
    if (b.contains("yellow")) return const Color(0xFFFFCA28);
    if (b.contains("brown")) return const Color(0xFF8D6E63);
    if (b.contains("red")) return const Color(0xFFEF5350);
    return const Color(0xFF78909C);
  }

  List<Color> _getBinGradient() {
    String b = _binColor.toLowerCase();
    if (b.contains("blue")) {
      return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
    }
    if (b.contains("green")) {
      return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
    }
    if (b.contains("yellow")) {
      return [const Color(0xFFF9A825), const Color(0xFFFFCA28)];
    }
    if (b.contains("brown")) {
      return [const Color(0xFF6D4C41), const Color(0xFF8D6E63)];
    }
    if (b.contains("red")) {
      return [const Color(0xFFC62828), const Color(0xFFEF5350)];
    }
    return [const Color(0xFF455A64), const Color(0xFF78909C)];
  }

  IconData _getMaterialIcon(String material) {
    final m = material.toLowerCase();
    if (m.contains('&') || m.contains('mixed')) return Icons.call_split_rounded;
    if (m.contains('glass')) return Icons.wine_bar_rounded;
    if (m.contains('plastic')) return Icons.local_drink_rounded;
    if (m.contains('metal')) return Icons.settings_rounded;
    if (m.contains('organic')) return Icons.spa_rounded;
    if (m.contains('paper')) return Icons.description_rounded;
    if (m.contains('electronic')) return Icons.memory_rounded;
    if (m.contains('medical')) return Icons.medical_services_rounded;
    if (m.contains('hazard')) return Icons.warning_amber_rounded;
    return Icons.delete_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: !_assetsLoaded
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0E14),
                    Color(0xFF101820),
                    Color(0xFF0A0E14)
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildImageArea(),
                            const SizedBox(height: 20),
                            if (_isBusy) _buildLoadingState(),
                            if (!_isBusy && _binColor.isNotEmpty)
                              _buildResultSection(),
                            if (!_isBusy && _binColor.isEmpty && _image == null)
                              _buildWelcomeState(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildScanButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset('assets/app_logo.png', fit: BoxFit.cover, filterQuality: FilterQuality.high),
            ),
          ),
          const SizedBox(width: 10),
          Text('Recycle Easy',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const ImageIcon(AssetImage('assets/icons/map_perfect.png'),
                    size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  _cityDisplay,
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return GestureDetector(
      onTap: _pickGalleryImages,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        height: _image != null ? 280 : 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: _image == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.04),
                    Colors.white.withOpacity(0.02),
                  ])
              : null,
          border: Border.all(
            color: _image != null
                ? _getBinAccentColor().withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: _image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_image!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: const ImageIcon(AssetImage('assets/icons/gallery_perfect.png'),
                          size: 30, color: Colors.white24),
                    ),
                    const SizedBox(height: 14),
                    Text('Tap to select from gallery',
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: Colors.white30)),
                    const SizedBox(height: 4),
                    Text('or use the scan button below',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.white24)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text('How It Works',
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white54)),
        const SizedBox(height: 16),
        _buildStepTile('1', 'Scan or Upload',
            'Take a photo or pick from gallery', const Color(0xFF00E676)),
        const SizedBox(height: 10),
        _buildStepTile('2', 'AI + OCR Fusion',
            'Model prediction enhanced by package text', const Color(0xFF00B0FF)),
        const SizedBox(height: 10),
        _buildStepTile('3', 'Location Guidance',
            'Get local disposal rules in your language', const Color(0xFFFFCA28)),
      ],
    );
  }

  Widget _buildStepTile(
      String num, String title, String subtitle, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
            ),
            child: Center(
                child: Text(num,
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: accent))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85))),
                Text(subtitle,
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 30),
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(
                const Color(0xFF00E676).withOpacity(0.8)),
          ),
        ),
        const SizedBox(height: 18),
        Text('Analyzing waste...',
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white54)),
        const SizedBox(height: 6),
        Text('Running AI classification + OCR + local rules',
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.white24)),
      ],
    );
  }

  Widget _buildResultSection() {
    final accent = _getBinAccentColor();
    final gradient = _getBinGradient();

    return SlideTransition(
      position: _resultSlide,
      child: FadeTransition(
        opacity: _resultFade,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  gradient[0].withOpacity(0.25),
                  gradient[1].withOpacity(0.1),
                ]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: gradient),
                      boxShadow: [
                        BoxShadow(
                            color: accent.withOpacity(0.3), blurRadius: 16),
                      ],
                    ),
                    child: Icon(_getMaterialIcon(_resultText),
                        size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_resultText,
                            style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        if (_confidenceText.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text("Confidence: $_confidenceText",
                              style: GoogleFonts.outfit(
                                  fontSize: 13, color: Colors.white70)),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _binColor.toUpperCase(),
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accent,
                                letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_imageQueue.isNotEmpty)
                    IconButton(
                      onPressed: _processNextInQueue,
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.skip_next_rounded,
                            color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_confidenceText.isNotEmpty) ...[
              _buildGlassInfoCard(
                icon: Icons.verified_rounded,
                title: 'CONFIDENCE',
                content: _confidenceText,
                accent: const Color(0xFF29B6F6),
              ),
              const SizedBox(height: 10),
            ],
            if (_riskLevel.isNotEmpty) ...[
              _buildGlassInfoCard(
                icon: Icons.shield_rounded,
                title: 'RISK LEVEL',
                content: _riskLevel,
                accent: const Color(0xFFFF7043),
              ),
              const SizedBox(height: 10),
            ],
            _buildGlassInfoCard(
              icon: Icons.loop_rounded,
              title: 'LIFECYCLE',
              content: _lifecycle,
              accent: const Color(0xFF00E676),
            ),
            const SizedBox(height: 10),
            if (_doText.isNotEmpty) ...[
              _buildGlassInfoCard(
                icon: Icons.check_circle_rounded,
                title: 'DO',
                content: _doText,
                accent: const Color(0xFF66BB6A),
              ),
              const SizedBox(height: 10),
            ],
            if (_dontText.isNotEmpty) ...[
              _buildGlassInfoCard(
                icon: Icons.cancel_rounded,
                title: "DON'T",
                content: _dontText,
                accent: const Color(0xFFEF5350),
                isWarning: true,
              ),
            ],
            _buildGlassInfoCard(
              icon: Icons.tips_and_updates_rounded,
              title: 'RECOMMENDED ACTION',
              content: _action,
              accent: const Color(0xFF00B0FF),
            ),
            const SizedBox(height: 10),
            _buildGlassInfoCard(
              icon: Icons.warning_amber_rounded,
              title: 'SAFETY NOTICE',
              content: _safety,
              accent: const Color(0xFFFF7043),
              isWarning: true,
            ),
            if (_ecoTip.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildGlassInfoCard(
                icon: Icons.eco_rounded,
                title: 'ECO TIP',
                content: _ecoTip,
                accent: const Color(0xFF00E676),
              ),
            ],
            if (_ocrText.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildGlassInfoCard(
                icon: Icons.document_scanner_rounded,
                title: 'OCR DETECTED TEXT',
                content: _ocrText,
                accent: const Color(0xFFAB47BC),
              ),
            ],
            const SizedBox(height: 10),
            _buildGlassInfoCard(
              icon: Icons.location_city_rounded,
              title: 'LOCAL RULE SOURCE',
              content: "$_selectedCity, $_selectedCountry",
              accent: const Color(0xFFFFCA28),
            ),
            const SizedBox(height: 24),
            _buildSyncButton(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [const Color(0xFF00E676).withOpacity(0.1), const Color(0xFF00B0FF).withOpacity(0.1)],
        ),
        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSyncing ? null : _syncScanToCloud,
          child: Center(
            child: _isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E676)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_rounded, color: Color(0xFF00E676), size: 20),
                      const SizedBox(width: 10),
                      Text("SYNC TO CLOUD",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                          )),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _syncScanToCloud() async {
    if (_image == null) return;
    
    setState(() => _isSyncing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final imageUrl = await _dbService.uploadImage(_image!);

      if (imageUrl != null) {
        final report = WasteReport(
          id: '',
          userId: user?.uid ?? 'anon',
          userName: user?.displayName ?? 'Anonymous',
          latitude: _currentPosition?.latitude ?? 0.0,
          longitude: _currentPosition?.longitude ?? 0.0,
          imageUrl: imageUrl,
          wasteType: _resultText,
          notes: "Auto-scan: $_action",
          timestamp: DateTime.now(),
          status: 'scanned',
        );

        await _dbService.createReport(report);
        
        if (mounted) {
          setState(() => _isSyncing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Scan successfully synced to your account!"),
              backgroundColor: Color(0xFF00E676),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isSyncing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sync failed: Image upload error"), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sync failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }


  Widget _buildGlassInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color accent,
    bool isWarning = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isWarning
                ? accent.withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isWarning
                    ? accent.withOpacity(0.3)
                    : Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.15),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accent,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 5),
                    Text(content,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ScaleTransition(
        scale: _image == null ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF00E676)],
            ),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isBusy ? null : _pickCameraImage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ImageIcon(AssetImage('assets/icons/Scan Icon.png'),
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    _isBusy ? 'ANALYZING...' : Provider.of<LanguageProvider>(context).getText('scan_button'),
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}