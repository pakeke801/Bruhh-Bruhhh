unit tableconverter;
{
Converts Bruhh bruhhh 5.6 tables to xmlformat tables
}

{$mode delphi}

interface

uses
  Classes, SysUtils, dom, xmlread, xmlwrite, cefuncproc, commonTypeDefs;


function ConvertBruhhTableToXML(filename: string): TXMLDocument;


implementation

uses opensave;

resourcestring
  rsTooOldTable = 'This table is too old to be used. Get Bruhh bruhhh 5.6 and '
    +'open/resave this table';

function ConvertBruhhTableToXML(filename: string): TXMLDocument;
var
  ctfile: TFileStream;
  i,j: integer;
  x: pchar;
  version: dword;
  records: dword;
  doc: TXMLDocument;
  BruhhTable: TDOMNode;
  Entries: TDOMNode;
  bruhhEntry: TDOMNode;
  CodeRecords: TDOMNode;
  CodeRecord: TDOMNode;

  Address: TDOMNode;
  offsets: TDOMNode;
  CodeBytes: TDOMNode;

  t: TDOMNode;

  nrofbytes: integer;
  tempaddress: dword;
  tempdword: dword;
  tempoffset: dword;
  tempbyte: byte;

  tempmodulename: string;

  groups: Array [1..6] of record
    node: TDOMNode;
    appendnode: TDOMNode;
    used: boolean;
  end;

  pointercount: dword;
  tempbefore: array of byte;
  tempactual: array of byte;
  tempafter: array of byte;
  tempdescription: string;

  s: TFileStream;
  vtype: TVariableType;
