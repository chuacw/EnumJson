// chuacw, Singapore, 8 Dec 2017
unit EnumDemo;

interface
uses EnumJSON.Interceptors, REST.Json, REST.JsonReflect, REST.Json.Types;

type

  TSampleEnum = (suOne, suTwo, suThree);
  TFunnyEnums = (Highlander, GalaxyFish, TomorrowNeverComes);

  // Place the EnumAs attribute on the interceptor, one for each enum value
  // This is because Delphi doesn't support attributes on enums... yet!
  // Declare a new class, as you can't use generics on attributes due to a compiler bug.
  // Otherwise, you would be able to do
  // JSONReflect(ctString, rtString, TEnumInterceptor<TFunnyEnums>, nil, true)] directly on the field itself instead
  // of
  // [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
  [EnumAs('High...lander!'), EnumAs('Galaxy Fish???'), EnumAs('James Bond!')]
  TFunnyEnumInterceptor = class(TEnumInterceptor<TFunnyEnums>)end;

  TSomeClass1 = class
  public
    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
    FOption1: TFunnyEnums;

    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
    FOption2: TFunnyEnums;

    // Normal enums
    FEnum: TSampleEnum;
    FFunnyEnum: TFunnyEnums;
  end;

  TSomeClass2 = class
    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
    [JsonNameAttribute('NewName1')]
    Option1: TFunnyEnums;

    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
    [JSONName('NewName2')]
    Option2: TFunnyEnums;

    // Normal enums
    [JSONName('Third Name')]
    Enum: TSampleEnum;

    [JsonName('Fourth Name')]
    FunnyEnum: TFunnyEnums;
  public
    constructor Create(AOption1, AOption2, AFunnyEnum: TFunnyEnums; AEnum: TSampleEnum);
  end;

implementation

{ TSomeClass2 }

constructor TSomeClass2.Create(AOption1, AOption2, AFunnyEnum: TFunnyEnums;
  AEnum: TSampleEnum);
begin
  Option1 := AOption1;
  Option2 := AOption2;
  FunnyEnum := AFunnyEnum;
  Enum := AEnum;
end;

end.
