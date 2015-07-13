unit UCompress;

{$mode objfpc}{$H+}

Interface

uses
  Classes, SysUtils;

type
  Tree = ^Ttree;
  Ttree = record
    value: byte;
    f: integer;
    left, right: Tree;
  end;

  Sym = record
    value: byte;
    h: integer;
    code: integer;
  end;

var
  i, j: integer;
  tr: Tree;
  m: array of Sym;
  FreqTable: array of byte;
  Count: array of integer;

implementation
procedure sort(l, r: longint);
  var
    j, i, mid, samp: longint;
    buf: byte;
begin
    i := l;
    j := r;
    mid := Count[(i+j) div 2];
    repeat
      while Count[i] < mid do inc(i);
      while Count[j] > mid do dec(j);
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
    if i < r then sort(i,r);
    if j > l then sort(l,j);
end;

procedure sortArray(l, r: longint);
  var
    j, i, mid, samp: longint;
    buf: sym;
begin
    i := l;
    j := r;
    mid := Count[(i+j) div 2];
    repeat
      while M[i].h < mid do inc(i);
      while M[j].h > mid do dec(j);
      if i <= j then
      begin
        buf := M[i];
        M[i] := M[j];
        M[j] := buf;
        inc(i);
        dec(j);
      end;
    until i > j;
    if i < r then sort(i,r);
    if j > l then sort(l,j);
end;

procedure getFrequency();
  var Found: boolean;
    a: byte;
begin
 repeat begin
   found:=false;
   read(a);
   for i:= 0 to high(FreqTable) do  begin
     if a = FreqTable[i] then inc(Count[i]);
     found:=true;
     break;
   end;
   if not found then begin
     SetLength(FreqTable, length(FreqTable) +1 );
     SetLength(Count, length(Count) +1 );
     FreqTable[high(FreqTable)]:=a;
   end;
   end;
 until eof();
 Sort(0, high(FreqTable));
end;

function buildtree(i, j: integer) : tree;
var in1, in2: tree;
  Knots: array of Tree;

  function findknot(): tree;
    begin
    if (i<=length(FreqTable)) and (Count[i]<=Knots[j]^.f)
      then begin
        result:=new(Tree);
        result^.value:=FreqTable[i];
        result^.f:=Count[i];
        inc(i);
      end else if j<=length(Knots)
        then begin
        result:=Knots[j];
        inc(j);
     end;
   end;
  function makeknot(a, b: tree) : tree;
    begin
      setlength(Knots, length(Knots) + 1);
      New(tr);
      tr^.right:=a;
      tr^.left:=b;
      tr^.f:=a^.f + b^.f;
      tr^.value:= -1;
      Knots[high(Knots)]:=tr;
      result:=tr;
    end;
begin
 in1:=findknot;
 in2:=findknot;
 result:=makeknot(in1, in2);
  if (i = length(FreqTable)) and (j = length(Knots)) then
 exit;
end;

procedure getM(tr: tree; l: integer);
begin
 if tr^.value <> -1 then
 begin
   SEtlength(M, length(M) + 1);
   M[high(M)].value:=tr^.value;
   M[high(M)].h:=l;
 end
 else
 begin
   getM(tr^.left, l + 1);
   getM(tr^.right, l + 1);
 end;
end;

procedure Compress();
begin
 SortArray(0, high(M));
 M[0].code:=0;
 for i:= 1 to high(M) do
   if M[i].h = M[i-1].h then
     M[i].code:=M[i].code + 1 else
       M[i].code:=(M[i-1].code + 1) shl 1;
end;

begin

end.
