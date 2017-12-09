// Code by chuacw, Singapore, 8 Dec 2017
unit EnumJSON.Interceptors;

interface
uses System.JSON, REST.JsonReflect;

type
  EnumBreakAttribute = class(TCustomAttribute)
  end;

  EnumAsAttribute = class(TCustomAttribute)
  protected
    FName: string;
  public
    constructor Create(const AName: string); overload;
    function ToString: string; override;
    property Name: string read FName;
  end;

  EnumsAsAttribute = class(EnumAsAttribute)
  protected
    FNames: TArray<string>;
  public
    constructor Create(const ANames: TArray<string>); overload;
    constructor Create(const ANames: string; ASeparator: Char=','); overload;
    property Names: TArray<string> read FNames;
  end;

  EnumSetAsAttribute = class(TCustomAttribute)
  private
    FName: string;
    FSeparator: Char;
  public
    constructor Create(const AName: string; const ASeparator: Char = ','); overload;
    function ToString: string; override;
    property Name: string read FName;
    property Separator: Char read FSeparator;
  end;

  TBaseEnumInterceptor<T> = class(TJSONInterceptor)
  protected
    procedure ExpectTypeKind(ATypeKind: TTypeKind);
  end;

  TEnumInterceptor<T> = class(TBaseEnumInterceptor<T>)
  public
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TEnumSetInterceptor<T> = class(TBaseEnumInterceptor<T>)
  protected
    function GetEnumSetAttr: EnumSetAsAttribute;
    function GetEnumStrings: TArray<string>;
  public
//    function StringConverter(Data: TObject; Field: string): string; override;
//    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
// for arrays
    function StringsConverter(Data: TObject; Field: string): TListOfStrings; override;
    procedure StringsReverter(Data: TObject; Field: string; Args: TListOfStrings); override;
  end;

implementation
uses System.Rtti, System.TypInfo, System.SysUtils, System.StrUtils;

constructor EnumAsAttribute.Create(const AName: string);
begin
  FName := AName;
end;

function EnumAsAttribute.ToString: string;
begin
  Result := FName;
end;

constructor EnumSetAsAttribute.Create(const AName: string; const ASeparator: Char);
begin
  FName := AName;
  FSeparator := ASeparator;
end;

function EnumSetAsAttribute.ToString: string;
begin
  Result := FName;
end;

constructor EnumsAsAttribute.Create(const ANames: TArray<string>);
begin
end;

{ TBaseEnumInterceptor<T> }

procedure TBaseEnumInterceptor<T>.ExpectTypeKind(ATypeKind: TTypeKind);
begin
  Assert(TypeInfo(T) <> nil, 'Type has no typeinfo!');
  Assert(PTypeInfo(TypeInfo(T)).Kind = ATypeKind, 'Type is not expected type!');
end;

{ TEnumInterceptor<T> }

function TEnumInterceptor<T>.StringConverter(Data: TObject; Field: String): string;
var
  LRttiContext: TRttiContext;
  LValue: Integer;
  LType: TRttiType;
  LAttrs: TArray<TCustomAttribute>;
begin
  ExpectTypeKind(tkEnumeration);

  LRttiContext := TRttiContext.Create;
  LType := LRttiContext.GetType(ClassType);
  LAttrs := LType.GetAttributes;
  LValue := LRttiContext.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsOrdinal;

  Assert(LValue <= High(LAttrs), Format('Insufficient number of attributes on %s', [ClassName]));

  Result := LAttrs[LValue].ToString;
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
  ExpectTypeKind(tkEnumeration);

  if Field = 'side' then
    begin
      LEnum := LEnum;
    end;

  LRttiContext := TRttiContext.Create;
  LInterceptorType := LRttiContext.GetType(ClassType);
  LAttrs := LInterceptorType.GetAttributes;
  I := 0;
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

{ TBaseEnumSetInterceptor<T> }

function TEnumSetInterceptor<T>.GetEnumSetAttr: EnumSetAsAttribute;
var
  LRttiContext: TRttiContext;
  LInterceptorType: TRttiType;
  LAttrs: TArray<TCustomAttribute>;
  LAttr: TCustomAttribute;
begin
  LRttiContext := TRttiContext.Create;
  LInterceptorType := LRttiContext.GetType(ClassType);
  LAttrs := LInterceptorType.GetAttributes;
  for LAttr in LAttrs do
    if LAttr is EnumSetAsAttribute then
      Exit(LAttr as EnumSetAsAttribute);
  Result := nil;
