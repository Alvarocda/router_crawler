import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

void main() async {
  print('hello World');
  
  String results = await crawlFolders(directory: Directory('./results'));
  print(results);
}

///
///
///
Future<String> crawlFolders({required Directory directory}) async {
  final List<FileSystemEntity> folders = await directory.list().toList();
  StringBuffer stringBuffer = StringBuffer();

  if(folders.whereType<Directory>().isEmpty){
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

///
///
///
Future<String> crawlFiles({required String ip, required Directory directory}) async {
  final List<FileSystemEntity> files = await directory.list().toList();
  StringBuffer stringBuffer = StringBuffer();
  for(int x = 0; x < files.length; x++){
      stringBuffer.write('${ip},');
      String filename = files[x].path.split('/').last;
      if(filename.contains('.txt')){
        String parsedErrorFile = await parseErrorFile(file: files[x] as File, filename: filename);
        stringBuffer.writeln('${parsedErrorFile}');
      } else if (filename.contains('.json')){
        String parsedJsonFile = await parseJsonFile(file: files[x] as File, filename: filename);
        stringBuffer.writeln('${parsedJsonFile}');
      }else{
        // parse Html FIle
        stringBuffer.writeln('html');
      }
    }
    return stringBuffer.toString();
}

///
///
///
Future<String> parseJsonFile({required File file, required String filename}) async{
  return 'JSON';
}
///
///
///
Future<String> parseErrorFile({required File file, required String filename})async{
  filename = filename.replaceAll('.txt', '');
  List<String> filenameParts = filename.split('_');
  String exception = await parseExceptionMessage(file: file);
  return 'ERRO,${filenameParts[1]},$exception';
}

///
///
///
Future<String> parseExceptionMessage({required File file}) async{
  String exceptionLine = await file.openRead().transform(utf8.decoder).transform(LineSplitter()).last;
  return exceptionLine.split(' ').first.trim();
}



///
///
///
String getIp(List<String> foldersNames){
  StringBuffer ip = StringBuffer();
  for(int x = 4; x > 0; x--){
    if(x == 1){
      ip.write(foldersNames[foldersNames.length - x]);
    } else {
      ip.write('${foldersNames[foldersNames.length - x]}.');
    }
    
  }
  return ip.toString();
}
