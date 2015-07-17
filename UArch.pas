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
    function findsym(a: byte; Arr: array of symb): string;
    procedure MakeNewCodes(var Arr: array of symb);
    function Compress(var InputArray: array of byte): ByteArray;
    procedure SortBySym(l, r: longint);
    procedure SortByFreqSym(l, r: longint);
  end;

var
  Arch: TArch;
  k, m: integer;
  tr: Tree;
  symbol, Alph: array of Symb;
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
  mid := symbol[(i + j) div 2].Value;
  repeat
    while symbol[i].Value < mid do
      Inc(i);
    while symbol[j].Value> mid do
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

procedure TArch.SortByFreqSym(l, r: longint);
var
  j, i, mid: longint;
  buf: byte;
begin
  i := l;
  j := r;
  mid := FreqTable[(i + j) div 2];
  repeat
    while FreqTable[i] < mid do
      Inc(i);
    while FreqTable[j]> mid do
      Dec(j);
    if i <= j then
    begin
      buf := FreqTable[i];
      FreqTable[i] := FreqTable[j];
      FreqTable[j] := buf;
      Inc(i);
      Dec(j);
    end;
  until i > j;
  if i < r then
    SortByFreqSym(i, r);
  if j > l then
    SortByFreqSym(l, j);
end;

procedure TArch.getFrequency(Arr: array of byte);
var
  a: byte;
  i: integer;
  found: boolean;
  l, f: integer;
begin
  for k := 0 to high(Arr) do
  begin
    a := Arr[k];
    found:=false;
    for i := 0 to High(FreqTable) do
      if a = FreqTable[i] then
      begin
        Inc(Count[i]);
        found:=true;
        break;
      end;
    if not found then begin
      Setlength(FreqTable, length(FreqTable) + 1);
      Setlength(Count, length(Count) + 1);
      FreqTable[High(Freqtable)]:=a;
      Inc(Count[high(Count)]);
    end;
  end;
  l:=0;
  f:=0;
  Sort(0, High(FreqTable));
  for i:=1 to high(FreqTable) do  begin
     if Count[i] = Count[i-1] then
       l:=i else
       if l <> f then begin
         SortByFreqSym(f, l);
         l:=i;
         f:=i;
       end;
  end;
  if l <> f then
    SortByFreqSym(f, l);
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

function TArch.findsym(a: byte; Arr: array of symb): string;
var
  i: integer;
begin
  for i := 0 to high(Arr) do
    if Arr[i].Value = a then
    begin
      Result := Arr[i].code;
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
  for i := 1 to Arr[0].h do
    Arr[0].code := Arr[0].code + '0';
  for i := 1 to high(Arr) do
    if Arr[i].h = Arr[i - 1].h then
      Arr[i].code := Increase(Arr[i - 1].code)
    else
    begin
      Arr[i].code := Increase(Arr[i - 1].code);
      for j := 1 to (Arr[i].h - Arr[i - 1].h) do
        Arr[i].code := Arr[i].code + '0';
    end;
end;

function TArch.Compress(var InputArray: array of byte): ByteArray;
var
  curcode: string;
  i, j, pos, l, f, k, index: integer;
  NilSym: symb;
begin
  if length(InputArray) = 0 then
    exit;
  getFrequency(InputArray);
  GetSymb(buildtree(0, 0), 0);
  SortArray(0, High(Symbol));
  f:=0;
  l:=0;
  for i:=1 to high(Symbol) do  begin
     if Symbol[i].h = Symbol[i-1].h then
       l:=i else
       if l <> f then begin
         SortBySym(f, l);
         l:=i;
         f:=i;
       end;
  end;
  if l <> f then
    SortBySym(f, l);
  MakeNewCodes(Symbol);
  Setlength(Result, 257);
  NilSym.h:=0;
  for i := 0 to 255 do
    for k:= 0 to high(Symbol) do
      if Symbol[k].Value = i then begin
        Result[i] :=Symbol[k].h;
        break;
      end else
    Result[i]  := 0;
  index := 256;
  pos := 0;
  Result[index]:=0;
  for i := 0 to high(InputArray) do begin
    curcode := findsym(InputArray[i], Symbol);
    for j := 1 to length(curcode) do begin
      if pos = 8 then begin
        pos := 0;
        Inc(index);
        Setlength(Result, length(Result) + 1);
        Result[index]:=0;
      end;
      if curcode[j] = '1' then
        Result[index] := Result[index] xor (1 shl pos);
      Inc(pos);
    end;
  end;
end;

initialization

  Arch := TArch.Create();
end.
