import 'dart:io';

import 'package:fast_gbk/fast_gbk.dart';

import 'brands.dart';
import 'models.dart';

void main() async {
  print('hello World');

  String results = await crawlFolders(directory: Directory('./results'));
  await File('results.csv').writeAsString(results);
}

/// A recursive method to browse through all the folders, when it reaches the last level,
/// it concatenates the folder names and forms the IP.
/// After that, it calls the crawlFiles method that will browse through all the files in that folder.
Future<String> crawlFolders({required Directory directory}) async {
  final List<FileSystemEntity> folders = await directory.list().toList();
  StringBuffer stringBuffer = StringBuffer();

  if (folders.whereType<Directory>().isEmpty) {
    List<String> foldersNames = directory.path.split('/');
    String ip = getIp(foldersNames);
    StringBuffer results = StringBuffer();

    String filesResult = await crawlFiles(ip: ip, directory: directory);
    results.write(filesResult);
    return results.toString();
  }
  for (int x = 0; x < folders.whereType<Directory>().toList().length; x++) {
    Directory nextDir = Directory(folders[x].path);
    stringBuffer.write(await crawlFolders(directory: nextDir));
  }
  return stringBuffer.toString();
}

///Iterates over the files inside the folder passed in the [directory] parameter and checks
///if it is a success or error file, if successful, it will parse the json and html
///
Future<String> crawlFiles({
  required String ip,
  required Directory directory,
}) async {
  final List<FileSystemEntity> files = await directory.list().toList();
  StringBuffer stringBuffer = StringBuffer();
  for (int x = 0; x < files.length; x++) {
    String filename = files[x].path.split('/').last;
    if (filename.contains('.txt')) {
      stringBuffer.write('${ip},');
      String parsedErrorFile =
          await parseErrorFile(file: files[x] as File, filename: filename);
      stringBuffer.writeln('${parsedErrorFile}');
    } else if (filename.contains('.json')) {
      stringBuffer.write('${ip},');
      String parsedJsonFile =
          await parseSucessFile(jsonFile: files[x] as File, filename: filename);
      stringBuffer.writeln('${parsedJsonFile}');
    } else {
      continue;
    }
  }
  return stringBuffer.toString();
}

///
///
///
Future<String> parseSucessFile({
  required File jsonFile,
  required String filename,
}) async {
  filename = filename.replaceAll('.json', '');
  List<String> filenameParts = filename.split('_');
  String port = filenameParts[1];
  String statusCode = filenameParts.last;
  String sucess = 'SUCESSO,$port,$statusCode';
  File indexFile = File('${jsonFile.parent.path}/index.html');
  String htmlFileData;
  htmlFileData = await parseRouterInfo(htmlFile: indexFile, jsonFile: jsonFile);
  return '${sucess},${htmlFileData}';
}

///
///
///
Future<String> parseRouterInfo({
  required File htmlFile,
  required File jsonFile,
}) async {
  String htmlFileData;
  String jsonString = await jsonFile.readAsString();
  try {
    htmlFileData = await htmlFile.readAsString();
  } catch (e) {
    try {
      htmlFileData = await htmlFile.readAsString(encoding: gbk);
    } catch (e) {
      return 'CORRUPTED_HTML, null';
    }
  }
  String brand =
      getRouterBrand(indexHtmlString: htmlFileData, jsonString: jsonString);
  String model =
      getRouterModel(indexHtmlString: htmlFileData, jsonString: jsonString);
  return '${brand},${model}';
}

///
///
///
String getRouterBrand({
  required String indexHtmlString,
  required String jsonString,
}) {
  String brand = 'UNKNOWN_BRAND';

  routerBrands.any((element) {
    if (jsonString.toLowerCase().contains(element.toLowerCase())) {
      brand = element;
      return true;
    }
    return false;
  });

  if (brand == 'UNKNOWN_BRAND') {
    routerBrands.any((element) {
      if (indexHtmlString.toLowerCase().contains(element.toLowerCase())) {
        brand = element;
        return true;
      }
      return false;
    });
  }
  return brand;
}

///
///
///
String getRouterModel({
  required String indexHtmlString,
  required String jsonString,
}) {
  String model = 'UNKNOWN_MODEL';
  routerModels.any((element) {
    if (jsonString.toLowerCase().contains(element.toLowerCase())) {
      model = element;
      return true;
    }
    return false;
  });

  if (model == 'UNKNOWN_MODEL') {
    routerModels.any((element) {
      if (indexHtmlString.toLowerCase().contains(element.toLowerCase())) {
        model = element;
        return true;
      }
      return false;
    });
  }

  return model;
}

///
///
///
Future<String> parseErrorFile({
  required File file,
  required String filename,
}) async {
  filename = filename.replaceAll('.txt', '');
  List<String> filenameParts = filename.split('_');
  return 'ERRO,${filenameParts[1]},null,null,null';
}

///
///
///
String getIp(List<String> foldersNames) {
  StringBuffer ip = StringBuffer();
  for (int x = 4; x > 0; x--) {
    if (x == 1) {
      ip.write(foldersNames[foldersNames.length - x]);
    } else {
      ip.write('${foldersNames[foldersNames.length - x]}.');
    }
  }
  return ip.toString();
}
