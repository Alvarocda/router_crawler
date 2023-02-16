import 'dart:io';

void main() async {
  print('hello World');
  
  String results = await getInfo(directory: Directory('./results'));
  print(results);
}

///
///
///
Future<String> getInfo({required Directory directory}) async {
  final List<FileSystemEntity> folders = await directory.list().toList();
  StringBuffer stringBuffer = StringBuffer();

  if(folders.whereType<Directory>().isEmpty){
    List<String> foldersNames = directory.path.split('/');
    return getIp(foldersNames);
  }
  for (int x = 0; x < folders.whereType<Directory>().toList().length; x++) {
      Directory nextDir = Directory(folders[x].path);
      stringBuffer.write(await getInfo(directory: nextDir));
  }
  return stringBuffer.toString();
}

///
///
///
String getIp(List<String> foldersNames){
  StringBuffer ip = StringBuffer();
  for(int x = 4; x > 0; x--){
    if(x == 1){
      ip.writeln(foldersNames[foldersNames.length - x]);
    } else {
      ip.write('${foldersNames[foldersNames.length - x]}.');
    }
    
  }
  return ip.toString();
}
