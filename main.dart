import 'dart:io';

List<String> routerBrands = <String>[
  'TP-Link',
  'TPLink'
  'Xiaomi',
  'Asus',
  'D-link',
  'DLink',
  'Intelbras',
  'Greatek',
  'MikroTik',
  'Linksys',
  'Google',
  'Netgear',
  'Amazon',
  '3com',
  'Atheros',
  'Cisco',
  'Tenda',
  'Huawei',
  'Zyxel',
  'Juniper',
  'HPE',
  'Hewlett Packard',
  'HewlettPackard',
  'Aruba',
  'Dell',
  'Nokia',
  'Avaya',
  'Synology'
];

void main() async {
  print('hello World');

  String results = await crawlFolders(directory: Directory('./results'));
  print(results);
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
Future<String> crawlFiles(
    {required String ip, required Directory directory}) async {
  final List<FileSystemEntity> files = await directory.list().toList();
  StringBuffer stringBuffer = StringBuffer();
  for (int x = 0; x < files.length; x++) {
    stringBuffer.write('${ip},');
    String filename = files[x].path.split('/').last;
    if (filename.contains('.txt')) {
      String parsedErrorFile =
          await parseErrorFile(file: files[x] as File, filename: filename);
      stringBuffer.writeln('${parsedErrorFile}');
    } else if (filename.contains('.json')) {
      String parsedJsonFile =
          await parseSucessFile(file: files[x] as File, filename: filename);
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
Future<String> parseSucessFile(
    {required File file, required String filename}) async {
  filename = filename.replaceAll('.json', '');
  List<String> filenameParts = filename.split('_');
  String port = filenameParts[1];
  String statusCode = filenameParts.last;
  String sucess = 'SUCESSO,$port,$statusCode';
  File indexFile = File('${file.parent.path}/index.html');
  String htmlFileData;
  try{
    String htmlFileData = await parseHtmlFile(file: indexFile);
    return '${sucess},${htmlFileData}';
  } catch(e){
    return '$sucess,CORRUPTED_HTML, null';
  }
}

Future<String> parseHtmlFile({required File file}) async {
  String fileData = await file.readAsString();
  String brand = 'UNKNOWN BRAND';

  routerBrands.any((element) {
    if (fileData.toLowerCase().contains(element.toLowerCase())) {
      brand = element;
      return true;
    }
    return false;
  });
  return '${brand}';
}

///
///
///
Future<String> parseErrorFile(
    {required File file, required String filename}) async {
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
