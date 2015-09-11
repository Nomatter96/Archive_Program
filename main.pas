{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, crt, UArch, UDeArch;

type
  { TMyApplication }
  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure ReadFile(Path: String);
    procedure WriteArch(AName: String);
    procedure ReadArch(Path: String);
    procedure WriteFile(Path: String);
  private
    Buf: array of Byte;
    IncorrectFile: Boolean;
    Compress: Boolean;
    is_solid: Boolean;
  end;

{ TMyApplication }

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;

begin
  ErrorMsg := CheckOptions('c a e h','create add extract help');
  if ErrorMsg <> '' then
  begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;
  if HasOption('c', 'create') then
  begin
    ReadFile(ParamStr(4));
    if ParamStr(2) = 'comp' then
      Buf := Arch.Compress(Buf);
    WriteArch(ParamStr(3));
    Terminate;
    Exit;
  end;
  if HasOption('a', 'add') then
  begin
    ReadFile(ParamStr(3));
    Terminate;
    Exit;
  end;
  if HasOption('e', 'extract') then
  begin
    ReadArch(ParamStr(2));
    if IncorrectFile then
      exit;
    if Compress then
      Buf := DeArch.DeCompress(Buf);
    WriteFile(ParamStr(3));
    Terminate;
    Exit;
  end;
  if HasOption('h', 'help') then
  begin
    WriteHelp;
    Terminate;
    Exit;
  end;
  WriteHelp;
  Terminate;
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;
end;

destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TMyApplication.WriteHelp;
begin
  write('Welcome to program for archive and compress files' + LineEnding
       + 'Developers:' + LineEnding
       + '-Zhikhareva A.' + LineEnding
       + '-Lipov I.' + LineEnding
       + '-Trofimova O.' + LineEnding
       + LineEnding
       + 'Commands:' + LineEnding
       + '-c [arch\comp] [New Archive Name] [Path to file] - create new archive' + LineEnding
       + '-a [Path to archive] [Path to file] - add to archive' + LineEnding
       + '-e [Path to archive] [Path to extract] - extract files' + LineEnding
       + '-h - help');
end;

procedure TMyApplication.ReadFile(Path: String);
var
  fi: File;
  NumRead: Int64 = 0;
  i: int64 = 0;
begin
  AssignFile(fi, Path);
  Reset(fi, 1);
  SetLength(Buf, FileSize(fi));
  While i < Length(Buf) do
  begin
    BlockRead(fi, Buf[i], SizeOf(Buf), NumRead);
    Inc(i, SizeOf(Buf));
  end;
  CloseFile(fi);
end;

procedure TMyApplication.WriteArch(AName: String);
var
  fo: File of Char;
  NumWrite: byte = 0;
  i: Int64 = 0;
  count: Word = 1;
begin
  AssignFile(fo, AName + '.upa');
  Rewrite(fo, 1);
  write(fo, 'U', 'P', 'A');
  case ParamStr(2) of
    'comp':  Write(fo, 'H', 'U', 'F', 'F');
    'arch' :  Write(fo, 'N', 'O', 'P', 'E');
  end;
  While i < Length(Buf) do
  begin
    BlockWrite(fo, Buf[i], 1);
    inc(i, 1);
  end;
  CloseFile(fo);
end;

procedure TMyApplication.ReadArch(Path: String);
var
  fi: File of Char;
  sign: array[1..3] of Char;
  TypeCompress: array[1..4] of Char;
  i: Int64 = 0;
  NumRead: Int64;

begin
  AssignFile(fi, Path);
  Reset(fi, 1);
  BlockRead(fi, sign, 3);
  if (sign[1] <> 'U') or (sign[2] <> 'P') or (sign[3] <> 'A') then
  begin
    Write('Incorrect File');
    CloseFile(fi);
    exit;
  end;
  BlockRead(fi, TypeCompress, 4);
  if TypeCompress = 'HUFF' then
    Compress := True
  else
    Compress := False;
  SetLength(Buf, FileSize(fi) - 7);

  While i < Length(Buf) - 1 do
  begin
    BlockRead(fi, Buf[i], SizeOf(Buf), NumRead);
    inc(i, SizeOf(Buf));
  end;
  close(fi);
end;

procedure TMyApplication.WriteFile(Path: String);
var
  fo: File of Char;
  i: Int64 = 0;
  NumWrite: Int64 = 0;
begin
  AssignFile(fo, Path);
  Rewrite(fo);
  While i < Length(Buf) do
  begin
    BlockWrite(fo, Buf[i], 1);
    inc(i, 1);
  end;
  Close(fo);
end;

var
  Application: TMyApplication;
begin
  Application := TMyApplication.Create(nil);
  Application.Title := 'Archive Program';
  Application.Run;
  Application.Free;
end.
