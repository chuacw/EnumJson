program CustomizedEnumJSON;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  REST.Json,  System.SysUtils,
  EnumDemo in 'EnumDemo.pas',
  EnumJSON.Interceptors in 'EnumJSON.Interceptors.pas';

var
  LSomeClass11, LSomeClass12: TSomeClass1;
  LSomeClass21, LSomeClass22: TSomeClass2;
  LJson: string;
begin

  LSomeClass11 := TSomeClass1.Create;
  LSomeClass12 := nil;

  LSomeClass21 := TSomeClass2.Create(Highlander, GalaxyFish, TomorrowNeverComes, suThree);
  LSomeClass22 := nil;
  try
    LSomeClass11.FOption1 := GalaxyFish;
    LSomeClass11.FOption2 := TomorrowNeverComes;
    LSomeClass11.FEnum := suTwo;
    LSomeClass11.FFunnyEnum := TomorrowNeverComes;

    LJson := TJson.ObjectToJsonString(LSomeClass11);
    WriteLn('The marshalled value is: ', LJson);
    LSomeClass12 := TJson.JsonToObject<TSomeClass1>(LJson);

    Assert(LSomeClass11.FOption1 = LSomeClass12.FOption1);
    Assert(LSomeClass11.FOption2 = LSomeClass12.FOption2);
    Assert(LSomeClass11.FEnum = LSomeClass12.FEnum);
    Assert(LSomeClass11.FFunnyEnum = LSomeClass12.FFunnyEnum);

    WriteLn('Successfully marshalled back!');
    WriteLn;

    LJson := TJson.ObjectToJsonString(LSomeClass21);
    WriteLn('The marshalled value is: ', LJson);
    LSomeClass22 := TJson.JsonToObject<TSomeClass2>(LJson);

    Assert(LSomeClass21.Option1 = LSomeClass22.Option1);
    Assert(LSomeClass21.Option2 = LSomeClass22.Option2);
    Assert(LSomeClass21.Enum    = LSomeClass22.Enum);
    Assert(LSomeClass21.FunnyEnum = LSomeClass22.FunnyEnum);

    WriteLn('Successfully marshalled back!');
    ReadLn;

  finally
    LSomeClass22.Free;
    LSomeClass21.Free;
    LSomeClass12.Free;
    LSomeClass11.Free;
  end;

end.
