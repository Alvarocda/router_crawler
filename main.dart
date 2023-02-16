import 'dart:io';

void main() async {
  print('hello World');
  
  String results = await getInfo(directory: Directory('./results'), stringBuffer: StringBuffer());
  results.replaceAll('-', '\n');
  print(results);
}

Future<String> getInfo({required Directory directory, required StringBuffer stringBuffer}) async {
  final List<FileSystemEntity> folders = await directory.list().toList();

  if(folders.whereType<Directory>().isEmpty){
    List<String> folderNames = directory.path.split('/');
    return getIp(folderNames);
  }

  for (int x = 0; x < folders.whereType<Directory>().toList().length; x++) {
      Directory nextDir = Directory(folders[x].path);
      await getInfo(directory: nextDir, stringBuffer: stringBuffer);
  }
  
  print(stringBuffer.toString());

  return stringBuffer.toString();
}


String getIp(List<String> foldersName){
  StringBuffer ip = StringBuffer();
  for(int x = 4; x > 0; x--){
    if(x == 1){
      ip.writeln(foldersName[foldersName.length - x]);
    } else {
      ip.write('${foldersName[foldersName.length - x]}.');
    }
    
  }
  print(ip.toString());
  return ip.toString();
}
