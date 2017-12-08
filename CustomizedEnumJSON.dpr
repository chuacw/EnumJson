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
    LSomeClass1.Option1 := GalaxyFish;
    LSomeClass1.Option2 := TomorrowNeverComes;
    LSomeClass1.Enum := suTwo;
    LSomeClass1.FunnyEnum := TomorrowNeverComes;

    LJson := TJson.ObjectToJsonString(LSomeClass1);
    WriteLn('The marshalled value is: ', LJson);
    LSomeClass2 := TJson.JsonToObject<TSomeClass>(lJson);

    Assert(LSomeClass1.Option1 = LSomeClass2.Option1);
    Assert(LSomeClass1.Option2 = LSomeClass2.Option2);
    Assert(LSomeClass1.Enum = LSomeClass2.Enum);
    Assert(LSomeClass1.FunnyEnum = LSomeClass2.FunnyEnum);

    WriteLn('Successfully marshalled back!');

  finally
    LSomeClass2.Free;
    LSomeClass1.Free;
  end;

end.
