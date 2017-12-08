// chuacw, Singapore, 8 Dec 2017
unit EnumDemo;

interface
uses EnumJSON.Interceptors, REST.JsonReflect;

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
  [EnumAs('Only one'), EnumAs('Two fish'), EnumAs('Godzilla')]
  TFunnyEnumInterceptor = class(TEnumInterceptor<TFunnyEnums>)end;

  TSomeClass = class
  public
    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
    Option1: TFunnyEnums;

    [JSONReflect(ctString, rtString, TFunnyEnumInterceptor, nil, true)]
    Option2: TFunnyEnums;

    // Normal enums
    Enum: TSampleEnum;
    FunnyEnum: TFunnyEnums;
  end;

implementation

end.
