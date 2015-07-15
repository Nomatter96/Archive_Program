{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, crt, UCompress;

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
    procedure WriteFile(AName: String);
  private
    Buf: array of Byte;
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
    ReadFile(ParamStr(3));
    if ParamStr(2) = 'Compress' then
      Buf := Compress.Compress(Buf);
    WriteFile(ParamStr(2));
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
    Write('data extracted to ... ');
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
       + '-c [Archive\Compress] [New Archive Name] [Path to file] - create new archive' + LineEnding
       + '-a [Path to archive] [Path to file] - add to archive' + LineEnding
       + '-e [Path to archive] [Path to extract] - extract files' + LineEnding
       + '-h - help');
end;

procedure TMyApplication.ReadFile(Path: String);
var
  fi: File;
  b: Byte;
  NumRead: Int64;
  i: int64 = 0;
begin
  AssignFile(fi, Path);
  Reset(fi, 1);
  SetLength(Buf, FileSize(fi));
  repeat
    BlockRead(fi, Buf[i], SizeOf(Buf), NumRead);
    Inc(i, SizeOf(Buf));
  until (NumRead = 0);
  CloseFile(fi);
end;

procedure TMyApplication.WriteFile(AName: String);
var
  fo: File of Char;
  count: Integer = 1;
  is_solid: Boolean;
  i: Int64 = 0;
begin
  AssignFile(fo, AName + '.upa');
  Rewrite(fo, 1);
  write(fo, 'U', 'P', 'A');
  case ParamStr(2) of
    'Compress':  Write(fo, 'HUFF');
    'Archive' :  Write(fo, 'NOPE');
  end;
  is_solid := false;
  Write(fo, is_solid);
  Write(fo, count);
  While i <= Length(Buf) do
  begin
    BlockWrite(fo, Buf[i], SizeOf(Buf));
    inc(i, SizeOf(Buf));
  end;
  CloseFile(fo);
end;

var
  Application: TMyApplication;

begin
  Application := TMyApplication.Create(nil);
  Application.Title := 'Archive Program';
  Application.Run;
  Application.Free;
end.
