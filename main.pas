{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, crt
  { you can add units after this };

type
  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure ConvertPath;
    procedure ReadFile;
    procedure CompressFile;
  private
    path: string;

  fi: File;

  m: array of byte;
  end;

{ TMyApplication }

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg := CheckOptions('h','help');
  if ErrorMsg <> '' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }

  // stop program loop
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
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

procedure TMyApplication.ConvertPath;
begin
  write('Welcome to the program for archive and compress files' + LineEnding
                 + 'Developers:' + LineEnding + '-Zhikhareva A.' + LineEnding
                 + '-Lipov I.' + LineEnding + '-Trofimova O.' + LineEnding
                 + 'Enter path to the file: ');
  readln(path);
end;

procedure TMyApplication.ReadFile;
var
  i: integer = 0;
  NumRead, NumWrite: Word;
begin
  write('That is your bytes, congratulations! ');
  repeat
    SetLength(m, Length(m) + 1);
    BlockRead(fi, m[i], NumRead, NumWrite);
    write( m[i], ' ');
    inc(i);
  until (NumRead = 0) or (NumWrite <> NumRead);
end;

procedure TMyApplication.CompressFile;
begin

end;

var
  Application: TMyApplication;
  s: string;
begin
  Application := TMyApplication.Create(nil);
  Application.Title := 'My Application';
  Application.Run;
  Application.Free;

  Application.ConvertPath;
  try
    Assign(Application.fi, Application.path);
    reset(Application.fi, 1); //считаваем по одному байту
  except
    On EInOutError do
    begin
      writeln('Wrong path, try again');
      readln;
    end;
  end;

  Application.ReadFile;
  Application.CompressFile;
  readln;
  close(input);
end.
