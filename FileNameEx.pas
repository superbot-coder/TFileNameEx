unit FileNameEx;

interface

USES
   System.SysUtils, System.StrUtils, System.IOUtils;

type
   TFileNameEx = Record
   private
     class var
     FFilePath: String;
     FFileName: String;
     FFileExt: String;
     class function GetFileName: string; static;
     class procedure SetFileExt(Value: string); static;
     class function DeleteInvalidCharsInFileName(const ValueStr: String): string; inline; static;
     class function GetFilePath: string; static;
     class procedure SetFilePath(const Value: string); static;
     class function GetFileExt: string; static;
     class procedure SetFileName(const Value: string); static;
     class function IsValidCharsInPathInternal(const FilePath: String): Boolean; static;
   public
     constructor Create(const FilePath, FileName: String); overload;
     constructor Create(const FileName: String); overload;
     class property FileName: string read GetFileName write SetFileName;
     class property FilePath: string read GetFilePath write SetFilePath;
     class property Extention: string read GetFileExt write SetFileExt;
     class function GetFileNameIncriment: string; static;
     class function DeleteInvalidCharsInPath(const Value: String): string; inline; static;
   End;

   THelperForFileNameEx = record helper for TFileNameEx
     function GetFileNameIncriment: String;
     function IsValidCharsInPath(const FilePath: String; Accept: Boolean): Boolean;
   end;


implementation

{ TFileNameRec }

constructor TFileNameEx.Create(const FileName: String);
var
  LFilePath, LFileName: string;
begin
  LFilePath := ExtractFilePath(FileName);
  LFileName := ExtractFileName(FileName);
  FFilePath := IfThen(Not LFilePath.IsEmpty, LFilePath);
  FFileName := IfThen(LFilePath.IsEmpty, TPath.GetRandomFileName);
end;

constructor TFileNameEx.Create(const FilePath, FileName: String);
Var
  FilePathNotEmty: Boolean;
  LFilePath: string;
begin
  FFilePath := '';
  FFileName := '';

  FFilePath  := FilePath;

  if Not FileName.isEmpty then
  begin
    FFileName := ExtractFileName(FileName);
    LFilePath  := ExtractFileDir(FileName);

    if FilePath.IsEmpty and (Not LFilePath.IsEmpty) then
      FFilePath := LFilePath;
  end
  else
    FFileName := TPath.GetRandomFileName;

end;

class function TFileNameEx.DeleteInvalidCharsInFileName(const ValueStr: String): string;
begin
  for var CharElement in ValueStr do
    Result := Result + ifthen(TPath.IsValidFileNameChar(CharElement), CharElement);
end;

class function TFileNameEx.DeleteInvalidCharsInPath(
  const Value: String): string;
begin
  for var CharElement in Value do
    Result := Result + IfThen(TPath.IsValidPathChar(CharElement), CharElement);
end;

class function TFileNameEx.GetFilePath: string;
begin
  Result := FFilePath;
end;

class function TFileNameEx.IsValidCharsInPathInternal(const FilePath: String): Boolean;
begin
  Result := true;
  for var CharElement in FilePath do
    if Not TPath.IsValidPathChar(CharElement) then
    begin
      Result := false;
      Exit;
    end;
end;

class function TFileNameEx.GetFileExt: string;
begin
  Result := ifthen(FFileExt.IsEmpty, ExtractFileExt(FFileName), FFileExt);
end;

class function TFileNameEx.GetFileName: string;
var
  FileName: string;
begin
  Result := IfThen(FFileExt.IsEmpty, FFileName, ChangeFileExt(FFileName, FFileExt));
  Result := IfThen(FFilePath.IsEmpty, FFileName, ChangeFilePath(FFileName, FFilePath));
end;

class function TFileNameEx.GetFileNameIncriment: string;
var
  Counter: Cardinal;
  LFileExt: String;
begin

  Result := GetFileName;
  LFileExt := ExtractFileExt(Result);

  While FileExists(Result) do
  begin
    Result := ChangeFileExt(Result, '(' + Counter.ToString + ')' + LFileExt);
    inc(Counter);
  end;

end;

class procedure TFileNameEx.SetFileExt(Value: string);
var
  LFileExt: string;
begin
  if Value.IsEmpty then
  begin
    FFileExt := Value;
    Exit;
  end;
  LFileExt := ExtractFilePath(Value);
  LFileExt := DeleteInvalidCharsInFileName(LFileExt);
  FFileExt := ifthen(LFileExt.StartsWith('.'), LFileExt, '.' + LFileExt);
end;

class procedure TFileNameEx.SetFilePath(const Value: string);
begin
 // if Not IsValidCharsInPath(Value) then
 //   raise Exception.Create('Is Invalid Chars In Path');
 if IsValidCharsInPathInternal(Value) then;
   FFilePath := Value;
end;

class procedure TFileNameEx.SetFileName(const Value: string);
begin
  FFileName := ifthen(Not Value.IsEmpty,  DeleteInvalidCharsInFileName(Value), TPath.GetRandomFileName);
end;

{ THelperForFileNameEx }

function THelperForFileNameEx.GetFileNameIncriment: String;
var
  Counter: Cardinal;
  LFileExt: String;
begin
  Result := Self.GetFileName;
  LFileExt := ExtractFileExt(Result);

  While FileExists(Result) do
  begin
    Result := ChangeFileExt(Result, '(' + Counter.ToString + ')' + LFileExt);
    inc(Counter);
  end;
end;

function THelperForFileNameEx.IsValidCharsInPath(const FilePath: String; Accept: Boolean): Boolean;
var
  IsValid: boolean;
begin
  Result := Self.IsValidCharsInPathInternal(FilePath);
  if Result and Accept then
    Self.FFilePath := FilePath;
end;

end.