end;

function TEnumSetInterceptor<T>.GetEnumStrings: TArray<string>;
var
  LRttiContext: TRttiContext;
  LInterceptorType: TRttiType;
  LAttrs: TArray<TCustomAttribute>;

  LAttr: TCustomAttribute;
  LEnumSetAttr: EnumSetAsAttribute absolute LAttr;

  LNames: string;
begin
  LRttiContext := TRttiContext.Create;
  LInterceptorType := LRttiContext.GetType(ClassType);
  LAttrs := LInterceptorType.GetAttributes;
  for LAttr in LAttrs do
    if LAttr is EnumSetAsAttribute then
      begin
        LNames := LEnumSetAttr.Name;
        Exit(TArray<string>(SplitString(LNames, LEnumSetAttr.Separator)));
      end;
  Result := nil;
end;

(*
function TEnumSetInterceptor<T>.StringConverter(Data: TObject; Field: string): string;
var
  LRttiContext: TRttiContext;
  LValue: TValue;
  LFieldType: TRttiType;
  LSetType: TRttiSetType;
  LEnumSetAttr: EnumSetAsAttribute;
  LAllNames: string;
  LField: TRttiField;
  LEnumType: TRttiEnumerationType;

// Do not change this sequence!!!
  LSetValues: set of 0..SizeOf(Integer) * 8 - 1; // this applies to all sets, so, it can map any set
  LEnumSet: T absolute LSetValues;               // any generic set is <= LSetValues

  LIValue, LMinValue, LMaxValue: Integer;
  LSplitNames: TArray<string>;
  LName: string;
begin
  ExpectTypeKind(tkSet);

  Result := '';
  LRttiContext := TRttiContext.Create;

  LEnumSetAttr := GetEnumSetAttr;
  Assert(Assigned(LEnumSetAttr), Format('EnumSet attribute missing from %s!', [ClassName]));

  LSplitNames := GetEnumStrings;
  Assert(Length(LSplitNames)>0, Format('EnumSet attribute needs string parameters on %s!', [ClassName]));

// Data is an istance of the class containing the field
  LField := LRttiContext.GetType(Data.ClassType).GetField(Field);
  if LField.FieldType is TRttiSetType then
    begin
      LValue := LField.GetValue(Data);
      LEnumSet := LValue.AsType<T>;
      LSetType := TRttiSetType(LField.FieldType);
      if LSetType.ElementType is TRttiEnumerationType then
        begin
          LEnumType := TRttiEnumerationType(LSetType.ElementType);
          LMinValue := LEnumType.MinValue;
          LMaxValue := LEnumType.MaxValue;

          // You got 3 elements, but you only provided 2 names,
          // or you separated the strings with a pipe (|) but the separator is comma (,)
          Assert(LMaxValue <= High(LSplitNames),
            'Number of elements in set does not match, or separator mismatch!');

          for LIValue := LMinValue to LMaxValue do
            if LIValue in LSetValues then // values beyond LMaxValue in LSetValues are invalid!!!
              if Result = '' then
                Result := LSplitNames[LIValue] else
                Result := Result + LEnumSetAttr.Separator + LSplitNames[LIValue];
        end;
    end;
end;

procedure TEnumSetInterceptor<T>.StringReverter(Data: TObject; Field: string; Arg: string);
var
  LRttiContext: TRttiContext;
  LValue: TValue;

  I, J: Integer;
  LField: TRttiField;
  LSeparator: Char;
  LEnumSetAttr: EnumSetAsAttribute;

// Do not change this sequence!!!
  LSetValues: set of 0..SizeOf(Integer) * 8 - 1;
  LEnumSet: T absolute LSetValues;

  LSplitNames, LSplitNamesArg: TArray<string>;
begin
  ExpectTypeKind(tkSet);

  LRttiContext := TRttiContext.Create;

  LEnumSetAttr := GetEnumSetAttr;
  Assert(Assigned(LEnumSetAttr), Format('EnumSet attribute missing from %s!', [ClassName]));

  LSplitNames := GetEnumStrings;
  Assert(Length(LSplitNames)>0, 'EnumSet attribute needs string parameters!');

  LSetValues := [];

  LSplitNamesArg := TArray<string>(SplitString(Arg, LEnumSetAttr.Separator));
  for I := Low(LSplitNames) to High(LSplitNames) do
    for J := Low(LSplitNamesArg) to High(LSplitNamesArg) do
      if LSplitNames[I] = LSplitNamesArg[J] then
        Include(LSetValues, I);

  LField := LRttiContext.GetType(Data.ClassType).GetField(Field);
  LValue := TValue.From<T>(LEnumSet);
  LField.SetValue(Data, LValue);

end;
*)

