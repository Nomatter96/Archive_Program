unit UDeArch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UArch;

type

  { TDeArch }

  TDeArch = class
  public
    procedure BuildTree(var t: Tree; Symbol: Symb; i: Integer);
    function DeCompress(var InputArray: array of Byte): ByteArray;
    procedure SortLength(var InputArray: array of Symb; l, r: Integer);
    procedure ConvertToSymbol(InputArray: array of Byte);
    function SearchLeaf(t: Tree ;AByte: Byte; i: Integer): Byte;
  private
    Symbols: array of Symb;
    t: Tree;
  end;

var
  DeArch: TDeArch;

implementation

procedure TDeArch.BuildTree(var t: Tree; Symbol: Symb; i: Integer);
begin
  if t = nil then
    New(t);
  if i = Length(Symbol.code) - 1 then
  begin
    t^.Value := Symbol.Value;
  end
  else
  begin
    if Symbol.code[i] = '0' then
      BuildTree(t^.left, Symbol, i + 1)
    else
      BuildTree(t^.right, Symbol, i + 1);
  end;
end;

function TDeArch.DeCompress(var InputArray: array of Byte): ByteArray;
var
  i: Integer;
begin
  ConvertToSymbol(InputArray);
  SortLength(Symbols,0, High(Symbols));
  Compress.MakeNewCodes(Symbols);
  for i := 0 to High(Symbols) do
    BuildTree(t, Symbols[i], 0);
  SetLength(result, Length(InputArray) - 256);
  for i := 256 to High(InputArray) do
  begin
    result[i - 256] := SearchLeaf(t, InputArray[i], 0);
  end;
end;

procedure TDeArch.SortLength(var InputArray: array of Symb; l, r: Integer);
var
  i, j, mid: Integer;
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
    if (i < j) or ((i = j) and (Symbols[i].Value < Symbols[j].Value)) then
    begin
      buf := Symbols[i];
      Symbols[i] := Symbols[j];
      Symbols[j] := buf;
      Inc(i);
      Dec(j);
    end;
  until i > j;
  if i < r then
    SortLength(InputArray,i, r);
  if j > l then
    SortLength(InputArray,l, j);
end;

procedure TDeArch.ConvertToSymbol(InputArray: array of Byte);
var
  i: Integer;
begin
  SetLength(Symbols, 256);
  for i := 0 to High(Symbols) do
  begin
    Symbols[i].h := InputArray[i];
    Symbols[i].Value := i;
  end;
end;

function TDeArch.SearchLeaf(t: Tree; AByte: Byte; i: Integer): Byte;
begin
  if i > SizeOf(Byte) - 1 then
  begin
    result := t^.Value;
    exit;
  end;
  if (AByte and (1 shl i)) <> 0 then
    result := SearchLeaf(t^.left, AByte, i + 1)
  else
    result := SearchLeaf(t^.right, AByte, i + 1);
end;

end.
