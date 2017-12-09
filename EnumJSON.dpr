program EnumJSON;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  REST.Json,
  System.SysUtils,
  EnumJSON.Demo in 'EnumJSON.Demo.pas',
  EnumJSON.Interceptors in 'EnumJSON.Interceptors.pas';

type
  TEnum1 = (Doe, Ray, Mi, Fa, So, La, Ti, Toe, Nine, Ten);

  TEnumSet<T: record> = class end;

var
  LSomeClass31, LSomeClass32: TSomeClass3;
  LSomeClass11, LSomeClass12: TSomeClass1;
  LSomeClass21, LSomeClass22: TSomeClass2;
  LSomeClass4: TSomeClass4;
  LJson: string;
begin

//  LEnumSet := [Doe, Ray, Mi];
//  WriteLn(Sizeof(LEnumSet));

  LSomeClass11 := TSomeClass1.Create;
  LSomeClass12 := nil;

  LSomeClass21 := TSomeClass2.Create(Highlander, GalaxyFish, TomorrowNeverComes, seThree);
  LSomeClass22 := nil;

  LSomeClass31 := TSomeClass3.Create([seOne, seThree], [seOne, seThree]);
  LSomeClass32 := nil;

  LSomeClass4 := TSomeClass4.Create([]);
  try
    try
      LJson := TJson.ObjectToJsonString(LSomeClass31);
      WriteLn('The marshalled value is: ', LJson);
      LSomeClass32 := TJson.JsonToObject<TSomeClass3>(LJson);
      Assert(LSomeClass31.FEnumSet1 = LSomeClass32.FEnumSet1);
      Assert(LSomeClass31.FEnumSet2 = LSomeClass32.FEnumSet2);
      WriteLn('Successfully marshalled back!');
      WriteLn;

      LSomeClass11.FOption1 := GalaxyFish;
      LSomeClass11.FOption2 := TomorrowNeverComes;
      LSomeClass11.FEnum := seTwo;
      LSomeClass11.FFunnyEnum := TomorrowNeverComes;
      LSomeClass11.FSampleEnumSet := [seTwo, seThree];

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
      WriteLn;

      // There'll be an error here, since the interceptor is missing attributes
      WriteLn('Error detection below...');
      LJson := TJson.ObjectToJsonString(LSomeClass4);

    except
      on E: Exception do
        WriteLn(E.Message);
    end;

  finally
    ReadLn;

    LSomeClass4.Free;

    LSomeClass22.Free;
    LSomeClass21.Free;
    LSomeClass12.Free;
    LSomeClass11.Free;

    LSomeClass32.Free;
    LSomeClass31.Free;
  end;

end.

