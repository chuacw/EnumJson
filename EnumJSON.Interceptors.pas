// Code by chuacw, Singapore, 8 Dec 2017
unit EnumJSON.Interceptors;

interface
uses System.JSON, REST.JsonReflect;

type
  EnumAsAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string); overload;
    function ToString: string; override;
    property Name: string read FName;
  end;

  EnumsAsAttribute = class(TCustomAttribute)
  private
    FNames: TArray<string>;
  public
    constructor Create(const ANames: array of const); overload;
    property Names: TArray<string> read FNames;
  end;

  TEnumInterceptor<T> = class(TJSONInterceptor)
  public
    function StringConverter(Data: TObject; Field: String): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

implementation
uses System.Rtti;

constructor EnumAsAttribute.Create(const AName: string);
begin
  FName := AName;
end;

function EnumAsAttribute.ToString: string;
begin
  Result := FName;
end;

constructor EnumsAsAttribute.Create(const ANames: array of const);
begin
end;

function TEnumInterceptor<T>.StringConverter(Data: TObject; Field: String): string;
var
  LRttiContext: TRttiContext;
  LValue: Integer;
  LType: TRttiType;
  LRttiAttrs: TArray<TCustomAttribute>;
begin
  LRttiContext := TRttiContext.Create;
  LType := LRttiContext.GetType(ClassType);
  LRttiAttrs := LType.GetAttributes;
  LValue := LRttiContext.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsOrdinal;
  Result := LRttiAttrs[LValue].ToString;
end;

procedure TEnumInterceptor<T>.StringReverter(Data: TObject; Field: string; Arg: string);
var
  LRttiContext: TRttiContext;
  LValue: TValue;
  LEnum: T;
  LAbsValue: Byte absolute LEnum;
  LRttiType, LInterceptorType: TRttiType;
  LAttrs: TArray<TCustomAttribute>;
  LAttr: TCustomAttribute;
  I: Integer;
  LField: TRttiField;
begin
  LRttiContext := TRttiContext.Create;
  I := 0;
  LInterceptorType := LRttiContext.GetType(ClassType);
  LAttrs := LInterceptorType.GetAttributes;
  for LAttr in LAttrs do
    begin
      if LAttr is EnumAsAttribute then
        begin
          if LAttr.ToString = Arg then
            begin
              LRttiType := TypeInfo(T); // RTTI for the Enum
              LAbsValue := I;           // Each enum is a byte
              LValue := TValue.From<T>(LEnum);
              LField := LRttiContext.GetType(Data.ClassType).GetField(Field);
              LField.SetValue(Data, LValue);
              Break;
            end;
          Inc(I);
        end;
    end;
end;

end.