function TEnumSetInterceptor<T>.StringsConverter(Data: TObject;
  Field: string): TListOfStrings;
var
  LRttiContext: TRttiContext;
  LValue: TValue;
  LFieldType: TRttiType;
  LSetType: TRttiSetType;
  LEnumSetAttr: EnumSetAsAttribute;
  LAllNames: string;
  LField: TRttiField;
  LEnumType: TRttiEnumerationType;

// Do not change this sequence!!!
  LSetValues: set of 0..SizeOf(Integer) * 8 - 1; // this applies to all sets, so, it can map any set
  LEnumSet: T absolute LSetValues;               // any generic set is <= LSetValues

  LIValue, LMinValue, LMaxValue: Integer;
  LSplitNames: TArray<string>;
  LName: string;
begin
  ExpectTypeKind(tkSet);

  Result := nil;
  LRttiContext := TRttiContext.Create;

  LEnumSetAttr := GetEnumSetAttr;
  Assert(Assigned(LEnumSetAttr), Format('EnumSet attribute missing from %s!', [ClassName]));

  LSplitNames := GetEnumStrings;
  Assert(Length(LSplitNames)>0, Format('EnumSet attribute needs string parameters on %s!', [ClassName]));

// Data is an istance of the class containing the field
  LField := LRttiContext.GetType(Data.ClassType).GetField(Field);
  if LField.FieldType is TRttiSetType then
    begin
      LValue := LField.GetValue(Data);
      LEnumSet := LValue.AsType<T>;
      LSetType := TRttiSetType(LField.FieldType);
      if LSetType.ElementType is TRttiEnumerationType then
        begin
          LEnumType := TRttiEnumerationType(LSetType.ElementType);
          LMinValue := LEnumType.MinValue;
          LMaxValue := LEnumType.MaxValue;

          // You got 3 elements, but you only provided 2 names,
          // or you separated the strings with a pipe (|) but the separator is comma (,)
          Assert(LMaxValue <= High(LSplitNames),
            'Number of elements in set does not match, or separator mismatch!');

          for LIValue := LMinValue to LMaxValue do
            if LIValue in LSetValues then // values beyond LMaxValue in LSetValues are invalid!!!
                Result := Result + [LSplitNames[LIValue]];
        end;
    end;
end;

procedure TEnumSetInterceptor<T>.StringsReverter(Data: TObject; Field: string;
  Args: TListOfStrings);
var
  LRttiContext: TRttiContext;
  LValue: TValue;

  I, J: Integer;
  LField: TRttiField;
  LSeparator: Char;
  LEnumSetAttr: EnumSetAsAttribute;

// Do not change this sequence!!!
  LSetValues: set of 0..SizeOf(Integer) * 8 - 1;
  LEnumSet: T absolute LSetValues;

  LSplitNames, LSplitNamesArg: TArray<string>;
  LArg: string;
begin
  ExpectTypeKind(tkSet);

  LRttiContext := TRttiContext.Create;

  LEnumSetAttr := GetEnumSetAttr;
  Assert(Assigned(LEnumSetAttr), Format('EnumSet attribute missing from %s!', [ClassName]));

  LSplitNames := GetEnumStrings;
  Assert(Length(LSplitNames)>0, 'EnumSet attribute needs string parameters!');

  LSetValues := [];

  LSplitNamesArg := TArray<string>(Args);
  for I := Low(LSplitNames) to High(LSplitNames) do
    for J := Low(LSplitNamesArg) to High(LSplitNamesArg) do
      if LSplitNames[I] = LSplitNamesArg[J] then
        Include(LSetValues, I);

  LField := LRttiContext.GetType(Data.ClassType).GetField(Field);
  LValue := TValue.From<T>(LEnumSet);
  LField.SetValue(Data, LValue);

end;

constructor EnumsAsAttribute.Create(const ANames: string; ASeparator: Char=',');
begin
  FNames := TArray<string>(SplitString(ANames, ASeparator));
end;

end.
