# Archive_Program
UniPack Archive (UPA) Format Specification 
14.07.2015 (d.m.y) 
 
════════════════════════════════════════════════════════════════════════════════ 
1. GENERAL INFO 
 
File extension:            ".upa" 
Max amount of files:       65535 
Filename codepage:         Windows-1251 
Folder hierarchy support:  No 
Solid archives support:    Yes 
Compression methods:       One for whole archive 
Endianness:                little-endian (Intel) 
 
════════════════════════════════════════════════════════════════════════════════ 
2. FILE STRUCTURE 
 
Archive file is divided into 3 parts: header, FAT and packed data stream 
 
1.0) HEADER 
 
sign    char[3] = {'U','P','A'} 
  UPA file signature, must be 'UPA' 
method    char[4] 
  compression method ID 
is_solid  bool (C99) 
  solid data stream flag 
count     unsigned short int 
  count of files in the archive 

 
2.0) FILE ALLOCATION TABLE (FAT) 
 
FAT entry #1 
FAT entry #2 
... 
FAT entry #count 

2.1) FAT ENTRY
 
fn_len    char 
  zero-based filename length (i.e. 0 means 1, 255 means 256 etc.) 
filename  char[fn_len] 
  filename (max length is 256 as in NTFS standard) 
packsize  unsigned long long int 
  packed file data size 
origsize  unsigned long long int 
  original (non-packed) file size 

3.0) PACKED DATA STREAM 

Packed data structure is method-dependent. 
If archive is solid, the whole packed data stream represents all files, compressed as one. 
Otherwise, the packed data stream consists of packed files data, placed in the same order as in FAT. 
