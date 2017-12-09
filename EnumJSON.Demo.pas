// chuacw, Singapore, 8 Dec 2017
unit EnumJSON.Demo;
{$HINTS ON}

interface
uses EnumJSON.Interceptors, REST.Json, REST.JsonReflect, REST.Json.Types;

type

  TFunnyEnums = (Highlander, GalaxyFish, TomorrowNeverComes);

  // Place the EnumAs attribute on the interceptor, one for each enum value
  // This is because Delphi doesn't support attributes on enums... yet!
  // Declare a new class, as you can't use generics on attributes due to a compiler bug.
  // Otherwise, you would be able to do
  // [JSONReflect(ctString, rtString, TEnumInterceptor<TFunnyEnums>, nil, true)] directly on the field itself instead
  // of
  // [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
  [EnumAs('High...lander!'), EnumAs('Galaxy Fish???'), EnumAs('James Bond!')]
  TFunnyEnumInterceptor1 = class(TEnumInterceptor<TFunnyEnums>)end;

  [EnumAs('Not really Highlander!'), EnumAs('Not Galaxy Fish!!!'), EnumAs('I don''t like James Bond!')]
  TFunnyEnumInterceptor2 = class(TEnumInterceptor<TFunnyEnums>)end;

  TEnum = (seOne, seTwo, seThree);
  TEnumSet = set of TEnum;

  [EnumAs('Doe a dear'), EnumAs('Ray, a drop of golden sun'), EnumAs('Me, a name, I call myself')]
  TSampleEnumInterceptor = class(TEnumInterceptor<TEnum>)end;

  // These are classes that uses the enum...
  TSomeClass1 = class
  public
    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor1, nil, true)]
    FOption1: TFunnyEnums;

    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor2, nil, true)]
    // You can put different interceptors on the same enum but different fields, to get different results!
    FOption2: TFunnyEnums;

    [JSONReflect(ctString, rtString, TSampleEnumInterceptor, nil, true)]
    FEnum: TEnum;

    // Normal enum
    FFunnyEnum: TFunnyEnums;

    FSampleEnumSet: TEnumSet;
  end;

  TSomeClass2 = class
  public
    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor1, nil, true), JsonName('NewName1')]
    Option1: TFunnyEnums;

    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor1, nil, true), JSONName('NewName2')]
    Option2: TFunnyEnums;

    [JSONReflect(ctString, rtString, TSampleEnumInterceptor, nil, true), JSONName('Third Name')]
    Enum: TEnum;

    [JsonName('Fourth Name')]
    FunnyEnum: TFunnyEnums;
  public
    constructor Create(AOption1, AOption2, AFunnyEnum: TFunnyEnums; AEnum: TEnum);
  end;

  [EnumSetAs('One|Two|Three', '|')]
  TEnumSetInterceptor1 = class(TEnumSetInterceptor<TEnumSet>)end;

  [EnumSetAs('Nine,Five,Four')] // Default separator is comma
  TEnumSetInterceptor2 = class(TEnumSetInterceptor<TEnumSet>)end;

  // Deliberately leave out the Enum...Attribute, to demonstrate error
  TEnumSetInterceptor3 = class(TEnumSetInterceptor<TEnumSet>)end;

  TSomeClass3 = class
  public
    [JSONReflect(ctStrings, rtStrings, TEnumSetInterceptor1, nil, true), JSONName('EnumSet1')]
    FEnumSet1: TEnumSet;

    [JSONReflect(ctStrings, rtStrings, TEnumSetInterceptor2, nil, true), JSONName('EnumSet2')]
    FEnumSet2: TEnumSet;
  public
    constructor Create(AEnumSet1, AEnumSet2: TEnumSet);
  end;

  TSomeClass4 = class
  public
    [JSONReflect(ctStrings, rtStrings, TEnumSetInterceptor3, nil, true), JSONName('EnumSet1')]
    FEnumSet1: TEnumSet;
  public
    constructor Create(AEnumSet1: TEnumSet);
  end;

implementation

{ TSomeClass2 }

constructor TSomeClass2.Create(AOption1, AOption2, AFunnyEnum: TFunnyEnums;
  AEnum: TEnum);
begin
  Option1 := AOption1;
  Option2 := AOption2;
  FunnyEnum := AFunnyEnum;
  Enum := AEnum;
end;

constructor TSomeClass3.Create(AEnumSet1, AEnumSet2: TEnumSet);
begin
  FEnumSet1 := AEnumSet1;
  FEnumSet2 := AEnumSet2;
end;

// This is work in progress...
//procedure RegisterConverter;
//var
//  LConverter: TConverterEvent;
//  LReverter: TReverterEvent;
//begin
//  LConverter := TConverterEvent.Create();
//  LReverter  := TReverterEvent.Create();
//  TJSONConverters.AddConverter(LConverter);
//end;
//
//initialization
//  RegisterConverter;
{ TSomeClass3 }

{ TSomeClass4 }

constructor TSomeClass4.Create(AEnumSet1: TEnumSet);
begin
  // Not necessary to set up, since there'll be an error
end;

end.
