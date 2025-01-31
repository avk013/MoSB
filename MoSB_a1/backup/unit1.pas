unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  FileUtil, ShellApi, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    step2: TButton;
    step1: TButton;
    Label1: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure step1Click(Sender: TObject);
    procedure step2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  path_temp,path_unrar:string;
implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.FormCreate(Sender: TObject);
begin // впоследствии возьмем из настроек
//path_temp:='l:\temp_ship'; Каталог для работы
path_temp:=GetEnvironmentVariable('TEMP');
//GetCurrentDir
//path_unrar:='Y:\!monitoring\unpacker1\7z.exe x ';
path_unrar:=GetCurrentDir+'\7z.exe x ';
if not FileExists(GetCurrentDir+'\7z.exe') then
begin
step1.Enabled:=false; step2.Enabled:=false;
ShowMessage('В папке с программой "'+GetCurrentDir +'" должен размещаться файл 7z.exe!!!');
end;
end;

procedure TForm1.step1Click(Sender: TObject);
var
   dir1:string;
   arh1:TStringList;
   file_exct:string;
   i:integer;
begin  //получаем местоположение архива с судна
  //    dir1
  if SelectDirectoryDialog1.Execute then
      //Listbox1.Items.Assign(SelectDirectoryDialog1.Files);
     dir1:=SelectDirectoryDialog1.FileName;
     Label1.Caption:=dir1;
  //проверяем только папку без подпапок ()
  // протом продумаем каждому судну свою папку
  arh1:=FindAllFiles(dir1,'*.rar',false);
  try
    ShowMessage(Format('Found %d files',[arh1.Count]));
    for i:=0 to arh1.Count-1 //распаковываем каждый архив в Общую папку
  do
  begin
    Try
     // file_ar:=arh1[i];
   file_exct:=path_unrar+arh1[i]+' -o"'+path_temp+'" -y';  ExecuteProcess(file_exct, '');
    Except
      On E: EOSError Do
        WriteLn('ошибка с номером ', E.ErrorCode);
    End;
  // ok ....
end;   finally
    arh1.Free;
   end;
end;

procedure TForm1.step2Click(Sender: TObject);
var arh2, file_s:TStringList;
  i, i2, i3 , i4:integer;
  path_temp2, path_temp3, path_temp4, path_out:string;
  tfOut,tfIn:textfile;
 // temi2:string;
  file_exct:string;
  str_name_file, body_file:string;
//  cmd,fil,dir:string;
 arr_name_file:TStringArray;
 F: TfileStream;
begin
str_name_file:='acc.data,adam.data,boiler.data,gps.data,gpsriver.data,t.data';
arr_name_file:=str_name_file.Split(',');//получаем массив нужных файлов
path_temp2:=path_temp+'\shipBox\sent';
path_temp3:=path_temp+'\all';
path_temp4:=path_temp+'\all\shipBox\temp';
path_out:=path_temp+'\out\';
//temi2:='';
CreateDir(path_temp2);
CreateDir(path_temp3);
CreateDir(path_out);//узнаем все имена отосланных данных
//создаем пустые файлы для результатов
for i:=0 to Length(arr_name_file)-1
do begin
 if not FileExists(path_out+arr_name_file[i]) then
 begin
 //  ShowMessage('Нет файла с таким названием! Создаем!!!!');
   F:= TFileStream.Create(path_out+arr_name_file[i],fmCreate);
   F.Free;
end;
end;
Sleep(225);
//
arh2:=FindAllFiles(path_temp2,'*.rar',false);
for i2:=0 to arh2.Count-1 // перебираем все архивы
do begin //ShowMessage(arh2[i2]);
//распаковsваем каждый и объединяем
file_exct:=path_unrar+arh2[i2]+' -o"'+path_temp3+'" -y';
// !!! Очень плохо нужно использовать другое
ExecuteProcess(file_exct, '');
//
//if ShellExecute(0,nil, PChar(file_exct),PChar(''),nil,1)=0 then;
Sleep(225);
//а теперь смотрим что у нас там....
file_s:=FindAllFiles(path_temp4,'*',false);
//получили список распакованных файлов
for i3:=0 to file_s.Count-1
do begin
//Каждый расп.файл сравниваем со списком того что нам нужно
for i4:=0 to Length(arr_name_file)-1
do // arr_name_file список того что нужно брать
begin //если находим искомый файл - объединаем его в общий
if (file_s[i3].IndexOf(arr_name_file[i4])>=0) then
begin //copy 1.data+2.data /b 1.data
//file_exct:='cmd.exe /K ';
//ExecuteProcess(file_exct, 'copy '+path_out+arr_name_file[i4]+'+'+file_s[i3]+' /b '+path_out+arr_name_file[i4]);
//if ShellExecute(0,nil, PChar('cmd'),PChar(' /k copy '+path_out+arr_name_file[i4]+'+'+file_s[i3]+' /b '+path_out+arr_name_file[i4]),nil,1) =0 then;
//Sleep(100);// Вынужденно, что-то работает не так
//if ShellExecute(0,nil, PChar('cmd'),PChar(' /c copy '+path_out+arr_name_file[i4]+'+'+file_s[i3]+' /b '+path_out+arr_name_file[i4]),nil,0)=0 then;
//ShowMessage(path_out+arr_name_file[i4]+'+'+file_s[i3]+' /b '+path_out+arr_name_file[i4]);
//переписіваем добавление
AssignFile(tfIn, file_s[i3]);
reset(tfIn);
AssignFile(tfOut, path_out+arr_name_file[i4]);
 try
   // Open for append, write and close.
   append(tfOut);
//   writeln(tfOut, 'New data for text file');
//   writeln(tfOut, 'New informtion should be at the end of the file.');
while not eof(tfIn) do begin
readln(tfIn,body_file);
writeln(tfOut,body_file);
end;
   CloseFile(tfIn);
   CloseFile(tfOut);
 except
   on E: EInOutError do
    writeln('File error. Elaboration: ', E.Message);
 end;


//ExecuteProcess(file_exct, 'dir');
break; // выходим из for так как нашли то что надо
end
//ShowMessage(IntToStr(file_s[i3].IndexOf(arr_name_file[i4]))+file_s[i3]);
end;
end;
DeleteDirectory(path_temp3, True);
//temi2:=temi2+arh2[i2];
end; // переходим к следующему архиву
//ShowMessage(arh2[i2]);
//temi2:=temi2+arh2[i2];

//ShowMessage(arh1[i])
//распаковіваем по отдельности и добавляем в "общ файл"
//end;
arh2.Free;
//cmd := PChar('open');fil := PChar('explorer.exe');dir := PChar(' ');
//if ShellExecute(Self.Handle, cmd, fil, PChar(path_out), nil, 1)=0 then;
//if ShellExecute(0,nil, PChar('cmd'),PChar('/c copy '+path_out+arr_name_file[i4]+'+'+file_s[i3]+' /b '+path_out+arr_name_file[i4]),nil,0)=0 then;
ShellExecute(handle,'explore',PChar(path_out),nil,nil,1);
//  ShowMessage(temi2)
  end;

end.

