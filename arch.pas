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
    procedure WriteFile(Path: String);
  private
    Buf: array of Byte;
end;

  const NewFileName = 2;
  const FilePath = 3;

{ TMyApplication }

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;
begin
  ErrorMsg := CheckOptions('h a e c','help add extract create');
  if ErrorMsg <> '' then
  begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('c', 'create') then
  begin
    ReadFile(ParamStr(FilePath));
    Terminate;
    Exit;
  end;
  if HasOption('a', 'add') then
  begin
    ReadFile(ParamStr(FilePath));
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
       + '-c [New Archive Name] [Path to file] - create new archive' + LineEnding
       + '-a [Archive] [Path to file] - add to archive' + LineEnding
       + '-e [Archive] [Path to extract] - extract files' + LineEnding
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
  reset(fi, 1);
  SetLength(Buf, FileSize(fi));
  repeat
    BlockRead(fi, buf[i], SizeOf(buf), NumRead);
    Inc(i, SizeOf(buf));
  until (NumRead = 0);
  CloseFile(fi);
end;

procedure TMyApplication.WriteFile(Path: String);
var
  fo: File of Byte;
  i: int64 = 0;
begin
  AssignFile(fo, Path);
  Rewrite(fo, 1);
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
