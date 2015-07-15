unit UArch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  Tree = ^TTree;

  ByteArray = array of byte;

  TTree = record
    Value: byte;
    f: integer;
    left, right: Tree;
    node: boolean;
  end;

  Symb = record
    Value: byte;
    h: integer;
    code: string;
  end;

  TArch = class
  public
    procedure sort(l, r: longint);
    procedure sortArray(l, r: longint);
    procedure getFrequency(Arr: array of byte);
    function buildtree(i, j: integer): tree;
    procedure GetSymb(tr: tree; l: integer);
    function findsym(a: byte; Arr: array of symb): byte;
    procedure MakeNewCodes(var Arr: array of symb);
    function Compress(var InputArray: array of byte): ByteArray;
    procedure SortBySym(l, r: longint);
  end;

var
  Arch: TArch;
  k, m: integer;
  tr: Tree;
  symbol: array of Symb;
  FreqTable: array of byte;
  Count: array of integer;
  s: string;
  ex: array of byte;

implementation

procedure TArch.sort(l, r: longint);
var
  j, i, mid, samp: longint;
  buf: byte;
begin
  i := l;
  j := r;
  mid := Count[(i + j) div 2];
  repeat
    while Count[i] < mid do
      Inc(i);
    while Count[j] > mid do
      Dec(j);
    if i <= j then
    begin
      buf := FreqTable[i];
      FreqTable[i] := FreqTable[j];
      FreqTable[j] := buf;
      samp := Count[i];
      Count[i] := Count[j];
      Count[j] := samp;
      Inc(i);
      Dec(j);
    end;
  until i > j;
  if i < r then
    sort(i, r);
  if j > l then
    sort(l, j);
end;

procedure TArch.sortArray(l, r: longint);
var
  j, i, mid: longint;
  buf: Symb;
begin
  i := l;
  j := r;
  mid := symbol[(i + j) div 2].h;
  repeat
    while symbol[i].h < mid do
      Inc(i);
    while symbol[j].h > mid do
      Dec(j);
    if i <= j then
    begin
      buf := symbol[i];
      symbol[i] := symbol[j];
      symbol[j] := buf;
      Inc(i);
      Dec(j);
    end;
  until i > j;
  if i < r then
    sortArray(i, r);
  if j > l then
    sortArray(l, j);
end;

procedure TArch.SortBySym(l, r: longint);
var
  j, i, mid: longint;
  buf: Symb;
begin
  i := l;
  j := r;
  mid := symbol[(i + j) div 2].value;
  repeat
    while symbol[i].value < mid do
      Inc(i);
    while symbol[j].value > mid do
      Dec(j);
    if i <= j then
    begin
      buf := symbol[i];
      symbol[i] := symbol[j];
      symbol[j] := buf;
      Inc(i);
      Dec(j);
    end;
  until i > j;
  if i < r then
    SortBySym(i, r);
  if j > l then
    SortBySym(l, j);
end;

procedure TArch.getFrequency(Arr: array of byte);
var
  a: byte;
  i: integer;
begin
  Setlength(FreqTable, 256);
  Setlength(Count, 256);
  for a:= 0 to high(FreqTable) do
    FreqTable[a]:= a;
  for k := 0 to high(Arr) do
  begin
    a := Arr[k];
    for i := 0 to High(FreqTable) do
      if a = FreqTable[i] then
      begin
        Inc(Count[i]);
        break;
      end;
  end;
  Sort(0, High(FreqTable));
end;

function TArch.buildtree(i, j: integer): tree;
var
  l, r: tree;
  node: array of Tree;

  function FindNode(): tree;
  begin
    if (length(node) <= j) or ((i < Length(FreqTable)) and
      (Count[i] <= node[j]^.f)) then
    begin
      Result := new(Tree);
      Result^.Value := FreqTable[i];
      Result^.f := Count[i];
      Result^.node := False;
      Inc(i);
    end
    else
    begin
      Result := node[j];
      if j < (length(node)) then
        Inc(j);
    end;
  end;


  function MakeNode(a, b: tree): tree;
  begin
    SetLength(node, Length(node) + 1);
    New(tr);
    tr^.right := a;
    tr^.left := b;
    tr^.f := a^.f + b^.f;
    tr^.Value := -1;
    tr^.node := True;
    node[High(node)] := tr;
    Result := tr;
  end;

begin
  repeat
    l := FindNode;
    r := FindNode;
    Result := MakeNode(l, r);
  until (i > Length(FreqTable) - 1) and (j >= Length(node) - 1);
end;

procedure TArch.GetSymb(tr: tree; l: integer);
begin
  if not tr^.node then
  begin
    SetLength(symbol, Length(symbol) + 1);
    symbol[high(symbol)].Value := tr^.Value;
    symbol[high(symbol)].h := l;
  end
  else
  begin
    if tr^.left <> nil then
      GetSymb(tr^.left, l + 1);
    if tr^.right <> nil then
      GetSymb(tr^.right, l + 1);
  end;
end;

function TArch.findsym(a: byte; Arr: array of symb): byte;
var
  i: integer;
begin
  for i := 0 to high(Arr) do
    if Arr[i].Value = a then
    begin
      Result := i;
      exit;
    end;
end;

procedure TArch.MakeNewCodes(var Arr: array of symb);
var
  i, j: integer;
  function Increase(s: string): string;
    var
      t: integer;
    begin
      for t := length(s) downto 1 do
        if s[t] = '0' then
        begin
          s[t] := '1';
          Result := s;
          exit;
        end
        else
          s[t] := '0';
    end;
begin
  SortArray(0, High(Arr));
  for i := 1 to Arr[0].h do
    Arr[0].code := Arr[0].code + '0';
  for i := 1 to high(Arr) do
    if Arr[i].h = Arr[i - 1].h then
      Arr[i].code := Increase(Arr[i - 1].code)
    else begin
      Arr[i].code := Increase(Arr[i - 1].code);
      for j:= 1 to (Arr[i].h - Arr[i - 1].h) do
         Arr[i].code := Arr[i].code + '0';
    end;
end;

function TArch.Compress(var InputArray: array of byte): ByteArray;
var
  curcode: string;
  i, j, pos, index: integer;
begin
  if length(InputArray) = 0 then exit;
  getFrequency(InputArray);
  GetSymb(buildtree(0, 0), 0);
  MakeNewCodes(Symbol);

  Setlength(Result, length(Result) + 257);
  SortBySym(0, high(Symbol));
  for i:= 0 to 255 do
    result[i]:=length(symbol[i].code);
  index := 256;
  pos := 7;
  for i := 0 to high(InputArray) do
  begin
    k := findsym(InputArray[i], Symbol);
    curcode := symbol[k].code;
    for j := 1 to length(curcode) do
    begin
      if pos = 0 then begin
        pos := 7;
        Inc(index);
        Setlength(Result, length(Result) + 1);
      end;
      if curcode[j] = '1' then
        Result[index] := Result[index] or (1 shl pos);
      dec(pos);
    end;
  end;
end;

initialization

  Arch := TArch.Create();
end.
