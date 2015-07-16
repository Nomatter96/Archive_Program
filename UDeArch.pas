unit UDeArch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UArch;

type

  { TDeArch }

  TDeArch = class
  public
    procedure BuildTree(var t: Tree; Symbol: Symb; i: integer);
    function DeCompress(var InputArray: array of byte): ByteArray;
    procedure SortLength(var InputArray: array of Symb; l, r: integer);
    procedure ConvertToSymbol(InputArray: array of byte);
    function SearchLeaf(t: Tree; AByte: byte; i: integer): byte;
  private
    Symbols: array of Symb;
    t: Tree;
  end;

var
  DeArch: TDeArch;

implementation

procedure TDeArch.BuildTree(var t: Tree; Symbol: Symb; i: integer);
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

function TDeArch.DeCompress(var InputArray: array of byte): ByteArray;
var
  i: integer;
begin
  ConvertToSymbol(InputArray);
  SortLength(Symbols, 0, High(Symbols));
  Arch.MakeNewCodes(Symbols);
  for i := 0 to High(Symbols) do
    BuildTree(t, Symbols[i], 0);
  SetLength(Result, Length(InputArray) - 256);
  for i := 256 to High(InputArray) do
  begin
    Result[i - 256] := SearchLeaf(t, InputArray[i], 0);
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
    if (i <= j) then
    begin
      buf := Symbols[i];
      Symbols[i] := Symbols[j];
      Symbols[j] := buf;
      Inc(i);
      Dec(j);
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
  SetLength(Symbols, 256);
  for i := 0 to High(Symbols) do
  begin
    Symbols[i].h := InputArray[i];
    Symbols[i].Value := i;
  end;
end;

function TDeArch.SearchLeaf(t: Tree; AByte: byte; i: integer): byte;
begin
  if i > SizeOf(Byte) - 1 then
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
