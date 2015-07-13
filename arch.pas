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
    procedure ReadFile;
  private
    fname: string;
    fi: File;
    arr: array of byte;
  end;

{ TMyApplication }

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;
begin
  ErrorMsg := CheckOptions('h a e','help add extract');
  if ErrorMsg <> '' then
  begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('h', 'help') then
  begin
    WriteHelp;
    Terminate;
    Exit;
  end;
  if HasOption('a', 'add') then
  begin
    read(fname);

    Write('created new arch ', fname);
    Terminate;
    Exit;
  end;
  if HasOption('e', 'extract') then
  begin
    Write('extract data');
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
       + '-a - create archive (Press Enter and put name of archive)' + LineEnding
       + '-e - extract files (Press Enter and put path for extracting)' + LineEnding
       + '-h - help');
end;

procedure TMyApplication.ReadFile;
var
  NumRead, NumWrite: Word;
  i: integer = 0;
begin
  repeat
    SetLength(arr, Length(arr) + 1);
    BlockRead(fi, arr[i], NumRead, NumWrite);
    write( arr[i], ' ');
    inc(i);
  until (NumRead = 0) or (NumWrite <> NumRead);
end;

var
  Application: TMyApplication;

begin
  Application := TMyApplication.Create(nil);
  Application.Title := 'My Application';
  Application.DoRun;
  Application.Free;
end.
