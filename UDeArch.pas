unit UDeArch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UArch;

type

  TreeF = ^TTree;

  { TDeArch }

  TDeArch = class
  public
    procedure BuildTree(var t: TreeF; Symbol: Symb; i: integer);
    function DeCompress(var InputArray: array of byte): ByteArray;
    procedure SortLength(var InputArray: array of Symb; l, r: integer);
    procedure ConvertToSymbol(InputArray: array of byte);
    function SearchLeaf(t: TreeF; AByte: byte; i: integer): byte;
    procedure SortBySym(l, r: longint);
  private
    Symbols: array of Symb;
    t: TreeF;
  end;

var
  DeArch: TDeArch;

implementation

procedure TDeArch.BuildTree(var t: TreeF; Symbol: Symb; i: integer);
begin
  if t = nil then
  begin
    New(t);
    t^.left := nil;
    t^.right := nil;
  end;
  if (i = Length(Symbol.code) + 1) then
  begin
    t^.Value := Symbol.Value;
    t^.node := True;
  end
  else
  begin
    if Symbol.code[i] = '0' then
      BuildTree(t^.left, Symbol, i + 1)
    else
      BuildTree(t^.right, Symbol, i + 1);
  end;
end;

procedure TDeArch.SortBySym(l, r: longint);
var
  j, i, mid: longint;
  buf: Symb;
begin
  i := l;
  j := r;
  mid := symbols[(i + j) div 2].Value;
  repeat
    while symbols[i].Value < mid do
      Inc(i);
    while symbols[j].Value> mid do
      Dec(j);
    if i <= j then
    begin
      buf := symbols[i];
      symbols[i] := symbols[j];
      symbols[j] := buf;
      Inc(i);
      Dec(j);
    end;
  until i > j;
  if i < r then
    SortBySym(i, r);
  if j > l then
    SortBySym(l, j);
end;

function TDeArch.DeCompress(var InputArray: array of byte): ByteArray;
var
  i, j, f, l, k: Int64;
  tr: TreeF;
begin
  ConvertToSymbol(InputArray);
  SortLength(Symbols, 0, High(Symbols));
  f:=0;
  l:=0;

  for i:=1 to high(Symbols) do  begin
     if Symbols[i].h = Symbols[i-1].h then
       l:=i else
       if l <> f then begin
         SortBySym(f, l);
         l:=i;
         f:=i;
       end;
  end;
  if l <> f then
    SortBySym(f, l);

  Arch.MakeNewCodes(Symbols);

  for i := 0 to High(Symbols) do
    BuildTree(t, Symbols[i], 1);

  i := 255;

  tr := t;
  For i := 256 to high(InputArray) do
  begin
    for j := 0 to 7 do
      begin
        if (InputArray[i] and (1 shl j)) <> 0 then
          tr := tr^.right
        else
          tr := tr^.left;
        if (tr^.right = nil) and (tr^.left = nil) then
        begin
          SetLength(Result, Length(Result) +  1);
          Result[high(Result)] := tr^.Value;
          tr := t;
        end;
      end;
  end;
end;

procedure TDeArch.SortLength(var InputArray: array of Symb; l, r: integer);
var
  i, j, mid: integer;
  buf: symb;
begin
  i := l;
  j := r;
  mid := Symbols[(i + j) div 2].h;
  repeat
    while Symbols[i].h < mid do
      Inc(i);
    while Symbols[j].h > mid do
      Dec(j);
    if (i < j) then
    begin
      buf := Symbols[i];
      Symbols[i] := Symbols[j];
      Symbols[j] := buf;
      Inc(i);
      Dec(j);
    end
    else
      if (i = j) and (Symbols[i].h < Symbols[j].h) then
      begin
        buf := Symbols[i];
        Symbols[i] := Symbols[j];
        Symbols[j] := buf;
        Inc(i);
        Dec(j);
      end
      else
      begin
        if i = j then
        begin
          Inc(i);
          Dec(j);
        end;
      end;
  until i > j;
  if i < r then
    SortLength(InputArray, i, r);
  if j > l then
    SortLength(InputArray, l, j);
end;

procedure TDeArch.ConvertToSymbol(InputArray: array of byte);
var
  i: integer;
begin
  for i := 0 to 255 do
  begin
    if InputArray[i] <> 0 then
    begin
      SetLength(Symbols, Length(Symbols) + 1);
      Symbols[High(Symbols)].h := InputArray[i];
      Symbols[High(Symbols)].Value := i;
    end;
  end;
end;

function TDeArch.SearchLeaf(t: TreeF; AByte: byte; i: integer): Byte;
begin
  if t^.node then
  begin
    Result := t^.Value;
    exit;
  end;
  if (AByte and (1 shl i)) <> 0 then
    Result := SearchLeaf(t^.left, AByte, i + 1)
  else
    Result := SearchLeaf(t^.right, AByte, i + 1);
end;

initialization

  DeArch := TDeArch.Create();
end.
