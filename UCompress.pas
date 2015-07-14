unit UCompress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  Tree = ^TTree;

  TTree = record
    value: byte;
    f: integer;
    left, right: Tree;
  end;

  Symb = record
    value: byte;
    h: integer;
    code: string;
  end;

  ByteArray = array of byte;
var
  k, m: integer;
  tr: Tree;
  symbol: array of Symb;
  FreqTable: array of byte;
  Count: array of integer;
  s: string;
  ex: array of byte;
implementation

procedure sort(l, r: longint);
var
  j, i, mid, samp: longint;
  buf: byte;
begin
  i := l;
  j := r;
  mid := Count[(i + j) div 2];
  repeat
    while Count[i] < mid do
      inc(i);
    while Count[j] > mid do
      dec(j);
    if i <= j then
    begin
      buf := FreqTable[i];
      FreqTable[i] := FreqTable[j];
      FreqTable[j] := buf;
      samp := Count[i];
      Count[i] := Count[j];
      Count[j] := samp;
      inc(i);
      dec(j);
    end;
  until i > j;
  if i < r then
    sort(i, r);
  if j > l then
    sort(l, j);
end;

procedure sortArray(l, r: longint);
var
  j, i, mid, samp: longint;
  buf: Symb;
begin
  i := l;
  j := r;
  mid := symbol[(i + j) div 2].h;
  repeat
    while symbol[i].h < mid do
      inc(i);
    while symbol[j].h > mid do
      dec(j);
    if i <= j then
    begin
      buf := symbol[i];
      symbol[i] := symbol[j];
      symbol[j] := buf;
      inc(i);
      dec(j);
    end;
  until i > j;
  if i < r then
    sortArray(i, r);
  if j > l then
    sortArray(l, j);
end;

procedure getFrequency(Arr: array of byte);
var
  Found: boolean;
  a: byte;
  i, j:integer;
begin
 for k:= 0 to high(Arr) do begin
    found := False;
    a:=Arr[k];
    for i := 0 to High(FreqTable) do
      if a = FreqTable[i] then begin
        inc(Count[i]);
      found := True;
      break;
    end;
    if not found then
    begin
      SetLength(FreqTable, Length(FreqTable) + 1);
      SetLength(Count, Length(Count) + 1);
      FreqTable[High(FreqTable)] := a;
      inc(count[High(Count)]);
    end;
    end;
  Sort(0, High(FreqTable));
end;

function buildtree(i, j: integer): tree;
var
  l, r: tree;
  node: array of Tree;
  function FindNode(): tree;
  begin
   if (length(node) <= j) or( (i < Length(FreqTable))
    and (Count[i] <= node[j]^.f)) then
    begin
        Result := new(Tree);
        Result^.value := FreqTable[i];
        Result^.f := Count[i];
        inc(i);
    end
    else begin
      Result := node[j];
      if j<(length(node)) then
        inc(j);
    end;
  end;


  function MakeNode(a, b: tree): tree;
  begin
    SetLength(node, Length(node) + 1);
    New(tr);
    tr^.right := a;
    tr^.left := b;
    tr^.f := a^.f + b^.f;
    tr^.value := -1;
    node[High(node)] := tr;
    Result := tr;
  end;
begin
  repeat
    l := FindNode;
    r := FindNode;
    Result := MakeNode(l, r);
  until (i > Length(FreqTable)-1) and (j >= Length(node)-1);
end;

procedure GetSymb(tr: tree; l: integer; code: string);
begin
  if tr^.value <> -1 then
  begin
    SetLength(symbol, Length(symbol) + 1);
    symbol[high(symbol)].value := tr^.value;
    symbol[high(symbol)].h := l;
    symbol[high(symbol)].code:=code;
  end
  else
  begin
     if tr^.left <> nil then
       GetSymb(tr^.left, l + 1,  code + '0');
    if tr^.right <> nil then
     GetSymb(tr^.right, l + 1, code + '1');
  end;
end;

function findsym(a: byte): byte;
var i: integer;
begin
  for i:= 0 to high(Symbol) do
    if Symbol[i].value = a then begin
      result:=a;
      exit;
  end;
end;

procedure MakeNewCodes();
var i: integer;
  function Increase(s: string): string;
  var t: integer;
  begin
       for t := length(s) downto 1 do
      if s[t] = '0' then begin
        s[t] :='1';
        result:=s;
        exit;;
      end
     else s[t]:= '0';
  end;
begin
  SortArray(0, High(symbol));
  symbol[i].code:='';
  for i:= 1 to length(symbol[0].code) do
    symbol[0].code:= symbol[i].code + '0';
  for i:= 1 to high(symbol) do
    if symbol[i].h = symbol[i-1].h then
     symbol[i].code:=Increase(symbol[i].code) else
       Symbol[i].code:=Increase(symbol[i].code) + '0';
end;

function Compress(InputArray: array of byte): ByteArray;
var
 curcode: string;
 i, j, pos, index: integer;
begin
  getFrequency(InputArray);
  buildtree(0, 0);
  GetSymb(tr, 0, '');

  MakeNewCodes();
  {pos - индекс внутри байта
  index - номер байта}
  Setlength(Result, length(Result)+1);
  for i:= 0 to high(InputArray) do begin
    k:=findsym(InputArray[i]);
    curcode:=symbol[k].code;
      for j:= 1 to length(curcode) do begin
        if pos > 7 then begin
          pos:=0;
          inc(index);
          Setlength(Result, length(Result)+1);
        end;
        if curcode[j] = '1' then
          result[index]:=  result[index] or (1 shl pos);
        inc(pos);
  end;
  end;
 for i:= 0 to high(result) do
   write(result[i], ' / ');
end;


begin
 {   Assign(input, 'input.txt');
    Assign(output, 'output.txt');
    reset(input);
    rewrite(output);

   Compress(ex);


    Close(input);
    Close(output);  }
end.    