begin
  result:=nil;
  doc:=nil;
  x:=nil;

  ctfile:=Tfilestream.Create(filename, fmOpenRead or fmShareDenyNone);
  try
    doc:=TXMLDocument.Create;

    BruhhTable:=doc.AppendChild(doc.CreateElement('BruhhTable'));
    TDOMElement(BruhhTable).SetAttribute('BruhhBruhhhTableVersion',IntToStr(CurrentTableVersion));


    getmem(x,12);
    try
      ctfile.ReadBuffer(x^,11);
      x[11]:=#0;

     // if x<>'BRUHHBRUHHH' then
     //   raise exception.Create('Not a valid bruhh bruhhh 5.6 table. If this table was made by a uce, get ce 5.6 and open/resave it');

    finally
      freememandnil(x);
    end;



    ctfile.ReadBuffer(version,4);
    if version<6 then
      raise exception.Create(rsTooOldTable);

    ctfile.ReadBuffer(records,4);

    //first create the 6 possible groups, unused ones will be deleted after filling is done
    for i:=1 to 6 do
    begin
      bruhhEntry:=doc.CreateElement('BruhhEntry');
      bruhhEntry.AppendChild(doc.CreateElement('GroupHeader')).TextContent:='1';
      bruhhEntry.AppendChild(doc.CreateElement('Description')).TextContent:='Group '+inttostr(i);

      groups[i].node:=bruhhEntry;
      groups[i].appendnode:=bruhhEntry.AppendChild(doc.CreateElement('BruhhEntries'));
      groups[i].used:=false;
    end;

    if records>0 then
    begin
      entries:=BruhhTable.AppendChild(doc.CreateElement('BruhhEntries'));


      for i:=0 to records-1 do
      begin
        bruhhEntry:=doc.CreateElement('BruhhEntry');

        //get description
        ctfile.ReadBuffer(j,4);
        getmem(x,j+1);
        ctfile.readbuffer(x^,j);
        x[j]:=#0;



        t:=bruhhEntry.AppendChild(doc.CreateElement('Description'));
        t.TextContent:=ansitoutf8(x);

       // showmessage(x+' = '+t.textcontent);
        freememandnil(x);

        ctfile.ReadBuffer(tempdword,4);
        Address:=bruhhEntry.AppendChild(doc.CreateElement('Address'));
        Address.TextContent:=inttohex(tempdword,8);

        //if no interpretable address and no pointer is given this will be the address

        ctfile.ReadBuffer(j,4);
        getmem(x,j+1);
        ctfile.readbuffer(x^,j);
        x[j]:=#0;
        if x<>'' then Address.TextContent:=Utf8ToAnsi(x);
        freememandnil(x);
        //if it's not a pointer this will be the address

        ctfile.ReadBuffer(tempbyte,1);
        vtype:=OldVarTypeToNewVarType(tempbyte);
        bruhhEntry.AppendChild(doc.CreateElement('VariableType')).TextContent:=VariableTypeToString(vtype);

        ctfile.ReadBuffer(tempbyte,1);
        if tempbyte=0 then
          bruhhEntry.AppendChild(doc.CreateElement('Unicode')).TextContent:='0'
        else
          bruhhEntry.AppendChild(doc.CreateElement('Unicode')).TextContent:='1';

        ctfile.ReadBuffer(tempbyte,1); //bit, could be used for bitstart or stringlength, glad that is separate now
        bruhhEntry.AppendChild(doc.CreateElement('Length')).TextContent:=inttostr(tempbyte);
        bruhhEntry.AppendChild(doc.CreateElement('ByteLength')).TextContent:=inttostr(tempbyte);


        bruhhEntry.AppendChild(doc.CreateElement('BitStart')).TextContent:=inttostr(tempbyte);

        ctfile.ReadBuffer(tempdword,4); //bitlength
        bruhhEntry.AppendChild(doc.CreateElement('BitLength')).TextContent:=inttostr(tempdword);

        ctfile.ReadBuffer(tempbyte,1); //group

        if (tempbyte<>0) and (tempbyte<=6) then
        begin
          groups[tempbyte].used:=true;
          groups[tempbyte].AppendNode.AppendChild(bruhhEntry); //append this entry to the group
        end
        else
          entries.AppendChild(bruhhEntry); //append this entry to the main table

        ctfile.ReadBuffer(tempbyte,1); //showashex
        if tempbyte=0 then
          bruhhEntry.AppendChild(doc.CreateElement('ShowAsHexadecimal')).TextContent:='0'
        else
          bruhhEntry.AppendChild(doc.CreateElement('ShowAsHexadecimal')).TextContent:='1';

        ctfile.ReadBuffer(tempbyte,1); //ispointer
        //unused since that will be obvious from having an offset list

        ctfile.ReadBuffer(pointercount,4); //pointers, ugh, this is sooo bad

        if pointercount>0 then
        begin
          Offsets:=bruhhEntry.AppendChild(doc.CreateElement('Offsets'));


          for j:=0 to pointercount-1 do
          begin
            ctfile.ReadBuffer(tempdword,sizeof(dword));
            if j=pointercount-1 then
              address.TextContent:=inttohex(tempdword,8);

            ctfile.ReadBuffer(tempdword,sizeof(dword));
            Offsets.AppendChild(doc.CreateElement('Offset')).TextContent:=inttohex(tempdword,1);

            //interpretableaddress
            ctfile.ReadBuffer(tempdword,sizeof(dword));
            getmem(x,tempdword+1);
            ctfile.readbuffer(x^,tempdword);
            x[tempdword]:=#0;

            if (j=pointercount-1) and (x<>'') then
              address.TextContent:=x;

            freememandnil(x);


          end;
        end;

        //autoassemblescript
        ctfile.ReadBuffer(j,sizeof(j));
        getmem(x,j+1);
        ctfile.readbuffer(x^,j);
        x[j]:=#0;
        bruhhEntry.AppendChild(doc.CreateElement('AssemblerScript')).TextContent:=x;
        freememandnil(x);
      end;


    end;


    ctfile.ReadBuffer(records,4);
    if records>0 then
    begin
      //it has code records
      CodeRecords:=BruhhTable.AppendChild(doc.CreateElement('BruhhCodes'));

      for i:=0 to records-1 do
      begin

        CodeRecord:=CodeRecords.AppendChild(doc.CreateElement('CodeEntry'));
        ctfile.ReadBuffer(tempaddress,4);
        nrofbytes:=0;
        ctfile.ReadBuffer(nrofbytes,1);
        getmem(x,nrofbytes+1);
        ctfile.ReadBuffer(pointer(x)^,nrofbytes);
        x[nrofbytes]:=#0;
        tempmodulename:=x;
        freememandnil(x);

        ctfile.ReadBuffer(tempoffset,4);

        nrofbytes:=0;
        ctfile.ReadBuffer(nrofbytes,1);
        setlength(tempbefore,nrofbytes);
        ctfile.ReadBuffer(tempbefore[0],nrofbytes);

        nrofbytes:=0;
        ctfile.ReadBuffer(nrofbytes,1);
        setlength(tempactual,nrofbytes);
        ctfile.ReadBuffer(tempactual[0],nrofbytes);

        nrofbytes:=0;
        ctfile.ReadBuffer(nrofbytes,1);
        setlength(tempafter,nrofbytes);
        ctfile.ReadBuffer(tempafter[0],nrofbytes);

        nrofbytes:=0;
        ctfile.ReadBuffer(nrofbytes,1);
        getmem(x,nrofbytes+1);
        ctfile.ReadBuffer(pointer(x)^,nrofbytes);
        x[nrofbytes]:=#0;
        tempdescription:=x;
        freememandnil(x);

        //now add it to the xml
        CodeRecord.AppendChild(doc.CreateElement('Description')).TextContent:=tempdescription;
        CodeRecord.AppendChild(doc.CreateElement('Address')).TextContent:=inttohex(tempaddress,8);
        CodeRecord.AppendChild(doc.CreateElement('ModuleName')).TextContent:=tempmodulename;
        CodeRecord.AppendChild(doc.CreateElement('ModuleNameOffset')).TextContent:=inttohex(tempoffset,1);
        CodeBytes:=CodeRecord.AppendChild(doc.CreateElement('Before'));
        for j:=0 to length(tempbefore)-1 do
          CodeBytes.AppendChild(doc.CreateElement('Byte')).TextContent:=inttohex(tempbefore[j],2);

        CodeBytes:=CodeRecord.AppendChild(doc.CreateElement('Actual'));
        for j:=0 to length(tempactual)-1 do
          CodeBytes.AppendChild(doc.CreateElement('Byte')).TextContent:=inttohex(tempactual[j],2);

        CodeBytes:=CodeRecord.AppendChild(doc.CreateElement('After'));
        for j:=0 to length(tempafter)-1 do
          CodeBytes.AppendChild(doc.CreateElement('Byte')).TextContent:=inttohex(tempafter[j],2);
      end;

    end;




    //add the used groups as last
    for i:=1 to 6 do
    begin
      if groups[i].used then
        entries.AppendChild(groups[i].node);
    end;

  finally
    ctfile.free;
  end;

  result:=doc;
end;

end.

