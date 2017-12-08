program CustomizedEnumJSON;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  REST.Json,
  EnumDemo in 'EnumDemo.pas',
  EnumJSON.Interceptors in 'EnumJSON.Interceptors.pas';

var
  LSomeClass1, LSomeClass2: TSomeClass;
  LJson: string;
begin

  LSomeClass1 := TSomeClass.Create;
  LSomeClass2 := nil;
  try
    LSomeClass1.FOption1 := GalaxyFish;
    LSomeClass1.FOption2 := TomorrowNeverComes;
    LSomeClass1.FEnum := suTwo;
    LSomeClass1.FFunnyEnum := TomorrowNeverComes;

    LJson := TJson.ObjectToJsonString(LSomeClass1);
    WriteLn('The marshalled value is: ', LJson);
    LSomeClass2 := TJson.JsonToObject<TSomeClass>(lJson);

    Assert(LSomeClass1.FOption1 = LSomeClass2.FOption1);
    Assert(LSomeClass1.FOption2 = LSomeClass2.FOption2);
    Assert(LSomeClass1.FEnum = LSomeClass2.FEnum);
    Assert(LSomeClass1.FFunnyEnum = LSomeClass2.FFunnyEnum);

    WriteLn('Successfully marshalled back!');

  finally
    LSomeClass2.Free;
    LSomeClass1.Free;
  end;

end.
