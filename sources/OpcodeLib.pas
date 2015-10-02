unit OpcodeLib;

{******************************************************************************}
{ Copyright (c) 2013-2015 Dmitry Mozulyov                                      }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining a copy }
{ of this software and associated documentation files (the "Software"), to deal}
{ in the Software without restriction, including without limitation the rights }
{ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    }
{ copies of the Software, and to permit persons to whom the Software is        }
{ furnished to do so, subject to the following conditions:                     }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   }
{ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,}
{ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    }
{ THE SOFTWARE.                                                                }
{                                                                              }
{ email: softforyou@inbox.ru                                                   }
{ skype: dimandevil                                                            }
{ repository: https://github.com/d-mozulyov/OpcodeLib                          }
{******************************************************************************}


// ������, ������� ��������� � ������� ����������������
// ����������� ������������� � ������� ���������� � �������
// ��� ��������� - ������������� ������ ���������� (� ��� ���������� ����������)
{$define OPCODE_MODES}

// ���� ������ ��������� ������� ��������� �������� ����������
// � ������ ������� ��� ����������� ������ ����������
{$define OPCODE_TEST}


// compiler directives
{$ifdef FPC}
  {$mode Delphi}
  {$asmmode Intel}
  {$define INLINESUPPORT}
  {$ifdef CPU386}
    {$define CPUX86}
  {$endif}
  {$ifdef CPUX86_64}
    {$define CPUX64}
  {$endif}
{$else}
  {$if CompilerVersion >= 24}
    {$LEGACYIFEND ON}
  {$ifend}
  {$if CompilerVersion >= 15}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_TYPE OFF}
    {$WARN UNSAFE_CAST OFF}
  {$ifend}
  {$if (CompilerVersion < 23)}
    {$define CPUX86}
  {$ifend}
  {$if (CompilerVersion >= 17)}
    {$define INLINESUPPORT}
  {$ifend}
  {$if CompilerVersion >= 21}
    {$WEAKLINKRTTI ON}
    {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$ifend}
  {$if (not Defined(NEXTGEN)) and (CompilerVersion >= 20)}
    {$define INTERNALCODEPAGE}
  {$ifend}
{$endif}
{$U-}{$V+}{$B-}{$X+}{$T+}{$P+}{$H+}{$J-}{$Z1}{$A4}
{$O+}{$R-}{$I-}{$Q-}{$W-}
{$if Defined(CPUX86) or Defined(CPUX64)}
  {$define CPUINTEL}
{$ifend}
{$if Defined(CPUX64) or Defined(CPUARM64)}
  {$define LARGEINT}
{$else}
  {$define SMALLINT}
{$ifend}
{$ifdef KOL_MCK}
  {$define KOL}
{$endif}


interface
  uses {$ifdef MSWINDOWS}Windows,{$endif}
       Types, SysUtils;


{$if (not Defined(CPUX86)) and (not Defined(CPUX64))} (*and (not Defined(CPUARM))*)
  {$define PUREPASCAL}
{$else}
  {$undef PUREPASCAL}
{$ifend}

{$if (not Defined(PUREPASCAL)) and (not Defined(OPCODE_MODES))}
  {$define OPCODE_FAST}
{$else}
  {$undef OPCODE_FAST}
{$ifend}
        
{$if Defined(OPCODE_FAST) and (not Defined(OPCODE_TEST))}
  {$define OPCODE_FASTEST}
{$else}
  {$undef OPCODE_FASTEST}
{$ifend}       



const
  // reg_x86
  al = 0;
  cl = 1;
  dl = 2;
  bl = 3;
  ah = 4;
  ch = 5;
  dh = 6;
  bh = 7;
  ax = 8;
  cx = 9;
  dx = 10;
  bx = 11;
  sp = 12;
  bp = 13;
  si = 14;
  di = 15;
  eax = 16;
  ecx = 17;
  edx = 18;
  ebx = 19;
  esp = 20;
  ebp = 21;
  esi = 22;
  edi = 23;

  // reg_x64_d_new
  r8d  = 24;
  r9d  = 25;
  r10d = 26;
  r11d = 27;
  r12d = 28;
  r13d = 29;
  r14d = 30;
  r15d = 31;
  // reg_x64_w_new
  r8w  = 32;
  r9w  = 33;
  r10w = 34;
  r11w = 35;
  r12w = 36;
  r13w = 37;
  r14w = 38;
  r15w = 39;
  // reg_x64_q_new
  rax = 40;
  rcx = 41;
  rdx = 42;
  rbx = 43;
  rsp = 44;
  rbp = 45;
  rsi = 46;
  rdi = 47;
  r8  = 48;
  r9  = 49;
  r10 = 50;
  r11 = 51;
  r12 = 52;
  r13 = 53;
  r14 = 54;
  r15 = 55;
  // reg_x64_b_new
  r8b = 56;
  r9b = 57;
  r10b = 58;
  r11b = 59;
  r12b = 60;
  r13b = 61;
  r14b = 62;
  r15b = 63;
  // reg_x64_b_new_warnign
  spl = 64;
  bpl = 65;
  sil = 66;
  dil = 67;


const
  RET_OFF = high(word);


type
  // ������ ��������� ��������� ������ ����������
  // ��� ����������� x86
  reg_x86 = al..edi;
  // ������� ������
  reg_x86_dwords = eax..edi;
  reg_x86_wd = ax..edi;
  reg_x86_bytes = al..bh;
  // ��� �������
  reg_x86_addr = reg_x86_dwords;

  // ������ ��������� ��������� ������ ����������
  // ��� ����������� x64
  reg_x64 = al..dil;
  // ������� ������
  reg_x64_dwords = eax..r15d;
  reg_x64_wd = ax..r15w;
  reg_x64_wdq = ax..r15;
  reg_x64_wq = ax..r15;
  reg_x64_dq = eax..r15;
  reg_x64_qwords = rax..r15;
  reg_x64_bytes = al..dil;
  // ��� �������
  reg_x64_addr = reg_x64_qwords;

  // ������ ��������� ��������� ������ ����������
  // ��� ����������� ARM
  reg_ARM = 0..0{todo};

  // ��� ������ x86-64
  intel_cc = (_o,_no,_b,_c,_nae,_ae,_nb,_nc,_e,_z,_nz,_ne,_be,_na,_a,_nbe,_s,_ns,
              _p,_pe,_po,_np,_l,_nge,_ge,_nl,_le,_ng,_g,_nle);

  // "�������" � ������            
  intel_scale = (xNone, x1, x2, x4, x8, x1_plus, x2_plus, x4_plus, x8_plus);

  // ��� ���������� ���
  intel_rep = (REP_SINGLE, REP, REPE, REPZ, REPNE, REPNZ);

  // ����������� �������� (������)
  size_ptr = (byte_ptr, word_ptr, dword_ptr, qword_ptr, tbyte_ptr, dqword_ptr);

  // �������
  index8 = 0..7;
  index16 = 0..15;

  // ��� ������ ARM
  arm_cc = {bl=call,bal=jmp}(eq, ne, cs, hs{=cs}, cc, lo{=cc},
                             mi, pl, vs, vc, hi, ls, ge, lt, gt, le);

const
  ptr_1 = byte_ptr;
  ptr_2 = word_ptr;
  ptr_4 = dword_ptr;
  ptr_8 = qword_ptr;
  ptr_10 = tbyte_ptr;
  ptr_16 = dqword_ptr;

type
  // �������
  EOpcodeLib = class(Exception);

  // ��������� ����
  // ���������� ��� ���������� � �������������� ���������
  TOpcodeHeapState = record
    PoolSize: integer;
    Pool: pointer;
    Current: pointer;
    Margin: integer;
  end;

  // ����������� "��������� ������"
  // (��� ����������� �� ��������)
  TOpcodeHeap = class(TObject)
  private
    FState: TOpcodeHeapState;
    procedure NewPool();
  protected
    function Alloc(const Size: integer): pointer;

    {$ifdef OPCODE_MODES}
    function Format(const FmtStr: ShortString; const Args: array of const): PShortString;
    {$endif}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear();
    procedure SaveState(var HeapState: TOpcodeHeapState);
    procedure RestoreState(const HeapState: TOpcodeHeapState);
  end;

  // ����-"���������"
  TOpcodeGlobal = class;
  TOpcodeVariable = class;
  TOpcodeStorage = class;
  TOpcodeStorage_Intel = class;
  TOpcodeStorage_x86 = class;
  TOpcodeStorage_x64 = class;
  TOpcodeStorage_ARM = class;
  TOpcodeStorage_VM = class;
  POpcodeConst = ^TOpcodeConst;
  POpcodeAddress = ^TOpcodeAddress;
  TOpcodeProc = class;
  TOpcodeProc_Intel = class;
  TOpcodeProc_x86 = class;
  TOpcodeProc_x64 = class;
  TOpcodeProc_ARM = class;
  TOpcodeProc_VM = class;
  POpcodeCmd = ^TOpcodeCmd;
  POpcodeBlock = ^TOpcodeBlock;
  POpcodeBinaryBlock = ^TOpcodeBinaryBlock;
  POpcodeSwitchBlock = ^TOpcodeSwitchBlock;
  POpcodeBlock_Intel = ^TOpcodeBlock_Intel;
  POpcodeBlock_x86 = ^TOpcodeBlock_x86;
  POpcodeBlock_x64 = ^TOpcodeBlock_x64;
  POpcodeBlock_ARM = ^TOpcodeBlock_ARM;
  POpcodeBlock_VM = ^TOpcodeBlock_VM;
  TOpcodeProcClass = class of TOpcodeProc;

  // ��� ���������� �� ������
  // �������� ���(������), ��������� ��� "������"
  {$ifdef OPCODE_MODES}
    TOpcodeMode = (omBinary, omAssembler, omHybrid);
  {$endif} 

  // ����� ���������
  const_kind = ((* ������������ ����� *)
                    ckValue,  // �������� �����
                    ckPValue, // ��������� �� �����, ������� ����� ���������� ����� Fixup()
                   (* ������ � ���������� � ������� *)
                   // � �������� �������� ��������� ����� ��������� �� ������ ���������
                   // � ��������� ��������� ���� RET_OFF ��� FIXUPED_BLOCK_SIZE
                   // � �������� �������� ��������� ����� ��������� ����� ��������� ���� "TOpcodeAddress_offset + TOpcodeConst.FKind"
                   // ������� Condition �� OffsetedCondition ����������� � ���
                   // ��� ������ ������� ���������� � ����������� ������� (����������)
                   // � � ���� ����� ���� ��������� ��������� "offset ..."
                   {$ifdef OPCODE_MODES}
                    ckCondition, // RET_OFF ��� FIXUPED_BLOCK_SIZE ��� TOpcodeAddress_offset + TOpcodeConst.FKind
                    ckOffsetedCondition, // �� �� �����, �� ��������� ���������� � ����� ���������� ���������� ��� �������
                   {$endif}
                   (* ����������������� ���� �������� ������ � �������� �������� *)
                   (* ���� ������ ������� �������� ��� �� �� ���������� � ������� *)
                   ckBlock,
                   (* ������ � �������� �������� *)
                   ckVariable
                   {
                      �����!
                      � �������� ����� � �����/��������� �������
                      ��������� ���� �������� integer-�����(Value),
                      ���� [Offsetted]Condition (��� �������)

                      � ������ "��������� �����" Block-�������� ��� ��������� ������
                      ����������������� ������. ���� ��������� - � VariableOffset ������� 0
                      ���� ����������, �� � Variable ������� �������, � � VariableOffset - Reference
                   }
  );


  // ������� ��������� ��� ��������
  // ���������� �������� ����� ������� �� ����
  TOpcodeConst = object
  protected
    // 1 ����
    FKind: const_kind;

    // 8 ���� �� x86 � 12 ���� �� x64
    F: packed record
    case const_kind of
   ckValue: ( case Boolean of
            false: (Value: Integer);
             true: (Value64: Int64);
             );
  ckPValue: ( case Boolean of
            false: (pValue: PInteger);
             true: (pValue64: PInt64);
             );
    {$ifdef OPCODE_MODES}
        ckCondition: (Condition: PAnsiChar);
ckOffsetedCondition: (OffsetedCondition: PAnsiChar);
    {$endif}
           ckBlock: (Block: POpcodeBlock);
        ckVariable: (Variable: TOpcodeVariable; VariableOffset: Integer);
    end;
  public
    property Kind: const_kind read FKind write FKind;

    {ckBlock}
       property Block: POpcodeBlock read F.Block write F.Block;
    {ckVariable}
       property Variable: TOpcodeVariable read F.Variable write F.Variable;
       property VariableOffset: Integer read F.VariableOffset write F.VariableOffset;
    {$ifdef OPCODE_MODES}
    {ckCondition}
       property Condition: PAnsiChar read F.Condition write F.Condition;
    {ckOffsetedCondition}
       property OffsetedCondition: PAnsiChar read F.OffsetedCondition write F.OffsetedCondition;
    {$endif}
  end;


  // ���������, �������� � ���� 32 ������ �����
  const_32 = object(TOpcodeConst)
  public
    {ckValue} property Value: Integer read F.Value write F.Value;
    {ckPValue} property pValue: PInteger read F.pValue write F.pValue;
  end;

  // ���������, �������� � ���� 64 ������ �����
  // (����������� ������ ��� ������� mov �� ��������� x64)
  const_64 = object(TOpcodeConst)
  public
    {ckValue} property Value: Int64 read F.Value64 write F.Value64;
    {ckPValue} property pValue: PInt64 read F.pValue64 write F.pValue64;
  end;


  // ������� ��������� ��� ������
  // ���������� �������� ������� �� ����
  TOpcodeAddress = object
  protected
    F: packed record
    case Integer of
      0: (Bytes: array[0..2] of byte);
      1: (Reg: packed record
          case Integer of
              0: (v: byte);
              1: (x86: reg_x86_addr);
              2: (x64: reg_x64_addr);
              // ?
          end;
          Plus: packed record
            case Integer of
              0: (v: byte);
              1: (x86: reg_x86_addr);
              2: (x64: reg_x64_addr);
              // ?
          end;
          Scale: packed record
            case Integer of
              0: (intel: intel_scale);
              // ?
          end;
         );
    end;

    function IntelInspect(const params: integer{x64}): integer;
  public
    offset: const_32;
  end;


  // ����� ��� ����������� x86
  address_x86 = object(TOpcodeAddress)
  public
    property reg: reg_x86_addr read F.Reg.x86 write F.Reg.x86;
    property scale: intel_scale read F.Scale.intel write F.Scale.intel;
    property plus: reg_x86_addr read F.Plus.x86 write F.Plus.x86;
    {property offset: const_32 read/write}
  end;

  // ����� ��� ����������� x64
  address_x64 = object(TOpcodeAddress)
  public
    property reg: reg_x64_addr read F.Reg.x64 write F.Reg.x64;
    property scale: intel_scale read F.Scale.intel write F.Scale.intel;
    property plus: reg_x64_addr read F.Plus.x64 write F.Plus.x64;
    {property offset: const_32 read/write}
  end;

  // ����� ��� ����������� ARM
  address_ARM = object(TOpcodeAddress)
  private
    // todo
  end;

  // ��� �������
  //
  TOpcodeCmdMode = ( // �������� ������������������ ����
                     cmBinary,
                     // �������, �������������� � ���� ����������(������), � �.�. � ��� �������
                     {$ifdef OPCODE_MODES}
                     cmText,
                     {$endif}
                     // ����������/����������� + ret(n)(0), leave(1), jmp reg(2), jmp mem(3)
                     // �������� ����� ������� ����������� � ���, ��� ���� �������� ������������� ����!
                     // ����� ���� ��� ����������� �������, ���� �������� ����� �������� ����������� ������
                     cmLeave,
                     // �������, ���������� ���������������� ����������(���������� ��� ����) � ������ �������: cmBinary/cmText/cmLeave
                     // � 2� ������� ����� Param ���������� ������������ (� ����������) ������������� ������. � ��������� 6 ����� ���������� TOpcodeCmdMode
                     // Size (Hybrid min/max) ���� ���������� (��� �������� ���������)
                     cmJoined,
                    (* �������� � ������� ���� ����� ��������� ��� ������ ��� �������� ������� � ������ ��� ARM � ������� *)
                     // ������� ��������������� � ����: jcc/jmp/call
                     // call �������� � �������� � ������ ������� ��-�� �������� offset � ��-�� ������ ������� ������
                     // � ������ ������� ������� jmp ���� ����� ��������� �����
                     cmJumpBlock,
                     // ������ ������, ������� ����� ��� �������� case(switch)
                     // � ������������ � ��������� ���� ������ �����
                     // Size ������ �������� ������ ����� �����. ����� ���� ���������� ������ ����� Size div 4
                     cmSwitchBlock,
                     // ����������� (���������) ������������� �������, �����
                     // � �������� ���������(��) �������� ��������� ������� ���������
                     // � ���� ������ � ������ �������� ���������� �������� ������������� ������� (UnpointerCmd)
                     cmPointer
                   );


  // ������� ��������� ��� ���� ������
  TOpcodeCmd = object
  private
    FNext: POpcodeCmd;

    F: packed record
    case Integer of
      0: (Value: integer);
      {$ifdef OPCODE_MODES}
      1: (HybridSize_MinMax: word);
      2: (HybridSize_Min: byte; HybridSize_Max: byte);
      {$endif}
      3: (
            // ������, ������� �������� �������� ������� � ������
            // ��� ��������� ����� ������������� min/max
            // ��� ���������� ������ �� �����������
            // � ������ switch block ������ ���������� * 4(������ ����� ������)
            Size: word;

            case Boolean of
            false: (
              // � ���� ����� ����������� ������� ������������ �������
              // � �������� ������� �������� (��� ��������� ������) � ��������� (��� ����������)
              //
              // �� ���� ������ ���� ������.
              // ������, call, ret, ...
              Mode: TOpcodeCmdMode;

              // ������ ������� ����� ������������ ������ ���� �� ��� ����������
              //
              // �� �������� � ��������� ������� ���� �� ����������.
              // ��� cmLeave ����������� ������� leave + ����������/�����������
              // ��� cmJumpBlock ����������� ������ ������: cc_ex
              // � ������ cmJoined � 2� ����� ���������� ������������ (� ����������) ������������� ������. � ��������� 6 ����� ���������� TOpcodeCmdMode �������� �������: cmBinary/cmText/cmLeave
              // �� � � cmPointer ����������� boolean-� (0/1), ����� �� ������� ����� ����������: jmp mem (cmLeave) / cmJoined
              case Integer of
                0: (Param: byte);
                1: (cc_ex: shortint); {������ ��� cmJumpBlock}
            );
            true:
            (
              ModeParam: word
            );
         );
    end;       

    // �������������� �������� ���������, �������� ����, ������� ��������
    function NeutralizeFakeConst(const data_offs: integer=0): integer;
  public
    property Next: POpcodeCmd read FNext;
    property Mode: TOpcodeCmdMode read F.Mode;
    property Param: byte read F.Param;

    property Size: word read F.Size;
    {$ifdef OPCODE_MODES}
       property HybridSize_MinMax: word read F.HybridSize_MinMax;
       property HybridSize_Min: byte read F.HybridSize_Min;
       property HybridSize_Max: byte read F.HybridSize_Max;
    {$endif}
  end;

  // ������������� ����
  // ������� ������������ ��� ������ � �������� � �����������
  {$ifdef OPCODE_MODES}
    opused_const_32 = const_32;
  {$else}
    opused_const_32 = integer;
  {$endif}
  {$ifdef OPCODE_MODES}
    opused_const_64 = const_64;
  {$else}
    opused_const_64 = int64;
  {$endif}
  opused_callback_0{const} = function (const params: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};
  opused_callback_1{addr} = function (const params: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};
  opused_callback_2{addr,const} = function (const params: integer; const addr: TOpcodeAddress; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};
  opused_callback_3{const x64. ������ ��� mov} = function (const params: integer; const v_const: opused_const_64{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};


  // ��������� ������������������ ������
  TOpcodeBlock = object
  protected
    // ������ ������ � ����� (� �������� �������)
    // ��� ����� ������ � ������ ������� �����������������
    CmdList: POpcodeCmd;
    function AddCmd(const CmdMode: TOpcodeCmdMode; const SizeCorrection: integer=0): POpcodeCmd;

    {$ifdef OPCODE_MODES}
    function AddCmdText(const Str: PShortString): POpcodeCmd{POpcodeCmdText}; overload;
    function AddCmdText(const FmtStr: ShortString; const Args: array of const): POpcodeCmd{POpcodeCmdText}; overload;
    {$endif}

    // ������������ � ������� ���������������� ����������
    // �� �����(��) �/��� ����������(��), ������� ��� �������� ������ ��������
    // ��� ������� ����� �������� 4�������� (� x86 � x64) ���������� � ������������� �������� ������
    // ������� ����� �������� � ����������� �� ������ ������� ��� ������ ���������� ��������
    procedure JoinCmdCellData(const relative: boolean; const v_const: TOpcodeConst); overload;
    procedure JoinCmdCellData(const mode: byte; const v_addr, v_const: TOpcodeConst); overload;

    // ������ ��� ������, ������������ ��� ��������
    // ����� �������� ����� �������� ������ �� ����� ��������
    function AddCmdPointer(params: integer; pvalue: pointer; addr_kind: integer; callback, diffcmd: pointer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd{POpcodeCmdPointer};

    // ������� jcc(intel_cc), jmp(-1), call(-2)
    // ��� ������� �������� ��� ��������� ARM
    function cmd_jump_block(const cc_ex: shortint; const Block: POpcodeBlock): POpcodeCmd{POpcodeCmdJumpBlock};

    // ��������� ������� jcc(intel_cc), jmp(-1), call(-2) � ���������� ��������
    // ��� ������� �������� ��� ��������� ARM
    {$ifdef OPCODE_MODES}
    function cmd_textjump_proc(const cc_ex: shortint; const ProcName: pansichar): POpcodeCmd{POpcodeCmdJumpBlock};
    {$endif}

  protected
    P: record
    case integer of
      0: (Proc: TOpcodeProc);
      1: (Proc_x86: TOpcodeProc_x86);
      2: (Proc_x64: TOpcodeProc_x64);
      3: (Proc_ARM: TOpcodeProc_ARM);
      4: (Proc_VM: TOpcodeProc_VM);
    end;
    N: record
    case integer of
      0: (Next: POpcodeBlock);
      1: (Next_x86: POpcodeBlock_x86);
      2: (Next_x64: POpcodeBlock_x64);
      3: (Next_ARM: POpcodeBlock_ARM);
      4: (Next_VM: POpcodeBlock_VM);
    end;

    O: packed record
    case Boolean of
     false: (Value: integer);
      true: (
             Fixuped: word; // ����������� ����� �������������� ����� � ������� ��� ��������. �� ��������� NO_FIXUPED
             Reference: word; // ������� �����-�������������, ����������� ��������� �� ���� �����. �� ��������� NO_REFERENCE
            );
    end;
  protected
    // �������� ���� ����� Self � Next
    function AppendBlock(const ResultSize: integer): POpcodeBlock;
  public
    // ������� �������� � switch-������
    function AppendBinaryBlock(const Size: {word}integer): POpcodeBinaryBlock;
    function AppendSwitchBlock(const Count: {�� byte}integer): POpcodeSwitchBlock;

    // �������������� ���� ��� ��������� ��� ������� ���������
    // � ��������� ���� ����� ������������ ��� ���� ����� �������� ���������� ����� ������� (��� �������������)
    function MakeReference(): word;
  end;

  
  // ���� �������� ������
  // ����� �������������� ��� ������ �����
  TOpcodeBinaryBlock = object(TOpcodeBlock)
  private
    FSize: integer;
    Cmd: TOpcodeCmd;
  public
    // ������
    Data: record
    case Integer of
      0: (Bytes: array[word] of byte);
      1: (Words: array[word] of word);
      2: (Dwords: array[word] of dword);
      3: (Ints64: array[word] of int64);
    end;
  public
    // ������  
    property Size: integer read FSize;    
  end;

  // ���� ���������� �� �����
  // ������������ ��� ���������� case(switch)
  TOpcodeSwitchBlock = object(TOpcodeBlock)
  private
    FCount: integer;
    Cmd: TOpcodeCmd;
  public
    // �����
    Blocks: array[word] of POpcodeBlock;
  public
    // ����������
    property Count: integer read FCount;
  end;


  // ������������������ ������
  // ����� ����� ��� ��������� x32-64
  TOpcodeBlock_Intel = object(TOpcodeBlock)
  private
    // ����� ������ � ����������� Intel ����� �������
    // ��������� �� ���:
    // - �������� ����������� ���������� ������ ��� �������
    // - �������������� � ������� �������� �������
    // - �������� ��� ��������
    // - ����� ������� (1 ��� 2 ����)
    // - ������ Advanced (��� ����� ���� ��������� ��� �����-�� �������������� ������)
    //
    // ������:
    // 4 ������� ���� - ����� ���������
    // 4 ���� - �������� REX
    // 1 ��� 2 ����� - ����� �������
    // 1 ������� ���� - �������������� ������. ��� ����� ���� �������� ��������� ��� ������ ������
    function AddSmartBinaryCmd(Parameters, Advanced: integer): POpcodeCmd;

    // ��������������� ������� ��� �������
    // ��������� ���������� Min_Max �� ����������
    {$ifdef OPCODE_MODES}
    function HybridSize_MinMax(base_params, Parameters{�������� �������� ��� AddSmartBinaryCmd}: integer; addr: POpcodeAddress): integer{word};
    {$endif}
  private
     // ���� �������������(�������) �������, ������� ���������� �� PRE-�������
     // ����� ���� ����� ���������� � TOpcodeBlock

     procedure diffcmd_const32(params: integer; const v_const: const_32; callback: opused_callback_0{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
     procedure diffcmd_addr(params: integer; const addr: TOpcodeAddress; callback: opused_callback_1{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
     procedure diffcmd_addr_const(params: integer; const addr: TOpcodeAddress; const v_const: const_32; callback: opused_callback_2{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
     procedure diffcmd_const64(params: integer; const v_const: const_64; callback: opused_callback_3{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
  private
    // ���� �������
    // �������� emms | ud2
    function cmd_single(const opcode: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;

    // ���������� ������� (r)esi-(r)edi
    // �������� movsb(/w/d/q) | cmpsb(/w/d/q),
    function cmd_rep_bwdq(const reps: intel_rep{=REP_SINGLE}; opcode: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;

    // ������� � ����� ����������-����������
    // ���� �������� ������ push
    // PRE-���������� �������� �� �����
    function cmd_const_value(const opcode: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;

    // ������� � ����� ����������-���������
    // �������� inc al | push bx | bswap esp | jmp esi
    function cmd_reg(const opcode_reg: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;

    // ���� �������� ����� (��� ������� - �� ���������������)
    // �������� jmp [edx] | call [ebp+4] | fldcw [r12]
    function cmd_addr_value(const opcode: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_cmd_addr(const opcode: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������: ptr, addr
    // �������� dec byte ptr [ecx*4] | push dword ptr [esp]
    function cmd_ptr_addr_value(const base_opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_cmd_ptr_addr(const opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������: reg, reg
    // �������� mov esi, ebx | add bh, cl | test ax, dx
    function cmd_reg_reg(const base_opcode_reg, base_v_reg: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;

    // ��� ���������: reg, const_32
    // �������� cmp edx, 15 | and r8, $ff | test ebx, $0100
    function cmd_reg_const_value(const base_opcode_reg: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_cmd_reg_const(const opcode_reg: integer; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������: reg, const_32 | reg, cl
    // ������ ��� ��������� ������ rcl,rcr,rol,ror,sal,sar,shl,shr
    function shift_reg_const_value(const opcode_reg: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_shift_reg_const(const opcode_reg: integer; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������: reg, addr ��� addr, reg. ����������� ������������ �� ������
    // �������� add esi, [ebp-$14] | xchg [offset variable + ecx*2 + 6], dx
    function cmd_reg_addr_value(const opcode_reg: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_cmd_reg_addr(const opcode_reg: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������: ptr, addr, const_32
    // �������� cmp byte ptr [eax+ebx*2-12], 0 | sbb qword ptr [r12 + rdx], $17
    // ��������� ��� �� ������: rcl,rcr,rol,ror,sal,sar,shl,shr
    function cmd_ptr_addr_const_value(const opcode_ptr: integer; const addr: TOpcodeAddress; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_cmd_ptr_addr_const(const opcode_ptr: integer; const addr: TOpcodeAddress; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������: reg, reg, const_32/cl
    // ������ ������� shld | shrd | imul
    function cmd_reg_reg_const_value(const base_reg1_opcode_reg2: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_cmd_reg_reg_const(const reg1_opcode_reg2: integer; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������(shld,shrd): addr, reg, const_32/cl
    // ��� ��� imul: reg, addr, const_32
    function cmd_addr_reg_const_value(const base_opcode_reg: integer; const addr: TOpcodeAddress; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_cmd_addr_reg_const(const opcode_reg: integer; const addr: TOpcodeAddress; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ��� ���������: reg, reg
    // ��� movzx � movsx
    function movszx_reg_reg(const opcode_reg: integer; v_reg: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;

    // ��� ���������: reg, ptr, addr
    // ��� movzx � movsx
    function movszx_reg_ptr_addr_value(const reg_opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_movszx_reg_ptr_addr(const reg_opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // ������� setcc r8 | cmovcc reg_wd, reg_wd
    function setcmov_cc_regs(const params: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;

    // ������� setcc addr8 | cmovcc reg_wd, addr
    function setcmov_cc_addr_value(const params: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
    procedure PRE_setcmov_cc_addr(const params: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});

    // todo
  public
    (* removed:

       loop/loope/loopne - ������ ��� ������������� ������� � ������������ �� �������� (-128..+127)
    *)


    {todo ��������� � x86 ������ ��� � x64 �� ���}
    procedure aaa;
    procedure aad;
    procedure aam;
    procedure aas;
    procedure daa;
    procedure das;
    {-------------}

    procedure hlt;
    // int (int_0/int_3)
    procedure invd;
    procedure invlpg;
    procedure iret;
    procedure lahf;
    // lar ?

    // lds, les, lfs, lgs, lss ?


    {$ifdef OPCODE_MODES}
    procedure call(ProcName: pansichar);
    procedure j(cc: intel_cc; ProcName: pansichar);
    procedure jmp(ProcName: pansichar);
    {$endif}

    procedure leave;

    // lgdt, lidt

    // lldt

    // lmsw

    // lsl

    // ltr

    procedure pause;

    // popa/popad

    // popf/popfd

    // pusha/pushad

    // pushf/pushd

    procedure push(const v_const: const_32);

    // rdmsr

    // rdpmc

    // rdtsc

    procedure ret(const count: word=0);

    // rsm

    // sahf

    // sfrence

    // sldt

    // smsw

    // stc

    // std

    // sti

    // str

    // sysenter

    // sysexit

    procedure ud2;

    // verr/verw

    procedure wait;
    procedure fwait;


    // wbinvd

    // wrmsr

    // xlat, xlatb (��� ������ x64?)

    (* ���������� ������� *)

    procedure cmpsb(reps: intel_rep=REP_SINGLE);
    procedure cmpsw(reps: intel_rep=REP_SINGLE);
    procedure cmpsd(reps: intel_rep=REP_SINGLE);

    procedure insb(reps: intel_rep=REP_SINGLE);
    procedure insw(reps: intel_rep=REP_SINGLE);
    procedure insd(reps: intel_rep=REP_SINGLE);

    procedure scasb(reps: intel_rep=REP_SINGLE);
    procedure scasw(reps: intel_rep=REP_SINGLE);
    procedure scasd(reps: intel_rep=REP_SINGLE);

    procedure stosb(reps: intel_rep=REP_SINGLE);
    procedure stosw(reps: intel_rep=REP_SINGLE);
    procedure stosd(reps: intel_rep=REP_SINGLE);

    procedure lodsb(reps: intel_rep=REP_SINGLE);
    procedure lodsw(reps: intel_rep=REP_SINGLE);
    procedure lodsd(reps: intel_rep=REP_SINGLE);

    procedure movsb(reps: intel_rep=REP_SINGLE);
    procedure movsw(reps: intel_rep=REP_SINGLE);
    procedure movsd(reps: intel_rep=REP_SINGLE);


    (* ������� ������������ *)
    {�������� �� ���� ��������� x64 !!!}

    procedure f2xm1;
    procedure fabs;

    procedure fadd(d, s: index8); overload;
    procedure fadd(ptr: size_ptr; const addr: address_x86); overload;
    procedure faddp(st: index8=1);
    procedure fiadd(ptr: size_ptr; const addr: address_x86);

    procedure fchs;

    procedure fclex;
    procedure fnclex;

    procedure fcmov(cc: intel_cc; st_dest: index8);

    procedure fcom(st: index8=1); overload;
    procedure fcom(ptr: size_ptr; const addr: address_x86); overload;
    procedure fcomp(st: index8=1); overload;
    procedure fcomp(ptr: size_ptr; const addr: address_x86); overload;
    procedure fcompp;

    procedure ficom(ptr: size_ptr; const addr: address_x86);
    procedure ficomp(ptr: size_ptr; const addr: address_x86);

    procedure fcomi(st: index8=1);
    procedure fcomip(st: index8=1);
    procedure fucomi(st: index8=1);
    procedure fucomip(st: index8=1);

    procedure fucom(st: index8=1); overload;
    procedure fucom(ptr: size_ptr; const addr: address_x86); overload;
    procedure fucomp(st: index8=1); overload;
    procedure fucomp(ptr: size_ptr; const addr: address_x86); overload;
    procedure fucompp;

    procedure fsin;
    procedure fcos;
    procedure fsincos;

    procedure fdecstp;
    procedure fincstp;

    procedure fdiv(d, s: index8); overload;
    procedure fdiv(ptr: size_ptr; const addr: address_x86); overload;
    procedure fdivp(st: index8=1);
    procedure fidiv(ptr: size_ptr; const addr: address_x86);

    procedure fdivr(d, s: index8); overload;
    procedure fdivr(ptr: size_ptr; const addr: address_x86); overload;
    procedure fdivrp(st: index8=1);
    procedure fidivr(ptr: size_ptr; const addr: address_x86);

    procedure ffree;

    procedure fild(ptr: size_ptr; const addr: address_x86);

    // finit/fninit

    procedure fist(ptr: size_ptr; const addr: address_x86);
    procedure fistp(ptr: size_ptr; const addr: address_x86);

    procedure fld1;
    procedure fldl2t;
    procedure fldl2e;
    procedure fldlg2;
    procedure fldln2;
    procedure fldpi;
    procedure fldz;

    procedure fld(st: index8=1); overload;
    procedure fld(ptr: size_ptr; const addr: address_x86); overload;

    procedure fmul(d, s: index8); overload;
    procedure fmul(ptr: size_ptr; const addr: address_x86); overload;
    procedure fmulp(st: index8=1);
    procedure fimul(ptr: size_ptr; const addr: address_x86);

    procedure fnop;

    procedure fptan;
    procedure fpatan;

    procedure fprem;
    procedure fprem1;

    procedure frndint;

    procedure frstor;

    procedure fscale;
    procedure fsqrt;

    procedure fst(st: index8=1); overload;
    procedure fst(ptr: size_ptr; const addr: address_x86); overload;
    procedure fstp(st: index8=1); overload;
    procedure fstp(ptr: size_ptr; const addr: address_x86); overload;

    procedure fstsw_ax;
    procedure fnstsw_ax;

    procedure fsub(d, s: index8); overload;
    procedure fsub(ptr: size_ptr; const addr: address_x86); overload;
    procedure fsubp(st: index8=1);
    procedure fisub(ptr: size_ptr; const addr: address_x86);

    procedure fsubr(d, s: index8); overload;
    procedure fsubr(ptr: size_ptr; const addr: address_x86); overload;
    procedure fsubrp(st: index8=1);
    procedure fisubr(ptr: size_ptr; const addr: address_x86);

    procedure ftst;

    procedure fxam;

    procedure fxch(st: index8=1);

    procedure fxtract;
    procedure fyl2x;
    procedure fyl2xp1;


    (* todo MMX, SSE*)

  end;

  // ������������������ ������
  // ����������� x86
  TOpcodeBlock_x86 = object(TOpcodeBlock_Intel)
  public
    property Proc: TOpcodeProc_x86 read P.Proc_x86;
    property Next: POpcodeBlock_x86 read N.Next_x86 write N.Next_x86;
  public
    function AppendBlock(): POpcodeBlock_x86;

    procedure adc(reg: reg_x86; v_reg: reg_x86); overload;
    procedure adc(reg: reg_x86; const v_const: const_32); overload;
    procedure adc(reg: reg_x86; const addr: address_x86); overload;
    procedure adc(const addr: address_x86; v_reg: reg_x86); overload;
    procedure adc(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;
    procedure lock_adc(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_adc(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure add(reg: reg_x86; v_reg: reg_x86); overload;
    procedure add(reg: reg_x86; const v_const: const_32); overload;
    procedure add(reg: reg_x86; const addr: address_x86); overload;
    procedure add(const addr: address_x86; v_reg: reg_x86); overload;
    procedure add(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;
    procedure lock_add(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_add(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure and_(reg: reg_x86; v_reg: reg_x86); overload;
    procedure and_(reg: reg_x86; const v_const: const_32); overload;
    procedure and_(reg: reg_x86; const addr: address_x86); overload;
    procedure and_(const addr: address_x86; v_reg: reg_x86); overload;
    procedure and_(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;
    procedure lock_and(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_and(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure bswap(reg: reg_x86_dwords);

    //procedure bsf(dest: reg_x86_wd; src: reg_x86_wd); overload;
    //procedure bsf(dest: reg_x86_wd; const addr: address_x86); overload;
    // bt
    // btc
    // btr
    // bts
    // *lock

    procedure call(block: POpcodeBlock_x86); overload;
    procedure call(blocks: POpcodeSwitchBlock; index: reg_x86_addr; offset: integer=0); overload;
    procedure call(reg: reg_x86_addr); overload;
    procedure call(const addr: address_x86); overload;

    // cbw
    // cwde
    // cwd
    // cdq

    // clc
    // cld
    // cli
    // clts
    // cmc
    // clflush ?

    procedure cmov(cc: intel_cc; reg: reg_x86_wd; v_reg: reg_x86_wd); overload;
    procedure cmov(cc: intel_cc; reg: reg_x86_wd; const addr: address_x86); overload;

    procedure cmp(reg: reg_x86; v_reg: reg_x86); overload;
    procedure cmp(reg: reg_x86; const v_const: const_32); overload;
    procedure cmp(reg: reg_x86; const addr: address_x86); overload;
    procedure cmp(const addr: address_x86; v_reg: reg_x86); overload;
    procedure cmp(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    // cmpxchg

    // cmpxchg8b

    // cpuid

    procedure dec(reg: reg_x86); overload;
    procedure dec(ptr: size_ptr; const addr: address_x86); overload;
    procedure lock_dec(ptr: size_ptr; const addr: address_x86);

    procedure div_(reg: reg_x86); overload;
    procedure div_(ptr: size_ptr; const addr: address_x86); overload;

    // enter

    procedure idiv(reg: reg_x86); overload;
    procedure idiv(ptr: size_ptr; const addr: address_x86); overload;

    procedure imul(reg: reg_x86); overload;
    procedure imul(ptr: size_ptr; const addr: address_x86); overload;
    procedure imul(reg: reg_x86_wd; v_reg: reg_x86_wd); overload;
    procedure imul(reg: reg_x86_wd; const addr: address_x86); overload;
    procedure imul(reg: reg_x86_wd; const v_const: const_32); overload;
    procedure imul(reg1, reg2: reg_x86_wd; const v_const: const_32); overload;
    procedure imul(reg: reg_x86_wd; const addr: address_x86; const v_const: const_32); overload;

    // in

    procedure inc(reg: reg_x86); overload;
    procedure inc(ptr: size_ptr; const addr: address_x86); overload;
    procedure lock_inc(ptr: size_ptr; const addr: address_x86);

    procedure j(cc: intel_cc; block: POpcodeBlock_x86);

    procedure jmp(block: POpcodeBlock_x86); overload;
    procedure jmp(blocks: POpcodeSwitchBlock; index: reg_x86_addr; offset: integer=0); overload;
    procedure jmp(reg: reg_x86_addr); overload;
    procedure jmp(const addr: address_x86); overload;

    procedure lea(reg: reg_x86_addr; const addr: address_x86);

    procedure mov(reg: reg_x86; v_reg: reg_x86); overload;
    procedure mov(reg: reg_x86; const v_const: const_32); overload;
    procedure mov(reg: reg_x86; const addr: address_x86); overload;
    procedure mov(const addr: address_x86; v_reg: reg_x86); overload;
    procedure mov(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure movsx(reg: reg_x86; v_reg: reg_x86); overload;
    procedure movsx(reg: reg_x86; ptr: size_ptr; const addr: address_x86); overload;
    
    procedure movzx(reg: reg_x86; v_reg: reg_x86); overload;
    procedure movzx(reg: reg_x86; ptr: size_ptr; const addr: address_x86); overload;

    procedure mul(reg: reg_x86); overload;
    procedure mul(ptr: size_ptr; const addr: address_x86); overload;

    procedure neg(reg: reg_x86); overload;
    procedure neg(ptr: size_ptr; const addr: address_x86); overload;
    procedure lock_neg(ptr: size_ptr; const addr: address_x86);

    // nop(count)

    procedure not_(reg: reg_x86); overload;
    procedure not_(ptr: size_ptr; const addr: address_x86); overload;
    procedure lock_not(ptr: size_ptr; const addr: address_x86);

    procedure or_(reg: reg_x86; v_reg: reg_x86); overload;
    procedure or_(reg: reg_x86; const v_const: const_32); overload;
    procedure or_(reg: reg_x86; const addr: address_x86); overload;
    procedure or_(const addr: address_x86; v_reg: reg_x86); overload;
    procedure or_(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;
    procedure lock_or(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_or(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure pop(reg: reg_x86_wd); overload;
    procedure pop(ptr: size_ptr; const addr: address_x86); overload;

    // prefetch0/prefetch1/prefetch2/prefetchnta ?

    procedure push(reg: reg_x86_wd); overload;
    procedure push(ptr: size_ptr; const addr: address_x86); overload;

    procedure rcl_cl(reg: reg_x86); overload;
    procedure rcl(reg: reg_x86; const v_const: const_32); overload;
    procedure rcl_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure rcl(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure rcr_cl(reg: reg_x86); overload;
    procedure rcr(reg: reg_x86; const v_const: const_32); overload;
    procedure rcr_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure rcr(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure rol_cl(reg: reg_x86); overload;
    procedure rol(reg: reg_x86; const v_const: const_32); overload;
    procedure rol_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure rol(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure ror_cl(reg: reg_x86); overload;
    procedure ror(reg: reg_x86; const v_const: const_32); overload;
    procedure ror_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure ror(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure sal_cl(reg: reg_x86); overload;
    procedure sal(reg: reg_x86; const v_const: const_32); overload;
    procedure sal_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure sal(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure sar_cl(reg: reg_x86); overload;
    procedure sar(reg: reg_x86; const v_const: const_32); overload;
    procedure sar_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure sar(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure sbb(reg: reg_x86; v_reg: reg_x86); overload;
    procedure sbb(reg: reg_x86; const v_const: const_32); overload;
    procedure sbb(reg: reg_x86; const addr: address_x86); overload;
    procedure sbb(const addr: address_x86; v_reg: reg_x86); overload;
    procedure sbb(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;
    procedure lock_sbb(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_sbb(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure set_(cc: intel_cc; reg: reg_x86_bytes); overload;
    procedure set_(cc: intel_cc; const addr: address_x86); overload;

    procedure shl_cl(reg: reg_x86); overload;
    procedure shl_(reg: reg_x86; const v_const: const_32); overload;
    procedure shl_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure shl_(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure shr_cl(reg: reg_x86); overload;
    procedure shr_(reg: reg_x86; const v_const: const_32); overload;
    procedure shr_cl(ptr: size_ptr; const addr: address_x86); overload;
    procedure shr_(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure shld_cl(reg1, reg2: reg_x86); overload;
    procedure shld(reg1, reg2: reg_x86; const v_const: const_32); overload;
    procedure shld_cl(const addr: address_x86; reg2: reg_x86); overload;
    procedure shld(const addr: address_x86; reg2: reg_x86; const v_const: const_32); overload;

    procedure shrd_cl(reg1, reg2: reg_x86); overload;
    procedure shrd(reg1, reg2: reg_x86; const v_const: const_32); overload;
    procedure shrd_cl(const addr: address_x86; reg2: reg_x86); overload;
    procedure shrd(const addr: address_x86; reg2: reg_x86; const v_const: const_32); overload;

    procedure sub(reg: reg_x86; v_reg: reg_x86); overload;
    procedure sub(reg: reg_x86; const v_const: const_32); overload;
    procedure sub(reg: reg_x86; const addr: address_x86); overload;
    procedure sub(const addr: address_x86; v_reg: reg_x86); overload;
    procedure sub(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;
    procedure lock_sub(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_sub(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure test(reg: reg_x86; v_reg: reg_x86); overload;
    procedure test(reg: reg_x86; const v_const: const_32); overload;
    procedure test(reg: reg_x86; const addr: address_x86); overload;
    procedure test(const addr: address_x86; v_reg: reg_x86); overload;
    procedure test(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    procedure xadd(reg: reg_x86; v_reg: reg_x86); overload;
    procedure xadd(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_xadd(const addr: address_x86; v_reg: reg_x86);

    procedure xchg(reg: reg_x86; v_reg: reg_x86); overload;
    procedure xchg(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_xchg(const addr: address_x86; v_reg: reg_x86);

    procedure xor_(reg: reg_x86; v_reg: reg_x86); overload;
    procedure xor_(reg: reg_x86; const v_const: const_32); overload;
    procedure xor_(reg: reg_x86; const addr: address_x86); overload;
    procedure xor_(const addr: address_x86; v_reg: reg_x86); overload;
    procedure xor_(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;
    procedure lock_xor(const addr: address_x86; v_reg: reg_x86); overload;
    procedure lock_xor(ptr: size_ptr; const addr: address_x86; const v_const: const_32); overload;

    // FPU � ������
    procedure fbld(const addr: address_x86);
    procedure fbstp(const addr: address_x86);
    procedure fldcw(const addr: address_x86);
    procedure fldenv(const addr: address_x86);
    procedure fsave(const addr: address_x86);
    procedure fnsave(const addr: address_x86);
    procedure fstcw(const addr: address_x86);
    procedure fnstcw(const addr: address_x86);
    procedure fstenv(const addr: address_x86);
    procedure fnstenv(const addr: address_x86);
    procedure fstsw(const addr: address_x86);
    procedure fnstsw(const addr: address_x86);
  end;

  // ������������������ ������
  // ����������� x64
  TOpcodeBlock_x64 = object(TOpcodeBlock_Intel)
  private
    // ��� ���������: reg, const_64
    // ���� ����������� ������ ��� mov
    // PRE-���������� �������� �� �����
    function cmd_reg_const_value64(const opcode_reg: integer; const v_const: opused_const_64{$ifdef OPCODE_MODES}; const cmd: ShortString{$endif}): POpcodeCmd;
  public
    property Proc: TOpcodeProc_x64 read P.Proc_x64;
    property Next: POpcodeBlock_x64 read N.Next_x64 write N.Next_x64;
  public
    function AppendBlock(): POpcodeBlock_x64;

    procedure adc(reg: reg_x64; v_reg: reg_x64); overload;
    procedure adc(reg: reg_x64; const v_const: const_32); overload;
    procedure adc(reg: reg_x64; const addr: address_x64); overload;
    procedure adc(const addr: address_x64; v_reg: reg_x64); overload;
    procedure adc(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure lock_adc(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_adc(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure add(reg: reg_x64; v_reg: reg_x64); overload;
    procedure add(reg: reg_x64; const v_const: const_32); overload;
    procedure add(reg: reg_x64; const addr: address_x64); overload;
    procedure add(const addr: address_x64; v_reg: reg_x64); overload;
    procedure add(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure lock_add(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_add(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure and_(reg: reg_x64; v_reg: reg_x64); overload;
    procedure and_(reg: reg_x64; const v_const: const_32); overload;
    procedure and_(reg: reg_x64; const addr: address_x64); overload;
    procedure and_(const addr: address_x64; v_reg: reg_x64); overload;
    procedure and_(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure lock_and(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_and(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure bswap(reg: reg_x64_dq);

    //procedure bsf(dest: reg_x64_wd; src: reg_x64_wd); overload;
    //procedure bsf(dest: reg_x64_wd; const addr: address_x64); overload;
    // bt
    // btc
    // btr
    // bts
    // *lock

    procedure call(block: POpcodeBlock_x64); overload;
    procedure call(blocks: POpcodeSwitchBlock; index: reg_x64_addr; offset: integer=0{$ifdef OPCODE_MODES};buffer: reg_x64_addr=r11{$endif}); overload;
    procedure call(reg: reg_x64_addr); overload;
    procedure call(const addr: address_x64); overload;

    // cbw
    // cwde
    // cwd
    // cdq

    // clc
    // cld
    // cli
    // clts
    // cmc
    // clflush ?

    procedure cmov(cc: intel_cc; reg: reg_x64_wdq; v_reg: reg_x64_wdq); overload;
    procedure cmov(cc: intel_cc; reg: reg_x64_wdq; const addr: address_x64); overload;

    procedure cmp(reg: reg_x64; v_reg: reg_x64); overload;
    procedure cmp(reg: reg_x64; const v_const: const_32); overload;
    procedure cmp(reg: reg_x64; const addr: address_x64); overload;
    procedure cmp(const addr: address_x64; v_reg: reg_x64); overload;
    procedure cmp(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    // cmpxchg

    // cmpxchg8b

    // cpuid

    procedure dec(reg: reg_x64); overload;
    procedure dec(ptr: size_ptr; const addr: address_x64); overload;
    procedure lock_dec(ptr: size_ptr; const addr: address_x64);

    procedure div_(reg: reg_x64); overload;
    procedure div_(ptr: size_ptr; const addr: address_x64); overload;

    // enter

    procedure idiv(reg: reg_x64); overload;
    procedure idiv(ptr: size_ptr; const addr: address_x64); overload;

    procedure imul(reg: reg_x64); overload;
    procedure imul(ptr: size_ptr; const addr: address_x64); overload;
    procedure imul(reg: reg_x64_wdq; v_reg: reg_x64_wdq); overload;
    procedure imul(reg: reg_x64_wdq; const addr: address_x64); overload;
    procedure imul(reg: reg_x64_wdq; const v_const: const_32); overload;
    procedure imul(reg1, reg2: reg_x64_wdq; const v_const: const_32); overload;
    procedure imul(reg: reg_x64_wdq; const addr: address_x64; const v_const: const_32); overload;

    // in

    procedure inc(reg: reg_x64); overload;
    procedure inc(ptr: size_ptr; const addr: address_x64); overload;
    procedure lock_inc(ptr: size_ptr; const addr: address_x64);

    procedure j(cc: intel_cc; block: POpcodeBlock_x64);

    procedure jmp(block: POpcodeBlock_x64); overload;
    procedure jmp(blocks: POpcodeSwitchBlock; index: reg_x64_addr; offset: integer=0{$ifdef OPCODE_MODES};buffer: reg_x64_addr=r11{$endif}); overload;
    procedure jmp(reg: reg_x64_addr); overload;
    procedure jmp(const addr: address_x64); overload;

    procedure lea(reg: reg_x64_addr; const addr: address_x64);

    procedure mov(reg: reg_x64; v_reg: reg_x64); overload;
    procedure mov(reg: reg_x64; const v_const: const_32); overload;
    procedure mov(reg: reg_x64; const addr: address_x64); overload;
    procedure mov(const addr: address_x64; v_reg: reg_x64); overload;
    procedure mov(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure mov(reg: reg_x64{reg_x64_dwords}; const v_const: const_64); overload;

    procedure movsx(reg: reg_x64; v_reg: reg_x64); overload;
    procedure movsx(reg: reg_x64; ptr: size_ptr; const addr: address_x64); overload;
    
    procedure movzx(reg: reg_x64; v_reg: reg_x64); overload;
    procedure movzx(reg: reg_x64; ptr: size_ptr; const addr: address_x64); overload;

    procedure mul(reg: reg_x64); overload;
    procedure mul(ptr: size_ptr; const addr: address_x64); overload;

    procedure neg(reg: reg_x64); overload;
    procedure neg(ptr: size_ptr; const addr: address_x64); overload;
    procedure lock_neg(ptr: size_ptr; const addr: address_x64);

    // nop(count)

    procedure not_(reg: reg_x64); overload;
    procedure not_(ptr: size_ptr; const addr: address_x64); overload;
    procedure lock_not(ptr: size_ptr; const addr: address_x64);

    procedure or_(reg: reg_x64; v_reg: reg_x64); overload;
    procedure or_(reg: reg_x64; const v_const: const_32); overload;
    procedure or_(reg: reg_x64; const addr: address_x64); overload;
    procedure or_(const addr: address_x64; v_reg: reg_x64); overload;
    procedure or_(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure lock_or(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_or(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure pop(reg: reg_x64_wq); overload;
    procedure pop(ptr: size_ptr; const addr: address_x64); overload;

    // prefetch0/prefetch1/prefetch2/prefetchnta ?

    procedure push(reg: reg_x64_wq); overload;
    procedure push(ptr: size_ptr; const addr: address_x64); overload;

    procedure rcl_cl(reg: reg_x64); overload;
    procedure rcl(reg: reg_x64; const v_const: const_32); overload;
    procedure rcl_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure rcl(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure rcr_cl(reg: reg_x64); overload;
    procedure rcr(reg: reg_x64; const v_const: const_32); overload;
    procedure rcr_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure rcr(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure rol_cl(reg: reg_x64); overload;
    procedure rol(reg: reg_x64; const v_const: const_32); overload;
    procedure rol_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure rol(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure ror_cl(reg: reg_x64); overload;
    procedure ror(reg: reg_x64; const v_const: const_32); overload;
    procedure ror_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure ror(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure sal_cl(reg: reg_x64); overload;
    procedure sal(reg: reg_x64; const v_const: const_32); overload;
    procedure sal_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure sal(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure sar_cl(reg: reg_x64); overload;
    procedure sar(reg: reg_x64; const v_const: const_32); overload;
    procedure sar_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure sar(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure sbb(reg: reg_x64; v_reg: reg_x64); overload;
    procedure sbb(reg: reg_x64; const v_const: const_32); overload;
    procedure sbb(reg: reg_x64; const addr: address_x64); overload;
    procedure sbb(const addr: address_x64; v_reg: reg_x64); overload;
    procedure sbb(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure lock_sbb(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_sbb(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure set_(cc: intel_cc; reg: reg_x64_bytes); overload;
    procedure set_(cc: intel_cc; const addr: address_x64); overload;

    procedure shl_cl(reg: reg_x64); overload;
    procedure shl_(reg: reg_x64; const v_const: const_32); overload;
    procedure shl_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure shl_(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure shr_cl(reg: reg_x64); overload;
    procedure shr_(reg: reg_x64; const v_const: const_32); overload;
    procedure shr_cl(ptr: size_ptr; const addr: address_x64); overload;
    procedure shr_(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure shld_cl(reg1, reg2: reg_x64); overload;
    procedure shld(reg1, reg2: reg_x64; const v_const: const_32); overload;
    procedure shld_cl(const addr: address_x64; reg2: reg_x64); overload;
    procedure shld(const addr: address_x64; reg2: reg_x64; const v_const: const_32); overload;

    procedure shrd_cl(reg1, reg2: reg_x64); overload;
    procedure shrd(reg1, reg2: reg_x64; const v_const: const_32); overload;
    procedure shrd_cl(const addr: address_x64; reg2: reg_x64); overload;
    procedure shrd(const addr: address_x64; reg2: reg_x64; const v_const: const_32); overload;

    procedure sub(reg: reg_x64; v_reg: reg_x64); overload;
    procedure sub(reg: reg_x64; const v_const: const_32); overload;
    procedure sub(reg: reg_x64; const addr: address_x64); overload;
    procedure sub(const addr: address_x64; v_reg: reg_x64); overload;
    procedure sub(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure lock_sub(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_sub(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure test(reg: reg_x64; v_reg: reg_x64); overload;
    procedure test(reg: reg_x64; const v_const: const_32); overload;
    procedure test(reg: reg_x64; const addr: address_x64); overload;
    procedure test(const addr: address_x64; v_reg: reg_x64); overload;
    procedure test(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure xadd(reg: reg_x64; v_reg: reg_x64); overload;
    procedure xadd(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_xadd(const addr: address_x64; v_reg: reg_x64);

    procedure xchg(reg: reg_x64; v_reg: reg_x64); overload;
    procedure xchg(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_xchg(const addr: address_x64; v_reg: reg_x64);

    procedure xor_(reg: reg_x64; v_reg: reg_x64); overload;
    procedure xor_(reg: reg_x64; const v_const: const_32); overload;
    procedure xor_(reg: reg_x64; const addr: address_x64); overload;
    procedure xor_(const addr: address_x64; v_reg: reg_x64); overload;
    procedure xor_(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;
    procedure lock_xor(const addr: address_x64; v_reg: reg_x64); overload;
    procedure lock_xor(ptr: size_ptr; const addr: address_x64; const v_const: const_32); overload;

    procedure cmpsq(reps: intel_rep=REP_SINGLE);
    procedure insq(reps: intel_rep=REP_SINGLE);
    procedure scasq(reps: intel_rep=REP_SINGLE);
    procedure stosq(reps: intel_rep=REP_SINGLE);
    procedure lodsq(reps: intel_rep=REP_SINGLE);
    procedure movsq(reps: intel_rep=REP_SINGLE);

    // FPU � ������
    procedure fbld(const addr: address_x64);
    procedure fbstp(const addr: address_x64);
    procedure fldcw(const addr: address_x64);
    procedure fldenv(const addr: address_x64);
    procedure fsave(const addr: address_x64);
    procedure fnsave(const addr: address_x64);
    procedure fstcw(const addr: address_x64);
    procedure fnstcw(const addr: address_x64);
    procedure fstenv(const addr: address_x64);
    procedure fnstenv(const addr: address_x64);
    procedure fstsw(const addr: address_x64);
    procedure fnstsw(const addr: address_x64); 
  end;


  // ������������������ ������
  // ����������� ARM
  TOpcodeBlock_ARM = object(TOpcodeBlock)
  private

  public
    property Proc: TOpcodeProc_ARM read P.Proc_ARM;
    property Next: POpcodeBlock_ARM read N.Next_ARM write N.Next_ARM;
  public
    function AppendBlock(): POpcodeBlock_ARM;

    procedure b{jmp}(block: POpcodeBlock_ARM); overload;
    procedure b{jcc}(cc: arm_cc; block: POpcodeBlock_ARM); overload;
    procedure bl{call}(block: POpcodeBlock_ARM); overload;

    {$ifdef OPCODE_MODES}
    procedure b{jmp}(ProcName: pansichar); overload;
    procedure b{jcc}(cc: arm_cc; ProcName: pansichar); overload;
    procedure bl{call}(ProcName: pansichar); overload;
    {$endif}



  end;


  // ������������������ ������
  // � ����������� ������
  TOpcodeBlock_VM = object(TOpcodeBlock)
  private

  public
    property Proc: TOpcodeProc_VM read P.Proc_VM;
    property Next: POpcodeBlock_VM read N.Next_VM write N.Next_VM;
  public

    function AppendBlock(): POpcodeBlock_VM;
  end;


  //  ������� �������� ����������� �������
  POpcodeSubscribe = ^TOpcodeSubscribe;
  TOpcodeSubscribe = record
    // ����������� ������
    Next: POpcodeSubscribe;
    // ��� ������
    case Integer of
      0: (Global: TOpcodeGlobal);
      1: (Proc: TOpcodeProc);
      2: (Variable: TOpcodeVariable);

      100500: (Block: POpcodeBlock{����� ������ �������� �������}); 
  end;

  // ������ ����������� ������������
  // ������� ��� ����������/���.���������
  TOpcodeGlobal = class(TObject)
  protected
    // ���������
    FStorage: record
    case integer of
      0: (uni: TOpcodeStorage);
      1: (x86: TOpcodeStorage_x86);
      2: (x64: TOpcodeStorage_x64);
      3: (ARM: TOpcodeStorage_ARM);
      4: (VM: TOpcodeStorage_VM);
    end;
    // ��� ����������� ������: prev, next
    FPrev: record
    case integer of
      0: (uni: TOpcodeGlobal);
      1: (vrb: TOpcodeVariable);
      2: (x86: TOpcodeProc_x86);
      3: (x64: TOpcodeProc_x64);
      4: (ARM: TOpcodeProc_ARM);
      5: (VM: TOpcodeProc_VM);
    end;
    FNext: record
    case integer of
      0: (uni: TOpcodeGlobal);
      1: (vrb: TOpcodeVariable);
      2: (x86: TOpcodeProc_x86);
      3: (x64: TOpcodeProc_x64);
      4: (ARM: TOpcodeProc_ARM);
      5: (VM: TOpcodeProc_VM);
    end;
  private
    FOFFSET: integer;
    FSize: integer;
    FAlignedSize: integer;
    FMemory: pointer;

    procedure Set_OFFSET(const Value: integer);
    procedure SetSize(const Value: integer);
  private
    // ������ ����������� �������
    // � ������ ��������� OFFSET � ������ ������� ���������� ��������������� ������
    FSubscribedProcs: POpcodeSubscribe;
  public
    constructor Create; // error
    destructor Destroy; override;
    procedure FreeInstance; override;

    // ���������� ��������

    // �������� ������������� �����������!


    // GlobalId

    // ������� ������ ? = ���������� ����������� ���������

    property Storage: TOpcodeStorage read FStorage.uni;
    property Memory: pointer read FMemory;
    property Size: integer read FSize write SetSize;
    property AlignedSize: integer read FAlignedSize;
    property OFFSET: integer read FOFFSET write Set_OFFSET;
  end;


  // ���������� ���������� ��� �������������� ���������
  // (�������� ������ ��� Binary ������)
  TOpcodeVariable = class(TOpcodeGlobal)
  private

  protected

  public
    property Prev: TOpcodeVariable read FPrev.vrb;
    property Next: TOpcodeVariable read FNext.vrb;
  end;

  // ����� ���������, � ������ ��������
  // ����� ������������ ��������� �������
  // � ���������� ���������� � �����������
  //
  // � ���������� ����������� ������ (JIT)
  TOpcodeStorage = class(TObject)
  private
    {$ifdef OPCODE_MODES}
    FMode: TOpcodeMode;
    {$endif}
  private
    FOwnHeap: boolean;
    FJIT: boolean;
    FHeap: TOpcodeHeap;

  protected
    // 0 - Variable, 1 - Proc (���������� ����� ��� ���������� ���������)
    F: record
    case integer of
      0: (Globals: array[0..1] of TOpcodeGlobal);
      1: (Variables: TOpcodeVariable;
          Procs: record
          case integer of
            0: (uni: TOpcodeProc);
            1: (x86: TOpcodeProc_x86);
            2: (x64: TOpcodeProc_x64);
            3: (ARM: TOpcodeProc_ARM);
            4: (VM: TOpcodeProc_VM);
          end;)
    end;
    FFreeGlobals: array[0..1] of TOpcodeGlobal;

    function CreateInstance(const AClass: TClass): TOpcodeGlobal;
    function InternalCreateProc(const ProcClass: TOpcodeProcClass; const Callback: pointer; const AOwnHeap: boolean{=false}): TOpcodeProc;
  private
    FJITHeap: THandle;

    function JIT_Alloc(const Size: integer): pointer;
    procedure JIT_Free(const Proc: pointer);
  protected
    FSubscrBuffer: POpcodeSubscribe;

    procedure SubscribeGlobal(var List: POpcodeSubscribe; const Global: TOpcodeGlobal);
    procedure UnsubscribeGlobal(var List: POpcodeSubscribe; const Global: TOpcodeGlobal);
    procedure ReleaseSubscribeList(const List: POpcodeSubscribe);
  public
    {$ifdef OPCODE_MODES}
    property Mode: TOpcodeMode read FMode;
    {$endif}
  public
    constructor Create(const AHeap: TOpcodeHeap=nil{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode=omBinary{$endif});
    destructor Destroy; override;

    function CreateVariable(const Size: integer): TOpcodeVariable;
    // function CreateProc(const AOwnHeap: boolean=false): TOpcodeProc... - ��� ������ ��������� ����

    property Heap: TOpcodeHeap read FHeap;
    property OwnHeap: boolean read FOwnHeap;
    property JIT: boolean read FJIT;

    // ������
    property Variables: TOpcodeVariable read F.Variables;
    // property Procs: TOpcodeProc... - ��� ������ ���������
  end;


  TOpcodeStorage_Intel = class(TOpcodeStorage)
  private
  protected
  public
  end;


  TOpcodeStorage_x86 = class(TOpcodeStorage_Intel)
  private
  protected
  public
    {$ifdef CPUX86}
    constructor CreateJIT(const AHeap: TOpcodeHeap=nil);
    {$endif}

    function CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_x86;
    property Procs: TOpcodeProc_x86 read F.Procs.x86;
  end;

  TOpcodeStorage_x64 = class(TOpcodeStorage_Intel)
  private
  protected
  public
    {$ifdef CPUX64}
    constructor CreateJIT(const AHeap: TOpcodeHeap=nil);
    {$endif}

    function CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_x64;
    property Procs: TOpcodeProc_x64 read F.Procs.x64;
  end;


  TOpcodeStorage_ARM = class(TOpcodeStorage)
  private
  protected
  public

    function CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_ARM;
    property Procs: TOpcodeProc_ARM read F.Procs.ARM;
  end;


  TOpcodeStorage_VM = class(TOpcodeStorage)
  private
  protected
  public

    function CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_VM;
    property Procs: TOpcodeProc_VM read F.Procs.VM;
  end;

  // ������������� ���, �������������� �����
  TOpcodeProc = class(TOpcodeGlobal)
  private
    {$ifdef OPCODE_MODES}
    FMode: TOpcodeMode;
    {$endif}
  private
    FOwnHeap: boolean;
    FExternalCellsCount: word; // ������������� (��. FFixupedInfo)

    F: packed record
    case Integer of
      0: (Value: integer);
      1: (BlocksReferenced: word{����� �������� ������������������ ����� ��������}; RetN: word);
    end;

    FHeap: TOpcodeHeap;
  private
    // ��� ���������� ������ �������� ������
    FLastBinaryCmd: POpcodeCmd;
    FLastHeapCurrent: Pointer;
  private
    // ����� ������ �����, ������� ����� ���������� ����� �������������
    // � "�������������" � FFixupedInfo
    FCells: pointer{POpcodeCellInfo};

    // ����� �������, ����������� ���������� ������,
    // ����������� ������� ����, ������������ � ������
    // function AllocCell(const Global: TOpcodeGlobal; const LocalPtr ????; const Correction: integer): POpcodeExternalCell;
  private
    // ����� ���������� ����� ���������� (���������� � ���������� ��������� ������)
    // � ������� ��������:
    // 1) ReferencedBlocks: array[1..ReferencedBlocks[0]] of integer;
    //    ��� ������ ��������� �������� ��� ������� �����, ������� ����� �����
    //    ������ ������� �������� ����� ������ ������. ������� 1 ���� (prefix)
    //
    // 2) ExternalCells: array[0..FExternalCellsCount-1] of TOpcodeExternalCell;
    //    ������ ������������� ������ �� ������� ���������. ���� �� ����������
    //    ��� ������� �������. ����� ���� ������ �����, ����� ���� �������������
    //
    // 3) LocalCells: array[1..LocalCells[0]] of integer;
    //    ��� ������ ���������� ���������� �� �����. ������������ �������� �
    //    push @1, ��� � jmp [offset @case_edx + edx*4 - 4]
    //    ���������� �������� � 0� ��������. � ������ ����� ���� ����� 0.
    //    ����������� ������ � ���������� ������ �� Delta �������� OFFSET.
    FFixupedInfo: pointer;

    // �������� ������ ��� ���������� �����
    procedure AllocFixupedInfo(const Size: integer);
  protected
    // ������� ����� ����, ����������� �������� �������������� ����� ������
    // ������������ �����, �������� ������� ������� ������
    B_call_modes: record
    case integer of
      0: (uni: POpcodeBlock);
      1: (x86: POpcodeBlock_x86);
      2: (x64: POpcodeBlock_x64);
      3: (ARM: POpcodeBlock_ARM);
      4: (VM: POpcodeBlock_VM);
    end;

    // ������������� �����, ������������ ������ �������
    B_prefix: record
    case integer of
      0: (uni: POpcodeBlock);
      1: (x86: POpcodeBlock_x86);
      2: (x64: POpcodeBlock_x64);
      3: (ARM: POpcodeBlock_ARM);
      4: (VM: POpcodeBlock_VM);
    end;
    B_start: record
    case integer of
      0: (uni: POpcodeBlock);
      1: (x86: POpcodeBlock_x86);
      2: (x64: POpcodeBlock_x64);
      3: (ARM: POpcodeBlock_ARM);
      4: (VM: POpcodeBlock_VM);
    end;
    B_finish: record
    case integer of
      0: (uni: POpcodeBlock);
      1: (x86: POpcodeBlock_x86);
      2: (x64: POpcodeBlock_x64);
      3: (ARM: POpcodeBlock_ARM);
      4: (VM: POpcodeBlock_VM);
    end;
    B_postfix: record
    case integer of
      0: (uni: POpcodeBlock);
      1: (x86: POpcodeBlock_x86);
      2: (x64: POpcodeBlock_x64);
      3: (ARM: POpcodeBlock_ARM);
      4: (VM: POpcodeBlock_VM);
    end;

    // ��������� ������� ������ ����������� ������� ������������ �� ����������� ������������ ���������
    // ������ ��� � ������ ����������� ������� ������������� ��� ����������� ������� ���� ����������� TOpcodeProc
    // ������ ��� � TOpcodeStorage ��������� ���������� ��������� F
    // Mode 0 - ��������� �������������� ������� �� ������� JumpsInfo
    // Mode 1 - ��������� ��������� LastRetCmd
    // Mode 2 - �������� ���������� �������
    FCallback: procedure(const Mode: integer; const Storage: pointer{PFixupedStorage});
  public
    {$ifdef OPCODE_MODES}
    property Mode: TOpcodeMode read FMode;
    {$endif}
  public
    constructor Create(const AHeap: TOpcodeHeap=nil{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode=omBinary{$endif});

    // ������� ������������� ���� ������� �����, ������������� ������, ������ Heap (���� �����������)
    // ���������� � ������������ �������������
    // �� ����� ������������ ��� ����� ���������� �������
    // (���� RetN ������� ����������)
    procedure Initialize();

    // ����� ������� �������, �������:
    // 1) ���������� Heap � �������� ��������� ������� ������
    // 2) ����� ��������� ���� �������� �� ��������� Fixup-�
    // 3) ������������� ���������� �������������� ����� (FFixupedInfo)
    // 4) �������� ����������� ������� ������
    // 5) ������������ ������
    // 6) ��������� �����
    // 7) ���������� �������� ������
    // 8) ���������� ������
    // 9) ������ �� ����� ��������� ������
    procedure Fixup();

    // ��������� ��������
    property Heap: TOpcodeHeap read FHeap;
    property OwnHeap: boolean read FOwnHeap;
    property RetN: word read F.RetN write F.RetN;
  end;

  TOpcodeProc_Intel = class(TOpcodeProc)
  private
  protected
  public
    // ������������ ������ (�������� � ������� ������������ �������)
    constructor Create(const AHeap: TOpcodeHeap=nil{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode=omBinary{$endif});
  end;


  TOpcodeProc_x86 = class(TOpcodeProc_Intel)
  private
  protected
  public
    // ������������ ����
    property CallModes: POpcodeBlock_x86 read B_call_modes.x86;

    // �����
    property Prefix: POpcodeBlock_x86 read B_prefix.x86;
    property Start: POpcodeBlock_x86 read B_start.x86;
    property Finish: POpcodeBlock_x86 read B_finish.x86;
    property Postfix: POpcodeBlock_x86 read B_postfix.x86;

    // ���������
    property Storage: TOpcodeStorage_x86 read FStorage.x86;
    property Prev: TOpcodeProc_x86 read FPrev.x86;
    property Next: TOpcodeProc_x86 read FNext.x86;
  end;

  TOpcodeProc_x64 = class(TOpcodeProc_Intel)
  private
  protected
  public
    // ������������ ����
    property CallModes: POpcodeBlock_x64 read B_call_modes.x64;

    // �����
    property Prefix: POpcodeBlock_x64 read B_prefix.x64;
    property Start: POpcodeBlock_x64 read B_start.x64;
    property Finish: POpcodeBlock_x64 read B_finish.x64;
    property Postfix: POpcodeBlock_x64 read B_postfix.x64;

    // ���������
    property Storage: TOpcodeStorage_x64 read FStorage.x64;
    property Prev: TOpcodeProc_x64 read FPrev.x64;
    property Next: TOpcodeProc_x64 read FNext.x64;
  end;


  TOpcodeProc_ARM = class(TOpcodeProc)
  private
  protected
  public
    // ������������ ������ (�������� � ������� ������������ �������)
    constructor Create(const AHeap: TOpcodeHeap=nil{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode=omBinary{$endif});

    // ������������ ����
    property CallModes: POpcodeBlock_ARM read B_call_modes.ARM;

    // �����
    property Prefix: POpcodeBlock_ARM read B_prefix.ARM;
    property Start: POpcodeBlock_ARM read B_start.ARM;
    property Finish: POpcodeBlock_ARM read B_finish.ARM;
    property Postfix: POpcodeBlock_ARM read B_postfix.ARM;

    // ���������
    property Storage: TOpcodeStorage_ARM read FStorage.ARM;
    property Prev: TOpcodeProc_ARM read FPrev.ARM;
    property Next: TOpcodeProc_ARM read FNext.ARM;
  end;


  // ������������� ������� ��� ����������� ������
  TOpcodeProc_VM = class(TOpcodeProc)
  private
  protected
  public
    // ������������ ������ (�������� � ������� ������������ �������)
    constructor Create(const AHeap: TOpcodeHeap=nil{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode=omBinary{$endif});

    // ������������ ����
    property CallModes: POpcodeBlock_VM read B_call_modes.VM;

    // �����
    property Prefix: POpcodeBlock_VM read B_prefix.VM;
    property Start: POpcodeBlock_VM read B_start.VM;
    property Finish: POpcodeBlock_VM read B_finish.VM;
    property Postfix: POpcodeBlock_VM read B_postfix.VM;

    // ���������
    property Storage: TOpcodeStorage_VM read FStorage.VM;
    property Prev: TOpcodeProc_VM read FPrev.VM;
    property Next: TOpcodeProc_VM read FNext.VM;
  end;


// ���� �� ������� ��������� (def-����)
{$ifdef CPUX86}
  def_reg = reg_x86;
  def_reg_addr = reg_x86_addr;
  def_address = address_x86;
  TDefOpcodeBlock = TOpcodeBlock_x86;
  PDefOpcodeBlock = POpcodeBlock_x86;
  TDefOpcodeProc = TOpcodeProc_x86;
  TDefOpcodeStorage = TOpcodeStorage_x86;
{$elseif Defined(CPUX64)}
  def_reg = reg_x64;
  def_reg_addr = reg_x64_addr;
  def_address = address_x64;
  TDefOpcodeBlock = TOpcodeBlock_x64;
  PDefOpcodeBlock = POpcodeBlock_x64;
  TDefOpcodeProc = TOpcodeProc_x64;
  TDefOpcodeStorage = TOpcodeStorage_x64;
{$elseif Defined(CPUXARM)}
  def_reg = reg_ARM;
  def_reg_addr = reg_ARM_addr;
  def_address = address_ARM;
  TDefOpcodeBlock = TOpcodeBlock_ARM;
  PDefOpcodeBlock = POpcodeBlock_ARM;
  TDefOpcodeProc = TOpcodeProc_ARM;
  TDefOpcodeStorage = TOpcodeStorage_ARM;
{$ifend}


(* ��������������� ������� ������� ��� ���������� �������� *)

function const32(const Value: Integer): const_32; overload;
function const32(const pValue: PInteger): const_32; overload;
{$ifdef OPCODE_MODES}
function const32(const Condition: PAnsiChar; const Offseted: boolean=false): const_32; overload;
{$endif}
function const32(const Proc: TOpcodeProc): const_32; overload;
function const32(const Block: POpcodeBlock): const_32; overload;
function const32(const Variable: TOpcodeVariable; const Offset: Integer=0): const_32; overload;

function const64(const Value: Int64): const_64; overload;
function const64(const pValue: PInt64): const_64; overload;
{$ifdef OPCODE_MODES}
function const64(const Condition: PAnsiChar; const Offseted: boolean=false): const_64; overload;
{$endif}

function address86(const reg: reg_x86_addr; const offset: integer=0): address_x86; overload;
function address86(const reg: reg_x86_addr; const scale: intel_scale; const plus: reg_x86_addr; const offset: integer=0): address_x86; overload;
{$ifdef OPCODE_MODES}
function address86(const reg: reg_x86_addr; const scale: intel_scale; const plus: reg_x86_addr; const Condition: PAnsiChar; const Offseted: boolean=false): address_x86; overload;
{$endif}

function address64(const reg: reg_x64_addr; const offset: integer=0): address_x64; overload;
function address64(const reg: reg_x64_addr; const scale: intel_scale; const plus: reg_x64_addr; const offset: integer=0): address_x64; overload;
{$ifdef OPCODE_MODES}
function address64(const reg: reg_x64_addr; const scale: intel_scale; const plus: reg_x64_addr; const Condition: PAnsiChar; const Offseted: boolean=false): address_x64; overload;
{$endif}

implementation

{$if CompilerVersion < 19}
type
  NativeInt = Integer;
//  NativeUInt = Cardinal;
{$ifend}


const
  // ���������� ��������� ��� ������, ����������, ��� ������ �� ���� ���
  NO_REFERENCE = high(word);
  // �������� ���������� ��� �����������, ��� ����� �� �������� ������������� ����
  NO_FIXUPED = high(word);

  // ���������, ������� ��������� ��������� ����������� �������� ������
  // ���� ����� ��� ����� ��� ������������� ������
  NO_CMD = POpcodeCmd(NativeInt(-1));

  // ��������� ����� ������ ��� ���������� �������� ���������� �������
  {$ifdef OPCODE_MODES}
  NO_PROC = TOpcodeProc(NativeInt(-1));
  {$endif}


  // ���������� �� ��������� ��������� x32-64: ������ � �����
  reg_intel_info: array[reg_x64] of integer = ($00000001,$00090001,$00120001,$001B0001,$00240001,
  $002D0001,$00360001,$003F0001,$20000102,$20090102,$20120102,$201B0102,$20240102,$202D0102,
  $20360102,$203F0102,$00000104,$00090104,$00120104,$001B0104,$00240104,$002D0104,$00360104,
  $003F0104,$47000104,$47090104,$47120104,$471B0104,$47240104,$472D0104,$47360104,$473F0104,
  $67000102,$67090102,$67120102,$671B0102,$67240102,$672D0102,$67360102,$673F0102,$48000108,
  $48090108,$48120108,$481B0108,$48240108,$482D0108,$48360108,$483F0108,$4F000108,$4F090108,
  $4F120108,$4F1B0108,$4F240108,$4F2D0108,$4F360108,$4F3F0108,$47000001,$47090001,$47120001,
  $471B0001,$47240001,$472D0001,$47360001,$473F0001,$40240001,$402D0001,$40360001,$403F0001);

  // ����������� ��������� ����������� ARM
  reg_ARM_size: array[reg_ARM] of byte = (0{todo});

  {$ifdef OPCODE_MODES}
    // ����� ��������� ��������� x32-64 (����� ��� ������ ����������)
    reg_intel_names: array[reg_x64] of pansichar = (
    'al','cl','dl','bl','ah','ch','dh','bh','ax','cx','dx','bx','sp','bp','si','di',
    'eax','ecx','edx','ebx','esp','ebp','esi','edi','r8d','r9d','r10d','r11d','r12d','r13d','r14d','r15d',
    'r8w','r9w','r10w','r11w','r12w','r13w','r14w','r15w','rax','rcx','rdx','rbx','rsp','rbp','rsi','rdi',
    'r8','r9','r10','r11','r12','r13','r14','r15','r8b','r9b','r10b','r11b','r12b','r13b','r14b','r15b',
    'spl','bpl','sil','dil');

    // ����������� ��������� cc (����� ��� setcc,cmovcc,jcc)
    // ������� �� ���� � ��� ������� � ��� setcc/cmovcc. ��� pansichar � ��� PShortString(��� �������)
    // � ���� ��� call � jmp
    cc_intel_names: array[-2..ord(high(intel_cc))] of pansichar = (
    #4'call',#3'jmp',#2'jo',#3'jno',#2'jb',#2'jc',#4'jnae',#3'jae',#3'jnb',#3'jnc',
    #2'je',#2'jz',#3'jnz',#3'jne',#3'jbe',#3'jna',#2'ja',#4'jnbe',#2'js',#3'jns',#2'jp',
    #3'jpe',#3'jpo',#3'jnp',#2'jl',#4'jnge',#3'jge',#3'jnl',#3'jle',#3'jng',#2'jg',#4'jnle');

    // ����������� ������, ������ ��� ��������� ARM
    cc_arm_names: array[-2..ord(high(intel_cc))] of pansichar = (
    #2'bl',#1'b',#3'bvs',#3'bvc',#3'bcc',#3'bcc',#3'bcc',#3'bcs',#3'bcs',#3'bcs',
    #3'beq',#3'beq',#3'bnz',#3'bnz',#3'bls',#3'bls',#3'bhi',#3'bhi',#3'bmi',#3'bpl',
    nil,nil,nil,nil,#3'blt',#3'blt',#3'bge',#3'bge',#3'ble',#3'ble',#3'bgt',#3'bgt');

    // �������� ��������� ��� �������� ptr
    size_ptr_names: array[size_ptr] of pansichar = ('byte', 'word', 'dword', 'qword', 'tbyte', 'dqword');
  {$endif}

  // �������� �������, ��������������� ��� �����������
  size_ptr_size: array[size_ptr] of byte = (1, 2, 4, 8, 10, 16);


// ��������� ��������� ������ ����������
{$ifdef OPCODE_MODES}
const
  cmd_aaa: string[3] = 'aaa';
  cmd_aad: string[3] = 'aad';
  cmd_aam: string[3] = 'aam';
  cmd_aas: string[3] = 'aas';
  cmd_adc: string[3] = 'adc';
  cmd_add: string[3] = 'add';
  cmd_and: string[3] = 'and';
  cmd_bound: string[5] = 'bound';
  cmd_bsf: string[3] = 'bsf';
  cmd_bswap: string[5] = 'bswap';
  cmd_bt: string[2] = 'bt';
  cmd_btc: string[3] = 'btc';
  cmd_btr: string[3] = 'btr';
  cmd_bts: string[3] = 'bts';
  cmd_call: string[4] = 'call';
  cmd_cbw: string[3] = 'cbw';
  cmd_cdq: string[3] = 'cdq';
  cmd_clc: string[3] = 'clc';
  cmd_cld: string[3] = 'cld';
  cmd_clflush: string[7] = 'clflush';
  cmd_cli: string[3] = 'cli';
  cmd_clts: string[4] = 'clts';
  cmd_cmc: string[3] = 'cmc';
  cmd_cmov: string[4] = 'cmov';
  cmd_cmp: string[3] = 'cmp';
  cmd_cmpsb: string[5] = 'cmpsb';
  cmd_cmpsd: string[5] = 'cmpsd';
  cmd_cmpsq: string[5] = 'cmpsq';
  cmd_cmpsw: string[5] = 'cmpsw';
  cmd_cmpxchg: string[7] = 'cmpxchg';
  cmd_cmpxchg8b: string[9] = 'cmpxchg8b';
  cmd_cpuid: string[5] = 'cpuid';
  cmd_cwd: string[3] = 'cwd';
  cmd_cwde: string[4] = 'cwde';
  cmd_daa: string[3] = 'daa';
  cmd_das: string[3] = 'das';
  cmd_dec: string[3] = 'dec';
  cmd_div: string[3] = 'div';
  cmd_enter: string[5] = 'enter';
  cmd_f2xm1: string[5] = 'f2xm1';
  cmd_fabs: string[4] = 'fabs';
  cmd_fadd: string[4] = 'fadd';
  cmd_faddp: string[5] = 'faddp';
  cmd_fbld: string[4] = 'fbld';
  cmd_fbstp: string[5] = 'fbstp';
  cmd_fchs: string[4] = 'fchs';
  cmd_fclex: string[5] = 'fclex';
  cmd_fcmov: string[5] = 'fcmov';
  cmd_fcom: string[4] = 'fcom';
  cmd_fcomi: string[5] = 'fcomi';
  cmd_fcomip: string[6] = 'fcomip';
  cmd_fcomp: string[5] = 'fcomp';
  cmd_fcompp: string[6] = 'fcompp';
  cmd_fcos: string[4] = 'fcos';
  cmd_fdecstp: string[7] = 'fdecstp';
  cmd_fdiv: string[4] = 'fdiv';
  cmd_fdivp: string[5] = 'fdivp';
  cmd_fdivr: string[5] = 'fdivr';
  cmd_fdivrp: string[6] = 'fdivrp';
  cmd_ffree: string[5] = 'ffree';
  cmd_fiadd: string[5] = 'fiadd';
  cmd_ficom: string[5] = 'ficom';
  cmd_ficomp: string[6] = 'ficomp';
  cmd_fidiv: string[5] = 'fidiv';
  cmd_fidivr: string[6] = 'fidivr';
  cmd_fild: string[4] = 'fild';
  cmd_fimul: string[5] = 'fimul';
  cmd_fincstp: string[7] = 'fincstp';
  cmd_finit: string[5] = 'finit';
  cmd_fist: string[4] = 'fist';
  cmd_fistp: string[5] = 'fistp';
  cmd_fisub: string[5] = 'fisub';
  cmd_fld: string[3] = 'fld';
  cmd_fld1: string[4] = 'fld1';
  cmd_fldcw: string[5] = 'fldcw';
  cmd_fldenv: string[6] = 'fldenv';
  cmd_fldl2e: string[6] = 'fldl2e';
  cmd_fldl2t: string[6] = 'fldl2t';
  cmd_fldlg2: string[6] = 'fldlg2';
  cmd_fldln2: string[6] = 'fldln2';
  cmd_fldpi: string[5] = 'fldpi';
  cmd_fldz: string[4] = 'fldz';
  cmd_fmul: string[4] = 'fmul';
  cmd_fmulp: string[5] = 'fmulp';
  cmd_fnclex: string[6] = 'fnclex';
  cmd_fninit: string[6] = 'fninit';
  cmd_fnop: string[4] = 'fnop';
  cmd_fnsave: string[6] = 'fnsave';
  cmd_fnstcw: string[6] = 'fnstcw';
  cmd_fnstenv: string[7] = 'fnstenv';
  cmd_fnstsw: string[6] = 'fnstsw';
  cmd_fpatan: string[6] = 'fpatan';
  cmd_fprem: string[5] = 'fprem';
  cmd_fprem1: string[6] = 'fprem1';
  cmd_fptan: string[5] = 'fptan';
  cmd_frndint: string[7] = 'frndint';
  cmd_frstor: string[6] = 'frstor';
  cmd_fsave: string[5] = 'fsave';
  cmd_fscale: string[6] = 'fscale';
  cmd_fsin: string[4] = 'fsin';
  cmd_fsincos: string[7] = 'fsincos';
  cmd_fsqrt: string[5] = 'fsqrt';
  cmd_fst: string[3] = 'fst';
  cmd_fstcw: string[5] = 'fstcw';
  cmd_fstenv: string[6] = 'fstenv';
  cmd_fstp: string[4] = 'fstp';
  cmd_fstsw: string[5] = 'fstsw';
  cmd_fsub: string[4] = 'fsub';
  cmd_fsubp: string[5] = 'fsubp';
  cmd_fsubr: string[5] = 'fsubr';
  cmd_fsubrp: string[6] = 'fsubrp';
  cmd_ftst: string[4] = 'ftst';
  cmd_fucom: string[5] = 'fucom';
  cmd_fucomi: string[6] = 'fucomi';
  cmd_fucomip: string[7] = 'fucomip';
  cmd_fucomp: string[6] = 'fucomp';
  cmd_fucompp: string[7] = 'fucompp';
  cmd_fwait: string[5] = 'fwait';
  cmd_fxam: string[4] = 'fxam';
  cmd_fxch: string[4] = 'fxch';
  cmd_fxtract: string[7] = 'fxtract';
  cmd_fyl2x: string[5] = 'fyl2x';
  cmd_fyl2xp1: string[7] = 'fyl2xp1';
  cmd_hlt: string[3] = 'hlt';
  cmd_idiv: string[4] = 'idiv';
  cmd_imul: string[4] = 'imul';
  cmd_in: string[2] = 'in';
  cmd_inc: string[3] = 'inc';
  cmd_insb: string[4] = 'insb';
  cmd_insd: string[4] = 'insd';
  cmd_insq: string[4] = 'insq';
  cmd_insw: string[4] = 'insw';
  cmd_int: string[3] = 'int';
  cmd_invd: string[4] = 'invd';
  cmd_invlpg: string[6] = 'invlpg';
  cmd_iret: string[4] = 'iret';
  cmd_jmp: string[3] = 'jmp';
  cmd_lahf: string[4] = 'lahf';
  cmd_lar: string[3] = 'lar';
  cmd_lds: string[3] = 'lds';
  cmd_lea: string[3] = 'lea';
  cmd_leave: string[5] = 'leave';
  cmd_les: string[3] = 'les';
  cmd_lfs: string[3] = 'lfs';
  cmd_lgdt: string[4] = 'lgdt';
  cmd_lgs: string[3] = 'lgs';
  cmd_lidt: string[4] = 'lidt';
  cmd_lldt: string[4] = 'lldt';
  cmd_lmsw: string[4] = 'lmsw';
  cmd_lock_adc: string[8] = 'lock adc';
  cmd_lock_add: string[8] = 'lock add';
  cmd_lock_and: string[8] = 'lock and';
  cmd_lock_dec: string[8] = 'lock dec';
  cmd_lock_inc: string[8] = 'lock inc';
  cmd_lock_neg: string[8] = 'lock neg';
  cmd_lock_not: string[8] = 'lock not';
  cmd_lock_or: string[7] = 'lock or';
  cmd_lock_sbb: string[8] = 'lock sbb';
  cmd_lock_sub: string[8] = 'lock sub';
  cmd_lock_xadd: string[9] = 'lock xadd';
  cmd_lock_xchg: string[9] = 'lock xchg';
  cmd_lock_xor: string[8] = 'lock xor';
  cmd_lodsb: string[5] = 'lodsb';
  cmd_lodsd: string[5] = 'lodsd';
  cmd_lodsq: string[5] = 'lodsq';
  cmd_lodsw: string[5] = 'lodsw';
  cmd_lsl: string[3] = 'lsl';
  cmd_lss: string[3] = 'lss';
  cmd_ltr: string[3] = 'ltr';
  cmd_mov: string[3] = 'mov';
  cmd_movsb: string[5] = 'movsb';
  cmd_movsd: string[5] = 'movsd';
  cmd_movsq: string[5] = 'movsq';
  cmd_movsw: string[5] = 'movsw';
  cmd_movsx: string[5] = 'movsx';
  cmd_movsxd: string[6] = 'movsxd';
  cmd_movzx: string[5] = 'movzx';
  cmd_mul: string[3] = 'mul';
  cmd_neg: string[3] = 'neg';
  cmd_nop: string[3] = 'nop';
  cmd_not: string[3] = 'not';
  cmd_or: string[2] = 'or';
  cmd_out: string[3] = 'out';
  cmd_outs: string[4] = 'outs';
  cmd_outsb: string[5] = 'outsb';
  cmd_outsd: string[5] = 'outsd';
  cmd_outsw: string[5] = 'outsw';
  cmd_pause: string[5] = 'pause';
  cmd_pop: string[3] = 'pop';
  cmd_popa: string[4] = 'popa';
  cmd_popad: string[5] = 'popad';
  cmd_popf: string[4] = 'popf';
  cmd_popfd: string[5] = 'popfd';
  cmd_prefetch0: string[9] = 'prefetch0';
  cmd_prefetch1: string[9] = 'prefetch1';
  cmd_prefetch2: string[9] = 'prefetch2';
  cmd_prefetchnta: string[11] = 'prefetchnta';
  cmd_push: string[4] = 'push';
  cmd_pusha: string[5] = 'pusha';
  cmd_pushad: string[6] = 'pushad';
  cmd_pushd: string[5] = 'pushd';
  cmd_pushf: string[5] = 'pushf';
  cmd_rcl: string[3] = 'rcl';
  cmd_rcr: string[3] = 'rcr';
  cmd_rdmsr: string[5] = 'rdmsr';
  cmd_rdpmc: string[5] = 'rdpmc';
  cmd_rdtsc: string[5] = 'rdtsc';
  cmd_ret: string[3] = 'ret';
  cmd_rol: string[3] = 'rol';
  cmd_ror: string[3] = 'ror';
  cmd_rsm: string[3] = 'rsm';
  cmd_sahf: string[4] = 'sahf';
  cmd_sal: string[3] = 'sal';
  cmd_sar: string[3] = 'sar';
  cmd_sbb: string[3] = 'sbb';
  cmd_scasb: string[5] = 'scasb';
  cmd_scasd: string[5] = 'scasd';
  cmd_scasq: string[5] = 'scasq';
  cmd_scasw: string[5] = 'scasw';
  cmd_set: string[3] = 'set';
  cmd_sfrence: string[7] = 'sfrence';
  cmd_shl: string[3] = 'shl';
  cmd_shld: string[4] = 'shld';
  cmd_shr: string[3] = 'shr';
  cmd_shrd: string[4] = 'shrd';
  cmd_sldt: string[4] = 'sldt';
  cmd_smsw: string[4] = 'smsw';
  cmd_stc: string[3] = 'stc';
  cmd_std: string[3] = 'std';
  cmd_sti: string[3] = 'sti';
  cmd_stosb: string[5] = 'stosb';
  cmd_stosd: string[5] = 'stosd';
  cmd_stosq: string[5] = 'stosq';
  cmd_stosw: string[5] = 'stosw';
  cmd_str: string[3] = 'str';
  cmd_sub: string[3] = 'sub';
  cmd_sysenter: string[8] = 'sysenter';
  cmd_sysexit: string[7] = 'sysexit';
  cmd_test: string[4] = 'test';
  cmd_ud2: string[3] = 'ud2';
  cmd_verr: string[4] = 'verr';
  cmd_verw: string[4] = 'verw';
  cmd_wait: string[4] = 'wait';
  cmd_wbinvd: string[6] = 'wbinvd';
  cmd_wrmsr: string[5] = 'wrmsr';
  cmd_xadd: string[4] = 'xadd';
  cmd_xchg: string[4] = 'xchg';
  cmd_xlat: string[4] = 'xlat';
  cmd_xlatb: string[5] = 'xlatb';
  cmd_xor: string[3] = 'xor';
{$endif}


// ������������������ "���������" ������ ����
var
  ZERO_CONST_32: const_32{���������� �������������};

const
// ����������� �������� ���������, ������� ������������� ������ ����� � ����������
  FAKE_CONST_32 = $0B0F0B0F; // ud2 ud2

const
// ������ �� ��������� �� ��������� ���������� �� �����������: [REG].TOpcodeAddress.offset. ...
// ������� ���������� ������������ ��� ���������
  TOpcodeAddress_offset = 3;

{$ifdef OPCODE_MODES}
// ������ ��������� ������������ ��� ��������� ������
  FMT_ONE_STRING: AnsiString = '%s';
{$endif}  

type
  { TOpcodeCmdBinary = TOpcodeCmd + Data }

  {$ifdef OPCODE_MODES}
    // �������, �������������� � ���� ����������(������), � �.�. � ��� �������
    TOpcodeCmdText = record {TOpcodeCmd}
      Cmd: TOpcodeCmd;
      Str: PShortString;
    end;
    POpcodeCmdText = ^TOpcodeCmdText;
  {$endif}

  { TOpcodeCmdLeave = TOpcodeCmdBinary || TOpcodeCmdText }

  // ������� ��������������� � ����: jcc/jmp/call
  // call �������� � �������� � ������ ������� ��-�� �������
  // � ������ ������� ������� jmp ���� ����� ��������� �����
  // � �������� �������� ������ ������ intel_cc, ������ ����� �� ������� � ��� ARM
  // ������� jcc(intel_cc), jmp(-1), call(-2)
  TOpcodeCmdJumpBlock = record {TOpcodeCmd}
    Cmd: TOpcodeCmd;

    // ��������� ����� (�� �������� � TOpcodeCellData)
    Proc: TOpcodeProc;
    case Integer{is_global = (Proc <> Self)} of
      0{local}: (Block: POpcodeBlock);
      1{binary global}: (Reference: word{integer});
      {$ifdef OPCODE_MODES}
      2{text global}: (ProcName: pansichar);
      {$endif}
  end;
  POpcodeCmdJumpBlock = ^TOpcodeCmdJumpBlock;

  // ���������, ����������� ���������������� ����������(���������� ��� ����) � �������: cmBinary/cmText/cmLeave
  // (������������ ������ TOpcodeCmdJoined)
  POpcodeJoinedData = ^TOpcodeJoinedData;
  TOpcodeJoinedData = record
    // �������� ������ �������
    // ���� ������������� - Relative (����� ����������� � ������ x64)
    CmdOffset: integer;

    case Integer of
     -1: (Global: TOpcodeGlobal);
      0: (Variable: TOpcodeVariable; VariableOffset: Integer);
      1: (Proc: TOpcodeProc; //
            case Boolean{is_global = (Proc <> Self)} of
             false: (Block: POpcodeBlock);
              true: (Reference: integer);
         );
  end;

  // �������, ���������� ���������������� ����������(���������� ��� ����) � ������ �������: cmBinary/cmText/cmLeave
  // � 2� ������� ����� Param ���������� ������������ (� ����������) ������������� ������. � ��������� 6 ����� ���������� TOpcodeCmdMode
  // Size (Hybrid min/max) ���� ���������� (��� �������� ���������)
  POpcodeCmdJoined = ^TOpcodeCmdJoined;
  TOpcodeCmdJoined = record
    Cmd: TOpcodeCmd;
    Data: array[0..1]{�� ����� ��������� � 1 ���������!} of TOpcodeJoinedData;
  end;

  // ����������� (���������) ������������� �������, �����
  // � �������� ���������(��) �������� ��������� ������� ���������
  // � ���� ������ � ������ �������� ���������� �������� ������������� ������� (UnpointerCmd)
  TOpcodeCmdPointer = record {TOpcodeCmd}
    Cmd: TOpcodeCmd;
    
    params: integer;
    pvalue: pointer{pinteger ��� pint64 ��� ��� TOpcodeConst [� ������ addr/const]};
    {$ifdef OPCODE_MODES}cmd_name: PShortString;{$endif}

    addr_kind: integer; // 3 ����� ������(���� ����������) � kind (0..3)

    callback: pointer;
    // opused_callback_0{const} = function (params: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};
    // opused_callback_1{addr} = function (params: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};
    // opused_callback_2{addr,const} = function (params: integer; const addr: TOpcodeAddress; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};
    // opused_callback_3{const x64. ������ ��� mov} = function (params: integer; const v_const: opused_const_64{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd of object{TOpcodeBlock};

    diffcmd: record
    case Integer of
     -1: (ptr: pointer);
      0: (_0: procedure{diffcmd_const32}(const Block: TOpcodeBlock; params: integer; const v_const: const_32; callback: opused_callback_0{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}));
      1: (_1: procedure{diffcmd_addr}(const Block: TOpcodeBlock; params: integer; const addr: TOpcodeAddress; callback: opused_callback_1{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}));
      2: (_2: procedure{diffcmd_addr_const}(const Block: TOpcodeBlock; params: integer; const addr: TOpcodeAddress; const v_const: const_32; callback: opused_callback_2{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}));
      3: (_3: procedure{diffcmd_const64}(const Block: TOpcodeBlock; params: integer; const v_const: const_64; callback: opused_callback_3{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}));
    end;
  end;
  POpcodeCmdPointer = ^TOpcodeCmdPointer;


  // ���������, ��������� ������� ����� �������� �������������
  // ������ � ������
  TOpcodeCmdData = record
    Cmd: TOpcodeCmd;
    case Integer of
      0: (Bytes: array[word] of byte);
      1: (Words: array[0..(high(word)+1) div 2 -1] of word);
      2: (Dwords: array[0..(high(word)+1) div 4 -1] of dword);
      3: (Str: PShortString);
  end;
  POpcodeCmdData = ^TOpcodeCmdData;



{$ifdef OPCODE_MODES}
  // ��������� ��� ���������� �������� ������ (��� ���������� � �������)
  TOpcodeTextBuffer = object
  private
    function InternalConst(const v_const: TOpcodeConst; const can_offsetted, use_sign: boolean; const Number: byte): PShortString;
  public
    value: record
    case Integer of
      0: (S: ShortString{max 255});
      1: (bytes: array[0..511] of byte);
    end;

    function Format(const FmtStr: AnsiString; const Args: array of const; const Number: byte=0; const MakeLower: boolean=false): PShortString;
    function Str(const S: pansichar; const Number: byte=0): PShortString;
    function SizePtr(const params_ptr: integer; const Number: byte=0): PShortString;

    function Const32(const v_const: const_32; const Number: byte=0): PShortString;
    function Const64(const v_const: const_64; const Number: byte=0): PShortString;

    function IntelAddress(const params: integer{x64}; const addr: TOpcodeAddress; const can_offsetted: boolean=true; const Number: byte=0): PShortString;
  end;
{$endif}

(*  POpcodeCell = ^TOpcodeCell;
  TOpcodeCell = object
    LocalPtr: integer; // �������� ������ ������ �������, ���� ����� ��������� ����� �����
    Correction: integer; // �������������� ��������� ��������
  end;
  POpcodeExternalCell = ^TOpcodeExternalCell;
  TOpcodeExternalCell = object(TOpcodeCell)
    Relative: boolean; // ��� ��������: ������������� ��� ������
    __reserved: byte;
    Reference: word; // ������� �����-������������� ����� ��� NO_REFERENCE ��� ����������
  end;
  POpcodeCellInfo = ^TOpcodeCellInfo;
  TOpcodeCellInfo = record
    // ��� ����������� ������
    Next: POpcodeCellInfo;
    // ���������� ��� �������
    // ������� ������� ���� ��� ���������� � �������� FFixupedInfo
    Global: TOpcodeGlobal;

    // ���� ������ �� ������
    // ����� ���� � ������ TOpcodeCell
    Cell: TOpcodeExternalCell;
  end; *)

  // ��� ������� ���������� �����-�� ���������� ���������, ������� ������������
  // ����� ������ �� ��������, �� ��������� ����� �������
  //
  // � �������� ������ ������ ������������ ��� ����������� ������� ������ � ���������� ����������
  // ������������ ��� ��������� ��������, ��� � ���������� �����.
  // ��� ������ ��������� OFFSET (���� ��� ������� ����������� �������) - ��������� ������ ����� ��������.
  // _
  // ��� ��������� � �������� ���������� �������� � FFixupedInfo: �������������� �����, ��������� ������, ������� ������
  //
  //
  // � ��������� ������ (���������/������) ������ ������������ ������ ��� ��������� ���������
  // ������ � ��������� ����� � �������, ������� ������������ ��� ��������� ����������� ��� @������ ������ %s


  // ���������� �� ��������� ������
  // ���������� ������ �� ����� �����
(*  POpcodeLocalCell = ^TOpcodeLocalCell;
  TOpcodeLocalCell = record
    // �������� ������ ������ �������, ���� ����� ��������� ����� �����
    // ���� ����� ������������� - ��
    LocalPtr: integer; // �������� ������ ������ �������, ���� ����� ��������� ����� �����


    Correction: integer; // �������������� ��������� ��������
  end;


  {
    TOpcodeExternalCell_Header = record
      Global: TOpcodeGlobal;
      Count: integer;
    end;
  }
  TOpcodeExternalCell = record

    LocalPtr: integer;

  end; *)








{$ifndef PUREPASCAL}
procedure raise_not_realized_addr(CodeAddr: pointer);
begin
  raise EOpcodeLib.Create('Command is not realized yet') at CodeAddr;
end;
{$endif}

procedure raise_not_realized;
{$ifdef PUREPASCAL}
begin
  raise EOpcodeLib.Create('Command is not realized yet');
end;
{$else}
asm
  {$ifdef CPUX86}
    mov eax, [esp]
  {$else .CPUX64}
    mov RCX, [RSP]
  {$endif}

  jmp raise_not_realized_addr
end;
{$endif}

{$ifndef PUREPASCAL}
procedure raise_parameter_addr(CodeAddr: pointer);
begin
  raise EOpcodeLib.Create('Wrong parameter') at CodeAddr;
end;
{$endif}

procedure raise_parameter;
{$ifdef PUREPASCAL}
begin
  raise EOpcodeLib.Create('Wrong parameter');
end;
{$else}
asm
  {$ifdef CPUX86}
    mov eax, [esp]
  {$else .CPUX64}
    mov RCX, [RSP]
  {$endif}

  jmp raise_parameter_addr
end;
{$endif}


{ TOpcodeHeap }

const
  // ������ ���� �� ��������� (��� ����������� ����������� ������)
  DEFAULT_POOL_SIZE = 2*1024; // 2kb

constructor TOpcodeHeap.Create;
begin
  inherited;
  FState.PoolSize := DEFAULT_POOL_SIZE;
end;

procedure TOpcodeHeap.NewPool();
begin
  GetMem(FState.Current, FState.PoolSize);
  pointer(FState.Current^) := FState.Pool;
  FState.Pool := FState.Current;
  Inc(NativeInt(FState.Current), sizeof(Pointer));
  FState.Margin := FState.PoolSize-sizeof(Pointer);
end;

// �������� ����������� ���� ������ � ����
function TOpcodeHeap.Alloc(const Size: integer): pointer;
var
  NewPoolSize: integer;
begin
  if (FState.Margin < Size) then
  begin
    NewPoolSize := (sizeof(Pointer)+Size+(DEFAULT_POOL_SIZE-1)) and -DEFAULT_POOL_SIZE;
    if (NewPoolSize > FState.PoolSize) then FState.PoolSize := NewPoolSize;

    NewPool();
  end;

  Result := FState.Current;
  Inc(NativeInt(FState.Current), Size);
  Dec(FState.Margin, Size);
end;

{$ifdef OPCODE_MODES}
function TOpcodeHeap.Format(const FmtStr: ShortString; const Args: array of const): PShortString;
var
  Count: integer;
begin
  if (FState.Margin < 16) then NewPool();

  Count := SysUtils.FormatBuf(pointer(NativeInt(FState.Current)+1)^, FState.Margin, FmtStr[1], Length(FmtStr), Args);
  if (Count = FState.Margin) then
  begin
    NewPool();
    Count := SysUtils.FormatBuf(pointer(NativeInt(FState.Current)+1)^, FState.Margin, FmtStr[1], Length(FmtStr), Args);
  end;

  if (Count < 0) or (Count > high(byte)) then raise_parameter;

  Result := FState.Current;
  pbyte(Result)^ := Count;

  inc(Count);
  inc(NativeInt(FState.Current), Count);
  dec(FState.Margin, Count);
end;
{$endif}

destructor TOpcodeHeap.Destroy;
var
  Pool, NewPool: pointer;
begin
  Pool := FState.Pool;
  while (Pool <> nil) do
  begin
    NewPool := Pointer(Pool^);
    FreeMem(Pool);
    Pool := NewPool;
  end;              

  inherited;
end;

// ������� ��� ���� ����� �������
procedure TOpcodeHeap.Clear();
var
  NewPool: pointer;
begin
  if (FState.Pool <> nil) then
  begin
    while (true) do
    begin
      NewPool := Pointer(FState.Pool^);
      if (NewPool = nil) then break;

      FreeMem(FState.Pool);
      FState.Pool := NewPool;
    end;

    FState.Current := FState.Pool;
    FState.Margin := DEFAULT_POOL_SIZE;
    FState.PoolSize := DEFAULT_POOL_SIZE;
  end;
end;

procedure TOpcodeHeap.SaveState(var HeapState: TOpcodeHeapState);
begin
  HeapState := FState;
end;

procedure TOpcodeHeap.RestoreState(const HeapState: TOpcodeHeapState);
var
  NewPool, Pool: pointer;
begin
  Pool := Self.FState.Pool;

  while (Pool <> HeapState.Pool) do
  begin
    NewPool := Pointer(Pool^);
    FreeMem(Pool);
    Pool := NewPool;
  end;

  FState := HeapState;
end;


function const32(const Value: Integer): const_32;
begin
  Result.Kind := ckValue;
  Result.Value := Value;
end;

function const32(const pValue: PInteger): const_32;
begin
  Result.Kind := ckPValue;
  Result.pValue := pValue;
end;

{$ifdef OPCODE_MODES}
function const32(const Condition: PAnsiChar; const Offseted: boolean=false): const_32;
begin
  if (not Offseted) then
  begin
    Result.Kind := ckCondition;
    Result.Condition := Condition;
  end else
  begin
    Result.Kind := ckOffsetedCondition;
    Result.OffsetedCondition := Condition;
  end;
end;
{$endif}

function const32(const Proc: TOpcodeProc): const_32;
begin
  Result.Kind := ckBlock;
  Result.Block := Proc.B_prefix.uni;
end;

function const32(const Block: POpcodeBlock): const_32;
begin
  Result.Kind := ckBlock;
  Result.Block := Block;
end;

function const32(const Variable: TOpcodeVariable; const Offset: Integer=0): const_32;
begin
  Result.Kind := ckVariable;
  Result.Variable := Variable;
  Result.VariableOffset := Offset;
end;

function const64(const Value: Int64): const_64;
begin
  Result.Kind := ckValue;
  Result.Value := Value;
end;

function const64(const pValue: PInt64): const_64;
begin
  Result.Kind := ckPValue;
  Result.pValue := pValue;
end;

{$ifdef OPCODE_MODES}
function const64(const Condition: PAnsiChar; const Offseted: boolean=false): const_64;
begin
  if (not Offseted) then
  begin
    Result.Kind := ckCondition;
    Result.Condition := Condition;
  end else
  begin
    Result.Kind := ckOffsetedCondition;
    Result.OffsetedCondition := Condition;
  end;
end;
{$endif}

function address86(const reg: reg_x86_addr; const offset: integer=0): address_x86;
begin
  Result.reg := reg;
  Result.scale := x1;

  Result.offset.Kind := ckValue;
  Result.offset.Value := offset;
end;

function address86(const reg: reg_x86_addr; const scale: intel_scale; const plus: reg_x86_addr; const offset: integer=0): address_x86;
begin
  Result.reg := reg;
  Result.scale := scale;
  Result.plus := plus;

  Result.offset.Kind := ckValue;
  Result.offset.Value := offset;
end;

{$ifdef OPCODE_MODES}
function address86(const reg: reg_x86_addr; const scale: intel_scale; const plus: reg_x86_addr; const Condition: PAnsiChar; const Offseted: boolean=false): address_x86; overload;
begin
  Result.reg := reg;
  Result.scale := scale;
  Result.plus := plus;

  if (not Offseted) then
  begin
    Result.offset.Kind := ckCondition;
    Result.offset.Condition := Condition;
  end else
  begin
    Result.offset.Kind := ckOffsetedCondition;
    Result.offset.OffsetedCondition := Condition;
  end;
end;
{$endif}

function address64(const reg: reg_x64_addr; const offset: integer=0): address_x64;
begin
  Result.reg := reg;
  Result.scale := x1;

  Result.offset.Kind := ckValue;
  Result.offset.Value := offset;
end;

function address64(const reg: reg_x64_addr; const scale: intel_scale; const plus: reg_x64_addr; const offset: integer=0): address_x64;
begin
  Result.reg := reg;
  Result.scale := scale;
  Result.plus := plus;

  Result.offset.Kind := ckValue;
  Result.offset.Value := offset;
end;

{$ifdef OPCODE_MODES}
function address64(const reg: reg_x64_addr; const scale: intel_scale; const plus: reg_x64_addr; const Condition: PAnsiChar; const Offseted: boolean=false): address_x64; overload;
begin
  Result.reg := reg;
  Result.scale := scale;
  Result.plus := plus;

  if (not Offseted) then
  begin
    Result.offset.Kind := ckCondition;
    Result.offset.Condition := Condition;
  end else
  begin
    Result.offset.Kind := ckOffsetedCondition;
    Result.offset.OffsetedCondition := Condition;
  end;
end;
{$endif}


{ TOpcodeGlobal }

constructor TOpcodeGlobal.Create;
begin
  if (Storage = nil) then
  raise EOpcodeLib.CreateFmt('You can not call constructor of %s class', [Self.ClassName]);
end;

destructor TOpcodeGlobal.Destroy;
var
  Index: integer;
begin
  Index := ord(TClass(Pointer(Self)^) <> TOpcodeVariable);

  // ���-�� � ��������� ???
  if (FSubscribedProcs <> nil) then
  raise EOpcodeLib.CreateFmt('%s instance has subscribed procs', [Self.ClassName]);

  // ������
  if (Storage <> nil) then
  with Storage do
  begin
    // ���������� �� (�����������) ������
    if (FPrev.uni = nil) then
    begin
      F.Globals[Index] := FNext.uni;
      FNext.uni.FPrev.uni := nil;
    end else
    begin
      FPrev.uni.FNext.uni := Self.FNext.uni;
      if (Self.FNext.uni <> nil) then Self.FNext.uni.FPrev.uni := Self.FPrev.uni;
    end;

    // ���������� � (�����������) ������ ��������� ���������
    Self.FNext.uni := FFreeGlobals[Index];
    FFreeGlobals[Index] := Self;
  end;

  // ���������� ������, ������������� ������
  if (FSize <> 0) then
  Self.Size := 0;

  // ������ ������ �������
  if (Index <> 0) then
  with TOpcodeProc(Self) do
  begin
    if (FOwnHeap) then FHeap.Free;
    if (FFixupedInfo <> nil) then FreeMem(FFixupedInfo);
  end;

  // ������ �������� �� �����������, ��� �����
  // inherited;
end;

// ������ ����������� ������� ������+FreeMem ����� ������ � ��� ������, ����
// ���������� ������� ����������� ������� (��� ���������)
//
// � ���� �� � �������, ������� ������� ����� (������, ��� �������) � �������� �� ��������
procedure TOpcodeGlobal.FreeInstance;
begin
  if (Storage = nil) then
  inherited;
end;

procedure TOpcodeGlobal.SetSize(const Value: integer);
var
  NewAlignedSize: integer;
begin
  NewAlignedSize := (Value + 3) and -4;

  if (FAlignedSize = NewAlignedSize) then
  begin
    FSize := Value;
    exit;
  end;

  // ������
  if (Storage <> nil) and (Storage.JIT) and {Self is TOpcodeProc}(TClass(Pointer(Self)^) <> TOpcodeVariable) then
  begin
    if (FMemory <> nil) then Storage.JIT_Free(FMemory);

    if (NewAlignedSize = 0) then FMemory := nil
    else FMemory := Storage.JIT_Alloc(NewAlignedSize);

    OFFSET := NativeInt(FMemory);
  end else
  begin
    if (FMemory <> nil) then FreeMem(FMemory);

    if (NewAlignedSize = 0) then FMemory := nil
    else GetMem(FMemory, NewAlignedSize);
  end;

  // ����
  FAlignedSize := NewAlignedSize;
  FSize := Value;
end;

procedure TOpcodeGlobal.Set_OFFSET(const Value: integer);
var
  subscr: POpcodeSubscribe;
begin
  {$ifdef OPCODE_MODES}
    if (Storage.FMode <> omBinary) then
    raise EOpcodeLib.Create('OFFSET can be changed only in Binary mode');
  {$endif}

  // ��������
  FOFFSET := Value;

  // ������� ���� ��������
  subscr := FSubscribedProcs;
  while (subscr <> nil) do
  begin
    // todo subscr.Proc.

    subscr := subscr.Next;
  end;
end;


{ TOpcodeStorage }

constructor TOpcodeStorage.Create(const AHeap: TOpcodeHeap
           {$ifdef OPCODE_MODES}; const AMode: TOpcodeMode{$endif});
begin
  inherited Create;

  FHeap := AHeap;
  FOwnHeap := (AHeap = nil);
  if (FOwnHeap) then FHeap := TOpcodeHeap.Create;

  {$ifdef OPCODE_MODES}
  FMode := AMode;   
  {$endif}
end;

destructor TOpcodeStorage.Destroy;
begin
  // todo ��� ������� � ���������� ?

  if (FOwnHeap) then FHeap.Free;

  // ���� ���� ������ JIT ������������
  if (FJIT) then
  begin
    {$ifdef MSWINDOWS}
       if (FJITHeap <> 0) then Windows.HeapDestroy(FJITHeap);
    {$else}
       {$MESSAGE 'Look JIT memory manager!'}
    {$endif}
  end;

  inherited;
end;

function TOpcodeStorage.JIT_Alloc(const Size: integer): pointer;
begin
  {$ifdef MSWINDOWS}
     // ������ ���� ���� ������ �����
     if (FJITHeap = 0) then FJITHeap := Windows.HeapCreate($00040000{HEAP_CREATE_ENABLE_EXECUTE}, 0, 0);

     // ���������
     Result := Windows.HeapAlloc(FJITHeap, 0, Size);
  {$else}
     {$MESSAGE 'Look JIT memory manager!'}
     Result := nil;
  {$endif}

  // �������� ��������� �� x64
  {$ifdef CPUX64}
     if ((NativeInt(Result)+NativeInt(Size)) >= high(Integer)) then
     raise EOpcodeLib.Create('Address range overflow. You should use less virtual memory or call JIT routine before large memory allocating');
  {$endif}
end;

procedure TOpcodeStorage.JIT_Free(const Proc: pointer);
begin
  {$ifdef MSWINDOWS}
     Windows.HeapFree(FJITHeap, 0, Proc);
  {$else}
     {$MESSAGE 'Look JIT memory manager!'}
  {$endif}
end;

procedure TOpcodeStorage.SubscribeGlobal(var List: POpcodeSubscribe; const Global: TOpcodeGlobal);
var
  Result: POpcodeSubscribe;
begin
  // ����. �������� ����� ������ ��� ���� � ��������
  Result := List;
  while (Result <> nil) do
  begin
    if (Result.Global = Global) then exit;
    Result := Result.Next;
  end;

  // �������� ���������
  if (FSubscrBuffer <> nil) then
  begin
    Result := FSubscrBuffer;
    FSubscrBuffer := Result.Next;
  end else
  with FHeap do
  if (FState.Margin >= sizeof(TOpcodeSubscribe)) then
  begin
    Result := FState.Current;
    Inc(NativeInt(FState.Current), sizeof(TOpcodeSubscribe));
    Dec(FState.Margin, sizeof(TOpcodeSubscribe));
  end else
  begin
    Result := Alloc(sizeof(TOpcodeSubscribe));
  end;

  // ������
  Result.Global := Global;

  // ������� � ������
  Result.Next := List;
  List := Result;
end;

procedure TOpcodeStorage.UnsubscribeGlobal(var List: POpcodeSubscribe; const Global: TOpcodeGlobal);
var
  Prev, Item: POpcodeSubscribe;
begin
  Prev := nil;
  Item := List;
  if (Item = nil) then exit;

  // ���� �������
  while (Item.Global <> Global) do
  begin
    Prev := Item;
    Item := Item.Next;
    if (Item = nil) then exit;
  end;

  // ������� �� ������
  if (Prev = nil) then List := Item.Next
  else Prev.Next := Item;

  // ��������� Item � �����
  Item.Next := FSubscrBuffer;
  FSubscrBuffer := Item;
end;

// �������������� ���� ������� �������� ������ ��������� � FSubscrBuffer
// �������� ����� ��������� ������ ����������
procedure TOpcodeStorage.ReleaseSubscribeList(const List: POpcodeSubscribe);
var
  Last: POpcodeSubscribe;
begin
  if (List <> nil) then
  begin
    if (FSubscrBuffer = nil) then FSubscrBuffer := List
    else
    begin
      Last := List;
      while (Last.Next <> nil) do Last := Last.Next;

      Last.Next := FSubscrBuffer;
      FSubscrBuffer := List;
    end;
  end;  
end;

function TOpcodeStorage.CreateInstance(const AClass: TClass): TOpcodeGlobal;
const
  OFFSET = sizeof(TClass)+sizeof(TOpcodeStorage)+2*sizeof(TOpcodeGlobal);
var
  {Index,} Size: integer;
begin
  // ���� ����� - ���� �� ������ ���������
  // ����� �������� � ����
  Size{Index} := ord(AClass <> TOpcodeVariable);
  Result := FFreeGlobals[Size{Index}];
  if (Result <> nil) then
  begin
    FFreeGlobals[Size{Index}] := Result.FNext.uni;
    Size := PInteger(@PAnsiChar(AClass)[vmtInstanceSize])^; // AClass.InstanceSize
  end else
  begin
    with FHeap do
    begin
      Size := NativeInt(FState.Current) and 3;
      if (Size <> 0) then
      begin
        Size := 4-Size;
        Inc(NativeInt(FState.Current), Size);
        Dec(FState.Margin, Size);
      end;

      Size := PInteger(@PAnsiChar(AClass)[vmtInstanceSize])^; // AClass.InstanceSize
      if (FState.Margin >= Size) then
      begin
        Result := FState.Current;
        Inc(NativeInt(FState.Current), Size);
        Dec(FState.Margin, Size);
      end else
      begin
        Result := Alloc(Size);
      end;
    end;

    TClass(Pointer(Result)^) := AClass;
    Result.FStorage.uni := Self;
  end;

  // ������ ������
  FillChar(Pointer(NativeInt(Result)+OFFSET)^, Size-OFFSET, #0);

  // ���������� � ������
  Size{Index} := ord(AClass <> TOpcodeVariable);
  Result.FPrev.uni := nil;
  Result.FNext.uni := F.Globals[Size{Index}];
  F.Globals[Size{Index}] := Result;
  if (Result.FNext.uni <> nil) then Result.FNext.uni.FPrev.uni := Result;
end;

function TOpcodeStorage.InternalCreateProc(const ProcClass: TOpcodeProcClass; const Callback: pointer; const AOwnHeap: boolean{=false}): TOpcodeProc;
var
  H: TOpcodeHeap;
begin
  Result := TOpcodeProc(CreateInstance(ProcClass));

  H := nil;
  if (not AOwnHeap) then H := Heap;
  Result.Create(H{$ifdef OPCODE_MODES},Mode{$endif});

  @Result.FCallback := Callback;
end;

function TOpcodeStorage.CreateVariable(const Size: integer): TOpcodeVariable;
begin
  {$ifdef OPCODE_MODES}
    if (Mode <> omBinary) then
    raise EOpcodeLib.Create('Variable can be created only in Binary mode');
  {$endif}

  Result := TOpcodeVariable(CreateInstance(TOpcodeVariable));
  // ����������� �������� ������� Result.Create();
  if (Size <> 0) then Result.Size := Size;
end;


{ TOpcodeProc }

// ������� ������������� ���� ������� �����, ������������� ������, ������ Heap (���� �����������)
// ���������� � ������������ �������������
// �� ����� ������������ ��� ����� ���������� �������
// (���� RetN ������� ����������)
procedure TOpcodeProc.Initialize();
const
  BLOCKS_COUNT = 5;
  BLOCKS_SIZE = BLOCKS_COUNT*sizeof(TOpcodeBlock);
type
  TBlocksArray = array[0..BLOCKS_COUNT-1] of TOpcodeBlock;
var
  Blocks: ^TBlocksArray;
  NIL_VALUE: pointer;
  NO_FIX_REF: integer;
  NEXT_BLOCK: POpcodeBlock;
begin
  // ���� ���� ���� - ����� ����� � ���������� ����
  // �������� ���� ���� ����
  if (OwnHeap) and ({make faster}Heap.FState.Pool <> nil) then Heap.Clear();

  // ����
  {$ifdef OPCODE_MODES}
    F.BlocksReferenced := ord(Self.Mode=omBinary);
  {$else}
    F.BlocksReferenced := 1; // F.BlocksReferenced := 0; \ prefix.MakeReference();
  {$endif}
  NIL_VALUE{make_smaller} := nil;
  FLastBinaryCmd := NO_CMD;
  FLastHeapCurrent := NIL_VALUE;
  FCells := NIL_VALUE;

  // �������������� ����� ����������� ������ (������)
  with Heap do
  begin
    Blocks := FState.Current;
    if (FState.Margin >= BLOCKS_SIZE) then
    begin
      Inc(NativeInt(FState.Current), BLOCKS_SIZE);
      Dec(FState.Margin, BLOCKS_SIZE);
    end else
    begin
      Blocks := Alloc(BLOCKS_SIZE);
    end;
  end;
 // FillChar(Blocks^, BLOCKS_SIZE, 0);

  // call_modes
  NO_FIX_REF{make_smaller} := NO_FIXUPED or (NO_REFERENCE shl 16);
  B_call_modes.uni := @Blocks^[0];
  Blocks^[0].CmdList := NIL_VALUE;
  Blocks^[0].P.Proc := Self;
  NEXT_BLOCK := @Blocks^[1];
  Blocks^[0].N.Next := NEXT_BLOCK;
  Blocks^[0].O.Value := NO_FIX_REF;
  // prefix
  B_prefix.uni := NEXT_BLOCK;
  Blocks^[1].CmdList := NIL_VALUE;
  Blocks^[1].P.Proc := Self;
  NEXT_BLOCK := @Blocks^[2];
  Blocks^[1].N.Next := NEXT_BLOCK;
  Blocks^[1].O.Value := NO_FIXUPED; // B_prefix.uni.O.Reference := 0;
  {$ifdef OPCODE_MODES}
    if (Self.Mode <> omBinary) then Blocks^[1].O.Value := NO_FIX_REF;
  {$endif}
  // start
  B_start.uni := NEXT_BLOCK;
  Blocks^[2].CmdList := NIL_VALUE;
  Blocks^[2].P.Proc := Self;
  NEXT_BLOCK := @Blocks^[3];
  Blocks^[2].N.Next := NEXT_BLOCK;
  Blocks^[2].O.Value := NO_FIX_REF;
  // finish
  B_finish.uni := NEXT_BLOCK;
  Blocks^[3].CmdList := NIL_VALUE;
  Blocks^[3].P.Proc := Self;
  NEXT_BLOCK := @Blocks^[4];
  Blocks^[3].N.Next := NEXT_BLOCK;
  Blocks^[3].O.Value := NO_FIX_REF;
  // postfix
  B_postfix.uni := NEXT_BLOCK;
  Blocks^[4].CmdList := NIL_VALUE;
  Blocks^[4].P.Proc := Self;
  Blocks^[4].N.Next := NIL_VALUE;
  Blocks^[4].O.Value := NO_FIX_REF;
end;

// �������� ������ ��� ���������� �����
procedure TOpcodeProc.AllocFixupedInfo(const Size: integer{����� ��������� � ������ ?});
begin
  if (FFixupedInfo <> nil) then FreeMem(FFixupedInfo);
  if (Size <> 0) then GetMem(FFixupedInfo, Size);
end;

constructor TOpcodeProc.Create(const AHeap: TOpcodeHeap{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode{$endif});
begin
// ������ �� ����������! ��� Exception!
// inherited Create;

  FHeap := AHeap;
  FOwnHeap := (AHeap = nil);
  if (FOwnHeap) then FHeap := TOpcodeHeap.Create;

  {$ifdef OPCODE_MODES}
  FMode := AMode;
  {$endif}

  @FCallback := @raise_not_realized;

  // ��� ������������� ������
  Initialize();
end;

(* ���������� �������� � ������
destructor TOpcodeProc.Destroy;
begin
  if (FOwnHeap) then FHeap.Free;
  if (FFixupedInfo <> nil) then FreeMem(FFixupedInfo);

  inherited;
end;*)


const
  // ����, ������� ����������, ��� ���� (1 ������� ��� ���) �������� ���������
  // ��� ����� ��� ����� ������� � �������� ������ � ������ �������
  // � ����� ����� �� ����� ���������� ������������ ��������� � �������� ������.
  // ���������� �������� �� ����������� ����� ������� - ���� ������ ����, ������ �����
  {$ifdef OPCODE_MODES}
  REFID_FLAG_TEXT = Integer(1 shl 31);
  {$endif}

  // "����", �����������, ��� ���� ���������� �����, � ������� ���� ������
  REFID_ISNEXT = Integer(1 shl 30);

  // �������, ��������� ������� �������� - ������ ������������� � ��������� �����
  // ������� ������������������ ������ ������������ ������������������� (�������, Count>0, next)
  // ��� ���� ������ ������� Count(SingleMode) <= 0 
  (*SINGLE_MODE_EMPTY = 0;
  SINGLE_MODE_LEAVE = -1;
  SINGLE_MODE_LEAVE_JOINED = -2;
  SINGLE_MODE_JOINED = -3;
  SINGLE_MODE_JUMP_BLOCK = -4;
  SINGLE_MODE_INLINE = -5{!!!};

   *)
  // ������ �������������� �� ����� ��������
  // (������ ������� ��� ����������� �������)
  STACK_BUFFERED_SIZE = 300;

  // ������ ������ ���������� ������� ������
  JUMP_STACK_SIZE = 30;

type
  // ��� ����������, ������� �������� � �����
  TFixupedKind = (fkEmpty, // ������ ���� (��� ������������ ����� ����� ���������. � ���� ������ ���� value ����� 0)
                 fkNormal, // ����������� ��������
                 fkJoined, // add edx, [... + offset ...] / mov esi, offset @1
            fkLeaveJoined, // jmp [... + offset ...]
                  fkLeave, // ret(n), leave, jmp reg, jmp mem
        fkGlobalJumpBlock, // call axml_get_attribute / jne PRE_cmd_ptr_addr_const
         fkLocalJumpBlock, // jnle @2 / call @Specifier
                 fkInline  // pop esi, pop edi, ret
                 );


  // ���������� ���������
  // �������������� ���� ������
  // �� ����� ����� ������ � �������� ����� ���������� ��������(���������) �������������
  // 16(+4) ���� ��� x86, 20(+4) ���� ��� x64
  PFixupedBlockArray = ^TFixupedBlockArray;
  PFixupedBlock = ^TFixupedBlock;
  TFixupedBlock = packed record
    case Integer of
      0: (RefId: integer); // ������������ ��� �����/����������� ������. + ����������� �����������/����������
      1: (Offset: integer{������������ ��� �������� �����: ������� � call}; Size: integer{������������ ��� �������� ������});
      {$ifdef OPCODE_MODES}
      2: (_: integer;
          HybridSize_Min: integer; {text length?}
          case Integer of
            0: (HybridSize_Max: integer);
            1: (Number: integer{������������ ��� ��������� � ���������� � �������});
          );
      {$endif}
      3: (header_info: array[0..1{$ifdef OPCODE_MODES}+1{$endif}] of integer;
          case boolean of
           false: (Value: integer; Cmd: POpcodeCmd);
            true: (Kind: TFixupedKind;
              case TFixupedKind of
              // ������ ���� (��� ������������ ����� ����� ���������. � ���� ������ ���� value ����� 0)
              fkEmpty: ({� ���� ������ ���� Value ����� 0});
              // ����������� ��������
             fkNormal: ({Cmd. ���������� = (Value shr 8)});
              // add edx, [... + offset ...] / mov esi, offset @1
             fkJoined: ({Cmd + Cmd.Next});
              // jmp [... + offset ...]
        fkLeaveJoined: ({Cmd + Cmd.Next});             
              // ret(n), leave, jmp reg, jmp mem
              fkLeave: ({Cmd});
    fkGlobalJumpBlock,
     fkLocalJumpBlock,
             fkInline: ( // ��� ������� � ���� - ����������� ��������
                         // ��� inline � ������ <0 (-2) ��� jncc ������
                         // ��������, ����������/����������� ������ � ���� ������ ������������ �� �������(��) �����!
                         // ���������� inline-������� ����� ���������� ���� mask = mask and jmp_dest_mask[]
                         // ��� ����� ��� ��� � inline � ����������� -2(call) ��� ���� ��� ������� - ���������� ������
                         cc_ex: shortint;
                         case TFixupedKind of
                  fkGlobalJumpBlock: (Reference: word;
                                      {$ifdef OPCODE_MODES}
                                      case Boolean of
                                        false: (Proc: TOpcodeProc);
                                         true: (ProcName: pansichar);
                                      {$else}
                                        Proc: TOpcodeProc
                                      {$endif}
                                     );
                                     // ������ ������� �������� ����� ����������
                                     // ����� ���� ����� ����� �������� �������������
                   fkLocalJumpBlock: (Fixuped: word; JumpOffset: integer);
                           fkNormal: (JumpBuffer: array[0..5] of byte);
                                     // �����, ��� ������������� ����� �� ����� RefId !!!
                                     // � ������ ���� ������ ���������, �� ��� ��������/���������
                                     // ���������� ����� ������������� ����� InlineBlocks (4 �����)
                                     //
                                     // ��� ����� ��������, ��� inline-������������������ ���
                                     // ������ �������� ������������������ (� ������� ����)
                                     // ������� ��� � �������� ������ � ��������� ����������� ��
                                     // ������ ��� ����� ����� �������� ��� VM-����������
                           fkInline: (InlineBlocksCount: word; InlineBlocks: PFixupedBlockArray);
                        );
         ););               
  end;
  TFixupedBlockArray = array[0..{0}1] of TFixupedBlock;



  TWordArray = array[0..0] of Word;
  PWordArray = ^TWordArray;
  TIntegerArray = array[0..0] of Integer;
  PIntegerArray = ^TIntegerArray;

  // ������ ��� ��������� ������� (����� ����� �� ��������������)
  TLocalJumpsArray = array[0..0] of PFixupedBlock;
  PLocalJumpsArray = ^TLocalJumpsArray;

  // ������ ��� �������
  // ����� ��� (��������������) ��������� ����������
  {$ifdef OPCODE_MODES}
    TLocalJumpsNames = array[-2{call,jmp}..ord(high(intel_cc))] of PShortString;
  {$endif}

  // ����� ��������� (����������) �� ��������
  // ��� ����������� ���������� ���������� ����� ����������� + �����������
  // � ����������� �� ������ �������� "�����������"
  TFixupedStorage = record
    // ����� ����������
    // ����� � ������ ������� ��� ��������� � ����
    // Proc ����� ��� ������������ ������ + ����������� �������
    Heap: TOpcodeHeap;
    Proc: TOpcodeProc;
    {$ifdef OPCODE_MODES}
      Mode: TOpcodeMode;
    {$endif}

    // ��������, ����������� �������� �� FixupedBlock ����� ����� ������
    // ������ ���� ��������� ������, � ������ ���������� ����� - ������������ ����� �� ����
    SubscribedLines: TOpcodeSubscribe;

    // "�� ���������" ����, ����������� ������� ������� ��� UnpointerCmd
    FakeBlock: TOpcodeBlock;

    // ���������������� ���������� (����� ��������� ������������� ���������)
    Current: POpcodeBlock;
    CurrentRefId: dword;
    StartBlock: integer;
    TopResult: PFixupedBlock;

    // ����������� ������� ������������� ������
    BlocksCount: integer;
    BlocksAvailable: integer; // ���������� ��������� � ������ ������
    Blocks: PFixupedBlockArray; // ������� ������ ������ (���� �� ����� @BlocksBuffer - �� ������� � ����)
    EndBlock: PFixupedBlock; // ��������� (Ret-) ����. ����� ��� ����������

    // ������ ��������� �������, ��������������� NO_JUMP
    LocalJumpsCount: integer;
    LocalJumps: PLocalJumpsArray;

    {$ifdef OPCODE_MODES}
      TextBuffer: pansichar;
      // ���������� �� ������ (����� ������ ��� ��������� �������)
      LabelCount: integer;
      LabelLength: integer;
      // ����� �������� ������ 
      BinaryBuffer: pointer;
      BinarySize: integer;
    {$endif}

    // ������ ������� ������, �� ������� ���� ������
    References: PWordArray;

    // �������� ������� �������������� ������� ret(n),
    // ������� ����� ��� ���������� ����� ��� ��������
    LastRetCmd: record {TOpcodeCmd}
      Cmd: TOpcodeCmd;
      case Integer of
        0: (c3: byte);
        1: (c2: byte; i16: word);
        2: (arm_value: integer);
        {$ifdef OPCODE_MODES}
        3: (Str: PShortString; Chars: string[9]{ret 65535});
        {$endif}
    end;

    // ����������� ��������� ����������
    // ��� ������� ����������� (� ��������� ����������) �������
    JumpsInfo: record
      // ������� �������� � ������ ������
      small_sizes: array[-2{call,jmp}..ord(high(intel_cc))] of byte;
      big_sizes: array[-2{call,jmp}..ord(high(intel_cc))] of byte;

      // ������������������ ������� ��� �����������, ����� �� ������,
      // ���� �������� ��������, ������������� ������ �� ������
      //
      // �������� ��� intel ����� ������� ������ ���� -126 <= offset <= 131
      low_ranges: array[-2{call,jmp}..ord(high(intel_cc))] of integer;
      high_ranges: array[-2{call,jmp}..ord(high(intel_cc))] of integer;

      // ����� (��� ��������� ����������)
      {$ifdef OPCODE_MODES}
         names: ^TLocalJumpsNames{^array[-2..ord(high(intel_cc))] of PShortString};
      {$endif}
     end;

    // ������ �� �����, ������� ������ � ����������� �������
    BlocksBuffer: array[0..STACK_BUFFERED_SIZE-1] of TFixupedBlock;
    LocalJumpsBuffers: array[0..STACK_BUFFERED_SIZE-1+1] of PFixupedBlock;
    ReferencesBuffer: array[0..STACK_BUFFERED_SIZE-1] of word;
  end;



// ��������� ��������� ������ ������ �����
// �� �������� ������ ����������� ����������� �� �����
// �� �� ������ ������ ���������� �����
procedure GrowFixupedBlocks(var Storage: TFixupedStorage);
begin
  with Storage do
  begin
    BlocksAvailable := BlocksAvailable*2;

    if (Blocks = pointer(@BlocksBuffer)) then
    begin
      GetMem(Blocks, BlocksAvailable*sizeof(TFixupedBlock));
      CopyMemory(Blocks, @BlocksBuffer, sizeof(BlocksBuffer));
    end else
    begin
      ReallocMem(Blocks, BlocksAvailable*sizeof(TFixupedBlock));
    end;
  end;
end;

// �������, ���������� �� ��������� (� ����������) �������
// ������� �� �������� �������� ��������
function UnpointerCmd(var Storage: TFixupedStorage; const CmdPointer: POpcodeCmdPointer): POpcodeCmd;
var
  addr: TOpcodeAddress;
  v_const: TOpcodeConst;
  p_const: ^const_32;

  callback: TMethod;
begin
  pinteger(@addr.F.Bytes)^ := CmdPointer.addr_kind and $00ffffff; // addr + kind=ckValue
  v_const.Kind := ckValue;
  callback.Data := nil;
  callback.Code := CmdPointer.callback;

  // ��������
  case byte(CmdPointer.addr_kind shr 24) of
    0: begin
         v_const.F.Value := pinteger(CmdPointer.pvalue)^;
         CmdPointer.diffcmd._0(Storage.FakeBlock, CmdPointer.params, const_32(v_const),
                               opused_callback_0(callback){$ifdef OPCODE_MODES},CmdPointer.cmd_name^{$endif});
       end;
    1: begin
         addr.offset.F.Value := pinteger(CmdPointer.pvalue)^;
         CmdPointer.diffcmd._1(Storage.FakeBlock, CmdPointer.params, addr,
                               opused_callback_1(callback){$ifdef OPCODE_MODES},CmdPointer.cmd_name^{$endif});
       end;
    2: begin
         p_const := CmdPointer.pvalue;
         addr.offset := p_const^;
         if (addr.offset.Kind = ckPValue) then
         begin
           addr.offset.Value := addr.offset.pValue^;
           addr.offset.Kind := ckValue;
         end;

         inc(p_const);
         v_const := p_const^;
         if (v_const.Kind = ckPValue) then
         begin
           v_const.F.Value := v_const.F.pValue^;
           v_const.Kind := ckValue;
         end;

         CmdPointer.diffcmd._2(Storage.FakeBlock, CmdPointer.params, addr, const_32(v_const),
                               opused_callback_2(callback){$ifdef OPCODE_MODES},CmdPointer.cmd_name^{$endif});
       end;
    3: begin
         v_const.F.Value64 := pint64(CmdPointer.pvalue)^;
         CmdPointer.diffcmd._3(Storage.FakeBlock, CmdPointer.params, const_64(v_const),
                               opused_callback_3(callback){$ifdef OPCODE_MODES},CmdPointer.cmd_name^{$endif});
       end;
  end;

  Result := Storage.FakeBlock.CmdList;
  Storage.Proc.FLastBinaryCmd := NO_CMD;
end;


// ������������ ��� �� ��������������� �������,
// ������� ���������� ���� ����� ����, �������� ��� ��� ����� Fixuped-������
function AddFixupedBlocksLineAsLink(var Storage: TFixupedStorage; const CurrentResult: PFixupedBlock; Block: POpcodeBlock=nil): PFixupedBlock; forward;

// ������������ ����������� �������. �� �������� ������ ����� ����� ����� ����
// ������ ������� - ���������� ����� ������, ��������� ������ ������, ��������� ��� ����������� ����
// � ����� ���������� � ����������� � ������������������ ����������� � ���������� �������
//
// �������� �������� ����� �������, ��� ������� ����������� �����,
// � ����� ������ �������� �� ���� ��������� ������� - ����������� �������������
procedure AddFixupedBlocksLine(var Storage: TFixupedStorage{; const OpcodeBlock: POpcodeBlock});
label
  line_loop, opcodeblock_loop, line_loop_continue, line_loop_finished,
  first_iteration, second_iteration;
var
  Result: PFixupedBlock;
  OpcodeBlock: POpcodeBlock;
  Reference: integer;
  flags: integer{������������� ����-���������};
  AdvBlocksCount: integer;
  BottomCmd, Cmd: POpcodeCmd;

  Subscr: POpcodeSubscribe;
  i, Fixuped: integer;
  JoinedData: POpcodeJoinedData;
begin
  // ��������� OpcodeBlock � ������ �����, ������� ����� ����� ���������
  if (Storage.SubscribedLines.Block = nil) then
  begin
    Storage.SubscribedLines.Block := Storage.Current{OpcodeBlock};
  end else
  begin
    with Storage.Heap do
    begin
      Subscr := FState.Current;
      if (FState.Margin >= sizeof(TOpcodeSubscribe)) then
      begin
        Inc(NativeInt(FState.Current), sizeof(TOpcodeSubscribe));
        Dec(FState.Margin, sizeof(TOpcodeSubscribe));
      end else
      begin
        Subscr := Alloc(sizeof(TOpcodeSubscribe));
      end;
    end;

    Subscr.Block := Storage.Current{OpcodeBlock};
    Subscr.Next := Storage.SubscribedLines.Next;
    Storage.SubscribedLines.Next := Subscr;
  end;

  flags := Storage.BlocksCount;    
  Storage.StartBlock := flags;

  // ����� ������ ������������� �����-�� ������ (���������� ��� OpcodeBlock)
  // �� ���� nil (ret(n)/������ � �����), ���� ������ ��� ������������ ���� (������ � ����)
  // ������� ������������ ����� ����������� RefId �� CurrentRefId
  // Current - ��� ���, � �������� ���� �������� ����������
line_loop:
  begin
    // ���� ���� Current ��� ������ ������ ������, ����������� � ����� ��������� -
    // ������������� ���� �������� (�����������) � ����� ������
    {$ifdef OPCODE_TEST}
      if (flags = NO_FIXUPED) then raise_parameter;
    {$endif}
    if (flags = Storage.BlocksAvailable) then GrowFixupedBlocks(Storage);
    Result := @Storage.Blocks[flags];
    OpcodeBlock := Storage.Current;
    OpcodeBlock.O.Fixuped := flags;

    // ����������� RefId (������� ������� CurrentRefId)
    Result.RefId := Storage.CurrentRefId;     
    // inc(Storage.BlocksCount);
    Storage.BlocksCount := flags+1;
    // �������������� OpcodeBlock
    // ���� �� ������ - ��� �� ��������� ��������
    // + ���� ���� ������� ������ - ��������� 1 (� ����������� � ������)
    // ���� ������ ������������� (nil) ��� ��������� � �����-�� ��������� ���� - ������� ����
    opcodeblock_loop:
    begin
      // ����� Fixuped-�����
      OpcodeBlock.O.Fixuped := flags;

      // ������� ������
      Reference := OpcodeBlock.O.Reference;
      if (Reference <> NO_REFERENCE) then
      begin
        inc(Result.RefId);
        Storage.References[Reference] := flags;
      end;

      // ����������� ���� � ����� - �� �������
      Storage.Current := OpcodeBlock;

      // ���� ������ - ��� �� ��������� ��������
      if (OpcodeBlock.CmdList = nil) then
      begin
        OpcodeBlock := OpcodeBlock.N.Next;
        if (OpcodeBlock = nil) or (OpcodeBlock.O.Fixuped <> NO_FIXUPED) then
        begin
          Storage.Current := OpcodeBlock;
          goto line_loop_finished;
        end;  

        goto opcodeblock_loop;
      end;
    end;

    // ��������� ����� Current � �������������(�) ����(�) Result
    // ������������� ����� ����� ��������� ����
    (*TFixupedKind = (fkEmpty, // ������ ���� (��� ������������ ����� ����� ���������. � ���� ������ ���� value ����� 0)
                   fkNormal, // ����������� ��������
                    fkLeave, // ret(n), leave, jmp reg, jmp mem
              fkLeaveJoined, // jmp [... + offset ...]
                   fkJoined, // add edx, [... + offset ...] / mov esi, offset @1
          fkGlobalJumpBlock, // call axml_get_attribute / jne PRE_cmd_ptr_addr_const
           fkLocalJumpBlock, // jnle @2 / call @Specifier
                   fkInline  // pop esi, pop edi, ret
                   );*)

    // �� ������ �������� ������ ����������� ������������������ ������,
    // ������� ������� �������, ������� �� ����� �������.
    BottomCmd := OpcodeBlock.CmdList;
    AdvBlocksCount := -1;
    flags := 0{0 ��������, ��� ��� "�������"(fkNormal) ������� ������ "�����������" � �����������};
    Storage.CurrentRefId := REFID_ISNEXT{�� ��������� ����� ������� ������ ���� ����� ��������� ����� � ������� �����������. �� ����� ���� ���������� (cmLeave)};
    Cmd := BottomCmd;
    first_iteration:
    begin
      case Cmd.Mode of
           cmLeave, {cmLeave � cmJumpBlock ���������� ������, ��� ��� ����������� + ������ case �������}
       cmJumpBlock: begin
                      // fkLeave, fkLocalJumpBlock ��� fkGlobalJumpBlock 
                      flags := 0;
                      inc(AdvBlocksCount);

                      if (Cmd.Mode = cmLeave) or {cmJumpBlock}(Cmd.F.cc_ex = -1) then
                      begin
                        // ret(n), leave, jmp reg/mem/Block
                        BottomCmd := Cmd;
                        AdvBlocksCount := 0;
                        Storage.CurrentRefId := 0;
                      end;
                    end;
          cmJoined: begin
                      // fkJoined ��� fkLeaveJoined
                      flags := 0;
                      inc(AdvBlocksCount);

                      if (TOpcodeCmdMode(Cmd.Param shr 2) = cmLeave) then
                      begin
                        // jmp mem - fkLeaveJoined
                        BottomCmd := Cmd;
                        AdvBlocksCount := 0;
                        Storage.CurrentRefId := 0;
                      end;

                      Cmd := Cmd.Next;
                    end;
         cmPointer: begin
                      // ��� Pointer ����� ���������� ����� �������,
                      // � ����� ������ ��� �� ����� ��������� ����
                      flags := 0;
                      inc(AdvBlocksCount);

                      // �� ���� ��� jmp [mem] - �� ��������
                      if (Cmd.Param and 2 <> 0) then
                      begin
                        BottomCmd := Cmd;
                        AdvBlocksCount := 0;
                        Storage.CurrentRefId := 0;
                      end
                    end;
        else
          {cmBinary/Text:}
          // ������� ��������/��������� �������
          inc(AdvBlocksCount, ord(flags=0));
          inc(flags);
        end;

      // next
      Cmd := Cmd.Next;
      if (Cmd <> nil) then goto first_iteration;
    end;

    // ��� ���� ������� ������ - ������ �������
    if (AdvBlocksCount = 0) and (flags <> 0) then
    begin
      flags := (flags shl 8) + ord({Kind}fkNormal);
      Result.Cmd := BottomCmd;
      Result.Value := flags;
      goto line_loop_continue;
    end;

    // ������� ���������� �������� ������ ���������� ������������� ������
    begin
      flags{����� ���������� ������} := AdvBlocksCount + Storage.BlocksCount;
      Storage.BlocksCount := flags;
      {$ifdef OPCODE_TEST}
        if (flags > NO_FIXUPED) then raise_parameter;
      {$endif}
      while (flags > Storage.BlocksAvailable) do GrowFixupedBlocks(Storage);
      Storage.TopResult := Result;
      Result := @Storage.Blocks[flags-1];
    end;

    // ���� ���������� ������������� ������
    flags := 0{0 ��������, ��� ������� ���� ��� �� fkNormal � � ���� ������ "�����������"};
    second_iteration:
    begin
      // ���� ������� ������������ - ������ ���� � ������������� �� ����������� ����
      // � ��������� ����, �����������, ��� ������� �� ����� ����������� � ���������� ���������

      Cmd := BottomCmd;
      if (BottomCmd.Mode = cmPointer) then
      begin
        Cmd := UnpointerCmd(Storage, POpcodeCmdPointer(BottomCmd));
        flags := 0;
      end;

      case Cmd.Mode of
           cmLeave: begin
                      Result.Kind := fkLeave;
                      Result.Cmd := Cmd;
                      flags := 0;
                    end;
       cmJumpBlock: begin
                      Result.cc_ex := Cmd.F.cc_ex;
                      flags := 0;

                      if (POpcodeCmdJumpBlock(Cmd).Proc = Storage.Proc) then
                      begin
                        // ��������� ������
                        Result.Kind := fkLocalJumpBlock;
                        POpcodeBlock(Result.Cmd) := POpcodeCmdJumpBlock(Cmd).Block{!!! ����� ����� ������������� � Fixuped};
                      end else
                      begin
                        // ���������� ������
                        Result.Kind := fkGlobalJumpBlock;
                        {$ifdef OPCODE_MODES}
                        if (Storage.Mode <> omBinary) then
                        begin
                          // ��������� ���������� ������
                          Result.ProcName := POpcodeCmdJumpBlock(Cmd).ProcName;
                        end else
                        {$endif}
                        begin
                          // �������� ���������� ������
                          Result.Proc := POpcodeCmdJumpBlock(Cmd).Proc;
                          Result.Reference := POpcodeCmdJumpBlock(Cmd).Reference;
                        end;
                      end;
                    end;
          cmJoined: begin
                      Result.Kind := fkJoined;
                      Result.Cmd := Cmd;
                      flags := 0;

                      if (TOpcodeCmdMode(Cmd.Param shr 2) = cmLeave) then
                      begin
                        // jmp mem
                        Result.Kind := fkLeaveJoined;
                      end;

                      // Bottom ��������� �� ���������
                      // ������ � ����������� (�� cmPointer) ������
                      if (Cmd = BottomCmd) then BottomCmd := BottomCmd.Next;
                    end;
        else
          {cmBinary/Text:}
          // ������� ��������/��������� �������
          // ����������� ������� � � ������ ���� ����������� Kind ������ fkNormal
          if (flags = 0) then
          begin
            flags := $0100 or ord(fkNormal);
            Result.Cmd := Cmd;
          end else
          begin
            inc(flags, $0100);
            inc(Result);
          end;
          Result.Value := flags;

          if (Cmd <> BottomCmd{cmPointer}) then
          flags := 0;
        end;

      BottomCmd := BottomCmd.Next;
      if (BottomCmd <> nil) then
      begin
        if (Result <> Storage.TopResult) then Result.RefId := REFID_ISNEXT;
        dec(Result);
        goto second_iteration;
      end;  
    end;

    // ������� ��������� ���� � �����
    // ���� ����� ��� ��� ��������� ���� - ������ ���������
    line_loop_continue:    
    OpcodeBlock := Storage.Current.N.Next;
    flags := Storage.BlocksCount;
    Storage.Current := OpcodeBlock;
    if (OpcodeBlock <> nil) and (OpcodeBlock.O.Fixuped = NO_FIXUPED) then goto line_loop;
    // ����� ����������� - �������� ����
    if (flags = Storage.BlocksAvailable) then GrowFixupedBlocks(Storage);
    {$ifdef OPCODE_TEST}
      if (flags = NO_FIXUPED) then raise_parameter;
    {$endif}
    Result := @Storage.Blocks[flags];
    Result.RefId := REFID_ISNEXT;
    Storage.BlocksCount := flags+1;
  end{���� �� ���� Next-������ � OpcodeBlock};

  // � �������� ����� ��������� ���� � ����� ������
  // ��� ���� ��������� ���� (�������� ����������� nil)
  // ���� ���������� ���� (�������� ����������� ��������)
  // � ����������� �� �������� ����������� �������������� ������������� ����
  line_loop_finished:
  Result.Kind := fkLocalJumpBlock;
  Result.cc_ex := -1{jmp};
  Result.Cmd := pointer(Storage.Current);

  // � ������� ����� �������� �� ���� ����������� ������ � ���������� ��������� RefId
  // ������ ������. ��� ������������� - �������� ����������� ���������� ������
  // ���������� ������� ����� ���������, �� �� ���� ��� ������� ���������� � ��� �� ���������
  Result := @Storage.Blocks[Storage.StartBlock];
  for i := Storage.StartBlock to Storage.BlocksCount-1 do
  begin
  
    case Result.Kind of
      fkLeaveJoined,
           fkJoined:
           begin
             JoinedData := @POpcodeCmdJoined(Result.Cmd).Data[0];
             if (JoinedData.Proc = Storage.Proc) then
             begin
               OpcodeBlock := JoinedData.Block;
               Fixuped := OpcodeBlock.O.Fixuped;

               if (Fixuped <> NO_FIXUPED) then Inc(Storage.Blocks[Fixuped].RefId)
               else
               Result := AddFixupedBlocksLineAsLink(Storage, Result, OpcodeBlock);
             end;

             //inc(JoinedData);
             if (Result.Cmd.Param and 3 = 3) then
             begin
               JoinedData := @POpcodeCmdJoined(Result.Cmd).Data[1];
               if (JoinedData.Proc = Storage.Proc) then
               begin
                 OpcodeBlock := JoinedData.Block;
                 Fixuped := OpcodeBlock.O.Fixuped;

                 if (Fixuped <> NO_FIXUPED) then Inc(Storage.Blocks[Fixuped].RefId)
                 else
                 Result := AddFixupedBlocksLineAsLink(Storage, Result, OpcodeBlock);
               end;
             end;
           end;
   fkLocalJumpBlock:
           begin
             OpcodeBlock := POpcodeBlock(Result.Cmd);
             if (OpcodeBlock = nil) then
             begin
               // ������ � �����, ����� ����� �������� ���������� Fixuped
               Result.Fixuped := NO_FIXUPED;
             end else
             begin
               // ������ � ���������� ����
               // ���� ��������� ������, ���� ����� ��������
               // � ��������� �� ������ ������������
               Fixuped := OpcodeBlock.O.Fixuped;
               if (Fixuped <> NO_FIXUPED) then
               begin
                 Result.Fixuped := Fixuped;
                 Inc(Storage.Blocks[Fixuped].RefId);
               end else
               begin
                 Result := AddFixupedBlocksLineAsLink(Storage, Result);
               end;
             end;
           end;
    end;

    inc(Result);
  end;
end{�������};

// ��������������� �������,
// ������� ���������� ���� ����� ����, �������� ��� ��� ����� Fixuped-������
function AddFixupedBlocksLineAsLink(var Storage: TFixupedStorage; const CurrentResult: PFixupedBlock; Block: POpcodeBlock=nil): PFixupedBlock;
var
  Offset: NativeInt;
begin
  Offset := NativeInt(CurrentResult)-NativeInt(Storage.Blocks);

  if ({���� � CurrentResult ����� ������}Block = nil) then
  begin
    CurrentResult.Fixuped := Storage.BlocksCount;
    Block := POpcodeBlock(CurrentResult.Cmd);
  end;

  Storage.Current := Block;
  Storage.CurrentRefId := 1;
  AddFixupedBlocksLine(Storage);

  Result := pointer(NativeInt(Storage.Blocks)+Offset);
end;



const
  // �������� �������
  // ����� ��� inline-�����������
  intel_cc_invert: array[0..ord(high(intel_cc))] of intel_cc = (_no,_o,_nb,_nc,_ae,_nae,_b,_c,
  _ne,_nz,_z,_e,_nbe,_na,_na,_be,_ns,_s,_np,_po,_pe,_p,_nl,_ge,_nge,_l,_nle,_g,_ng,_le);

  
  // ����� ������� ���������� �� ������ ��������
  // call-->jmp (� ��� ����� cc) �������������� �����, �� jmp/call-->call ������
  // X <= Y ���� mask[X] and mask[Y] = mask[X]
  //
  // �� ��������� ������� ����� ������������� ��� ����� ��� and-�������
  // ������� ������� ������ ���������� ����� ����� cf/sf<>of/zf
  _csoz_000 = (1 shl 0);
  _csoz_001 = (1 shl 1);
  _csoz_010 = (1 shl 2);
  _csoz_011 = (1 shl 3);
  _csoz_100 = (1 shl 4);
  _csoz_101 = (1 shl 5);
  _csoz_110 = (1 shl 6);
  _csoz_111 = (1 shl 7);

  _cf_0 = _csoz_000 or _csoz_001 or _csoz_010 or  _csoz_011;
  _cf_1 = _csoz_100 or _csoz_101 or _csoz_110 or  _csoz_111;
  _sfof_0{sf=of} = _csoz_000 or _csoz_001 or _csoz_100 or _csoz_101;
  _sfof_1{sf<>of} = _csoz_010 or _csoz_011 or _csoz_110 or _csoz_111;
  _zf_0 = _csoz_000 or _csoz_010 or _csoz_100 or _csoz_110;
  _zf_1 = _csoz_001 or _csoz_011 or _csoz_101 or _csoz_111;

  _cf_0_zf_0{��� ja/jnbe} = _csoz_000 or _csoz_010;
  _sfof_0_zf_0{��� jg/jnle} = _csoz_000 or _csoz_100;

  _of_0 = (1 shl 8);
  _of_1 = (1 shl 9);
  _sf_1 = (1 shl 10);
  _sf_0 = (1 shl 11);
  _pf_1 = (1 shl 12);
  _pf_0 = (1 shl 13);

  // call ����� ������� ������ � jmp
  // � ���� �������� call �������� 0, ����� ������� X = X & Y �������� ���������
  _call_f = (1 shl 15);
                               
  // ������� ������ �����
  // ���� src = src & dest - �� ����� ����� ������� ������, ����� ���� ������
  // ���� src = src & ignore - �� ����� ������� �� � ��� �������(���������), � � ���������
  jmp_src_mask: array[-2{call,jmp}..ord(high(intel_cc))] of word =
  (
    _call_f{call},
    $ffff{jmp},
    _of_1{_o},
    _of_0{_no},
    _cf_1,_cf_1,_cf_1{_b,_c,_nae},
    _cf_0,_cf_0,_cf_0{_ae,_nb,_nc},
    _zf_1,_zf_1{_e,_z},
    _zf_0,_zf_0{_nz,_ne},
    _cf_1 or _zf_1, _cf_1 or _zf_1{_be,_na},
    _cf_0_zf_0, _cf_0_zf_0{_a,_nbe},
    _sf_1{_s},
    _sf_0{_ns},
    _pf_1,_pf_1{_p,_pe},
    _pf_0,_pf_0{_po,_np},
    _sfof_1,_sfof_1{_l,_nge},
    _sfof_0,_sfof_0{_ge,_nl},
    _zf_1 or _sfof_1,_zf_1 or _sfof_1{_le,_ng},
    _sfof_0_zf_0,_sfof_0_zf_0{_g,_nle}
  );

  // ���� src = src & dest - �� ����� ����� ������� ������, ����� ���� ������
  // �� � call ��� ������� ������
  jmp_dest_mask: array[-2{call,jmp}..ord(high(intel_cc))] of word =
  (
    0,{call}
    $ffff{jmp},
    _of_1{_o},
    _of_0{_no},
    _cf_1,_cf_1,_cf_1{_b,_c,_nae},
    _cf_0,_cf_0,_cf_0{_ae,_nb,_nc},
    _zf_1,_zf_1{_e,_z},
    _zf_0,_zf_0{_nz,_ne},
    _cf_1 or _zf_1, _cf_1 or _zf_1{_be,_na},
    _cf_0_zf_0, _cf_0_zf_0{_a,_nbe},
    _sf_1{_s},
    _sf_0{_ns},
    _pf_1,_pf_1{_p,_pe},
    _pf_0,_pf_0{_po,_np},
    _sfof_1,_sfof_1{_l,_nge},
    _sfof_0,_sfof_0{_ge,_nl},
    _zf_1 or _sfof_1, _zf_1 or _sfof_1{_le,_ng},
    _sfof_0_zf_0, _sfof_0_zf_0{_g,_nle}
  );

  // � ������ ���� ������ ������ �������������� �� ��������� - ��� ����� ����������
  // �������� jg --> jz, �� call � jmp ���������� �� �������
  // ��������� ���: jmp_src_mask[X] = jmp_src_mask[X] and jmp_ignore_mask[Y]
  //
  // ������ ������ jmp_ignore_mask ��������� jmp_invert_mask
  // ������ ��� ������� ��� �� ��������������(���������������) ������
  jmp_ignore_mask: array[-2{call,jmp}..ord(high(intel_cc))] of word =
  (
    0{call ���������� �� �������},
    0{jmp ���� ���������� �� �������},
    _of_0{_o},
    _of_1{_no},
    _cf_0,_cf_0,_cf_0{_b,_c,_nae},
    _cf_1,_cf_1,_cf_1{_ae,_nb,_nc},
    _zf_0,_zf_0{_e,_z},
    _zf_1,_zf_1{_nz,_ne},
    _cf_0_zf_0, _cf_0_zf_0{_be,_na},
    _cf_1 or _zf_1, _cf_1 or _zf_1{_a,_nbe},
    _sf_0{_s},
    _sf_1{_ns},
    _pf_0,_pf_0{_p,_pe},
    _pf_1,_pf_1{_po,_np},
    _sfof_0,_sfof_0{_l,_nge},
    _sfof_1,_sfof_1{_ge,_nl},
    _sfof_0_zf_0, _sfof_0_zf_0{_le,_ng},
    _zf_1 or _sfof_1, _zf_1 or _sfof_1{_g,_nle}
  );

  // ������ ����������� �������
  // ����� jump1 A / jump2 A --> X ===> jumpSUM A
  // included_jumps: array[-2{call,jmp}..ord(high(intel_cc)), -2{call,jmp}..ord(high(intel_cc))] of shortint;
  // ������[X, Y]: X*included_jumps_pitch+Y
  (* ��� �������:
    mask := jmp_src_mask[X] or jmp_src_mask[Y];
    for i := -1 to ord(high(intel_cc)) do if (jmp_src_mask[i] = mask) ...
  *)
  included_jumps_pitch{=32} = 2{call/jmp}+ord(high(intel_cc))+1;
  included_jumps: array[-2*included_jumps_pitch-2..high(jmp_src_mask)*included_jumps_pitch+high(jmp_src_mask)] of shortint = (
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},
  -1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},
  -1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-1{jmp},-2{none},-1{jmp},ord(_o),-1{jmp},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-1{jmp},-1{jmp},ord(_no),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},ord(_b),ord(_c),
  ord(_nae),-1{jmp},-1{jmp},-1{jmp},ord(_be),ord(_be),-2{none},-2{none},ord(_be),ord(_na),-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-1{jmp},-2{none},-2{none},ord(_b),ord(_c),ord(_nae),-1{jmp},-1{jmp},-1{jmp},ord(_be),ord(_be),-2{none},-2{none},
  ord(_be),ord(_na),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},ord(_b),ord(_c),ord(_nae),-1{jmp},
  -1{jmp},-1{jmp},ord(_be),ord(_be),-2{none},-2{none},ord(_be),ord(_na),-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},
  -2{none},-2{none},-1{jmp},-1{jmp},-1{jmp},ord(_ae),ord(_nb),ord(_nc),-2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},
  ord(_ae),ord(_ae),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-1{jmp},-1{jmp},-1{jmp},ord(_ae),ord(_nb),ord(_nc),-2{none},
  -2{none},-2{none},-2{none},-1{jmp},-1{jmp},ord(_nb),ord(_nb),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-1{jmp},
  -1{jmp},-1{jmp},ord(_ae),ord(_nb),ord(_nc),-2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},ord(_nc),ord(_nc),-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-1{jmp},-2{none},-2{none},ord(_be),ord(_be),ord(_be),-2{none},-2{none},-2{none},ord(_e),ord(_z),-1{jmp},-1{jmp},
  ord(_be),ord(_na),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_le),ord(_le),-2{none},
  -2{none},ord(_le),ord(_ng),-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},ord(_be),ord(_be),ord(_be),-2{none},
  -2{none},-2{none},ord(_e),ord(_z),-1{jmp},-1{jmp},ord(_be),ord(_na),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},ord(_le),ord(_le),-2{none},-2{none},ord(_le),ord(_ng),-2{none},-2{none},-2{none},-1{jmp},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},ord(_nz),ord(_ne),-1{jmp},-1{jmp},ord(_nz),
  ord(_nz),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},
  ord(_nz),ord(_nz),-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},
  -1{jmp},ord(_nz),ord(_ne),-1{jmp},-1{jmp},ord(_ne),ord(_ne),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},ord(_ne),ord(_ne),-2{none},-1{jmp},-2{none},-2{none},ord(_be),
  ord(_be),ord(_be),-1{jmp},-1{jmp},-1{jmp},ord(_be),ord(_be),-1{jmp},-1{jmp},ord(_be),ord(_na),-1{jmp},-1{jmp},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-1{jmp},-2{none},-2{none},ord(_na),ord(_na),ord(_na),-1{jmp},-1{jmp},-1{jmp},ord(_na),ord(_na),-1{jmp},-1{jmp},
  ord(_be),ord(_na),-1{jmp},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_ae),
  ord(_nb),ord(_nc),-2{none},-2{none},ord(_nz),ord(_ne),-1{jmp},-1{jmp},ord(_a),ord(_nbe),-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},
  -2{none},-2{none},-2{none},-2{none},-2{none},ord(_ae),ord(_nb),ord(_nc),-2{none},-2{none},ord(_nz),ord(_ne),-1{jmp},
  -1{jmp},ord(_a),ord(_nbe),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_s),-1{jmp},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-1{jmp},ord(_ns),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_p),ord(_pe),-1{jmp},
  -1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},ord(_p),ord(_pe),-1{jmp},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},ord(_po),ord(_np),
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-1{jmp},-1{jmp},ord(_po),ord(_np),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_le),ord(_le),
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_l),
  ord(_nge),-1{jmp},-1{jmp},ord(_le),ord(_ng),-2{none},-2{none},-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},ord(_le),ord(_le),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},ord(_l),ord(_nge),-1{jmp},-1{jmp},ord(_le),ord(_ng),-2{none},-2{none},
  -2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},
  ord(_ge),ord(_nl),-1{jmp},-1{jmp},ord(_ge),ord(_ge),-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-1{jmp},-1{jmp},ord(_ge),ord(_nl),-1{jmp},-1{jmp},ord(_nl),ord(_nl),-2{none},-1{jmp},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_le),ord(_le),-1{jmp},-1{jmp},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_le),ord(_le),-1{jmp},-1{jmp},
  ord(_le),ord(_ng),-1{jmp},-1{jmp},-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},ord(_ng),ord(_ng),-1{jmp},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},ord(_ng),ord(_ng),-1{jmp},-1{jmp},ord(_le),ord(_ng),-1{jmp},-1{jmp},-2{none},-1{jmp},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_nz),ord(_ne),-2{none},-2{none},-2{none},
  -2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},ord(_ge),ord(_nl),-1{jmp},-1{jmp},
  ord(_g),ord(_nle),-2{none},-1{jmp},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},ord(_nz),ord(_ne),-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},-2{none},
  -2{none},-2{none},ord(_ge),ord(_nl),-1{jmp},-1{jmp},ord(_g),ord(_nle));



// ������������ ����������� �������,
// ������ ������� �������� ���� � ����������������� �������� ������
// label-��� �������, ����� �� ��������� ������������� �� ��������� � �����
procedure RemoveFixupedBlock(var Storage: TFixupedStorage; B: PFixupedBlock);
label
  loop, loop_end;
var
  N: array[0..1] of PFixupedBlock;
  i, RefId: integer;
begin
  //while (true) do
  loop:
  begin
    // ���� ����� ��������� �� ������ �����
    // ���������� ��, ����� ����� ��������� ������ 
    N[0] := nil;
    N[1] := N[0]{nil};
    case B.Kind of
        fkLeaveJoined,
             fkJoined: begin
                         for i := 0 to 1 do
                         with POpcodeCmdJoined(B.Cmd).Data[i] do
                         begin
                           if (Global = Storage.Proc) then
                           N[i] := @Storage.Blocks[Block.O.Fixuped];

                           if (B.Cmd.Param and 3 <> 3) then break;
                         end;
                       end;
     fkLocalJumpBlock: begin
                         RefId := B.Fixuped;
                         if (RefId <> NO_FIXUPED{����� ���� ��� �� "���������" ������}) then N[0] := @Storage.Blocks[RefId];
                       end;
             fkInline: begin
                         if (B.cc_ex >= 0) then
                         N[0] := @PFixupedBlockArray(B)^[1];
                       end;
    end; 

    RefId := 0;
    B.Value := RefId{Kind := fkEmpty};
    {$ifdef OPCODE_MODES}
      B.HybridSize_Min := RefId;
      B.HybridSize_Max := RefId;
    {$else}
      B.Size := RefId;
    {$endif}

    // ���� ������� ���������� ������(��) �������(�) - ��������� ������� ������ ���
    for i := 0 to 1 do
    if (N[i] <> nil) then
    begin
      RefId := N[i].RefId-1;
      N[i].RefId := RefId;
      if (RefId(*{$ifdef OPCODE_MODES} shl 1{$endif}*) = 0) then RemoveFixupedBlock(Storage, N[i]);
    end;

    // �������������� ������ �������� ����� �������� ������������, ������������ �������� ����
    // ������������ ����� �������������� ��������� �������:
    // "���� ����" ����� ��������� ISNEXT ���� � ������� ����� ��� ������ �������� ���� ���� ������ 
    RefId := B.RefId;
    inc(B);
    if (RefId(*{$ifdef OPCODE_MODES} shl 1{$endif}*) <> 0) then goto loop_end;
    // � ��� ����� ������ �� �������� - ������� ������ ISNEXT-� ��������� ����
    RefId := B.RefId and (not REFID_ISNEXT);
    B.RefId := RefId;
    // ���� � ���� ����� �� �������� ������ - �� ���������� �������
    if (RefId(*{$ifdef OPCODE_MODES} shl 1{$endif}*) = 0) then goto loop;
  end;
  loop_end:
end;

const
  // ���������, ������� �������� ����� ���������� ������
  // ���c�� ��������� �������
  NO_JUMP = PFixupedBlock(NativeInt(-1));

  // ����� �����!
  //
  // � � ����������� x86-64, � � ����������� ARMv7 Thumb
  // ������ ������ ������ ����� 2� ������.
  // �������� �� ������� ����� �������������� �������, ��� ���� �� ����������.
  // �� � ������� ����������� � ���������� ������� Delphi ������ �������������
  // ���������� ���������� � ��������. ������� � ������ �������� �������� ������
  // ������ ������ ����������. � ������ ������� � ����������� - � ����� ������ ���������� �������.
  //
  // ������ small_sizes � TFixupedStorage �������
  // �� ������ ��� ���� ����� � ����� ������� ����������� ������������� ����� ������ �� ������
  // (����������� ��� ��� ������ ������� � ��� call)
  // ����� ���� ������ ����� ����, ��� � VM ������ �� ����� ����� �������.
  // �� ���� ��� ����� - ��� ������� ���� �������� � 2 �����.
  SMALL_JUMP_SIZE = 2;


  // ��� ��������� ����� ��� ����, ����� �������� ��������� ������ (� �������)
  // ��� ���������� � ��� ������, ����� OffsetMin �� ����� OffsetMax
  {$ifdef OPCODE_MODES}
     JUMP_OFFSET_TEXT = low(integer);
  {$endif}



// ������������� ����������� �������,
// ������� ������ ��������� ��������:
// 0) jcc A --> jcc B - � ������ ������������� ������� ������ �� �������� �������, ���� ������ ������������ (��� � ������ fkEmpty)
// 1) jcc A / jcc B - ������� ������������� ������ B
// 2) jcc/jmp next - ������ ������� ������
// 3) jcc/jmp A + jcc/jmp A - ���� �������� ����������� �������, ������ �������, � �� ������ ���������� �����������
//
// � ������� ����� ����� ������ while(true)do ������
// �� ��� ������, ��� � ������ ������ ������������ ������������� ���������� �� ���������
//
// ����� ��������� ����������:
//   Current(esi)^ - ������� ������ (�� ������� ��������� �������), ������� �� �������������.
//                   �� ������ �������� � ���������� Next.
//   Next(ebx) - ��������� ������� ����� Current^. ����� ������, ��� �� �� ������� ��� �����������!
//               � ������ ������ Next(�� Current^) ������� ������������� ������: ������ 1)
//               � ������ ������ �� Current^ � Next - ������� Current^: ������ 2)
//               ���� Current^ � Next ��������� �� ���� � ��� �� ���� - �� Current^ �������, � � Next ���������� �����������: ������ 3)
//   Dest(edi) - ����������, � ������� ���������� ����, ���� ��������� ������ Current^.
//               Dest ���� ����� ��������� �� ������ - ������� ����� ���� Dest-����.
//   B - ��������� �����
//   Storage(ebp) - ��������� ����� ����������
procedure RemoveExcessJumps(var Storage: TFixupedStorage);
{$ifdef OPCODE_TEST}
const
  EXCEPTION_JUMP_TO_SELF: string = 'Jump to self';
{$endif}  
label
  main_while, for_loop,
  foreach_dest, foreach_next,
  loop_1, loop_1_end, loop_2, loop_2_end, loop_3, loop_4;

var
  Current: ^PFixupedBlock;
  Next, Dest, B: PFixupedBlock;

  has_refs: integer;
  mask: word;
  StackCount: integer;

  // ����������, ������� �������������� ���� � ����
  Stack: record
    mask: word;
    included_cc: shortint;
    Changed: boolean; // ����, �����������, ��� ����������� ��������� (���� �����) - ���� ������� ��� ������� ���� ��������
    {$ifdef CPUX64}align_8: integer;{$endif}

    // ������ ������� �� Current^
    ReJumps: array[0..JUMP_STACK_SIZE-1] of PFixupedBlock;
    BufNext: PFixupedBlock;
  end;
begin
  //while (true) do
  main_while:
  begin
    Stack.Changed := false;
    Current := pointer(Storage.LocalJumps);
    dec(Current);

   // while (true) do
   // begin
    for_loop:
      inc(Current);
      Next := Current^;

      // ������� Next ��������� �� Current^
      // ����� ����� ������ ��������� (next) ���� ����� Current^
    if (Next <> NO_JUMP) then  //if (Next = NO_JUMP) then goto for_loop_end;
    begin
      if (Next = nil) then goto for_loop;
      if (Next.Kind = fkEmpty{���� ��� �����}) then
      begin
        Current^ := nil;
        goto for_loop;
      end;

      // ������� �� ������� call-�
      if (Next.cc_ex = -2) then goto for_loop;

      // �� ������ ����� ���������� ����� Next - �.�. ��������� ���� ����� Current^
      // ���������� Empty � ������������� ������ (����� �������): ������ 1)
      // ����� ����� ����� �������(����) �������� ������ � ���������� �� Current^ � Next
      // ����� �� ��� ���� �����.
      // ��-������, ��� �������� ������������� �������
      // ��-������, ��� ����������� ����������� (����� ��� ��������� ���� � Next ������): ������ 3)
      // � �������� ����� has_refs(-1) ����������� � included_cc, ����� ����� ����� ���� ��������� � �����������
      Stack.mask := jmp_dest_mask[Next.cc_ex]; // ��� Current^ ���������� dest-�����
      has_refs := 0{has_refs := false};
      loop_1:
      begin
        inc(Next);
        inc(has_refs, ord(Next.RefId and (REFID_ISNEXT-1){shl 2} <> 0)){has_refs := true};

        case Next.Kind of
          fkEmpty: goto loop_1;
 fkGlobalJumpBlock,
 fkLocalJumpBlock: begin
                     // ������������� ���� ���� [Next] <= [Current^] (������ ���� �����)
                     // ���� !has_refs �������
                     mask := jmp_src_mask[Next.cc_ex];
                     if (mask = mask and {jmp_dest_mask[Current^]}Stack.mask) then
                     begin
                       if (has_refs = 0){not has_refs} then
                       begin
                         Stack.Changed := true;
                         RemoveFixupedBlock(Storage, Next);
                       end;

                       goto loop_1;
                     end;
                   end;
        end;
      end;
      // ��������� ��� �����������
      Stack.included_cc := ord((has_refs-1) > 0);

      // �� ������ ����� ���������� ��������� Dest ������ (Stack.ReJumps)
      // (�� �������� ���������� ����� � ����������� �������: ������ 0)
      // �� ����� ��� ����, ����� � ����� ��������� ����������� �����������: ������ 3)
      // ����� ���� �������� jmp/jcc Next: ������ 2)
      //
      // ��� ������� ������ �������� �������������� �����������
      Stack.mask := jmp_src_mask[Current^.cc_ex];
      Dest := @Storage.Blocks[Current^.Fixuped];
      B := Dest;
      //while (true) do
      loop_2:
      begin
        {$ifdef OPCODE_TEST}
          // �������� ������ � ����
          if (Dest = Current^) then raise EOpcodeLib.Create(EXCEPTION_JUMP_TO_SELF);
        {$endif}

        case Dest.Kind of
          fkEmpty: ;
 fkGlobalJumpBlock,
 fkLocalJumpBlock: begin
                     if (Stack.mask <> Stack.mask and jmp_ignore_mask[Dest.cc_ex]) then goto loop_2_end;
                   end;
         fkInline: begin
                     if (Stack.mask <> Stack.mask and jmp_dest_mask[Dest.cc_ex]) then goto loop_2_end;
                   end;
        else
          goto loop_2_end;
        end;

        inc(Dest);
        inc(Current^.Fixuped);
        goto loop_2;
      end;
      loop_2_end:
      // � ������ ����������� - �������� ��������� �������� ������
      if (Dest <> B) then
      begin
        inc(Dest.RefId);
        dec(B.RefId);
        if (B.RefId(*{$ifdef OPCODE_MODES} shl 1{$endif}*) = 0) then
        begin
          Stack.Changed := true;
          RemoveFixupedBlock(Storage, B);
        end;
      end;

      // ���������� ��������� ������(����) �������
      // ������ ��������� 2) - ������ � Next
      StackCount := 0;
      //while (true) do
      loop_3:
      begin
        inc(StackCount);

        {$ifdef OPCODE_TEST}
          // �������� ������ � ����
          if (Dest = Current^) then raise EOpcodeLib.Create(EXCEPTION_JUMP_TO_SELF);
        {$endif}

        // ������ � next: ������ 2)
        if (NativeInt(Dest) <= NativeInt(Next)) and (NativeInt(Dest) > NativeInt(Current^)) then
        begin
          // RemoveFixupedBlock(Storage, Current^);
          {
            �������� �������� jcc/jmp Next ��� ������� ������.
            ���������� ���������� ����� REFID_ISNEXT �� ���� Current^+1 �� Next
            ����� ���� ��� ������� (�� �������� �������)
          }
          dec(Dest.RefId);

          Dest := Current^;
          StackCount := 0;
          Dest.Value := StackCount{Kind := fkEmpty};
          {$ifdef OPCODE_MODES}
            Dest.HybridSize_Min := StackCount;
            Dest.HybridSize_Max := StackCount;
          {$else}
            Dest.Size := StackCount;
          {$endif}

          repeat
            Next.RefId := Next.RefId or REFID_ISNEXT;
            dec(Next);
          until (Next = Dest);

          Stack.Changed := true;
          Current^ := nil;
          goto for_loop;
        end;   

        // ������� � �����
        Stack.ReJumps[StackCount-1] := Dest;

        // ������� ��������� (���� ��� ��������)
        if (StackCount <> JUMP_STACK_SIZE) and
           (Dest.Kind = fkLocalJumpBlock) and
           (Stack.mask = Stack.mask and jmp_dest_mask[Dest.cc_ex]) then
        begin
          Dest := @Storage.Blocks[Dest.Fixuped];

          // ���������� Dest �� �����������
          loop_4:
          begin
            case Dest.Kind of
              fkEmpty: ;
     fkGlobalJumpBlock,
     fkLocalJumpBlock: begin
                         if (Stack.mask <> Stack.mask and jmp_ignore_mask[Dest.cc_ex]) then goto loop_3;
                       end;
             fkInline: begin
                         if (Stack.mask <> Stack.mask and jmp_dest_mask[Dest.cc_ex]) then goto loop_3;
                       end;
            else
              goto loop_3;
            end;

            inc(Dest);
            goto loop_4;
          end;
        end;  
      end;

      // �� ��������� ����� �� �������� ���������� ������ [Current^] � [Next]: ������ 3)
      // ���� ��� ��������� � ���� � ��� �� ���� (��� ����������� ������������ ��� Dest �� ����� Next->).
      //
      // � �������� ��� ������� � ��� ������, ����� ����� Current^ � Next ��� ������ �������,
      // ���� Next ��� ��������� ������, � ���� ������ ���������� ����� ������, ������� ����� ���������� 2 ���� ������
      if (Stack.included_cc <> 0){has_refs} or (not (Next.Kind in [fkLocalJumpBlock, fkGlobalJumpBlock])) or (Next.cc_ex = -2) then goto for_loop;
      // �����������
      Stack.included_cc := included_jumps[Current^.cc_ex*included_jumps_pitch+Next.cc_ex];
      if (Stack.included_cc = -2) then goto for_loop;
      // ���������� ������ �� Next
      Stack.mask := jmp_src_mask[Next.cc_ex];
      Stack.BufNext := Next;
      Next := @Storage.Blocks[Next.Fixuped];

      // foreach Dest do
      // foreach Next do
      foreach_dest:
      begin
        Dest := Stack.ReJumps[StackCount-1];
        dec(StackCount);

        foreach_next:
        begin
          // �������� 2)
          if (Dest = Next) then
          begin
            RemoveFixupedBlock(Storage, Current^);

            //Stack.BufNext.cc_ex := Stack.included_cc;
            Next := Stack.BufNext;
            Next.cc_ex := Stack.included_cc;
            if (Next.cc_ex = -1) then
            begin
              // � ������ ���� ����������� ������ - ��� jmp �� � ����� ����
              // ����� ������ REFID_ISNEXT
              inc(Next);
              StackCount := Next.RefId and (not REFID_ISNEXT);
              Next.RefId := StackCount;
              if (StackCount = 0) then  RemoveFixupedBlock(Storage, Next);
            end;

            Stack.Changed := true;
            Current^ := nil;
            goto for_loop;
          end;

          // ������� ��������� Next
          // � ������ �������������� ������ - ����������
          // � ������ ���� ����� ���������� - ��������� � ��������� ������
          case Next.Kind of
            fkEmpty: begin
                       inc(Next);
                       goto foreach_next;
                     end;
  fkGlobalJumpBlock,
   fkLocalJumpBlock: begin
                       if (Stack.mask = Stack.mask and jmp_ignore_mask[Next.cc_ex]) then
                       begin
                         inc(Next);
                         goto foreach_next;
                       end;

                       if (Next.Kind = fkLocalJumpBlock) and
                          (Stack.mask = Stack.mask and jmp_dest_mask[Next.cc_ex]) then
                       begin
                         Next := @Storage.Blocks[Next.Fixuped];
                         goto foreach_next;
                       end;
                     end;
           fkInline: if (Stack.mask = Stack.mask and jmp_dest_mask[Next.cc_ex]) then
                     begin
                       inc(Next);
                       goto foreach_next;
                     end;

          end;
        end;

        if (StackCount <> 0) then
        begin
          Next := @Storage.Blocks[Stack.BufNext.Fixuped];
          goto foreach_dest;
        end;
      end;  

      {next jump} goto for_loop;
    end;

    if (Stack.Changed) then goto main_while;
  end;
end;


// ������� ������� �������� 3 ����:
// 1) ����������, ����� ������ ������ ����� ������� ��������� (������), � ����� ��� ��������� ���������
// 2) ���������� ������ ������
// 3) ���������� ����� ������� �������� ������������������
{$ifdef OPCODE_MODES}
procedure MarkupTextRoutine(var Storage: TFixupedStorage);
var
  i: integer;
  Block: PFixupedBlock;
  CurrentBlockNumber: integer;
  LabelLength: byte;

  BinarySize: integer;
  BinaryMaxSize: integer;
begin
  // ����� �� ������� ������ ����� ���� ��� �� �����
  Dec(Storage.Blocks[0].RefId);
  if (Storage.Proc.RetN = RET_OFF) then Dec(Storage.EndBlock.RefId);

  // ����������� ��������� � �������� �������
  // �� �������� ������ REFID_FLAG_TEXT
  Block := pointer(Storage.Blocks);
  if (Storage.Mode = omAssembler) then
  begin
    // � ��������� ������ ��� ����� ���������� ��� ���������
    for i := 0 to Storage.BlocksCount-1 do
    begin
      Block.RefId := Block.RefId or REFID_FLAG_TEXT;
      inc(Block);
    end;
  end else
  begin
    // � ��������� ������ ����� ������� ������
    // ����� ������ ��������, ����� ���������
    for i := 0 to Storage.BlocksCount-1 do
    begin
      case Block.Kind of
//              fkEmpty: {��������};
//             fkNormal: {��������};
//              fkLeave: {��������};
        fkLeaveJoined, // ������
             fkJoined, // ���������
    fkGlobalJumpBlock: begin
                         Block.RefId := Block.RefId or REFID_FLAG_TEXT;
                       end;
     fkLocalJumpBlock: // ��������� ��� �������������
                       // ��� �������� ��������� ���������� ������
                       // ����� �� ������� ������ �����
                       begin
                         if (Block.JumpOffset = JUMP_OFFSET_TEXT) then
                         begin
                           Block.RefId := Block.RefId or REFID_FLAG_TEXT;
                         end else
                         begin
                           Dec(Storage.Blocks[Block.Fixuped].RefId);
                         end;
                       end;
//             fkInline: {��������};
      end;

      inc(Block);
    end;
  end;

  // ����������� ������ ������ (��� �������: ���������� � �������)
  Block := pointer(Storage.Blocks);
  CurrentBlockNumber := 0;
  for i := 0 to Storage.BlocksCount-1 do
  begin
    if (Block.RefId and (REFID_ISNEXT-1) <> 0) then inc(CurrentBlockNumber);
    Block.Number := CurrentBlockNumber;

    inc(Block);
  end;

  // ���������� ��������� �� ������ � ���������
  // ����������� � ������ ����� ������, ��� ��� ������������� �����������
  Storage.LabelCount := CurrentBlockNumber;
  LabelLength := ord(CurrentBlockNumber > 9) + ord(CurrentBlockNumber > 99)
               + ord(CurrentBlockNumber > 999) + ord(CurrentBlockNumber > 9999){ + byte(CurrentBlockNumber > 99999)}+1;
  Storage.LabelLength := LabelLength;


  // ���������� ����� ������� �������� (��� �������) ������������������
  // � �������� ����������� ������
  if (Storage.Mode = omAssembler) then exit;
  
  BinarySize := 0;
  BinaryMaxSize := 0;
  for i := 0 to Storage.BlocksCount-1 do
  begin
    if (Block.RefId and (REFID_FLAG_TEXT or (REFID_ISNEXT-1)) <> 0) then
    begin
      // ���� ��������� ��� � ���� ���� ������ (����� ��� �����)
      if (BinarySize > BinaryMaxSize) then BinaryMaxSize := BinarySize;
      BinarySize := 0;
    end else
    begin
      // �������� ����
      inc(BinarySize, Block.Size{Min});
    end;

    inc(Block);
  end;

  // ��������
  Storage.BinaryBuffer := Storage.Heap.Alloc(((BinaryMaxSize+3) and -4));
end;
{$endif}


const
  // ����, ������� ������������� � Storage.CurrentRefId �� ������ ���� ��� ����� ����
  // ������ ���� ��������, ��� ����� ����� ��� ��� ������� RemoveExcessJumps
  FLAG_BLOCKS_REMOVED = $0100;

// ������� �������������� �������.
// �������� � ��������� ��� ������, ��� � ������ RealizeJumps �������� ��� ������
// ���������� ���������� � ���������. � ���� �� ����� ������������� ����� ����������.
//
// ������� ���������� �����, ����� �������������� �������� ������� �� Block � Next.
// �� ���� ���������� ��������� ����� ��������� ��������� (�� ������ ������)
// � ������ ��������� ������� ���������� Storage.CurrentRefId ������ 1
procedure OptimizeJumpsDifficult(var Storage: TFixupedStorage; Block, Next: PFixupedBlock);
label
  rejump_loop, skip_next, skip_next_end,
  offset_calc_prev, offset_calc_next;
var
  src_mask: word;
  Fixuped: integer;

  Offset{Min}: integer;
  {$ifdef OPCODE_MODES}
     OffsetMax: integer;
  {$endif}
  Buffer: PFixupedBlock;     
begin
  Storage.FakeBlock.O.Reference{src_mask} := jmp_src_mask[Block.cc_ex];

  rejump_loop:
  begin
    // �������, ���� ��������� Next
    Fixuped := Next.Fixuped;
    Next := @Storage.Blocks[Fixuped];

    // ���������� Next �� �����������
    skip_next:
    begin
      case Next.Kind of
        fkEmpty: ;
  fkGlobalJumpBlock,
  fkLocalJumpBlock: begin
                      src_mask := Storage.FakeBlock.O.Reference{src_mask};
                      if (src_mask <> src_mask and jmp_ignore_mask[Next.cc_ex]) then goto skip_next_end;
                    end;
          fkInline: begin
                      src_mask := Storage.FakeBlock.O.Reference{src_mask};
                      if (src_mask <> src_mask and jmp_dest_mask[Next.cc_ex]) then goto skip_next_end;
                    end;
      else
        goto skip_next_end;
      end;

      inc(Next);
      inc(Fixuped);
      goto skip_next;
    end;
    skip_next_end:
    Storage.FakeBlock.O.Fixuped := Fixuped;

    // ����� ���������� �� Block �� Next
    Buffer := Next;
    Offset{Min} := 0;
    {$ifdef OPCODE_MODES}
    OffsetMax := 0;
    {$endif}
    if (NativeInt(Buffer) <={������ ������ �� ������ ���� �����} NativeInt(Block)) then
    begin
      // ������� "�����"
      offset_calc_prev:
      begin
        dec(Offset{Min}, Buffer.Size{Min});
        {$ifdef OPCODE_MODES}
        dec(OffsetMax, Buffer.HybridSize_Max);
        {$endif}
        inc(Buffer);
        if (Buffer <> Block) then goto offset_calc_prev;
      end;
    end else
    begin
      // ������� "�����"
      offset_calc_next:
      begin
        dec(Buffer);
        inc(Offset{Min}, Buffer.Size{Min});
        {$ifdef OPCODE_MODES}
        inc(OffsetMax, Buffer.HybridSize_Max);
        {$endif}
        if (Buffer <> Block) then goto offset_calc_next;
      end;
    end;

    // ��������� ������ � Block ���� ���������� ������ ��� �����
    // ��� ������ ���������� ��������, ������� �������� �������� � Block
    Storage.StartBlock := Offset;
    {$ifdef OPCODE_MODES}
    if (Offset <> OffsetMax) then Storage.StartBlock := JUMP_OFFSET_TEXT;
    {$endif}
    // ����� ���������� ������, ������� �������� (Block.cc_ex ������������ �� ������)
    {$ifNdef OPCODE_MODES}Fixuped:=Block.cc_ex;{$endif}
    if (Offset < Storage.JumpsInfo.low_ranges[{$ifdef OPCODE_MODES}Block.cc_ex{$else}Fixuped{$endif}]) or
       (Offset > Storage.JumpsInfo.high_ranges[{$ifdef OPCODE_MODES}Block.cc_ex{$else}Fixuped{$endif}]) then
       Offset := Storage.JumpsInfo.big_sizes[{$ifdef OPCODE_MODES}Block.cc_ex{$else}Fixuped{$endif}]
       else
       Offset := SMALL_JUMP_SIZE;
    {$ifdef OPCODE_MODES}
    if (OffsetMax < Storage.JumpsInfo.low_ranges[Block.cc_ex]) or
       (OffsetMax > Storage.JumpsInfo.high_ranges[Block.cc_ex]) then
       OffsetMax := Storage.JumpsInfo.big_sizes[Block.cc_ex]
       else
       OffsetMax := SMALL_JUMP_SIZE;
    {$endif}
    // ���������� ������
    {$ifNdef OPCODE_MODES}Fixuped:=Block.Size;{$endif}
    if (Offset{Min} <= {$ifdef OPCODE_MODES}Block.Size{$else}Fixuped{$endif}){$ifdef OPCODE_MODES}and(OffsetMax<=Block.HybridSize_Max){$endif} then
    begin
      // ����� ��������

      // � ������ ������������� ���������� ����
      if (Offset{Min} < {$ifdef OPCODE_MODES}Block.Size{$else}Fixuped{$endif})
      {$ifdef OPCODE_MODES}or (OffsetMax < Block.HybridSize_Max){$endif}
      then Storage.CurrentRefId := 1{SizeChanged:=true};

      // �������� JumpOffset �� ������ ���� ���� �� ���������
      Block.JumpOffset := Storage.StartBlock;

      // ������
      Block.Size := Offset{Min};
      {$ifdef OPCODE_MODES}Block.HybridSize_Max := OffsetMax;{$endif}

      // Next.RefId++ / Block.Next.RefId--
      Buffer := @Storage.Blocks[Block.Fixuped];
      Block.Fixuped := Storage.FakeBlock.O.Fixuped{Fixuped};
      inc(Next.RefId);
      dec(Buffer.RefId);
      if (Buffer.RefId = 0) then
      begin
        inc(Storage.CurrentRefId, FLAG_BLOCKS_REMOVED);
        RemoveFixupedBlock(Storage, Buffer);
      end;
    end;

    // ������ �� ��������� �������� ���� �������� ����������
    if (Next.Kind = fkLocalJumpBlock) then
    begin
      src_mask := Storage.FakeBlock.O.Reference{src_mask};
      if (src_mask = src_mask and jmp_dest_mask[Next.cc_ex]) then goto rejump_loop;
    end;   
  end;
end;

// �� ��� �� ����� ������� ������� �������������� ������ ������� � ��������� �������
// Block ������� � Storage.TopResult, � ����������� � Next (fkLeaveJoined, fkLeave)
// �� Next ����� ���� (� ����� � �� ����) ������ ������� fkEmpty,fkNormal,fkJoined
// ���� ������ �� ����, �� Storage.TopResult=Next
//
// � ����� ������� � Block ��� ��������� ������� (���� �� ������ ���������� JumpOffset � RefId++ � ������ �������������)
procedure OptimizeJumpsInlineBlocks(var Storage: TFixupedStorage; Block, Next: PFixupedBlock);
label
  finalize_refid;
var
  Count, X: integer;
  Buffer: PFixupedBlock;
begin
  // ���������� ���������� ������ � �������
  Buffer := Storage.TopResult;
  Count := 1;
  while (Buffer <> Next) do
  begin
    dec(Next);
    inc(Count);
  end;

  // ��������� ������� ��� jmp �������� � ��� jcc
  X := Block.cc_ex;
  if (X = -1{jmp}) then
  begin
    if (Count = 1) then
    begin
      // ������ fkLeave ��� fkLeaveJoined
      Block.Kind := Next.Kind;
      Block.Cmd := Next.Cmd;
      goto finalize_refid;
    end else
    begin
      //Block.Kind := fkInline;
      //Block.cc_ex := -2;
      //Block.InlineBlocksCount := Count;
      Block.Value := (Count shl 16) + ($fe00{-2 shl 2} + ord(fkInline));
    end;
  end else
  begin
    // jcc �������
    Inc(PFixupedBlockArray(Block)^[1].RefId); // Block.Next.RefId++

    //Block.Kind := fkInline;
    //Block.cc_ex := shortint(intel_cc_invert[X]);
    //Block.InlineBlocksCount := Count;
    Block.Value := (Count shl 16) + (ord(intel_cc_invert[X]) shl 8) + ord(fkInline);
  end;

  // �������� ������, �������� ���� ������ ������
  // ����� ����� ��������, ��� RefId ������ inline ������ �� ����� �������� ��������!
  // ����� ��� ������, ��� ���������� ������ ���� ������ ��������
  // � ����� ��� �� ���������� ������ � ��� ������ ���� jmp --> leave ===> leave
  Count := Count*sizeof(TFixupedBlock);
  Buffer := Storage.Heap.Alloc(Count+4{����� ��� �������� ���������� ������});
  Block.InlineBlocks := pointer(Buffer);
  System.Move(Next^, Buffer^{Block.InlineBlocks^}, Count);

  // ������ ������
finalize_refid:  
  Count := Next.RefId-1;
  Next.RefId := Count;
  if (Count(*{$ifdef OPCODE_MODES} shl 1{$endif}*) = 0) then
  begin
    inc(Storage.CurrentRefId, FLAG_BLOCKS_REMOVED);
    RemoveFixupedBlock(Storage, Next);
  end;
end;


// �������, ����������� ����� ��������� �����:
// 1) ������� �����, �� ������� �������� (����� ���� ����� ����) ������� ������
// 2) ���������� �������� ����� ���������� ����� � ����������� ������� ������ �� ����
// 3) ����������� ������� ������� �����. ���������� ��� ������� ������ �� Storage (������������� ��������)
// 4) ��������� ������ ��������� �������
// 5) �������� ������������� �������������� ������� RemoveExcessJumps
// 6) ����� ������������������ ������� ���������� � ����������� �������
// 7) ������ ������������ ������, ������������ �������, ������������� ����� � ������ ���������� FixupedInfo
// 8) ����������� ������ ������
// 9) ������� ������� ��������� �������
procedure RealizeJumps(var Storage: TFixupedStorage);
label
  first_iteration, first_iteration_continue, normal_cmd_loop,
  optimize_loop, local_jumps_loop, offset_calc_prev, offset_calc_next,
  inline_loop_start, inline_loop;
var
  Block: PFixupedBlock;
  Cmd: POpcodeCmd;

  Count, X: integer;
  Size: integer;

  Current: ^PFixupedBlock;
  Offset{Min}: integer;
  {$ifdef OPCODE_MODES}
     OffsetMax: integer;
  {$endif}
  Next: PFixupedBlock;
  Buffer: PFixupedBlock;
begin
  // ��������� ������ ��� ������ LocalJumps
  Storage.LocalJumpsCount := 0;
  Size := sizeof(PFixupedBlock)*(Storage.BlocksCount+1);
  Storage.LocalJumps := pointer(@Storage.LocalJumpsBuffers);
  if (Size > sizeof(Storage.LocalJumpsBuffers)) then Storage.LocalJumps := Storage.Heap.Alloc(Size);

  // ������� �������� �� ���� ������
  // ������� ������ �������� (���� ����)
  // � ���������� ������ - ������������ ������
  Block := pointer(Storage.Blocks);
  first_iteration:
  begin
    if (Block.RefId{����� ��� �� ��������� ��������� �����} = 0) then
    begin
      if (Block.Kind <> fkEmpty) then RemoveFixupedBlock(Storage, Block);
      goto first_iteration_continue;
    end;

    {$ifdef OPCODE_MODES}
    if (Storage.Mode = omAssembler) and (Block.Kind <> fkLocalJumpBlock) then goto first_iteration_continue;
    {$endif}
    case Block.Kind of
        fkEmpty: {������ ��� 0};
        fkLeave: begin
                    // cmLeave ������ �������� (���� � ������ �������)
                    // �� � � ������ ���������� ������ �� ����� �����������
                    Block.Size{Min} := Block.Cmd.Size;
                    {$ifdef OPCODE_MODES}
                       Block.HybridSize_Max := Block.Size{Min};
                    {$endif}
                 end;
  fkLeaveJoined, // jmp [... + offset ...]
       fkJoined: // add edx, [... + offset ...] / mov esi, offset @1
                 begin
                    Cmd := Block.Cmd.Next;
                    X := Cmd.Size{HybridSize_MinMax};
                    // ���� ������� �������� ��� cmLeave - � �� ������ ������ ������ Size
                    // � ������ ������� - ������ Min/Max
                    // ��� ���������� ������ �� ������ ����

                    {$ifdef OPCODE_MODES}
                    if {Hybrid/���������}(Cmd.Mode = cmText) then
                    begin
                      Block.HybridSize_Min := X and $ff{Cmd.HybridSize_Min};
                      Block.HybridSize_Max := X shr 8{Cmd.HybridSize_Max};
                    end else
                    {$endif}
                    begin
                      Block.Size{Min} := X;
                      {$ifdef OPCODE_MODES}
                         Block.HybridSize_Max := X;
                      {$endif}
                    end;         
                 end;
  fkGlobalJumpBlock: // call axml_get_attribute / jne PRE_cmd_ptr_addr_const
                 begin
                   // ������ ���������������� ��� �������
                   Block.Size{Min} := Storage.JumpsInfo.big_sizes[Block.cc_ex];
                   {$ifdef OPCODE_MODES}
                     Block.HybridSize_Max := Block.Size;
                   {$endif}
                 end;
   fkLocalJumpBlock: // jnle @2 / call @Specifier
                 begin
                   if (Block.Fixuped = NO_FIXUPED) then
                   begin
                     X := Storage.BlocksCount-1;
                     Block.Fixuped := X;
                     Inc(Storage.EndBlock.RefId);
                   end;

                   X := Storage.LocalJumpsCount;
                   Storage.LocalJumps[X] := Block;
                   inc(X);
                   Storage.LocalJumpsCount := X;

                   // ������ ���������������� ��� �������
                   Block.Size{Min} := Storage.JumpsInfo.big_sizes[Block.cc_ex];
                   {$ifdef OPCODE_MODES}
                     Block.HybridSize_Max := Block.Size;
                   {$endif}
                 end;
      {fkInline: ��� ���} // pop esi, pop edi, ret
    else
      // fkNormal: ����������� �������� - ������ ������
      Cmd := Block.Cmd;
      Count := Block.Value shr 8;

      Size := 0{Min};
      {$ifdef OPCODE_MODES}
      Block.HybridSize_Max := Size{0};
      {$endif}

      normal_cmd_loop:
      begin
        X := Cmd.F.Value;
        dec(Count);

        {$ifdef OPCODE_MODES}
        //if (Cmd.Mode = cmText) then
        if (byte(X shr 16) = byte(cmText)) then
        begin
          // ������
          Inc(Size, X and $ff);
          Inc(Block.HybridSize_Max, (X shr 8) and $ff);
        end else
        // if (Cmd.Mode = cmBinary) then
        {$endif}
        begin
          // ��������
          X := X and $ffff;
          Inc(Size, X);
          {$ifdef OPCODE_MODES}
          Inc(Block.HybridSize_Max, X);
          {$endif}
        end;

        Cmd := Cmd.Next;
        if (Count <> 0) then goto normal_cmd_loop;
      end;

      Block.Size := Size{Min};
    end;


    first_iteration_continue:
    if (Block <> Storage.EndBlock) then
    begin
      inc(Block);
      goto first_iteration;
    end;
  end;

  // ��������� ������ ��������� �������
  Storage.LocalJumps[Storage.LocalJumpsCount] := NO_JUMP;

  // ������� �������� � ����������� �������:
  // 0) ���������� ������������� ������
  // 1) �������������� ��������
  // 2) ���� ���� ����������� ����� �� ������ - ����� � ��������� ��������������� ����
  // 3) ���� �� ����������
  // 4) ���� �� ������
  {$ifdef OPCODE_MODES}
  if (Storage.Mode = omAssembler) then
  begin
    RemoveExcessJumps(Storage);
  end else
  {$endif}
  begin
  Storage.CurrentRefId := FLAG_BLOCKS_REMOVED;
  optimize_loop:
    if (Storage.CurrentRefId > 1) then RemoveExcessJumps(Storage);
    Storage.CurrentRefId := 0{SizeChanged:=false};

    Current := pointer(Storage.LocalJumps);
    dec(Current);
    local_jumps_loop:
    begin
      inc(Current);
      Block := Current^;

      if (Block <> NO_JUMP) then  //}if (Block = NO_JUMP) then goto local_jumps_loop_end;
      begin
        if (Block = nil) then goto local_jumps_loop;

        // ������� ��������
        // Next := @Storage.Blocks[Block.Fixuped]; / Storage.TopResult := Next;
        Storage.TopResult := @Storage.Blocks[Block.Fixuped];{����� ����� �� �������� Storage.Blocks[Block.Fixuped]};
        Offset{Min} := 0;
        Next := Storage.TopResult;        
        {$ifdef OPCODE_MODES}
        OffsetMax := 0;
        {$endif}           
        if (NativeInt(Next) <={������ ������ �� ������ ���� �����} NativeInt(Block)) then
        begin
          // ������� "�����"
          offset_calc_prev:
          begin
            dec(Offset{Min}, Next.Size{Min});
            {$ifdef OPCODE_MODES}
            dec(OffsetMax, Next.HybridSize_Max);
            {$endif}
            inc(Next);
            if (Next <> Block) then goto offset_calc_prev;
          end;
        end else
        begin
          // ������� "�����"
          offset_calc_next:
          begin
            dec(Next);
            inc(Offset{Min}, Next.Size{Min});
            {$ifdef OPCODE_MODES}
            inc(OffsetMax, Next.HybridSize_Max);
            {$endif}
            if (Next <> Block) then goto offset_calc_next;
          end;
        end;


        // ���������� ����� Offset ������
        // � "�����������" ������ �������� ����� ���� ����� JUMP_OFFSET_TEXT
        // ��� ���������� �����, ����� �������� �� ����������� (OffsetMin <> OffsetMax)
        // � ���� ������ JumpOffset �� ���� ���������� �� ����� ������
        //
        // ������ JumpOffset �� ����� ��� � ������ ���� ���������� ��������� ������� (Storage.CurrentRefId := true)
        // ������ ��� JumpOffset ����� ��� ���������� ����������. � ���� ��������� ���� - ����� ��� ������� ��� ���� ��������
        Block.JumpOffset := Offset;
        {$ifdef OPCODE_MODES}
        if (Offset <> OffsetMax) then Block.JumpOffset := JUMP_OFFSET_TEXT;
        {$endif}

        // ����� �������� ��������� �������� ������ ������ (�� ��������� ������ �������)
        // �� �������� �� ��� ����� (���������/��������) ��� ��� call(������������� ������)
        //
        // �� �����-�� ������ ���� ��������� �������
        // �� ������ ��������������� ���� ��� �����������
        // �� � ������ ��, ��� ��� � ������ ��������, ��������� ��
        // integer(Block.cc_ex) ����� �� ���������� �� ����������� �������� � �������
        {$ifNdef OPCODE_MODES}X := Block.cc_ex;{$endif}
        if (Block.{$ifdef OPCODE_MODES}HybridSize_Max{$else}Size{$endif}<>Storage.JumpsInfo.small_sizes[{$ifdef OPCODE_MODES}Block.cc_ex{$else}X{$endif}]) then
        begin
          if  (Storage.JumpsInfo.low_ranges[{$ifdef OPCODE_MODES}Block.cc_ex{$else}X{$endif}]<=Offset)
          and (Offset<=Storage.JumpsInfo.high_ranges[{$ifdef OPCODE_MODES}Block.cc_ex{$else}X{$endif}]) then
          begin
            // �������
            Block.Size{Min} := SMALL_JUMP_SIZE{Storage.JumpsInfo.small_sizes[X]};
            pbyte(@Storage.CurrentRefId)^ := 1;{SizeChanged:=true}

            // �������/������ ������� �������
            // �������� Block.JumpOffset �� ����� ������
            {$ifdef OPCODE_MODES}
            if (Offset = OffsetMax) then Block.HybridSize_Max := SMALL_JUMP_SIZE{Storage.JumpsInfo.small_sizes[X]}
            else
            begin
              Offset{X} := Block.cc_ex;

              if  (Storage.JumpsInfo.low_ranges[Offset{X}]<=OffsetMax)
              and (OffsetMax<=Storage.JumpsInfo.high_ranges[Offset{X}]) then
              Block.HybridSize_Max := SMALL_JUMP_SIZE{Storage.JumpsInfo.small_sizes[X]};
            end;
            {$endif}
          end
        end;

        // �������� ��� ��������:
        // 3) ���� �� ����������
        // 4) ���� �� ������
        //
        // ������� �������� ���������� � (����������)������� ��� �� ������,
        // ����� ��������� ����������� ������� (���� ����� �����)
        Next := Storage.TopResult;
        case Next.Kind of
         fkGlobalJumpBlock,
          fkLocalJumpBlock:
                 begin
                   // if (jmp_src_mask[Block.cc_ex]=jmp_src_mask[Block.cc_ex]and jmp_dest_mask[Next.cc_ex])
                   // then OptimizeJumpsDifficult(Storage, Block, Next);
                   Offset := Block.cc_ex;
                   {$ifdef OPCODE_MODES}OffsetMax{$else}X{$endif} := Next.cc_ex;
                   Offset := jmp_src_mask[Offset];
                   {$ifdef OPCODE_MODES}OffsetMax{$else}X{$endif} := jmp_dest_mask[{$ifdef OPCODE_MODES}OffsetMax{$else}X{$endif}] and Offset;
                   if (Offset <> {$ifdef OPCODE_MODES}OffsetMax{$else}X{$endif}) then
                   begin
                     goto local_jumps_loop;
                   end else
                   begin
                     if (Next.Kind = fkLocalJumpBlock) then
                     begin
                       // ������� ��������, ���������� ���������� �������
                       OptimizeJumpsDifficult(Storage, Block, Next);
                       // Next := @Storage.Blocks[Block.Fixuped]; / Storage.TopResult := Next;
                       Storage.TopResult := @Storage.Blocks[Block.Fixuped];
                       Next := Storage.TopResult;
                       //goto inline_loop_start;
                     end else
                     begin
                       // ���������� � ���������� �������� ������ � ��� ������
                       // ���� Block-������ �������.
                       // � ���� ������ ������ ��������� Kind/Reference/Proc(Name)
                       if (Block.Size{Min} <> SMALL_JUMP_SIZE) then
                       begin
                         Current^ := nil{������ �� ��������� ������};
                         Block.Kind := fkGlobalJumpBlock;
                         Block.Reference := Next.Reference;
                         Block.Proc := Next.Proc{Name};

                         Dec(Next.RefId);
                         if (Next.RefId(*{$ifdef OPCODE_MODES} shl 1{$endif}*) = 0) then
                         begin
                           inc(Storage.CurrentRefId, FLAG_BLOCKS_REMOVED);
                           RemoveFixupedBlock(Storage, Next);
                         end;
                       end;
                       goto local_jumps_loop;
                     end;
                   end;
                 end;
        end;


        // 4) ���� �� ������ (�� �������� ��� call)
        // ������������ ������ ������ �� fkLeave ��� fkLeaveJoined
        // ���� ������ �� �������� - ��� � ��������� ��������
        Buffer := Next; {������-�� ��� ����� "����" � Next �������������� �����������}
        X := Block.cc_ex;
        if (X{Block.cc_ex} = -2) then goto local_jumps_loop;
        Offset{SizeMin} := (ord(X{Block.cc_ex}<>-1{jmp})*2); // 0 ��� jmp ��� SMALL_JUMP_SIZE ��� jcc
        {$ifdef OPCODE_MODES}
        OffsetMax{SizeMax} := Offset;
        {$endif}

        inline_loop:
        begin
          inc(Offset{SizeMin}, Buffer.Size{HybridSize_Min});
          {$ifdef OPCODE_MODES}
          inc(OffsetMax{SizeMax}, Buffer.HybridSize_Max);
          {$endif}


          if {$ifdef OPCODE_MODES}(OffsetMax > Block.HybridSize_Max){$else}(Offset > Block.Size){$endif}
          or (Buffer{Next}.Kind > fkLeave{fkGlobalJumpBlock,fkLocalJumpBlock,fkInline}) then goto local_jumps_loop;

          // �������
          if (Buffer{Next}.Kind < fkLeaveJoined) then
          begin
            inc(Buffer{Next});
            goto inline_loop;
          end;

          // ������ ������
          // �������� ����� ��������� ����
          if {$ifdef OPCODE_MODES}(OffsetMax < Block.HybridSize_Max) or{$endif}
             (Offset < Block.Size{Min}) then pbyte(@Storage.CurrentRefId)^ := 1;{SizeChanged:=true}

          // ����������� ����� �������
          Block.Size := Offset;
          {$ifdef OPCODE_MODES}
          Block.HybridSize_Max := OffsetMax;
          {$endif}

          // ��� ����������� �������� ��������� �������
          OptimizeJumpsInlineBlocks(Storage, Block, Buffer{Next});
          Current^ := nil{������ �� ��������� ������};
          goto local_jumps_loop;
        end;
      end;
    end;

    if (Storage.CurrentRefId<>0{SizeChanged}) then goto optimize_loop;
  end;


  // ��������� �����, �������� ��������� �� ��������,
  // ������ ����� ������� �������� ������������������
  {$ifdef OPCODE_MODES}
  if (Storage.Mode <> omBinary) then
  begin
    MarkupTextRoutine(Storage);
  end;
  {$endif}

  // ������������������ ���������� �������� �������
  {$ifdef OPCODE_MODES}
  if (Storage.Mode <> omAssembler) then
  {$endif}
  begin
    Storage.Proc.FCallback(2, @Storage);
  end;
end;



procedure BinaryBlocksWrite(Memory: pointer; Block: PFixupedBlock; var Storage: TFixupedStorage);
label
  main_loop, cmd_list_loop, copy_case, next_block;
type
  TMemoryParts = packed record
    case Integer of
      0: (Bytes: array[0..7] of byte);
      1: (Words: array[0..3] of word);
      2: (Dwords: array[0..2] of dword);
  end;
  PMemoryParts = ^TMemoryParts;

var
  Cmd: POpcodeCmd;
  CmdCount: integer;
  Size: integer{dword};
begin
  main_loop:
  begin
    if (Block.Kind = fkInline) then  // inline ��������: pop esi, pop edi, ret
    begin
      // ���������� � ���������� ���������� ������
      CmdCount := Storage.BlocksCount;
      Storage.BlocksCount := Block.InlineBlocksCount;
      
      // ������� ���������� ������������� ������ ���� ����
      Size := 0;
      if (Block.cc_ex >= 0) then
      begin
        pword(Memory)^ := pword(@Block.InlineBlocks[Block.InlineBlocksCount])^;
        Size := SMALL_JUMP_SIZE{2};
      end;

      // ����� �������� "��������" � ��������������� ���������� ������
      BinaryBlocksWrite(pointer(NativeInt(Memory)+integer(Size)), pointer(Block.InlineBlocks), Storage);
      Storage.BlocksCount := CmdCount;
    end else
    begin
      Cmd := Block.Cmd{������ nil};
      CmdCount := 0;
      case Block.Kind of
              fkEmpty: goto next_block;
             fkNormal: begin
                         // ����������� ��������
                         CmdCount := Block.Value shr 8;
                       end;
             fkJoined, // add edx, [... + offset ...] / mov esi, offset @1
        fkLeaveJoined: // jmp [... + offset ...]
                       begin
                         // todo join?
                         Cmd := Cmd.Next;
                         inc(CmdCount); //CmdCount := 1;
                       end;
              fkLeave: begin
                         // ret(n), leave, jmp reg, jmp mem
                         inc(CmdCount); //CmdCount := 1;
                       end;
    fkGlobalJumpBlock, // call axml_get_attribute / jne PRE_cmd_ptr_addr_const
     fkLocalJumpBlock: // jnle @2 / call @Specifier
                       begin
                         inc(CmdCount); //CmdCount := 1;
                         Size := Block.Size;
                         Cmd := pointer(@Block.JumpBuffer);
                         dec(Cmd);
                         goto copy_case;
                       end;
      end;


      // ��� ����������� ������ �� �������(��) � �����
      // ����������� ���������� � ����� ����� � ������
      Inc(NativeInt(Memory), Block.Size);
      cmd_list_loop:
      begin
        Size := Cmd.Size;
        // Memory -= Size; / CopyMemory(Memory, Cmd.Data, Size);
        //
        // � ��������� �� ���������� ������� ��� ����������� ����� �������������
        // ������ ��� ���������� ������������ ���������� ����������� ��������
        // � �� ����� ��� edx/ecx ����� �������� ������������
        Dec(NativeInt(Memory), Size);
        copy_case:
        case Size of
          0: ;
          1: PMemoryParts(Memory).Bytes[0] := POpcodeCmdData(Cmd).Bytes[0];
          2: PMemoryParts(Memory).Words[0] := POpcodeCmdData(Cmd).Words[0];
          3: begin
               PMemoryParts(Memory).Words[0] := POpcodeCmdData(Cmd).Words[0];
               PMemoryParts(Memory).Bytes[2] := POpcodeCmdData(Cmd).Bytes[2];
             end;
          4: PMemoryParts(Memory).Dwords[0] := POpcodeCmdData(Cmd).Dwords[0];
          5: begin
               PMemoryParts(Memory).Dwords[0] := POpcodeCmdData(Cmd).Dwords[0];
               PMemoryParts(Memory).Bytes[4] := POpcodeCmdData(Cmd).Bytes[4];
             end;
          6: begin
               PMemoryParts(Memory).Dwords[0] := POpcodeCmdData(Cmd).Dwords[0];
               PMemoryParts(Memory).Words[2] := POpcodeCmdData(Cmd).Words[2];
             end;
          7: begin
               PMemoryParts(Memory).Dwords[0] := POpcodeCmdData(Cmd).Dwords[0];
               PMemoryParts(Memory).Words[2] := POpcodeCmdData(Cmd).Words[2];
               PMemoryParts(Memory).Bytes[6] := POpcodeCmdData(Cmd).Bytes[6];
             end;
          8: begin
               PMemoryParts(Memory).Dwords[0] := POpcodeCmdData(Cmd).Dwords[0];
               PMemoryParts(Memory).Dwords[1] := POpcodeCmdData(Cmd).Dwords[1];
             end;
        else
          POpcodeCmd(Storage.Current) := Cmd;
            System.Move(POpcodeCmdData(Cmd).Bytes, Memory^, Cmd.Size);
          Cmd := POpcodeCmd(Storage.Current);
        end;

        // next Cmd
        dec(CmdCount);
        Cmd := Cmd.Next;
        if (CmdCount <> 0) then goto cmd_list_loop;
      end;
    end;

    // next block
  next_block:  
    CmdCount := Storage.BlocksCount-1;
    Inc(NativeInt(Memory), Block.Size);
    Storage.BlocksCount := CmdCount;
    inc(Block);
    if (CmdCount <> 0) then goto main_loop;
  end;                                  
end;


{$ifdef OPCODE_MODES}
const
  W_CRLF = 13 or (10 shl 8);
  W_SPSP = 32 or (32 shl 8);


function MemoryFormat(const Memory: pansichar; const Fmt: ShortString; const Args: array of const): pansichar;
begin
  Result := Memory + SysUtils.FormatBuf(Memory^, high(integer), Fmt[1], Length(Fmt), Args);
end;

// ���������� �������� ������ � ���������(���������) ����
// ��������
// DD $C0D9EED9,$64248489,$D9000001,$01A42494,$C0D90000,$C9D9C1D9,$CAD9CBD9,$6CE9C9D9,$90FFFFE9,$0026748D
// ���
// DB $D9,$EE,$D9,$C0,$89,$84
function HybridBinaryWrite(Memory: pansichar; BinarySize{�� 0}: integer; const Storage{Binary}: TFixupedStorage): pansichar;
label
  dword_lines_loop, dword_line_start, dwords_loop, dwords_lines_end, bytes_loop;
const
  _D = 32 or (32 shl 8) or (ord('D') shl 16);
  _DD = _D or (ord('D') shl 24);
  _DB = _D or (ord('B') shl 24);

  _HEX_FIRST = 32 or (ord('$') shl 8);
  _HEX_DEFAULT = ord(',') or (ord('$') shl 8);

  HEX_CHARS: array[0..15] of ansichar = '0123456789ABCDEF';
var
  flags: dword; // ����� � �����
  Binary: pdword;
  Count: integer;
begin
  flags := ord(Memory <> Storage.TextBuffer);
  Binary := Storage.BinaryBuffer;
  Result := Memory;

  // ���������� dword-�����
  if (BinarySize < 40) then goto dwords_lines_end;
  dword_lines_loop:
  begin
    Count := 10;

    // ������ �����
    dword_line_start:
    begin
      if (flags <> 0{CRLF}) then
      begin
        pword(Result)^ := W_CRLF;
        inc(Result, 2);
      end;

      // DD
      pdword(Result)^ := _DD;
      inc(Result, 4);
      flags := _HEX_FIRST;
    end;

    // ������ dword-��
    dwords_loop:
    begin
      pword(Result)^ := flags;
      dec(Count);
      flags := Binary^;
      inc(Binary);

      // hex
      Result[9] := HEX_CHARS[flags and $f];
      flags := flags shr 4;
      Result[8] := HEX_CHARS[flags and $f];
      flags := flags shr 4;
      Result[7] := HEX_CHARS[flags and $f];
      flags := flags shr 4;
      Result[6] := HEX_CHARS[flags and $f];
      flags := flags shr 4;
      Result[5] := HEX_CHARS[flags and $f];
      flags := flags shr 4;
      Result[4] := HEX_CHARS[flags and $f];
      flags := flags shr 4;
      Result[3] := HEX_CHARS[flags and $f];
      Result[2] := HEX_CHARS[flags shr 4];
      
      // continue
      inc(Result, 10);
      flags := _HEX_DEFAULT;
      if (Count <> 0) then goto dwords_loop;
    end;

    dec(BinarySize, 40);
  end;
  dwords_lines_end:

  // ��������� (� �������� � ���� �������) ����� �������� dword-���
  if (BinarySize <> 0) and ((BinarySize and 3 = 0) or (BinarySize > 30)) then
  begin
    Count := BinarySize shr 2;
    BinarySize := (BinarySize and 3) + 40{������ ��� ����� ����� ���������};
    goto dword_line_start;
  end;

  // �������� ������� ����� �������� �������
  if (BinarySize <> 0) then
  begin
    if (flags <> 0{CRLF}) then
    begin
      pword(Result)^ := W_CRLF;
      inc(Result, 2);
    end;

    // DB
    pdword(Result)^ := _DB;
    inc(Result, 4);
    flags := _HEX_FIRST;

    // ������ ������
    bytes_loop:
    begin
      pword(Result)^ := flags;
      dec(BinarySize);
      flags := pbyte(Binary)^;
      inc(pbyte(Binary));

      // hex
      Result[2] := HEX_CHARS[flags shr 4];
      Result[3] := HEX_CHARS[flags and $f];

      // continue
      inc(Result, 4);
      flags := _HEX_DEFAULT;
      if (BinarySize <> 0) then goto bytes_loop;
    end;
  end;
end;

// ������ �������:
// 1) ���������� �������� ������������������
// 2) ������, ������� ���� ��� ����� � ��������� ����
// 3) ���� ���������� ���� ������ ������ - ������ ������
// 4) ������� ������� ���� � Storage.TopResult
function SmartHybridBinarySize(Block: PFixupedBlock; var Storage: TFixupedStorage): integer;
label
  binary_start, binary_loop;
const
  LINE_LEFT_LENGTH = 2+4; // #13#10'  DD'; // ��������� ������ ��������� ������� � �������
var
  EndBlock: PFixupedBlock;
  BinarySize: integer;
  DD_Lines: integer;
begin
  Result := 0;
  EndBlock := Storage.EndBlock;

  binary_start:
    BinarySize := 0;

  binary_loop:
  begin
    inc(BinarySize, Block.Size);

    inc(Block);
    if (NativeInt(Block) <= NativeInt(EndBlock)) and
       ((Block.Kind = fkEmpty) or (Block.RefId and (not REFID_ISNEXT) = 0)) then goto binary_loop;
  end;

  // ��������� �������� ������ � ���������
  DD_Lines := BinarySize div 40;
  BinarySize := BinarySize - DD_Lines*40; // mod 40
  Result := Result + DD_Lines * (LINE_LEFT_LENGTH{������ �����}+40*2{hex-�������������}+2{,$}*10);
  if (BinarySize <> 0) then
  begin
    if (BinarySize and 3 = 0) then
    begin
      // ������ DD
      Result := Result + LINE_LEFT_LENGTH + (BinarySize shr 2)*(4*2{hex}+2{,$})
    end else
    if (BinarySize <= 30) then
    begin
      // ������ DB
      Result := Result + LINE_LEFT_LENGTH + BinarySize*(2{hex}+2{,$})
    end else
    begin
      // ������� DD, ����� DB
      Result := Result + LINE_LEFT_LENGTH + (BinarySize shr 2)*(4*2{hex}+2{,$}) +
                         LINE_LEFT_LENGTH + (BinarySize and 3)*(2{hex}+2{,$})
    end;
  end;

  // ���� ����� ���������� (����� �����)
  if (NativeInt(Block) <= NativeInt(EndBlock)) and
       ((Block.Kind = fkEmpty) or (Block.RefId and (REFID_ISNEXT-1) = 0)) then goto binary_start;

  // ������� ����
  dec(Block);
  Storage.TopResult := Block;
end;


// ������� �� ���� ��������� ��������� ��������:
// 1) ������� ���������� �������� ������ (��������� �������� ����� �������� � Storage.TopResult)
// 2) ������ �������� ������ ����� BinaryBlocksWrite()
// 3) ������ ��������� ������ � Memory ����� HybridBinaryWrite()
function SmartHybridBinaryWrite(const Memory: pansichar; Block: PFixupedBlock; var Storage: TFixupedStorage): pansichar;
label
  binary_loop;
var
  EndBlock: PFixupedBlock;
  BinarySize, Count: integer;
begin
  // ������������ ������ � ���������� �������� ������
  BinarySize := 0;
  Count := 0;
  Storage.TopResult := Block;
  EndBlock := Storage.EndBlock;
  binary_loop:
  begin
    inc(BinarySize, Block.Size);

    inc(Block);
    inc(Count);
    if (NativeInt(Block) <= NativeInt(EndBlock)) and
       ((Block.Kind = fkEmpty) or (Block.RefId and (not REFID_ISNEXT) = 0)) then goto binary_loop;
  end;

  // ��������������� ����
  // ���������� ��������� �������� ����
  dec(Block);
  // swap(Storage.TopResult, Block);
  EndBlock := Storage.TopResult;
  Storage.TopResult := Block;
  Block := EndBlock;

  // ���������� �������� ������
  Storage.BlocksCount{��������������� �� �����, ������ ��� ������� ��������� Storage.EndBlock} := Count;
  BinaryBlocksWrite(Storage.BinaryBuffer, Block, Storage);

  // ���������� ��������� ������
  Result := HybridBinaryWrite(Memory, BinarySize, Storage);
end;

// ������ ������ (��� �����) ������
(*function TextCmdListSize(Cmd: POpcodeCmd; Count: integer): integer;
label
  main_loop;
begin
  Result := 0;

  main_loop:
  begin
    inc(Result, 4{#13#10__});

    case Cmd.Mode of
      cmJoined: begin

                end;
   cmJumpBlock: begin
                  Cmd.
                end;
    else
      // cmText, cmLeave
      Inc(Result, Length(POpcodeCmdText(Cmd).Str^));
    end;

    dec(Count);
    if (Count <> 0) then goto main_loop;
  end;
end;  *)

// ����� ��������������� �����
function TextLabelWrite(Memory: pansichar; LabelLength: integer; Number: integer): pansichar;
const
  FMT: array[0..3] of ansichar = '@%*d';
begin
  Result := Memory + SysUtils.FormatBuf(Memory^, high(integer), FMT, Length(FMT),[LabelLength, Number]);
  while (Memory <> Result) do
  begin
    if (Memory^ = #32) then Memory^ := '0';
    inc(Memory);
  end;
end;

// �������� ������-������������������
function TextInlineBlocksWrite(Memory: pansichar; Block: PFixupedBlock; var Storage: TFixupedStorage): pansichar;
label
  blocks_loop, cmd_loop;
var
  S: PShortString;
  BlocksCount, Size: integer;
begin
  // ������
  if (Block.cc_ex >= 0) then
  begin
    if (Storage.TextBuffer <> Memory) then
    begin
      pword(Memory)^ := W_CRLF;
      inc(Memory, 2);
    end;

    // jmp/jcc
    //Memory := MemoryFormat(Memory, '  %s ', [Storage.JumpsInfo.names^[Block.cc_ex]^]);
    pword(Memory)^ := W_SPSP;
    S := Storage.JumpsInfo.names^[Block.cc_ex];
    Size := Length(S^);
    inc(Memory, Size+2);
    System.Move(S^[1], Pointer(NativeInt(Memory)-Size)^, Size);

    // �����
    Memory := TextLabelWrite(Memory, Storage.LabelLength, PFixupedBlockArray(Block)^[1].Number);
  end;

  // ����� ������������������, �������������� �������� ����������
  BlocksCount := Block.InlineBlocksCount;
  Block := pointer(Block.InlineBlocks);
  blocks_loop:
  begin
    if (Block.Kind <> fkEmpty) then
    begin
      if (Block.Kind = fkNormal) then
      begin
        //Cmd := Block.Cmd;
        //CmdCount := Block.Value shr 8;

        Storage.TopResult := Block;
        Storage.CurrentRefId := BlocksCount;
        BlocksCount{CmdCount} := Block.Value shr 8;
        Block{Cmd} := pointer(Block.Cmd);
        cmd_loop:
        begin
          if (Storage.TextBuffer <> Memory) then
          begin
            pword(Memory)^ := W_CRLF;
            inc(Memory, 2);
          end;

          pword(Memory)^ := W_SPSP;
          S := POpcodeCmdText(Block.Cmd).Str;
          Size := Length(S^);
          inc(Memory, Size+2);
          System.Move(S^[1], Pointer(NativeInt(Memory)-Size)^, Size);

          dec(BlocksCount{CmdCount});
          Block{Cmd} := pointer(POpcodeCmd(Block{Cmd}).Next);
          if (BlocksCount{CmdCount} <> 0) then goto cmd_loop;
        end;
        Block := Storage.TopResult;
        BlocksCount := Storage.CurrentRefId;
      end else
      // fkLeave
      begin
        if (Storage.TextBuffer <> Memory) then
        begin
          pword(Memory)^ := W_CRLF;
          inc(Memory, 2);
        end;

        pword(Memory)^ := W_SPSP;
        S := POpcodeCmdText(Block.Cmd).Str;
        Size := Length(S^);
        inc(Memory, Size+2);
        System.Move(S^[1], Pointer(NativeInt(Memory)-Size)^, Size);
      end;
    end;

    dec(BlocksCount);
    inc(Block);
    if (BlocksCount <> 0) then goto blocks_loop;
  end;

  // ���������
  Result := Memory;
end;

// �������� ������� fkJoined ��� fkLeaveJoined
// � ����� ������ ������ ��������� �� ��������� ������!
// ������ ��� ����� ��� ������� ��� ����������� �� � �������!
function TextJoinedCmdWrite(Memory: pansichar; const Joined: POpcodeCmdJoined; var Storage: TFixupedStorage): pansichar;
var
  buffer1, buffer2: string[6]; // ������ ������ "@65535"
begin
  // ������� �������
  if (Storage.TextBuffer <> Memory) then
  begin
    pword(Memory)^ := W_CRLF;
    inc(Memory, 2);
  end;

  // �������
  pword(Memory)^ := W_SPSP;
  inc(Memory, 2);

  // ������ �������� - ��������� ��� ����������
  pbyte(@buffer1)^ := Storage.LabelLength+1;
  TextLabelWrite(pansichar(@buffer1[1]), Storage.LabelLength, Storage.Blocks[Joined.Data[0].Block.O.Fixuped].Number);
  if (Joined.Cmd.Param and 3 <> 3) then
  begin
    // ������� � ����� ������
    Result := MemoryFormat(Memory, POpcodeCmdText(Joined.Cmd.Next).Str^, [buffer1]);
  end else
  begin
    // ������� � ����� �������
    pbyte(@buffer2)^ := Storage.LabelLength+1;
    TextLabelWrite(pansichar(@buffer2[1]), Storage.LabelLength, Storage.Blocks[Joined.Data[1].Block.O.Fixuped].Number);

    Result := MemoryFormat(Memory, POpcodeCmdText(Joined.Cmd.Next).Str^, [buffer1, buffer2]);
  end;
end;


// �������� ������� fkNormal ��� fkLeave
// �� ���� ��� � ����� �� �������������� � �������� �������� �� ����� � ������ � ������ ������ ������
// ���������� ����������� ������ �� ������ - Storage.CurrentRefId
function TextCmdWrite(Memory: pansichar; const Cmd: POpcodeCmd; var Storage: TFixupedStorage): pansichar;
var
  S: PShortString;
  Size: integer;
begin
  // ��������
  dec(Storage.CurrentRefId);
  if (Storage.CurrentRefId <> 0) then Memory := TextCmdWrite(Memory, Cmd.Next, Storage);

  // ������� �������
  if (Storage.TextBuffer <> Memory) then
  begin
    pword(Memory)^ := W_CRLF;
    inc(Memory, 2);
  end;

  // �������
  pword(Memory)^ := W_SPSP;
  S := POpcodeCmdText(Cmd).Str;
  Size := Length(S^);
  inc(Memory, Size+2);
  System.Move(S^[1], Pointer(NativeInt(Memory)-Size)^, Size);

  // ���������
  Result := Memory;
end;


// ������ ������� ������ ������ �� Storage.EndBlock
// �.�. �� ���� ����� ������� ������������ ������� ��� ������
procedure TextBlocksWrite(Memory: pansichar; Block: PFixupedBlock; var Storage: TFixupedStorage);
label
  main_loop;
var
  LastNumber: integer;
  S: PShortString;
  Size: integer;
begin
  LastNumber := 0;
  Block := pointer(Storage.Blocks);
  main_loop:
  begin
    // ���� ����� �����
    if (LastNumber <> Block.Number) then
    begin
      LastNumber := Block.Number;

      // ������� �������
      if (Storage.TextBuffer <> Memory) then
      begin
        pword(Memory)^ := W_CRLF;
        inc(Memory, 2);
      end;

      // ���� ����� + ���������
      Memory := TextLabelWrite(Memory, Storage.LabelLength, LastNumber);
      Memory^ := ':';
      inc(Memory);
    end;

    if (Block.RefId and REFID_FLAG_TEXT = 0) then
    begin
      // �������� ������������������ ������
      Memory := SmartHybridBinaryWrite(Memory, Block, Storage);
      Block := Storage.TopResult;
    end else
    begin
      // ��������� ����
      case Block.Kind of
             fkNormal: // ����������� ��������
                       begin
                         Storage.CurrentRefId{Count} := Block.Value shr 8;
                         Memory := TextCmdWrite(Memory, Block.Cmd, Storage);
                       end;
             fkJoined, // add edx, [... + offset ...] / mov esi, offset @1
        fkLeaveJoined: // jmp [... + offset ...]
                       begin
                         Memory := TextJoinedCmdWrite(Memory, POpcodeCmdJoined(Block.Cmd), Storage);
                       end;
              fkLeave: // ret(n), leave, jmp reg, jmp mem
                       begin
                         Storage.CurrentRefId{Count} := 1;
                         Memory := TextCmdWrite(Memory, Block.Cmd, Storage);
                       end; 
    fkGlobalJumpBlock, // call axml_get_attribute / jne PRE_cmd_ptr_addr_const
     fkLocalJumpBlock: // jnle @2 / call @Specifier
                       begin
                         // ������� �������
                         if (Storage.TextBuffer <> Memory) then
                         begin
                           pword(Memory)^ := W_CRLF;
                           inc(Memory, 2);
                         end;

                         // jmp/jcc/call
                         pword(Memory)^ := W_SPSP;
                         S := Storage.JumpsInfo.names^[Block.cc_ex];
                         Size := Length(S^);
                         inc(Memory, Size+2);
                         System.Move(S^[1], Pointer(NativeInt(Memory)-Size)^, Size);

                         // ����� ��� ��� �������
                         Memory^ := #32;
                         inc(Memory);
                         if (Block.Kind = fkGlobalJumpBlock) then
                         begin
                           Size := StrLen(Block.ProcName);
                           inc(Memory, Size);
                           System.Move(Block.ProcName^, Pointer(NativeInt(Memory)-Size)^, Size);
                         end else
                         begin
                           Memory := TextLabelWrite(Memory, Storage.LabelLength, Storage.Blocks[Block.Fixuped].Number);
                         end;
                       end;
             fkInline: // pop esi, pop edi, ret
                       begin
                         Memory := TextInlineBlocksWrite(Memory, Block, Storage);
                       end;
       end;
    end;

    inc(Block);
    if (NativeInt(Block) <= NativeInt(Storage.EndBlock)) then goto main_loop;
  end;

  {$ifdef OPCODE_TEST}
  Size := NativeInt(Memory)-NativeInt(Storage.TextBuffer);
  if (Size <> Storage.Proc.Size) then
  raise EOpcodeLib.CreateFmt('Fail writed text size: %d bytes (%d needed)', [Size, Storage.Proc.Size]);  //raise_parameter;
  {$endif}
end;
{$endif}

// �������������� ������ �������� - �������� �������������� ������
// ������� �� ��������� ���������:
// 1) ������������ �������� ������. ����� ������ ������ �������
// 2) ���������� �������� �����
// 3) � ������ ��������� ������ ��������� FFixupedInfo � ��������� ������ ����� ������
//
// ������� �������� �������� ������� BinaryBlocksWrite()/TextBlocksWrite()
// ������ ������, ��� �������� ���������� ����� - � ���� ������ ������� �������� ������ ����� "��������"
procedure FixupDataWrite(var Storage: TFixupedStorage);
{$ifdef OPCODE_MODES}
label
  text_block_loop,  text_block_cmd_loop, text_inline_loop, text_inline_cmd_loop, text_block_continue;
{$endif}
var
  i: integer;
  Block: PFixupedBlock;

  ResultSize: integer;
                                   
  {$ifdef OPCODE_MODES}
  Count: integer;
  Cmd: POpcodeCmd;
  {$endif}
begin
  Block := pointer(Storage.Blocks);
  {$ifdef OPCODE_MODES}
  if (Storage.Mode <> omBinary) then
  begin
    // ��������� ��� ������

    // ������������ ������
    // ������� �������, ������� ������ ������ �����
    ResultSize := (Storage.LabelLength+{#13#10@____:}4)*Storage.LabelCount;

    // ����� ���������� �� ���� ������
    // �������� ������� �������� ������������������ � �����
    text_block_loop:
    begin
      if (Block.RefId and REFID_FLAG_TEXT = 0) then
      begin
        Inc(ResultSize, SmartHybridBinarySize(Block, Storage));
        Block := Storage.TopResult;
      end else
      begin
        Cmd := Block.Cmd;
        case Block.Kind of
          fkNormal: // ����������� ��������
                    begin
                      Count := Block.Value shr 8;
                    end;
           fkLeave: // ret(n), leave, jmp reg, jmp mem
                    begin
                      Count := 1;
                    end;
     fkLeaveJoined, // jmp [... + offset ...]
          fkJoined: // add edx, [... + offset ...] / mov esi, offset @1
                    begin
                      // %s ���������� �������� �� @label
                      Count := Storage.LabelLength-1;
                      Inc(ResultSize, Count);
                      if (Cmd.Param and 3 = 3) then Inc(ResultSize, Count);
                      Count := 1;
                      Cmd := Cmd.Next;
                    end;
 fkGlobalJumpBlock: begin
                      // Count := 0;
                      Inc(ResultSize, 5{#13#10__XXX_});
                      Inc(ResultSize,StrLen(Block.ProcName));
                      goto text_block_continue;
                    end;
  fkLocalJumpBlock: begin
                      // Count := 0;
                      Inc(ResultSize, Length(Storage.JumpsInfo.names[Block.cc_ex]^)+Storage.LabelLength+6{#13#10__XXX_@});
                      goto text_block_continue;
                    end;
          {fkInline: �� ������ � ��������� ����}       
        else
          goto text_block_continue;
        end;

        text_block_cmd_loop:
        begin
          Inc(ResultSize, Length(POpcodeCmdText(Cmd).Str^) + 4{#13#10__});
          dec(Count);
          Cmd := Cmd.Next;
          if (Count <> 0) then goto text_block_cmd_loop;
        end;
      end;

      text_block_continue:
      inc(Block);
      if (NativeInt(Block) <= NativeInt(Storage.EndBlock)) then goto text_block_loop;
    end;


    // ����� ������(�), ����������
    if (ResultSize = 0) then
    begin
      Storage.Proc.Size := 0;
    end else
    begin
      Storage.Proc.Size := ResultSize-{������ ������� #13#10}2;
      Storage.TextBuffer := Storage.Proc.Memory;
      TextBlocksWrite(Storage.TextBuffer, pointer(Storage.Blocks), Storage);
    end;
  end else
  {$endif}
  begin
    // �������� �����
    ResultSize := 0;

    // ����������� �������� � ������������ ������������ ����� ������
    for i := 0 to Storage.BlocksCount-1 do
    begin
      Block.Offset := ResultSize;
      inc(ResultSize, Block.Size);

      inc(Block);
    end;

    // ����� ������, ����������
    Storage.Proc.Size := ResultSize;
    BinaryBlocksWrite(Storage.Proc.Memory, pointer(Storage.Blocks), Storage);
  end;
                     


end;


{$ifdef MSWINDOWS}
var
  CurrentProcess: THandle=0;
{$endif}

// ����� ������� �������, �������:
// 1) ���������� Heap � �������� ��������� ������� ������
// 2) ����� ��������� ���� �������� �� ��������� Fixup-�
// 3) ������������� ���������� �������������� ����� (FFixupedInfo)
// 4) �������� ����������� ������� ������
// 5) ������������ ������
// 6) ��������� �����
// 7) ���������� �������� ������
// 8) ���������� ������
// 9) ������ �� ����� ��������� ������
procedure TOpcodeProc.Fixup();
var
  S: integer;
  HeapState: TOpcodeHeapState;
  SubsLine: POpcodeSubscribe;
  SubsBlock: POpcodeBlock;

  Storage: TFixupedStorage;
  Block: PFixupedBlock;
begin
  // ��������� ��������� ������
  // ����� �� ��������� ��� ������������
  FHeap.SaveState(HeapState);

  // ����������� ������ � Heap �� 4 �����
  S := NativeInt(Heap.FState.Current) and 3;
  if (S <> 0) then
  begin
    S := 4-S;
    Inc(NativeInt(Heap.FState.Current), S);
    Dec(Heap.FState.Margin, S);
  end;

  // �������������
  with Storage do
  begin
    Heap := Self.Heap;
    Proc := Self;
    {$ifdef OPCODE_MODES}
      Mode := Self.Mode;
    {$endif}            
    SubscribedLines.Next := nil;
    SubscribedLines.Block := nil;
    FakeBlock.CmdList := nil;
    FakeBlock.P.Proc := Self;
    BlocksCount := 0;

    // ���������� ������
    Self.FCallback(0, @Storage);

    // �����
    BlocksAvailable := Length(BlocksBuffer);
    Blocks := pointer(@BlocksBuffer);
    // �����, �� ������� ���� ������� ������
    References := pointer(@ReferencesBuffer);
    S := Self.F.BlocksReferenced*sizeof(word);
    if (S > sizeof(ReferencesBuffer)) then References := Heap.Alloc(S);
    FillChar(References^, S, $ff{NO_FIXUPED});

  end;
  FLastBinaryCmd := NO_CMD;

  try
    // (����������) ��������� ������ ������ � ���������
    // ������ ���� �������� �������� ����� �� ��������
    Storage.CurrentRefId := 1;
    Storage.Current := Self.B_call_modes.uni;
    AddFixupedBlocksLine(Storage);

    // � �������� ����� ����� ��������� ����������� ������� (EndBlock)
    // � ����� ������ ��� ����� fkLeave
    // ������ � ������� ������ ������ ������� ��������� � RefId ����� ���� ����� ����,
    // � � ������ RET_OFF ������ ������ �������� (����� �� �����������) � RefId ����������� (����� �� ���������)
    // RefId ���������������� ������ MarkupTextRoutine. ��� ����� ��� ������� �����(��������� �����).
    with Storage do
    begin
      // ���������� RefId + ������� �������� ���������� local jump � EndBlock
      S := integer(REFID_ISNEXT);
      Block := @Blocks[BlocksCount-1];
      while (Block <> pointer(Blocks)) and (Block.Kind = fkLocalJumpBlock) and (Block.Fixuped = NO_FIXUPED) do
      begin
        Block.Value := 0{fkEmpty};
        Block.Size{Min} := 0;
        {$ifdef OPCODE_MODES}
          Block.HybridSize_Max := 0;
        {$endif}
        dec(Block);
      end;  
      with Block^ do
      case Kind of
        // ����������/����������� + ret(n)(0), leave(1), jmp reg(2), jmp mem(3)
        fkLeave, fkLeaveJoined: S := 0;

        // ������ � ������ ����
        fkLocalJumpBlock,
       fkGlobalJumpBlock: if (cc_ex = -1{jmp}) then S := 0;
      end;

      {$ifdef OPCODE_TEST}
        if (BlocksCount = NO_FIXUPED) then raise_parameter;
      {$endif}
      if (BlocksCount = BlocksAvailable) then GrowFixupedBlocks(Storage);
      inc(BlocksCount);
      EndBlock := @Blocks[BlocksCount-1];
      with EndBlock^ do
      begin
        Kind := fkLeave;
        Cmd := @LastRetCmd.Cmd;

        if (Self.RetN <> RET_OFF) then
        begin
          Self.FCallback(1, @Storage);
        end else
        begin
          inc(S);

          {$ifdef OPCODE_MODES}
          if (Storage.Proc.Mode = omAssembler) then
          begin
            LastRetCmd.Cmd.F.ModeParam := ord(cmLeave) + ((128{�����}+0{ret(n)}) shl 8);
          end else
          {$endif}
          begin
            LastRetCmd.Cmd.F.Size := high(word);
            LastRetCmd.Cmd.F.ModeParam := ord(cmLeave) + ((0{��������}+0{ret(n)}) shl 8);
          end;
        end;

        RefId := S;
      end;
    end;

    // (��)����������� � �������������� ������
    RealizeJumps(Storage);

    // ������� ������ � ���������� ����� ���� �� ����
    if (Self.RetN = RET_OFF) then
    with Storage.EndBlock^ do
    begin
      Size{Min} := 0;
      {$ifdef OPCODE_MODES}
      HybridSize_Max := 0;
      {$endif}
      Cmd.F.Size := 0;
    end;

    // ���������� ������
    FixupDataWrite(Storage);

    // ������ ���� ������ (����� �� ���� ������� � JIT-����������� ����� ����)
    if (Size <> 0) and (Self.Storage <> nil) and (Self.Storage.JIT) then
    begin
      {$ifdef MSWINDOWS}
      if (CurrentProcess = 0) then CurrentProcess := Windows.GetCurrentProcess;
      Windows.FlushInstructionCache(CurrentProcess, Self.Memory, Self.Size);
      {$endif}
    end;

    // ��������� ��������� �������� ��� ������� ������ (�������� ������ ��� ��������)
    {$ifdef OPCODE_MODES}
    if (Storage.Mode = omBinary) then
    {$endif}
    begin
    {  for S := 0 to Self.F.BlocksReferenced-1 do
      if (Manager.FReferencedBlocks[S] <> nil) then
      begin
        // todo
      end; }
    end;

    // ������ ����� "FixupedBlock"
    SubsLine := @Storage.SubscribedLines;
    while (SubsLine <> nil) do
    begin
      SubsBlock := SubsLine.Block;
      while (SubsBlock <> nil) and (SubsBlock.O.Fixuped <> NO_FIXUPED) do
      begin
        SubsBlock.O.Fixuped := NO_FIXUPED;
        SubsBlock := SubsBlock.N.Next;
      end;

      SubsLine := SubsLine.Next;
    end;

    // ��������������� ��������� ������
    FHeap.RestoreState(HeapState);
  finally
    // ������ ������ ��� ����� ���� ��� �����������
    if (Storage.Blocks <> pointer(@Storage.BlocksBuffer)) then
    FreeMem(Storage.Blocks);
  end;
end;



// --------------   ������������� �������� �������   -----------------------

{$ifdef OPCODE_TEST}
procedure test_size_ptr(ptr: size_ptr);
begin
  if (ptr > high(size_ptr)) then raise_parameter;
end;

procedure test_intel_reps(reps: intel_rep);
begin
  if (reps > high(intel_rep)) then raise_parameter;
end;

procedure test_intel_cc(cc: intel_cc);
begin
  if (cc > high(intel_cc)) then raise_parameter;
end;

function test_const(const v_const: TOpcodeConst; const is64: boolean; const Proc: TOpcodeProc): integer{��� �������� PValue};
begin
  if (v_const.Kind > high(const_kind)) then raise_parameter;

  // �������� ������������ ��������
  Result := 0;
  case v_const.Kind of
    ckPValue: begin
                Result := v_const.F.PValue^;
                if (is64) then inc(Result, v_const.F.PValue64^ shr 32);
              end;
     ckBlock: begin
                Result := NativeInt(v_const.Block.CmdList);
                {$ifdef OPCODE_MODES}
                  if (Proc.Mode <> omBinary) and (Proc <> v_const.Block.P.Proc) then
                  raise_parameter;
                {$endif}

                if (Proc.Storage <> v_const.Block.P.Proc.Storage) then raise_parameter;
                {$ifdef OPCODE_MODES}
                  // �� ������ Storage nil
                  if (Proc.Mode <> v_const.Block.P.Proc.Mode) then raise_parameter;
                {$endif}
              end;
  ckVariable: begin
                Result := v_const.Variable.FOFFSET + NativeInt(v_const.Variable.FMemory);
                {$ifdef OPCODE_MODES}
                  if (Proc.Mode <> omBinary) then raise_parameter;
                {$endif}
                if (Proc.Storage <> v_const.Variable.Storage) then raise_parameter;
              end;
   {$ifdef OPCODE_MODES}
    ckCondition,ckOffsetedCondition:
    begin
      if (v_const.Condition = nil) or (v_const.Condition^ = #0) then raise_parameter;
      if (Proc.Mode = omBinary) then raise_parameter;      
    end;
   {$endif}
  end;
end;

procedure test_intel_address(const addr: TOpcodeAddress; const x64: boolean; const Proc: TOpcodeProc);
begin
  // ��������
  if (addr.F.Scale.intel > high(intel_scale)) then raise_parameter;
  if (x64) then
  begin
    if not (addr.F.Reg.v in [rax..r15{reg_x64_addr}]) then raise_parameter;
    if (addr.F.Scale.intel >= x1_plus) and (not (addr.F.Plus.v in [rax..r15{reg_x64_addr}])) then raise_parameter;
  end else
  begin
    if not (addr.F.Reg.v in [eax..edi{reg_x86_addr}]) then raise_parameter;
    if (addr.F.Scale.intel >= x1_plus) and (not (addr.F.Plus.v in [eax..edi{reg_x86_addr}])) then raise_parameter;
  end;

  // �������� esp/rsp � �������� �������
  if (addr.F.Reg.v in [esp, rsp]) then
  case addr.F.Scale.intel of
    xNone, x1: {������};
    x1_plus: if (addr.F.Plus.v in [esp, rsp]) then raise_parameter;
  else
    // x2, x4, x8, x2_plus, x4_plus, x8_plus
    raise_parameter;
  end;

  // ���������
  {$ifdef OPCODE_MODES}
  if (x64) and (Proc.Mode <> omBinary) and (addr.F.Scale.intel <> xNone) and
     (not (addr.offset.Kind in [ckValue, ckPValue, ckCondition])) then raise_parameter;
  {$endif}
  test_const(addr.offset, false, Proc);
end;


{$endif}

// <<<-----------   ������������� �������� �������   -----------------------


{ TOpcodeBlock }

const
  CMD_CUSHION_SIZE = sizeof(integer);

function TOpcodeBlock.AddCmd(const CmdMode: TOpcodeCmdMode; const SizeCorrection: integer=0): POpcodeCmd;
const
  CMD_SIZES: array[TOpcodeCmdMode] of integer = (
    sizeof(TOpcodeCmd){cmBinary},
    {$ifdef OPCODE_MODES}sizeof(TOpcodeCmdText),{cmText}{$endif}
    0{cmLeave},
    sizeof(TOpcodeCmd){cmJoined},
    sizeof(TOpcodeCmdJumpBlock){cmJumpBlock},
    0{cmSwitchBlock},
    sizeof(TOpcodeCmdPointer){cmPointer}
  );
var
  ResultSize: integer;
begin
  with  P.Proc do
  if (CmdMode = cmBinary) and(FLastBinaryCmd = Self.CmdList) and (FLastHeapCurrent = Heap.FState.Current)
  and (Integer(Self.CmdList.F.Size) + SizeCorrection <= high(word))
  and (Heap.FState.Margin >= (SizeCorrection+CMD_CUSHION_SIZE)) then
  begin
    // � ������ ������ SizeCorrection - ��� ������ �������� ������
    Result := Self.CmdList;
    Inc(Result.F.Size, SizeCorrection);

    Inc(NativeInt(Heap.FState.Current), SizeCorrection);
    Dec(Heap.FState.Margin, SizeCorrection);
    FLastHeapCurrent := Heap.FState.Current;
  end else
  begin
    // ������������ ��������� ������
    with Heap do
    begin
      // Align
      ResultSize := NativeInt(FState.Current) and 3;
      if (ResultSize <> 0) then
      begin
        ResultSize := 4-ResultSize;
        Inc(NativeInt(FState.Current), ResultSize);
        Dec(FState.Margin, ResultSize);
      end;

      // Size
      ResultSize := CMD_SIZES[CmdMode]+SizeCorrection;

      // Alloc
      Result := FState.Current;
      if (FState.Margin >= (ResultSize+CMD_CUSHION_SIZE)) then
      begin
        Inc(NativeInt(FState.Current), ResultSize);
        Dec(FState.Margin, ResultSize);
      end else
      begin
        Result := Alloc(ResultSize+CMD_CUSHION_SIZE);
        Dec(NativeInt(FState.Current), CMD_CUSHION_SIZE);
        Inc(FState.Margin, CMD_CUSHION_SIZE);
      end;
    end;

    // fields
    Result.F.Value := Integer(ord(CmdMode)) shl 16;

    // ����������� ������ ��� �������� � ��������� ����� ������
    if (CmdMode = cmBinary) then
    begin
      Result.F.Size := SizeCorrection;
      FLastBinaryCmd := Result;
      FLastHeapCurrent := Heap.FState.Current;
    end else
    begin
      FLastBinaryCmd := NO_CMD;
      FLastHeapCurrent := nil;
    end;

    // cmd list
    Result.FNext := CmdList;
    CmdList := Result;
  end;
end;

{$ifdef OPCODE_MODES}
function TOpcodeBlock.AddCmdText(const Str: PShortString): POpcodeCmd{POpcodeCmdText};
begin
  Result := AddCmd(cmText);
  POpcodeCmdText(Result).Str := Str;
end;

function TOpcodeBlock.AddCmdText(const FmtStr: ShortString; const Args: array of const): POpcodeCmd{POpcodeCmdText};
begin
  Result := AddCmd(cmText);
  POpcodeCmdText(Result).Str := P.Proc.Heap.Format(FmtStr, Args);
end;
{$endif}

// ������������ � ������� ���������������� ����������
// �� ����� ��� ����������, ������� ��� �������� ������ ��������
// ��� ������� ����� �������� 4�������� (� x86 � x64) ���������� � ������������� �������� ������
// ������� ����� �������� � ����������� �� ������ ������� ��� ������ ���������� ��������
procedure TOpcodeBlock.JoinCmdCellData(const relative: boolean; const v_const: TOpcodeConst);
var
  Result: POpcodeCmdJoined;
  JoinedData: POpcodeJoinedData;
begin
  // �� ��� ������������ ���� �������� ��������
  Self.P.Proc.FLastBinaryCmd := NO_CMD;

  // Result.Next - ��� �������, ��� ������� ����������� ������ ������!
  Result := POpcodeCmdJoined(AddCmd(cmJoined, sizeof(TOpcodeJoinedData)));
  Result.Cmd.F.Size := Result.Cmd.Next.Size;
  Result.Cmd.F.Param := 1 or (ord(Result.Cmd.Next.Mode) shl 2);
  JoinedData := @Result.Data[0];

  {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode <> omBinary) then
  begin
    { JoinedData.CmdOffset �� ����� �������� }
    JoinedData.Proc := Self.P.Proc;
    JoinedData.Block := v_const.Block;
  end else
  {$endif}
  begin
    if (v_const.Kind = ckBlock) then
    begin
      JoinedData.Proc := v_const.Block.P.Proc;
      if (JoinedData.Proc = Self.P.Proc) then
      begin
        // local
        JoinedData.Block := v_const.Block;
      end else
      begin
        // global
        with v_const.Block^ do
        begin
          JoinedData.Reference := O.Reference;
          if (JoinedData.Reference = NO_REFERENCE) then JoinedData.Reference := MakeReference();
        end;
      end;
    end else
    // if (v_const.Kind = ckVariable) then
    begin
      JoinedData.Variable := v_const.Variable;
      JoinedData.VariableOffset := v_const.VariableOffset;
    end;

    // ��������
    JoinedData.CmdOffset := Result.Cmd.Next.NeutralizeFakeConst();

    if (relative) then
    JoinedData.CmdOffset := -JoinedData.CmdOffset;
  end;
end;

// ������������ � ������� ���������������� ����������
// �� �����(��) �/��� ����������(��), ������� ��� �������� ������ ��������
// ��� ������� ����� �������� 4�������� (� x86 � x64) ���������� � ������������� �������� ������
// ������� ����� �������� � ����������� �� ������ ������� ��� ������ ���������� ��������
procedure TOpcodeBlock.JoinCmdCellData(const mode: byte; const v_addr, v_const: TOpcodeConst);
var
  Result: POpcodeCmdJoined;
  JoinedData: POpcodeJoinedData;
  PConst: POpcodeConst;

  Count, i: integer;
begin
  Count := ((mode shr 1) and 1) + (mode and 1);

  // �� ��� ������������ ���� �������� ��������
  Self.P.Proc.FLastBinaryCmd := NO_CMD;

  // Result.Next - ��� �������, ��� ������� ����������� ������ ������!
  Result := POpcodeCmdJoined(AddCmd(cmJoined, Count*sizeof(TOpcodeJoinedData)));
  Result.Cmd.F.Size := Result.Cmd.Next.Size;
  Result.Cmd.F.Param := (mode and 3) or (ord(Result.Cmd.Next.Mode) shl 2);
  JoinedData := @Result.Data[0];
  if (mode and 1 <> 0) then PConst := @v_const else PConst := @v_addr;

  // �������� �� ���� ������ ����������
  for i := Count-1 downto 0 do
  begin
    with PConst^ do
    {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode <> omBinary) then
    begin
      { JoinedData.CmdOffset �� ����� �������� }
      JoinedData.Proc := Self.P.Proc;
      JoinedData.Block := Block;
    end else
    {$endif}
    begin
      if (Kind = ckBlock) then
      begin
        if (VariableOffset = 0) then
        begin
          // local
          JoinedData.Proc := Self.P.Proc;
          JoinedData.Block := Block;
        end else
        begin
          // global
          JoinedData.Proc := TOpcodeProc(Variable);
          JoinedData.Reference := VariableOffset;
        end;
      end else
      // if (v_const.Kind = ckVariable) then
      begin
        JoinedData.Variable := Variable;
        JoinedData.VariableOffset := VariableOffset;
      end;

      // ��������
      JoinedData.CmdOffset := Result.Cmd.Next.NeutralizeFakeConst(ord(PConst = @v_addr));

      if {relative}(mode and 4 <> 0) and (PConst = @v_addr) then
      JoinedData.CmdOffset := -JoinedData.CmdOffset;
    end;

    dec(JoinedData);
    PConst := @v_addr;
  end;
end;

// ������ ��� ������, ������������ ��� ��������
// ����� �������� ����� �������� ������ �� ����� ��������
function TOpcodeBlock.AddCmdPointer(params: integer; pvalue: pointer; addr_kind: integer; callback, diffcmd: pointer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd{POpcodeCmdPointer};
type
  TTwoConsts = array[0..1] of TOpcodeConst;
  PTwoConsts = ^TTwoConsts;
var
  R: POpcodeCmdPointer absolute Result;
begin
  Result := AddCmd(cmPointer);
  Result.F.Param{will_join} := ord((byte{Kind}(addr_kind shr 24)=2)and((PTwoConsts(pvalue)^[0].Kind>=ckBlock)or(PTwoConsts(pvalue)^[1].Kind>=ckBlock)));

  R.params := params;
  R.pvalue := pvalue;
  R.addr_kind := addr_kind;
  R.callback := callback;
  R.diffcmd.ptr := diffcmd;

  {$ifdef OPCODE_MODES}
    R.cmd_name := @cmd;
  {$endif}
end;

// ������� jcc(intel_cc), jmp(-1), call(-2)
// ��� ������� �������� ��� ��������� ARM
// � ������ ������������� ���������� �������� � ��������
function TOpcodeBlock.cmd_jump_block(const cc_ex: shortint; const Block: POpcodeBlock): POpcodeCmd{POpcodeCmdJumpBlock};
begin
  {$ifdef OPCODE_TEST}
     if (cc_ex < -2{call}) or (cc_ex > ord(high(intel_cc))) then raise_parameter;
     if (P.Proc.Storage <> Block.P.Proc.Storage) then raise_parameter;
     if (@Self = Block) then raise_parameter;
     {$ifdef OPCODE_MODES}
       // �� ������ Storage nil
       if (P.Proc.Mode <> Block.P.Proc.Mode) then raise_parameter;
     {$endif}
  {$endif}

  Result := AddCmd(cmJumpBlock);
  Result.F.cc_ex := cc_ex;

  if (Block.P.Proc <> Self.P.Proc) then
  begin
    // ����������
    with POpcodeCmdJumpBlock(Result)^ do
    begin
      Proc := Block.P.Proc;
      Reference := Block.O.Reference;
      if (Reference = NO_REFERENCE) then Reference := Block.MakeReference();
    end;

    // ��������
    with Block.P.Proc do Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
  end else
  begin
    // ���������
    POpcodeCmdJumpBlock(Result).Proc := Self.P.Proc;
    POpcodeCmdJumpBlock(Result).Block := Block;
  end;
end;

// ��������� ������� jcc(intel_cc), jmp(-1), call(-2) � ���������� ��������
// ��� ������� �������� ��� ��������� ARM
{$ifdef OPCODE_MODES}
function TOpcodeBlock.cmd_textjump_proc(const cc_ex: shortint; const ProcName: pansichar): POpcodeCmd{POpcodeCmdJumpBlock};
begin
  {$ifdef OPCODE_TEST}
    if (cc_ex < -2{call}) or (cc_ex > ord(high(intel_cc))) then raise_parameter;
    if (ProcName = nil) or (ProcName^ = #0) then raise_parameter;
    if (P.Proc.Mode = omBinary) then raise_parameter;
  {$endif}

  Result := AddCmd(cmJumpBlock);
  Result.F.cc_ex := cc_ex;
  POpcodeCmdJumpBlock(Result).Proc := NO_PROC{���������� "����������, ���������"};
  POpcodeCmdJumpBlock(Result).ProcName := ProcName;
end;
{$endif}


// �������� ���� ����� Self � Next
function TOpcodeBlock.AppendBlock(const ResultSize: integer): POpcodeBlock;
begin
  // Alloc
  with P.Proc.Heap do
  begin
    Result := FState.Current;
    if (FState.Margin >= ResultSize) then
    begin
      Inc(NativeInt(FState.Current), ResultSize);
      Dec(FState.Margin, ResultSize);
    end else
    begin
      Result := Alloc(ResultSize);
    end;
  end;

  // base fields
  Result.CmdList := nil;
  Result.P.Proc := P.Proc;
  Result.N.Next := N.Next;
  N.Next := Result;
  Result.O.Value := NO_FIXUPED or (NO_REFERENCE shl 16);
end;

function TOpcodeBlock.AppendBinaryBlock(const {word}Size: integer): POpcodeBinaryBlock;
begin
  {$ifdef OPCODE_TEST}
    if (Size <= 0) or (Size > high(word)) then raise_parameter;
  {$endif}

  Result := pointer(AppendBlock(sizeof(TOpcodeBlock)+sizeof(integer)+sizeof(TOpcodeCmd) + Size));
  Result.FSize := Size;
  Result.CmdList := @Result.Cmd;
  Result.Cmd.F.Value := Size; // Size = Size, Mode = cmBinary.
end;

function TOpcodeBlock.AppendSwitchBlock(const {�� byte}Count: integer): POpcodeSwitchBlock;
begin
  {$ifdef OPCODE_TEST}
    if (Count <= 0) or (Count > (high(word) div 4)) then raise_parameter;
  {$endif}

  Result := pointer(AppendBlock(sizeof(TOpcodeBlock)+sizeof(integer)+sizeof(TOpcodeCmd) + {BinarySize}Count*sizeof(POpcodeBlock)));
  FillChar(Result.Blocks, {BinarySize}Count*sizeof(POpcodeBlock), #0);
  Result.FCount := Count;
  Result.CmdList := @Result.Cmd;
  Result.Cmd.F.Value := Count*4 + (ord(cmSwitchBlock) shl 16);
end;


// �������������� ���� ��� ��������� ��� ������� ���������
// � ��������� ���� ����� ������������ ��� ���� ����� �������� ���������� ����� ������� (��� �������������)
function TOpcodeBlock.MakeReference(): word;
begin
  Result := O.Reference;

  if (Result = NO_REFERENCE) then
  with P.Proc do
  begin
    Result := F.BlocksReferenced;
    inc(F.BlocksReferenced);

    O.Reference := Result;
  end;
end;


const
  // ����� (������� ���� opcode)
  flag_0f = 1 shl 31;
  flag_rex = 1 shl 30;
  flag_word_ptr = 1 shl 29;
  flag_lock = 1 shl 28;

  flag_x64 = 1 shl 27;
  flag_extra = 1 shl 26; // ������� ��������� �������� � ������ ������

  // 25
  // 24

  // 4 ���� rex, ������������ ��� �� ���� � 24 �� 27
  rex_W = flag_rex or (1 shl 27); // 1 - ������� 64 ����, 0 - ������� 32 ����
  rex_R = flag_rex or (1 shl 26); // ������� ��� ��� reg � �������� ������� ���������
  rex_X = flag_rex or (1 shl 25); // ������� ��� ��� sib
  rex_B = flag_rex or (1 shl 24); // ������� ��� ��� reg/mem � �������� ������� ���������

  // ����� ��������� r8..r15
  rex_RXB = (rex_R or rex_X or rex_B) and (not flag_rex);

  // ��� � ������, ������������, ��� �������� �� 1 ���� (2, 4 ��� 8)
  intel_nonbyte_mask = $0100;

  // ����� ���������
  intel_prefixes: array[0..15] of integer = ($00000000, $000000F0, $00000066,
  $000066F0, $00000040, $000040F0, $00004066, $004066F0, $0000000F, $00000FF0,
  $00000F66, $000F66F0, $00000F40, $000F40F0, $000F4066, $0F4066F0);

  // ������ ������ � ����� � �� ��� rex
  intel_prefixes_info: array[0..15] of word = ($0000,   $0100,     $0100,
  $0200,     $0100,     $0208,     $0208,     $0310,     $0100,     $0200,
  $0200,     $0300,     $0200,     $0308,     $0308,     $0410);

  // ���������� �� ������������: ����� � ������
  ptr_intel_info: array[size_ptr] of integer = (0 or 1, flag_word_ptr or intel_nonbyte_mask or 2,
                                               intel_nonbyte_mask or 4, rex_W or intel_nonbyte_mask or 8, 0, 0);
  // ��������-��������� ��
  cc_intel_info: array[intel_cc] of byte =
  (
    0{_o},
    1{_no},
    2,2,2{_b,_c,_nae},
    3,3,3{_ae,_nb,_nc},
    4,4{_e,_z},
    5,5{_nz,_ne},
    6,6{_be,_na},
    7,7{_a,_nbe},
    8{_s},
    9{_ns},
    $a,$a{_p,_pe},
    $b,$b{_po,_np},
    $c,$c{_l,_nge},
    $d,$d{_ge,_nl},
    $e,$e{_le,_ng},
    $f,$f{_g,_nle}
  );

  // ��������� ��������, ������, �������������� ������ 0
  intel_opcode_mask = integer($f0ffff00);

  // ���������, ����������� �� reg_intel_info ����, ����������� ��� modrm � �������� source
  intel_modrm_src_index = (rex_R or (7 shl (16+3))) xor flag_rex;
  intel_modrm_src_mask = integer($f0000000) or rex_W or intel_modrm_src_index or $ff00{intel_nonbyte_mask};

  // ���������, ����������� �� reg_intel_info ����, ����������� ��� modrm � �������� destination
  intel_modrm_dest_index = (rex_B or (7 shl 16)) xor flag_rex;
  intel_modrm_dest_mask = integer($f0000000) or rex_W or intel_modrm_dest_index or $ff00{intel_nonbyte_mask};

  // imm = (...)
  imm0 = 0;
  imm8 = 1;
  imm32 = 2;  

(*// ���� Intel x64
function TOpcodePackedAddress.Getx64: boolean;
begin
  Result := (bytes[2] and 128 <> 0);
end;

// ������� ����������� 3 ����� � ��������� 4 �����, ������������ �� IntelInspect
function TOpcodePackedAddress.GetIntelInspect(opcode)(): integer;
const
  CLEAN_MASK = rex_R or rex_X or rex_B or $00ffffff;
var
  value, s: integer;
begin
  // 3 �����
  value := pinteger(@bytes)^ shl 8;

  // ������
  s := (value shr 28) and 3;
  if (s = 3) then s := 4;
  value := value or s;

  // ������������ �� sib
  if (value and (1 shl 27) <> 0) then value := value or $f0;

  // �������� ������ ���
  Result := value and CLEAN_MASK;
end; *)

// ������������ ����� ������:
// REX | modrm | sib ��� 0 | imm size
// �������� ����������� � ��������� ������� test_intel_address
function TOpcodeAddress.IntelInspect(const params: integer{x64}): integer;
const
  IMM_VALUES: array[imm0..imm32] of integer =
              ($00000000{mod=00}, $00000001 or (01 shl (6+16)), $00000004 or (02 shl (6+16)));

  // modm = (...)
  m_imm32 = 0;
  m_reg = 1;
  m_sib_nobase = 2;
  m_based_sib = 3;

  // intel_scale = (xNone, x1, x2, x4, x8, x1_plus, x2_plus, x4_plus, x8_plus);
  SCALES: array[intel_scale] of byte = (0, 1, 2, 3{4}, 4{8}, 1, 2, 3{4}, 4{8});
{$ifdef PUREPASCAL}
const
  use_rex_R: array[0..1] of integer = (0, rex_R);
  use_rex_X: array[0..1] of integer = (0, rex_X);
  use_rex_B: array[0..1] of integer = (0, rex_B);
var
  index, base, scale{0, 1, 2, 4, 8}: byte;
  imm: byte;
  modm: byte;

  offset_value: integer;
begin
  // ������� ���������� �����
  if (params and flag_x64 <> 0{x64}) then
  begin
    index := (Self.F.Reg.v - rax) and $f;
    base := (Self.F.Plus.v - rax) and $f;
  end else
  begin
    index := Self.F.Reg.v - eax;
    base := Self.F.Plus.v - eax;
  end;
  scale := SCALES[Self.F.Scale.intel];

  // ���������� imm �� ���������
  if (Self.offset.Kind <> ckValue) then imm := imm32
  else
  begin
    offset_value := Self.offset.Value;
    if (offset_value = 0) then imm := imm0
    else
    if (offset_value >= -128) and (offset_value <= 127) then imm := imm8
    else
    imm := imm32;
  end;

  // ���������� ������� ���������
  case Self.F.Scale.intel of
    xNone: // [$...]
           begin
             modm := m_imm32; // ������������� imm ������� �� �����
           end;
       x1: // [reg + $...]
           begin
             modm := m_reg;

             case (index and 7) of
               4{esp/rsp/r12}: begin
                      base := index;
                      index := 4; 
                      modm := m_based_sib;
                    end;
               5{ebp/rbp/r13}: begin
                      if (imm = imm0) then imm := imm8;
                    end;
             end;
           end;
       x2: // [reg*2 + $...]
           begin
             modm := m_sib_nobase;

             if (imm < imm32) then
             begin
               modm := m_based_sib;
               base := index;
               scale := 1;
             end;  
           end;
    x4,x8: // [reg*4/8 + $...]
           begin
             modm := m_sib_nobase;
           end;
      x1_plus: //[reg1 + reg_base + $...]
           begin
             modm := m_based_sib;

             if (index = 4{esp/rsp}) then
             begin
               index := base;
               base := 4;
             end;
           end;
  else
    // x2_plus, x4_plus, x8_plus
    modm := m_based_sib;
  end;

  // ����������� modm ���� � �������� ���� � sib ������������ ebp � �������� 0
  // ���������� [sib+0]/ebp ������������ ��� sib ��� ����
  if (modm = m_based_sib) and (base and 7 = 5{ebp/rbp/r13}) and (imm = imm0) then imm := imm8;
  
  // ���������: REX | modrm | sib ��� 0 | imm size
  case modm of
       m_imm32: begin
                  Result := $00050004; // modm = imm32
                end;
         m_reg: begin
                  Result := // modm = reg (1 ����)
                            ((index and 7) shl 16) // ������� �������
                            or IMM_VALUES[imm] // ��� imm, ������
                            or USE_REX_B[index shr 3];
                end;
  m_sib_nobase: begin
                  Result := $000405f4 // modm = sib, 4 ����� �� imm, base = *
                            or ((index and 7) shl 11) or ((scale-1) shl 14)
                            or USE_REX_X[index shr 3];
                end;
  else
    // modm = m_based_sib
    Result := $000400f0 or IMM_VALUES[imm]
              or ((base and 7) or ((index and 7) shl 3) or ((scale-1) shl 6)) shl 8
              or USE_REX_B[base shr 3] or USE_REX_X[index shr 3];
  end;
end;
{$else .ASSEMBLER_MODE_x86-64}
const
  sub_rax_rax = -((rax shl 8) or (rax));
  sub_eax_eax = -((eax shl 8) or (eax));
asm
   // ������� � eax �������� const.kind | intel_scale | base | index
   // � edx - ��������� ���������, � ecx - �������� imm (��� $00ffffff {��� imm32})
   test edx, flag_x64
   mov edx, sub_eax_eax
   {$ifdef CPUX86}
      mov ecx, sub_rax_rax
      cmovnz edx, ecx
      mov ecx, [EAX + TOpcodeAddress_offset + TOpcodeConst.F.Value]
      mov eax, dword ptr [EAX].TOpcodeAddress.F.Bytes
   {$else .CPUX64}
      mov eax, sub_rax_rax
      cmovnz edx, eax
      mov eax, dword ptr [RCX].TOpcodeAddress.F.Bytes
      mov ecx, [RCX + TOpcodeAddress_offset + TOpcodeConst.F.Value]
   {$endif}
   test eax, $ff000000 // cmp FKind.v32, ckValue
   jz @offset_calculated
     and eax, $00ffffff
     mov ecx, $00ffffff
   @offset_calculated:

   // ��������� base ��� intel_scale None, x1, x2, x4, x8
   cmp eax, $050000 // x1_plus
   jae @base_corrected
     or eax, $ff00
   @base_corrected:

   // ������������ ������� scale-1| intel_scale | base | index --> edx
   xadd eax, edx
   shr edx, 16
   and eax, $00ff0f0f
   {$ifdef CPUX86}
      mov edx, dword ptr [SCALES + edx]
   {$else .CPUX64}
      lea r11, [SCALES]
      mov edx, [r11 + rdx]
   {$endif}
   shl edx, 24
   sub ecx, -128  // ecx += 128 
   lea edx, [edx + eax - $01000000]
   mov eax, imm32

  // ���������� imm �� ���������
  cmp ecx, 255
  ja @imm_calculated
    cmp ecx, 128
    setne al
  @imm_calculated:

  // ���������� ������� ���������
  mov ecx, edx
  {$ifdef CPUX64}
     lea r11, [IMM_VALUES]
  {$endif}
  shr ecx, 16
  cmp cl, x1_plus
  ja @m_based_sib  // x2_plus, x4_plus, x8_plus
  je @x1_plus
  cmp cl, x2
  ja @m_sib_nobase // x4,x8
  je @x2
  test cl, cl
  jz @m_imm32
  @x1:
    mov ecx, edx
    and ecx, 7
    sub ecx, 4
    cmp ecx, 1
    ja @m_reg
    je @look_ebp_rbp_r13
    @look_esp_rbp_r12:
      mov dh, dl
      mov dl, 4
      jmp @m_based_sib_std
    @look_ebp_rbp_r13:
      test eax, eax
      mov ecx, imm8
      cmovz eax, ecx
      jmp @m_reg
  @x2:
    cmp eax, imm32
    je @m_sib_nobase
    mov dh, dl
    and edx, $0000ffff
    jmp @m_based_sib  
  @x1_plus:
    cmp dl, 4
    jnz @m_based_sib
    xchg dl, dh 
    jmp @m_based_sib

  // ���������: REX | modrm | sib ��� 0 | imm size
  @m_imm32:
     mov eax, $00050004
     ret
  @m_reg:
     shl edx, 16
    {$ifdef CPUX86}
       mov eax, [offset IMM_VALUES + eax*4]
       test edx, $080000
       lea ecx, [eax+REX_B]
    {$else .CPUX64}
       mov eax, [r11 + rax*4]
       test edx, $080000       
       lea rcx, [rax+REX_B]
    {$endif}
     cmovnz eax, ecx
     and edx, $070000
     or eax, edx
     ret
  @m_sib_nobase:
     test dl, 8
     mov eax, $000405f4
     mov ecx, $000405f4 + REX_X
     cmovnz eax, ecx
     mov ecx, edx
     and edx, 7
     and ecx, $ff000000
     shl edx, 11
     shr ecx, 10
     or eax, edx
     or eax, ecx
     ret
  @m_based_sib:
     //  if (modm = m_based_sib) and (base and 7 = 5{ebp/rbp/r13}) and (imm = imm0) then imm := imm8;
     test eax, eax
     movzx ecx, dh
     jnz @m_based_sib_std
     and ecx, 7
     cmp ecx, 5
     mov ecx, imm8
     cmove eax, ecx 
  @m_based_sib_std:
     test dh, 8
    {$ifdef CPUX86}
       mov eax, [offset IMM_VALUES + eax*4]
       push ebx
       lea ecx, [eax+REX_B]
    {$else .CPUX64}
       mov eax, [r11 + rax*4]
       xchg rbx, r8
       lea rcx, [rax+REX_B]
    {$endif}
     mov ebx, REX_X
     cmovnz eax, ecx
     test dl, 8
     mov ecx, 0
     cmovz ebx, ecx
     or eax, $000400f0
     mov ecx, edx
     or eax, ebx
     and ecx, $ff000000
     mov ebx, edx
     and edx, 7
     and ebx, $0700
     shr ecx, 10
     or eax, ebx
     shl edx, 11
     or eax, ecx
     or eax, edx

     // ��������
    {$ifdef CPUX86}
       pop ebx
    {$else .CPUX64}
       xchg rbx, r8
    {$endif}
end;
{$endif}


// �������������� �������� ���������, �������� ����, ������� ��������
function TOpcodeCmd.NeutralizeFakeConst(const data_offs: integer=0): integer;
var
  Ptr: PInteger;
begin
  // ��������
  Ptr := Pointer(NativeInt(@Self) + sizeof(TOpcodeCmd) + integer(Self.Size) - sizeof(integer) - data_offs);

  // �������
  while (Ptr^ <> FAKE_CONST_32) do dec(PByte(Ptr));

  // ���������
  Ptr^ := 0;
  Result := NativeInt(Ptr)-NativeInt(@Self)-sizeof(TOpcodeCmd);
end;



// ��������� ��� ���������� �������� ������ (��� ���������� � �������)
{$ifdef OPCODE_MODES}

{ TOpcodeTextBuffer }

const
  STR_UNKNOWN: string[9] = '<UNKNOWN>';
  STR_CL: string[2] = 'cl';
  STR_NULL: string[0] = '';


function TOpcodeTextBuffer.Format(const FmtStr: AnsiString; const Args: array of const; const Number: byte=0; const MakeLower: boolean=false): PShortString;
var
  Offset: integer;
  Len, i: integer;
begin
  Offset := 0;
  for i := 1 to Number do
  begin
    Offset := Offset + value.bytes[Offset] + sizeof(byte);
  end; 

  if (Offset >= high(value.bytes)) then Result := nil
  else
  begin
    Len := SysUtils.FormatBuf(value.bytes[Offset+1], high(value.bytes)-Offset, pointer(FmtStr)^, Length(FmtStr), Args);

    if (Len > 255) then Len := 255;
    value.bytes[Offset] := Len;

    Result := PShortString(@value.bytes[Offset]);

    if (MakeLower) then
    for i := 1 to Len do
    if (Result^[i] in ['A'..'Z']) then inc(Result^[i], 32);
  end;
end;

function TOpcodeTextBuffer.Str(const S: pansichar; const Number: byte=0): PShortString;
begin
  Result := Format(FMT_ONE_STRING, [S], Number);
end;

// ptr ������ ���� � ������� �����
function TOpcodeTextBuffer.SizePtr(const params_ptr: integer; const Number: byte=0): PShortString;
begin
  Result := Format('%s ptr ', [size_ptr_names[size_ptr(params_ptr)]], Number);
end;

function TOpcodeTextBuffer.InternalConst(const v_const: TOpcodeConst; const can_offsetted, use_sign: boolean; const Number: byte): PShortString;
const
  STR_INTHEX_FMT: array[boolean] of AnsiString = ('%d','$%x');
  SIGNS: array[0..2] of AnsiString = ('', ' + ', ' - ');
var
  X, sign: integer;
  hex: boolean;
begin
  with v_const do
  case Kind of
            ckValue: begin
                       X := F.Value;
                       hex := (X < -128) or (X > 127);

                       if (not use_sign) then
                       begin
                         Result := Format(STR_INTHEX_FMT[hex], [X], Number, {lower if hex}hex);
                       end else
                       begin
                         sign := 1;
                         if (X < 0) then
                         begin
                           X := -X;
                           sign := 2;
                         end;

                         if (hex) then Result := Format('%s$%x', [SIGNS[sign], X], Number, true)
                         else Result := Format('%s%d', [SIGNS[sign], X], Number);
                       end;
                     end;
        ckCondition,
ckOffsetedCondition: begin
                       if (Kind = ckOffsetedCondition) and (can_offsetted) then
                         Result := Format('offset %s%s', [OffsetedCondition, SIGNS[ord(use_sign)]], Number)
                       else
                         Result := Format('%s%s', [SIGNS[ord(use_sign)], Condition], Number);
                     end;
            ckBlock,
         ckVariable: if (can_offsetted) then
                         Result := Format('offset %%s%s', [{Block,} SIGNS[ord(use_sign)]], Number)
                       else
                         Result := Format('%s%%s', [SIGNS[ord(use_sign)]{, Block}], Number);
  else
    Result := Format('%s%s', [SIGNS[ord(use_sign)], STR_UNKNOWN], Number);
  end;
end;

function TOpcodeTextBuffer.Const32(const v_const: const_32; const Number: byte=0): PShortString;
begin
  Result := InternalConst(v_const, true, false, Number);
end;

function TOpcodeTextBuffer.Const64(const v_const: const_64; const Number: byte=0): PShortString;
begin
  with v_const do
  if (Kind = ckValue) then
  begin
    if (Value < -128) then
    begin
      Result := {Int64}Format('-$%x', [-v_const.Value], Number, true);
      exit;
    end;

    if (Value > 127) then
    begin
      Result := {Int64}Format('$%x', [v_const.Value], Number, true);
      exit;
    end;
  end;

  Result := InternalConst(v_const, true, false, Number);
end;

function TOpcodeTextBuffer.IntelAddress(const params: integer{x64}; const addr: TOpcodeAddress;
                                        const can_offsetted: boolean=true; const Number: byte=0): PShortString;
const
  BASE_REG: array[boolean{x64}] of integer = (eax, rax);
  SCALES: array[0..3] of AnsiString = ('', '*2', '*4', '*8');

  //offs_R = 26-4+1; // rex_R = flag_rex or (1 shl 26); // ������� ��� ��� reg � �������� ������� ���������
  offs_X = 25-4+1; // rex_X = flag_rex or (1 shl 25); // ������� ��� ��� sib
  offs_B = 24-4+1; // rex_B = flag_rex or (1 shl 24); // ������� ��� ��� reg/mem � �������� ������� ���������
var
  addr_value: integer;
  x64, const_left: boolean;

  const_str: TOpcodeTextBuffer;
  reg_str: PShortString;

  // �������� ����� �� 3 ������������
  low, middle, high, last_high: byte;
  procedure inspect_byte(const b: byte);
  begin
    low := b and 7;
    middle := (b shr 3) and 7;
    high := b shr 6;
  end;

  // ���������� ������ �� ���������
  procedure MakeRegStr(const FmtStr: AnsiString; const Args: array of const);
  begin
    reg_str := const_str.Format(FmtStr, Args, 1);
  end;

begin
  x64 := (params and flag_x64 <> 0);
  addr_value := addr.IntelInspect(params);


  // ���� ������������ modrm
  inspect_byte(addr_value shr 16);

  // ��� disp32 ������ ������
  if (high = 0) and (low = 5) then
  begin
    const_str.InternalConst(addr.offset, can_offsetted and (not x64), false, 0);
    Result := Format('[%s]', [const_str.value.S], Number);
    exit;
  end;

  // ���������� ��������� � ������
  case addr.offset.Kind of
    ckValue: if (addr.offset.Value = 0) then
             begin
               // ��� ��������� ������ ������ ������
               const_left := true;
               const_str.value.bytes[0] := 0;
             end else
             begin
               // + <��������>
               const_left := false;
               const_str.InternalConst(addr.offset, false, true, 0);
             end;
    ckOffsetedCondition,
    ckBlock,
 ckVariable: begin
               // offset ... +
               const_left := true;
               const_str.InternalConst(addr.offset, can_offsetted, true, 0);
             end;
  else
    // + <UNKNOWN>
    const_left := false;
    const_str.InternalConst(addr.offset, can_offsetted, true, 0);
  end;

  // modrm/sib
  if (low <> 4) then
  begin
    low := low + (addr_value shr offs_B) and 8;
    MakeRegStr(reg_intel_names[BASE_REG[x64] + low], []);
  end else
  begin
    // sib
    last_high := high;
    inspect_byte(addr_value shr 8);
    middle := middle + (addr_value shr offs_X) and 8;
    low := low + (addr_value shr offs_B) and 8;

    if (low = 4) then
    begin
      // ��� ���������
      MakeRegStr(reg_intel_names[BASE_REG[x64] + low], []);
    end else
    if (last_high = 0) and (low in [5, 13]) then
    begin
      // ������ ��������� (��� ����)
      MakeRegStr('%s%s',
      [
        reg_intel_names[BASE_REG[x64] + middle],
        SCALES[high]
      ]);
    end else
    begin
      // ���� ���������
      MakeRegStr('%s%s + %s',
      [
        reg_intel_names[BASE_REG[x64] + middle],
        SCALES[high],
        reg_intel_names[BASE_REG[x64] + low]
      ]);
    end;
  end;

  // ���������
  if (const_left) then Result := Format('[%s%s]', [const_str.value.S, reg_str^], Number)
  else Result := Format('[%s%s]', [reg_str^, const_str.value.S], Number);
end;
{$endif}


{ TOpcodeBlock_Intel }

// ����� ������ � ����������� Intel ����� �������
// ��������� �� ���:
// - �������� ����������� ���������� ������ ��� �������
// - �������������� � ������� �������� �������
// - �������� ��� ��������
// - ����� ������� (1 ��� 2 ����)
// - ������ Advanced (��� ����� ���� ��������� ��� �����-�� �������������� ������)
//
// ������:
// 4 ������� ���� - ����� ���������
// 4 ���� - �������� REX
// 1 ���� ������ ������� - ���� ������ ����� ��������� modrm
// 1 ���� ������ ������� - �� �� ����� ������������� (0)
// 8 ��� (1 ����) - �������������� ������. ��� ����� ���� �������� ��������� ��� ������ ������
function TOpcodeBlock_Intel.AddSmartBinaryCmd(Parameters, Advanced: integer): POpcodeCmd;
{$ifdef PURE_PASCAL}
var
  Dest: pinteger;

  X: integer;
  OpcodeOffset, OpcodeSize: integer;
  DataSize: integer;
begin
  // ����� ���������
  X := Parameters shr 28;
  // ������ ������ ���������
  OpcodeOffset := intel_prefixes_info[X] shr 8;

  // ������ ������: 1 ��� 2
  OpcodeSize := 2;
  if (Parameters and $00ff00 = 0) then
  begin
    Parameters := Parameters or ((Parameters and $ff0000) shr 8);
    OpcodeSize := 1;
  end;

  // ����� ������, ��������� �������
  DataSize := OpcodeOffset + OpcodeSize + byte(Parameters);
  Result := AddCmd(cmBinary, DataSize);

  // ���������� ������ � �����
  Dest := pinteger(@Result.Data.Bytes[Result.Size-DataSize]);
  // ��������
  Dest^ := intel_prefixes[X] or ((Parameters shr 24) and $f) shl byte(intel_prefixes_info[X]);
  // ����� �������
  Inc(NativeInt(Dest), OpcodeOffset);
  Dest^ := Parameters shr 8;
  // ����� Advanced
  Inc(NativeInt(Dest), OpcodeSize);
  Dest^ := Advanced;
end;
{$else .ASSEMBLER_MODE_x86-64}
const
  CMD_HEADER_SIZE = sizeof(TOpcodeCmd);
  CMD_HEADER_PLUS_CUSHION = CMD_HEADER_SIZE + CMD_CUSHION_SIZE;
asm
  // ��������� Advanced � Parameters 
  // "��������" ebx/rbx � rsi/esi
  {$ifdef CPUX86}
     push esi
     push ebx
     push ecx     
     push edx
  {$else .CPUX64}
     push r12
     // mov r8, r8 - Advanced
     mov r9, rsi
     xchg r10, rbx
     mov r11, rdx
     
     // ��������� Self � rax ����� �� �������� � ���������
     xchg rax, rcx
  {$endif}

  // ��������� ������ ���������� - ebx
  // ��������� DataSize - ecx
  mov esi, edx
  shr edx, 28
  mov ecx, 2
  test esi, $00ff00
  {$ifdef CPUX86}
  movzx ebx, word ptr [intel_prefixes_info + edx*2]
  {$else .CPUX64}
  lea r12, [intel_prefixes_info]
  movzx ebx, word ptr [r12 + rdx*2]
  {$endif}
  jnz @opcode_size_done
    mov ecx, esi
    and esi, $ff0000
    shr esi, 8
    or ecx, esi
    {$ifdef CPUX86}
      mov [esp], ecx
    {$else .CPUX64}
      mov r11, rcx
    {$endif}
    mov ecx, 1
  @opcode_size_done:
  shl edx, 24   // X | | |
  mov esi, ecx
  xadd ebx, edx // X | | opc offs | rex shl
  shl esi, 16
  shr edx, 8 // OpcodeOffset(PrefixesSize)
  or ebx, esi // ���� � �����
  // �������������� ������
  {$ifdef CPUX86}
    movzx esi, byte ptr [esp]
  {$else .CPUX64}
    movzx esi, r11b
  {$endif}
  add ecx, edx
  // ��������� ebx
  {$ifdef CPUX86}
    push ebx
  {$else .CPUX64}
    xchg rbx, r12
  {$endif}
  add ecx, esi

  // Result := AddCmd(cmBinary, DataSize);
  // [�� ���� ������ ������������� ���� ������� ��� ��� ���������] 
  // in:
  // eax/rax - Self
  // ebx - ������ ����:  X | OpcodeSize | OpcodeOffset | byte(intel_prefixes_info[X])
  // ecx - DataSize
  // edx � esi - ������
  // out:
  // eax/rax - ��������� (CmdList)
  // esi/rsi - Dest
  {$ifdef CPUX86}
    // with Self.P.Proc
    mov esi, [EAX].TOpcodeBlock.P.Proc
    // if  LastBinaryCmd <> Self.CmdList (ebx)
    mov ebx, [EAX].TOpcodeBlock.CmdList
    cmp [ESI].TOpcodeProc.FLastBinaryCmd, ebx
    jne @allocate_new
    // if LastHeapCurrent <> Heap(esi).FState.Current
    mov edx, [ESI].TOpcodeProc.FLastHeapCurrent
    mov esi, [ESI].TOpcodeProc.FHeap
    cmp [ESI].TOpcodeHeap.FState.Current, edx
    jne @allocate_new
    // if (Integer(Self.CmdList.F.Size) + DataSize > high(word))
    add word ptr [EBX].TOpcodeCmd.F.Size, cx
    jo @allocate_new_step_overflow
    // if (Heap.FState.Margin < (DataSize+CMD_CUSHION_SIZE))
    add ecx, CMD_CUSHION_SIZE
    sub [ESI].TOpcodeHeap.FState.Margin, ecx
    jl @allocate_new_step_margin
    @allocate_append:
      // �������� ������ ������� - ������ ��������� ������ � �����
      // eax - TOpcodeBlock, esi - TOpcodeHeap, ebx - CmdList(Result), edx - Current, ecx - (DataSize+CMD_CUSHION_SIZE)
      lea ecx, [ecx + edx - CMD_CUSHION_SIZE]
      mov eax, [EAX].TOpcodeBlock.P.Proc
      mov [ESI].TOpcodeHeap.FState.Current, ecx
      xchg esi, edx
      mov [EAX].TOpcodeProc.FLastHeapCurrent, ecx
      xchg eax, ebx
    jmp @allocating_done
    @allocate_new_step_margin:
      add [ESI].TOpcodeHeap.FState.Margin, ecx
      sub ecx, CMD_CUSHION_SIZE
    @allocate_new_step_overflow:
      sub word ptr [EBX].TOpcodeCmd.F.Size, cx
    @allocate_new:
      // �������� ����� �������
      mov esi, [EAX].TOpcodeBlock.P.Proc
      mov ebx, [ESI].TOpcodeProc.FHeap
      add ecx, CMD_HEADER_PLUS_CUSHION // ResultSize+CMD_CUSHION_SIZE
      mov esi, [EBX].TOpcodeHeap.FState.Current
      mov edx, [EBX].TOpcodeHeap.FState.Margin
      // ������������ �� 4 �����
      add esi, 3
      and edx, -4
      and esi, -4
      // if FState.Margin < (ResultSize+CMD_CUSHION_SIZE) then @call_alloc_cmd()
      sub edx, ecx
      jl @call_alloc_cmd
      @no_call_alloc_cmd:
        // ������ ������� - ������ ������ Current/Margin
        // Margin := bufMargin + CMD_CUSHION_SIZE
        add edx, CMD_CUSHION_SIZE
        mov [EBX].TOpcodeHeap.FState.Margin, edx
        // Current ���������� � @allocated_fields (= ����� edx) 
        lea edx, [esi + ecx - CMD_CUSHION_SIZE]
      jmp @allocated_fields
      @call_alloc_cmd:
        // ������������ ����� Heap.Alloc(), �� ��� ����������� Current � Margin
        add edx, ecx
        mov [EBX].TOpcodeHeap.FState.Current, esi
        mov [EBX].TOpcodeHeap.FState.Margin, edx
        push eax
        push ecx
          mov eax, ebx
          mov edx, ecx
          call TOpcodeHeap.Alloc
          mov esi, eax
        pop ecx
        pop eax
        mov edx, [EBX].TOpcodeHeap.FState.Current
        add [EBX].TOpcodeHeap.FState.Margin, CMD_CUSHION_SIZE
        sub edx, CMD_CUSHION_SIZE
      @allocated_fields:
      // eax - TOpcodeBlock, ebx - TOpcodeHeap, edx - new Heap.Current,
      // ecx - (DataSize+Header+Cushion), esi - TOpcodeCmd (Result)

      // ������
      sub ecx, CMD_HEADER_PLUS_CUSHION
      mov [ESI].TOpcodeCmd.F.Value, ecx
      // ����������� ����
      mov [EBX].TOpcodeHeap.FState.Current, edx
      mov ecx, [EAX].TOpcodeBlock.P.Proc
      mov ebx, [EAX].TOpcodeBlock.CmdList
      mov [ECX].TOpcodeProc.FLastBinaryCmd, esi
      mov [ECX].TOpcodeProc.FLastHeapCurrent, edx
      // cmd list
      mov [ESI].TOpcodeCmd.FNext, ebx
      mov [EAX].TOpcodeBlock.CmdList, esi
      // ��������� (eax) � Dest (esi)
      mov eax, CMD_HEADER_SIZE
      xadd esi, eax
  {$else .CPUX64}
    // with Self.P.Proc
    mov rsi, [RAX].TOpcodeBlock.P.Proc
    // if  LastBinaryCmd <> Self.CmdList (ebx)
    mov rbx, [RAX].TOpcodeBlock.CmdList
    cmp [RSI].TOpcodeProc.FLastBinaryCmd, rbx
    jne @allocate_new
    // if LastHeapCurrent <> Heap(esi).FState.Current
    mov rdx, [RSI].TOpcodeProc.FLastHeapCurrent
    mov rsi, [RSI].TOpcodeProc.FHeap
    cmp [RSI].TOpcodeHeap.FState.Current, rdx
    jne @allocate_new
    // if (Integer(Self.CmdList.F.Size) + DataSize > high(word))
    add word ptr [RBX].TOpcodeCmd.F.Size, cx
    jo @allocate_new_step_overflow
    // if (Heap.FState.Margin < (DataSize+CMD_CUSHION_SIZE))
    add ecx, CMD_CUSHION_SIZE
    sub [RSI].TOpcodeHeap.FState.Margin, ecx
    jl @allocate_new_step_margin
    @allocate_append:
      // �������� ������ ������� - ������ ��������� ������ � �����
      // rax - TOpcodeBlock, rsi - TOpcodeHeap, rbx - CmdList(Result), rdx - Current, ecx - (DataSize+CMD_CUSHION_SIZE)
      lea rcx, [rcx + rdx - CMD_CUSHION_SIZE]
      mov rax, [RAX].TOpcodeBlock.P.Proc
      mov [RSI].TOpcodeHeap.FState.Current, rcx
      xchg rsi, rdx
      mov [RAX].TOpcodeProc.FLastHeapCurrent, rcx
      xchg rax, rbx
    jmp @allocating_done
    @allocate_new_step_margin:
      add [RSI].TOpcodeHeap.FState.Margin, ecx
      sub ecx, CMD_CUSHION_SIZE
    @allocate_new_step_overflow:
      sub word ptr [RBX].TOpcodeCmd.F.Size, cx
    @allocate_new:
      // �������� ����� �������
      mov rsi, [RAX].TOpcodeBlock.P.Proc
      mov rbx, [RSI].TOpcodeProc.FHeap
      add ecx, CMD_HEADER_PLUS_CUSHION // ResultSize+CMD_CUSHION_SIZE
      mov rsi, [RBX].TOpcodeHeap.FState.Current
      mov edx, [RBX].TOpcodeHeap.FState.Margin
      // ������������ �� 4 �����
      add rsi, 3
      and edx, -4
      and rsi, -4
      // if FState.Margin < (ResultSize+CMD_CUSHION_SIZE) then @call_alloc_cmd()
      sub edx, ecx
      jl @call_alloc_cmd
      @no_call_alloc_cmd:
        // ������ ������� - ������ ������ Current/Margin
        // Margin := bufMargin + CMD_CUSHION_SIZE
        add edx, CMD_CUSHION_SIZE
        mov [RBX].TOpcodeHeap.FState.Margin, edx
        // Current ���������� � @allocated_fields (= ����� edx)
        lea rdx, [rsi + rcx - CMD_CUSHION_SIZE]
      jmp @allocated_fields
      @call_alloc_cmd:
        // ������������ ����� Heap.Alloc(), �� ��� ����������� Current � Margin
        add edx, ecx
        mov [RBX].TOpcodeHeap.FState.Current, rsi
        mov [RBX].TOpcodeHeap.FState.Margin, edx
        push rax
        push rcx
          mov rcx, rbx
          mov edx, ecx
          push r8
          push r9
          push r10
          push r11
            call TOpcodeHeap.Alloc
          pop r11
          pop r10
          pop r9
          pop r8
          mov rsi, rax
        pop rcx
        pop rax
        mov rdx, [RBX].TOpcodeHeap.FState.Current
        add [RBX].TOpcodeHeap.FState.Margin, CMD_CUSHION_SIZE
        sub rdx, CMD_CUSHION_SIZE
      @allocated_fields:
      // rax - TOpcodeBlock, rbx - TOpcodeHeap, rdx - new Heap.Current,
      // rcx - (DataSize+Header+Cushion), rsi - TOpcodeCmd (Result)

      // ������
      sub ecx, CMD_HEADER_PLUS_CUSHION
      mov [RSI].TOpcodeCmd.F.Value, ecx
      // ����������� ����
      mov [RBX].TOpcodeHeap.FState.Current, rdx
      mov rcx, [RAX].TOpcodeBlock.P.Proc
      mov rbx, [RAX].TOpcodeBlock.CmdList
      mov [RCX].TOpcodeProc.FLastBinaryCmd, rsi
      mov [RCX].TOpcodeProc.FLastHeapCurrent, rdx
      // cmd list
      mov [RSI].TOpcodeCmd.FNext, rbx
      mov [RAX].TOpcodeBlock.CmdList, rsi
      // ��������� (rax) � Dest (rsi)
      mov rax, CMD_HEADER_SIZE
      xadd rsi, rax
  {$endif}
  @allocating_done:

  // ������ ��������, ��������� ��� ����� � eax/rax, Dest - � esi/rsi
  // ������ ebx/rbx
  {$ifdef CPUX86}
    pop ebx
  {$else .CPUX64}
    xchg rbx, r12
  {$endif}


  // ������� ������: ��������, ����� �������, advanced
  // � ��������� ������� edx � ecx
  {$ifdef CPUX86}
    // ��������
    mov edx, [esp]
    shr edx, 24
    mov ecx, ebx
    and edx, $f
    shl edx, cl
    shr ecx, 24
    or edx, [offset intel_prefixes + ecx*4]
    mov [esi], edx
    // ����� �������
    pop edx
    movzx ecx, bh
    shr edx, 8
    add esi, ecx
    shr ebx, 16
    mov [esi], edx

    // advanced
    and ebx, $ff
    pop dword ptr [esi+ebx]
  {$else .CPUX64}
  // ������ ��������, ��������� ��� ����� � rax, Dest - � rsi
  // rbx �������� ����:  X | OpcodeSize | OpcodeOffset | byte(intel_prefixes_info[X])

     // r8 - Advanced
     // r9 - ������ rsi
     // r10 - ������ rbx
     // r11 - Parameters   

    // ��������
    lea rdx, [intel_prefixes]
    mov r12, r11
    mov ecx, ebx
    shr r11, 24
    shr ecx, 24
    and r11, $f
    mov edx, [rdx + rcx*4]
    mov ecx, ebx
    shr r12, 8
    shl r11, cl
    or rdx, r11
    movzx ecx, bh
    mov [rsi], edx

    // ����� �������
    add rsi, rcx
    shr ebx, 16
    mov [rsi], r12d

    // advanced
    and ebx, $ff
    mov [rsi+rbx], r8d
  {$endif}

  // ������� ���������
  {$ifdef CPUX86}
    pop ebx
    pop esi
  {$else .CPUX64}
    xchg r10, rbx
    xchg r9, rsi
    pop r12
  {$endif}
end;
{$endif}


// ��������������� ������� ��� �������
// ��������� ���������� Min_Max �� ����������
{$ifdef OPCODE_MODES}
function TOpcodeBlock_Intel.HybridSize_MinMax(base_params, Parameters{�������� �������� ��� AddSmartBinaryCmd}: integer;
                                              addr: POpcodeAddress): integer{word};
var
  buf: TOpcodeAddress;
  i1, i2: integer;
begin
  Result := (intel_prefixes_info[Parameters shr 28] shr 8) + // ������ ������ ���������
            (1 + ord(Parameters and $00ff00 <> 0)) + // ������ ������: 1 ��� 2
            byte(Parameters); // �������������� �����

  // Min_Max
  Result := Result or (Result shl 8);

  // ������������� Min ��� ������
  if (addr <> nil) and (addr.offset.Kind = ckCondition) then
  begin
    i1 := addr.IntelInspect(base_params);
    buf := addr^;
    buf.offset.Kind := ckValue;
    buf.offset.Value := 0;
    i2 := buf.IntelInspect(base_params);

    Result := Result - ((i1 and $f)+ord(i1 and $f0))-((i2 and $f)+ord(i2 and $f0));
  end;
end;
{$endif}



procedure TOpcodeBlock_Intel.diffcmd_const32(params: integer; const v_const: const_32; callback: opused_callback_0{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
var
  fake_const: const_32;
  use_const: ^const_32;
begin
  use_const := @v_const;
  
  if (TMethod(callback).Data <> nil) then
  begin
    {$ifdef OPCODE_TEST}
       test_const(v_const, false, P.Proc);
    {$endif}

    // ������ ��������
    if (v_const.Kind = ckPValue) then
    begin
      AddCmdPointer(params, v_const.pValue, 0 shl 24, TMethod(callback).Code, @TOpcodeBlock_Intel.diffcmd_const32{$ifdef OPCODE_MODES},cmd{$endif});
      exit;
    end else
    if (v_const.Kind >= ckBlock) then
    begin
      {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode <> omBinary) then
      begin
        fake_const.Kind := ckOffsetedCondition;
        fake_const.OffsetedCondition := pointer(FMT_ONE_STRING);
      end else
      {$endif}
      begin
        fake_const.Kind := ckValue;
        fake_const.Value := FAKE_CONST_32;
      end;
      use_const := @fake_const;
    end;
  end else  
  begin
    TMethod(callback).Data := @Self;
  end;

  // ��������
  callback(params, {$ifdef OPCODE_MODES}use_const^,cmd{$else}use_const.Value{$endif});

  // ������������� ��� �������� ������
  // ������ �������� �������� � v_const
  if (use_const = @fake_const) then
  begin
    // ��������
    with v_const do
    if (Kind = ckBlock) then
    begin
      if (Block.P.Proc <> Self.P.Proc) then
      with Block.P.Proc do
      Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
    end else
    // if (Kind = ckVariable) then
    begin
      with Variable do
      Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
    end;

    // ������������ ���������������� ����������
    JoinCmdCellData(false, v_const);
  end;
end;

procedure TOpcodeBlock_Intel.diffcmd_addr(params: integer; const addr: TOpcodeAddress; callback: opused_callback_1{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
var
  fake_addr: TOpcodeAddress;
  use_addr: ^TOpcodeAddress;
begin
  use_addr := @addr;
  
  if (TMethod(callback).Data <> nil) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, params and flag_x64 <> 0, P.Proc);
    {$endif}

    // ������ ��������
    if (addr.offset.Kind = ckPValue) then
    begin
      AddCmdPointer(params, addr.offset.pValue, (pinteger(@addr.F.Bytes)^ and $00ffffff) or (1 shl 24),
                    TMethod(callback).Code, @TOpcodeBlock_Intel.diffcmd_addr{$ifdef OPCODE_MODES},cmd{$endif});
      exit;
    end else
    if (addr.offset.Kind >= ckBlock) then
    begin
      pinteger(@fake_addr.F.Bytes)^ := pinteger(@addr.F.Bytes)^;
      use_addr := @fake_addr;

      {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode <> omBinary) then
      begin
        fake_addr.offset.Kind := ckOffsetedCondition;
        fake_addr.offset.OffsetedCondition := pointer(FMT_ONE_STRING);
      end else
      {$endif}
      begin
        fake_addr.offset.Kind := ckValue;
        fake_addr.offset.Value := FAKE_CONST_32;
      end;
    end;
  end else  
  begin
    TMethod(callback).Data := @Self;
  end;

  // ��������
  callback(params, use_addr^{$ifdef OPCODE_MODES},cmd{$endif});

  // ������������� ��� �������� ������
  // ������ �������� �������� � addr
  if (use_addr = @fake_addr) then
  begin
    // ��������
    with addr.offset do
    if (Kind = ckBlock) then
    begin
      if (Block.P.Proc <> Self.P.Proc) then
      with Block.P.Proc do
      Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
    end else
    // if (Kind = ckVariable) then
    begin
      with Variable do
      Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
    end;

    // ������������ ���������������� ����������
    JoinCmdCellData({relative: boolean} (addr.F.Scale.intel = xNone) and
                    (params and flag_x64 <> 0) and (addr.offset.Kind = ckBlock)
                   , addr.offset);
  end;
end;

procedure TOpcodeBlock_Intel.diffcmd_addr_const(params: integer; const addr: TOpcodeAddress; const v_const: const_32; callback: opused_callback_2{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
var
  buf_addr, fake_addr: TOpcodeAddress;
  buf_const, fake_const: const_32;

  use_addr: POpcodeAddress;
  use_const: ^const_32;

  cmd_ptr_mode: boolean;
  Consts: POpcodeConst;

  difficult_mode: byte; {����� �� 0 �� 3}
begin
  use_addr := @addr;
  use_const := @v_const;

  if (TMethod(callback).Data <> nil) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, params and flag_x64 <> 0, P.Proc);
       test_const(v_const, false, P.Proc);
    {$endif}

    // �������� ��������� �����������, ����������, �������� �� "�������� ����"
    // ����� ����������� � ���, ����� ����� ������� �������� (���� �����) � MakeReference()
    cmd_ptr_mode := false;
    with addr.offset do
    case Kind of
      ckPValue: cmd_ptr_mode := true;
       ckBlock: // ����������� ������ ������������ ������ ��� ������ � �������� ������
                {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode = omBinary) then{$endif}
                begin
                 use_addr := @buf_addr;
                 pinteger(@buf_addr.F.Bytes)^ := pinteger(@addr.F.Bytes)^;

                 if (Block.P.Proc <> Self.P.Proc) then
                 begin
                   // ���������� (�������� �����) - ���������������  Variable/VariableOffset
                   // ����� ������� � ��������
                   buf_addr.offset.Variable := TOpcodeVariable(Block.P.Proc);
                   // buf_addr.offset.VariableOffset := Block.MakeReference;
                   buf_addr.offset.VariableOffset := Block.O.Reference;
                   if (buf_addr.offset.VariableOffset = NO_REFERENCE) then buf_addr.offset.VariableOffset := Block.MakeReference;

                   // ��������
                   with Block.P.Proc do
                   Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
                 end else
                 begin
                   // ���������: ���� + 0
                   buf_addr.offset.VariableOffset := 0;
                 end;
               end;
   ckVariable: begin
                 // ��������
                 with Variable do
                 Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
               end;
    end;
    with v_const do
    case Kind of
      ckPValue: cmd_ptr_mode := true;
       ckBlock: // ����������� ������ ������������ ������ ��� ������ � �������� ������
                {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode = omBinary) then{$endif}
                begin
                 use_const := @buf_const;

                 if (Block.P.Proc <> Self.P.Proc) then
                 begin
                   // ���������� (�������� �����) - ���������������  Variable/VariableOffset
                   // ����� ������� � ��������
                   buf_const.Variable := TOpcodeVariable(Block.P.Proc);
                   // buf_const.VariableOffset := Block.MakeReference;
                   buf_const.VariableOffset := Block.O.Reference;
                   if (buf_const.VariableOffset = NO_REFERENCE) then buf_const.VariableOffset := Block.MakeReference;

                   // ��������
                   with Block.P.Proc do
                   Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
                 end else
                 begin
                   // ���������: ���� + 0
                   buf_const.VariableOffset := 0;
                 end;
               end;
   ckVariable: begin
                 // ��������
                 with Variable do
                 Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
               end;
    end;

    // ���� ���������
    if (cmd_ptr_mode){(addr.offset.Kind = ckPValue) or (v_const.Kind = ckPValue)} then
    begin
      Consts := P.Proc.Heap.Alloc(2*sizeof(TOpcodeConst));
      Consts^ := use_addr.offset;
      inc(Consts);
      Consts^ := use_const^;
      dec(Consts);

      AddCmdPointer(params, Consts, (pinteger(@use_addr.F.Bytes)^ and $00ffffff) or (2 shl 24),
                    TMethod(callback).Code, @TOpcodeBlock_Intel.diffcmd_addr_const{$ifdef OPCODE_MODES},cmd{$endif});
      exit;
    end;
  end else
  begin
    TMethod(callback).Data := @Self;
  end;

  // ������������ ������� �������� (Block � Variable)
  difficult_mode := 0;
  if (use_addr.offset.Kind >= ckBlock) then
  begin
    difficult_mode := 2;

    // buf_addr � ����� ������ ������ ��������� ������ ��������
    if (use_addr <> @buf_addr) then buf_addr := use_addr^{addr};

    // use_addr := @FAKE_ADDRESS;
    pinteger(@fake_addr.F.Bytes)^ := pinteger(@use_addr.F.Bytes)^;
    {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode <> omBinary) then
    begin
      fake_addr.offset.Kind := ckOffsetedCondition;
      fake_addr.offset.OffsetedCondition := pointer(FMT_ONE_STRING);
    end else
    {$endif}
    begin
      fake_addr.offset.Kind := ckValue;
      fake_addr.offset.Value := FAKE_CONST_32;
    end;
    use_addr := @fake_addr;                       
  end;
  if (use_const.Kind >= ckBlock) then
  begin
    inc(difficult_mode);

    // buf_const � ����� ������ ������ ��������� ������ ��������
    if (use_const <> @buf_const) then buf_const := use_const^{v_const};

    // ��������� �� �������� ���������
    {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode <> omBinary) then
    begin
      fake_const.Kind := ckOffsetedCondition;
      fake_const.OffsetedCondition := pointer(FMT_ONE_STRING);
    end else
    {$endif}
    begin
      fake_const.Kind := ckValue;
      fake_const.Value := FAKE_CONST_32;
    end;
    use_const := @fake_const;
  end;

  // ��������
  callback(params, use_addr^, {$ifdef OPCODE_MODES}use_const^,cmd{$else}use_const.Value{$endif});

  // ������������� ��� �������� ������
  // ������ �������� �������� � buf_addr/buf_const
  if (difficult_mode <> 0) then
  begin
    // ����������� ���������� ���� relative (mode |= 4)
    if (difficult_mode and 2 <> 0) and (params and flag_x64 <> 0) and
       (buf_addr.F.Scale.intel = xNone) and (buf_addr.offset.Kind = ckBlock) then
       difficult_mode := difficult_mode or 4;

    // ������������ ���������������� ����������
    JoinCmdCellData(difficult_mode, buf_addr.offset, buf_const);
  end;  
end;

procedure TOpcodeBlock_Intel.diffcmd_const64(params: integer; const v_const: const_64; callback: opused_callback_3{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
var
  fake_const: const_64;
  use_const: ^const_64;
begin
  use_const := @v_const;
  if (TMethod(callback).Data <> nil) then
  begin
    {$ifdef OPCODE_TEST}
       test_const(v_const, true, P.Proc);
    {$endif}

    // ������ ��������
    if (v_const.Kind = ckPValue) then
    begin
      AddCmdPointer(params, v_const.pValue, 3 shl 24, TMethod(callback).Code, @TOpcodeBlock_Intel.diffcmd_const64{$ifdef OPCODE_MODES},cmd{$endif});
      exit;
    end else
    if (v_const.Kind >= ckBlock) then
    begin
      {$ifdef OPCODE_MODES}if (Self.P.Proc.Mode <> omBinary) then
      begin
        fake_const.Kind := ckOffsetedCondition;
        fake_const.OffsetedCondition := pointer(FMT_ONE_STRING);
      end else
      {$endif}
      begin
        fake_const.Kind := ckValue;
        fake_const.Value := FAKE_CONST_32;
      end;
      use_const := @fake_const;
    end;
  end else
  begin
    TMethod(callback).Data := @Self;
  end;

  // ��������
  callback(params, {$ifdef OPCODE_MODES}use_const^,cmd{$else}use_const.Value{$endif});

  // ������������� ��� �������� ������
  // ������ �������� �������� � v_const
  if (use_const = @fake_const) then
  begin
    // ��������
    with v_const do
    if (Kind = ckBlock) then
    begin
      if (Block.P.Proc <> Self.P.Proc) then
      with Block.P.Proc do
      Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
    end else
    if (Kind = ckVariable) then
    begin
      with Variable do
      Storage.SubscribeGlobal(FSubscribedProcs, Self.P.Proc);
    end;

    // ������������ ���������������� ����������
    JoinCmdCellData(false, v_const);
  end;
end;

// ���� �������
// �������� emms ��� ud2
function TOpcodeBlock_Intel.cmd_single(const opcode: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
{$ifndef OPCODE_FAST}
var
  cmd_size: integer;
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    if (@cmd = nil) then Result := nil
    else Result := AddCmdText(@cmd);
    
    exit;
  end;
  {$endif}

  // ������
  if (opcode > $ffff) then
  begin
    if (opcode > $ffffff) then cmd_size := 4
    else cmd_size := 3;
  end else
  begin
    if (opcode > $ff) then cmd_size := 2
    else cmd_size := 1;
  end;

  // ���������
  Result := AddCmd(cmBinary, cmd_size);
  pinteger(@POpcodeCmdData(Result).Bytes[Result.Size-cmd_size])^ := opcode;
  //Result := AddSmartBinaryCmd((cmd_size-1) or ((opcode and $ff) shl 16), opcode shr 8);
end;
{$else}
asm
  {$ifdef CPUX64}
     xchg rcx, r8
  {$endif}

  mov ecx, edx
  movzx edx, dl
  shl edx, 16

  shr ecx, 8
  jz @1
  cmp ecx, $ff
  jle @2
  cmp ecx, $ffff
  jle @3
@4: inc edx
@3: inc edx
@2: inc edx
@1:
  {$ifdef CPUX64}
     xchg rcx, r8
  {$endif}
  jmp AddSmartBinaryCmd
end;
{$endif}

// ���������� ������� (r)esi-(r)edi
// �������� movsb(/w/d/q), cmpsb(/w/d/q),
function TOpcodeBlock_Intel.cmd_rep_bwdq(const reps: intel_rep{=REP_SINGLE}; opcode: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
{$ifndef OPCODE_FASTEST}
var
  CmdSize: integer;
  X: integer;
{$ifdef OPCODE_MODES}
const
  intel_rep_names: array[intel_rep] of pansichar = (nil, 'REP', 'REPE', 'REPZ', 'REPNE', 'REPNZ');
{$endif}
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    // RepToStr() + cmd
    if (reps = REP_SINGLE) then Result := AddCmdText(@cmd)
    else Result :=  AddCmdText('%s %s', [intel_rep_names[reps], cmd]);

    exit;
  end;
  {$endif}

  X := opcode;
  CmdSize := 1;
  if (opcode > $ff) then CmdSize := 2;

  case reps of
    REP, REPE, REPZ: begin
                       X := (X shl 8) or $F3;
                       System.Inc(CmdSize);
                     end;
       REPNE, REPNZ: begin
                       X := (X shl 8) or $F2;
                       System.Inc(CmdSize);
                     end;
  end;

  // ���������
  //Result := AddCmd(cmBinary, CmdSize);
  //Result.Data.Dwords[0] := X;
  Result := AddSmartBinaryCmd((CmdSize-1) or ((X and $ff) shl 16), X shr 8);
end;
{$else}
asm
  test dl, dl
  jz @no_rep
  {$ifdef CPUX86}
    shl ecx, 8
    or ecx, $F3
  {$else .CPUX64}
    shl r8, 8
    or r8, $F3
  {$endif}
  cmp dl, REPZ
  {$ifdef CPUX86}
    lea edx, [ecx-1]
    cmova ecx, edx
  {$else .CPUX64}
    lea rdx, [r8-1]
    cmova r8, rdx
  {$endif}
  @no_rep:

  {$ifdef CPUX86}
    movzx edx, cl
  {$else .CPUX64}
    movzx rdx, r8b
  {$endif}
  shl edx, 16
  {$ifdef CPUX86}
    shr ecx, 8
  {$else .CPUX64}
    shr r8, 8
  {$endif}
  jz AddSmartBinaryCmd
  {$ifdef CPUX86}
    cmp ecx, $ff
    lea edx, [edx + 1]
  {$else .CPUX64}
    cmp r8, $ff
    lea rdx, [rdx + 1]
  {$endif}
  jna AddSmartBinaryCmd
  inc edx
  jmp AddSmartBinaryCmd
end;
{$endif}

// ������� � ����� ����������-����������
// ���� �������� ������ push
// PRE-���������� �������� �� �����
function TOpcodeBlock_Intel.cmd_const_value(const opcode: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
var
  X, value: integer;

  // cmd + ConstToStr()  
  {$ifdef OPCODE_MODES}
const
  HYBRID_MINMAX: array[boolean] of word = ($0502, $0505);

  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
  begin
    buffer.Const32(v_const);
    Result := AddCmdText('%s %s', [cmd, buffer.value.S]);
  end;
  {$endif}
begin

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end else
  if (P.Proc.Mode = omHybrid) and (v_const.Kind <> ckValue) then
  begin
    FillAsText();
    Result.F.HybridSize_MinMax := HYBRID_MINMAX[(v_const.Kind = ckOffsetedCondition)];
    exit;
  end else
  begin
    value := v_const.Value;
  end;
  {$else}
    value := v_const;
  {$endif}

  // ��������
  if (value >= -128) and (value <= 127) then
  begin
    X := ((opcode and $ff) shl 16) or 1;
  end else
  begin
    X := ((opcode and $ff00) shl 8) or 4;
  end;

  // �����
  Result := AddSmartBinaryCmd(X, value);
end;

// ������� � ����� ����������-���������
// �������� inc al, push bx, bswap esp, jmp esi
function TOpcodeBlock_Intel.cmd_reg(const opcode_reg: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  UN_REX_W = (not rex_W);
  UN_REX_W_ONLY = (not (rex_W xor flag_rex));
  MP_JMP_LEAVE = ord(cmLeave) + ((0{��������}+2{jmp reg}) shl 8);
{$ifndef OPCODE_FASTEST}
var
  Parameters: integer;
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}


  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    // cmd �������
    Result := AddCmdText('%s %s', [cmd, reg_intel_names[byte(opcode_reg)]]);

    // jmp
    if (word(opcode_reg shr 8) = $E0FE) then
    begin
      Result.F.ModeParam := MP_JMP_LEAVE + (128{�����} shl 8);
    end;

    exit;
  end;
  {$endif}

  // ��������� �������� � ������, �������������� ������ 0
  Parameters := opcode_reg and intel_opcode_mask;

  // ���������� ��� ����������� �����, ������ � modrm
  Parameters := Parameters or (reg_intel_info[byte(opcode_reg)] and intel_modrm_dest_mask);

  // ������ ������
  if (word(opcode_reg shr 8) = $E0FE) then
  begin
    // jmp reg
    P.Proc.FLastBinaryCmd := NO_CMD;
    Result := AddSmartBinaryCmd(Parameters, 0);
    Result.F.ModeParam := MP_JMP_LEAVE;
    exit;
  end;
  if (opcode_reg and flag_extra <> 0) and (byte(opcode_reg) >= ax) and (byte(opcode_reg) <= edi)  then
  begin
    // ��� "������" ������� ��������������� ������� inc � dec,
    // ������� ��� ��������� x86 � ��������� ax..edi �������� ���� ����

    Parameters := Parameters and $ff4f00ff;
  end else
  if (opcode_reg and $ff00 = 0) then
  begin
    // ��� ������ pop � push ������ ������������ 1 �������� ��������
    // � x64 ��� ��������� rax..rdi �� ������������ rex

    Parameters := Parameters and $ffff00ff;

    case byte(opcode_reg) of
      rax..rdi: Parameters := Parameters and UN_REX_W;
       r8..r15: Parameters := Parameters and UN_REX_W_ONLY;
    end;
  end;

  // ���������
  Result := AddSmartBinaryCmd(Parameters, 0);
end;
{$else}
const
  const_rax = rax;
  const_ax = ax;
  const_edi = edi;
asm
  {$ifdef CPUX86}
     push ebx
  {$else .CPUX64}
     xchg r8, rbx
     xchg rax, rcx
     lea r9, [reg_intel_info]
  {$endif}

  // edx - Parameters, ebx - ��������� �����
  // ecx - ������ ����� ��� "������ �������"

  movzx ebx, dl
  mov ecx, edx
  {$ifdef CPUX86}
  mov ebx, [offset reg_intel_info + ebx*4]
  {$else .CPUX64}
  mov ebx, [r9 + rbx*4]
  {$endif}
  and edx, intel_opcode_mask
  and ebx, intel_modrm_dest_mask
  or edx, ebx

  // ������ ������
  mov ebx, ecx
  shr ebx, 8
  cmp bx, $E0FE
  {$ifdef CPUX86}
  pop ebx
  {$endif}
  jne @non_jmp
    {$ifdef CPUX86}
      mov ecx, [EAX].TOpcodeBlock.P.Proc
      push offset @fill_cmleave
      mov dword ptr [ECX].TOpcodeProc.FLastBinaryCmd, -1 //NO_CMD
    {$else .CPUX64}
      lea rcx, [@fill_cmleave]
      or rbx, -1 //NO_CMD
      push rcx
      mov rcx, [RAX].TOpcodeBlock.P.Proc
      mov [RCX].TOpcodeProc.FLastBinaryCmd, rbx
    {$endif}
    jmp @done
  @non_jmp:
  test ch, ch
  jnz @non_push_pop
  @push_pop:
    sub cl, const_rax
    and edx, $fff00ff
    cmp cl, 15
    ja @done
    cmp cl, 7
    ja @r8_r15
    @rax_edi:
      and edx, UN_REX_W
      jmp @done
    @r8_r15:
      and edx, UN_REX_W_ONLY
      jmp @done
  @non_push_pop:
    test ecx, flag_extra
    jz @done
    sub cl, const_ax
    cmp cl, const_edi - const_ax
    ja @done
    and edx, $ff4f00ff
@done:
  {$ifdef CPUX64}
     xchg rcx, rax
     xchg rbx, r8
  {$endif}
  jmp AddSmartBinaryCmd

@fill_cmleave:
  {$ifdef CPUX86}
    mov [EAX].TOpcodeCmd.F.ModeParam, MP_JMP_LEAVE
  {$else .CPUX64}
    mov [RAX].TOpcodeCmd.F.ModeParam, MP_JMP_LEAVE
  {$endif}
end;
{$endif}

// ���� �������� ����� (��� ������� - �� ���������������)
// �������� jmp [edx], call [ebp+4], fldcw [r12]
function TOpcodeBlock_Intel.cmd_addr_value(const opcode: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  MP_JMP_LEAVE = ord(cmLeave) + ((0{��������}+3{jmp mem}) shl 8);
{$ifndef OPCODE_FAST}
var
  X: integer;
  cmd_jmp: boolean;
  offset, leftover: integer;

  // cmd + AddrToStr()
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
  begin
    buffer.IntelAddress(opcode, addr);
    Result := AddCmdText('%s %s', [cmd, buffer.value.S]);

    if (cmd_jmp) then
    Result.F.ModeParam := MP_JMP_LEAVE + (128{�����} shl 8);
  end;
  {$endif}

begin
  // ����� ����������
  cmd_jmp := (dword(opcode shr 8) = $20FF{jmp mem});
  X := addr.IntelInspect(opcode);

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end else
  if (P.Proc.Mode = omBinary) or {omHybrid and}(addr.offset.Kind = ckValue) then
  {$endif}

  // ��� �������� extra ��������� ������ $9B
  // ���������� ���� ������� ����� ������� � POpcodeCmd, � ����� � ���
  // �� ������������ ����� ����� �� �������� ������ �����
  if (opcode and flag_extra <> 0) then cmd_single($9B{$ifdef OPCODE_MODES},PShortString(nil)^{$endif});

  // ��������, ������� (��� sib)
  leftover := 0;
  offset := addr.offset.Value;
  if (X and $f0 <> 0) then
  begin
    leftover := offset shr 24;
    offset := (offset shl 8) or ((X shr 8) and $ff);
    X := (X and $ffff000f)+1;
  end;

  // �����
  X := (opcode and intel_opcode_mask) or X;
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (addr.offset.Kind <> ckValue) then
  begin
    FillAsText();
    Result.F.HybridSize_MinMax := HybridSize_MinMax(opcode, X, @addr);
  end else
  {$endif}
  begin
    if (cmd_jmp) then P.Proc.FLastBinaryCmd := NO_CMD;
    Result := AddSmartBinaryCmd(X, offset);

    // �������������� ����
    if (byte(X) = 5) then
    begin
      POpcodeCmdData(Result).Bytes[Result.Size-1] := byte(leftover);
    end;

    if (cmd_jmp) then
    Result.F.ModeParam := MP_JMP_LEAVE;
  end;
end;
{$else}
asm
  // �������� �� jmp
  // ���� �� - ����� ��������� �� @fill_cmleave, ����� ������� ��� ����� �������� ��������� � ��
  // � "��������" P.Proc.FLastBinaryCmd
  {$ifdef CPUX86}
    mov [esp-4], edx
    shr edx, 8
    cmp dx, $20FF
    je @jmp_mode
    mov edx, [esp-4]
    jmp @no_jmp_mode

    @jmp_mode:
    mov edx, [EAX].TOpcodeBlock.P.Proc
    mov dword ptr [EDX].TOpcodeProc.FLastBinaryCmd, -1 //NO_CMD
    mov edx, [esp-4]
    push offset @fill_cmleave 
  {$else .CPUX64}
    mov eax, edx
    shr edx, 8
    cmp dx, $20FF
    mov edx, eax
    jne @no_jmp_mode

    or r9, -1 //NO_CMD
    lea r10, [@fill_cmleave]
    mov rax, [RCX].TOpcodeBlock.P.Proc
    push r10
    mov [RAX].TOpcodeProc.FLastBinaryCmd, r9
  {$endif}
  @no_jmp_mode:

  // ��� ����������
  // ������ $9B ���� ����
  {$ifdef CPUX86}
     test edx, flag_extra
     push eax // Self
     push edx // opcode
     jz @no_extra
     push ecx
     mov edx, $009B0000
     call AddSmartBinaryCmd
     pop ecx
     mov edx, [esp]
     mov eax, [esp+4]
  {$else .CPUX64}
     test edx, flag_extra
     push rcx // Self
     push rdx // opcode
     jz @no_extra
     push r8
     mov edx, $009B0000
     call AddSmartBinaryCmd
     pop r8
     mov rdx, [esp]
     mov rcx, [esp+8]
  {$endif}
  @no_extra:

  
  // offset := addr.offset.Value;
  // X := addr.IntelInspect(opcode);
  {$ifdef CPUX86}
     push [ECX + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     xchg eax, ecx
  {$else .CPUX64}
     push dword ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     xchg rcx, r8
  {$endif}
  call TOpcodeAddress.IntelInspect

  // ������ offset �� ��������� ����� � �������
  // opcode ������� �������������� � edx
  // if (X and $f0 <> 0) then {���� ���� sib}
  test al, $f0
  {$ifdef CPUX86}
    pop ecx
    pop edx
  {$else .CPUX64}
    pop r8 {$message '����� r8d?'}
    pop rdx
  {$endif}

  // � �����: Self
  // � ���������: eax - X, edx - opcode, ecx(r8d) - offset
  jz @std_call

  // �������� X, offset
  cmp al, $f4
  jne @change_offset_change
  @stack_correction:
    // � ������ ������ ���� ���������������� ����, ����� �� ����������� �� AddSmartBinaryCmd
    // �������� ��������� ���� (offset shr 24)
    {$ifdef CPUX86}
      push offset @byte_finalizing
      push [esp+4] // self
      mov [esp+8], ecx
    {$else .CPUX64}
      lea r9, [@byte_finalizing]
      push r9
      push [rsp+8] // self
      mov [rsp+16], r8
    {$endif}
  @change_offset_change:
  {$ifdef CPUX86}
    shl ecx, 8
    mov cl, ah
  {$else .CPUX64}
    movzx ecx, ah
    shl r8, 8
    or r8, rcx
  {$endif}
  and eax, $ffff000f
  inc eax

  // AddSmartBinaryCmd((opcode and intel_opcode_mask) or X, offset);
  @std_call:
  and edx, intel_opcode_mask
  or edx, eax
  {$ifdef CPUX86}
    pop eax
  {$else .CPUX64}
    pop rcx
  {$endif}
  jmp AddSmartBinaryCmd

  @fill_cmleave:
  {$ifdef CPUX86}
    mov [EAX].TOpcodeCmd.F.ModeParam, MP_JMP_LEAVE
  {$else .CPUX64}
    mov [RAX].TOpcodeCmd.F.ModeParam, MP_JMP_LEAVE
  {$endif}
  ret

  // Result.Data.Bytes[Result.Size-1] := byte(leftover);
  @byte_finalizing:
   {$ifdef CPUX86}
      pop ecx
      movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
      shr ecx, 24
      mov [eax + TOpcodeCmdData.bytes + edx - 1], cl
   {$else .CPUX64}
      pop rcx
      movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
      shr ecx, 24
      mov [rax + TOpcodeCmdData.bytes + rdx - 1], cl
   {$endif}
end;
{$endif}

// ���� �������� ����� (��� ������� - �� ���������������)
// �������� jmp [edx], call [ebp+4], fldcw [r12]
procedure TOpcodeBlock_Intel.PRE_cmd_addr(const opcode: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (addr.offset.Kind = ckValue) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, opcode and flag_x64 <> 0, P.Proc);
    {$endif}
    cmd_addr_value(opcode, addr{$ifdef OPCODE_MODES},cmd{$endif});
  end else
  begin
    diffcmd_addr(opcode, addr, cmd_addr_value{$ifdef OPCODE_MODES},cmd{$endif});

    // ������ ������ ��� jmp [pointer]
    if (word(opcode shr 8) = $20FF) and (addr.offset.Kind = ckPValue) then
    Inc(Self.CmdList.F.Param, 2);
  end;  
end;

// ��� ���������: ptr, addr
// �������� dec byte ptr [ecx*4] | push dword ptr [esp]
function TOpcodeBlock_Intel.cmd_ptr_addr_value(const base_opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
{$ifndef OPCODE_FAST}
var
  X, Y: integer;
  offset, leftover: integer;
  opcode_ptr: integer;

  // cmd + PtrToStr(ptr) + AddrToStr()
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
    str_ptr: PShortString;
  begin
    buffer.IntelAddress(base_opcode_ptr, addr);

    if (false{!}) then str_ptr := PShortString(@STR_NULL)
    else str_ptr := buffer.SizePtr(base_opcode_ptr, 1);

    Result := AddCmdText('%s %s%s', [cmd, str_ptr^, buffer.value.S]);
  end;
  {$endif}
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  opcode_ptr := base_opcode_ptr;
  // ������ ������: push/pop ��� x64 � qword ptr
  if (opcode_ptr and flag_extra <> 0) and (size_ptr(opcode_ptr) = qword_ptr) then System.Dec(opcode_ptr);

  // ����� ����������
  X := ptr_intel_info[size_ptr(opcode_ptr)];
  Y := addr.IntelInspect(opcode_ptr);

  // ��������, ������� (��� sib)
  leftover := 0;
  offset := addr.offset.Value;
  if (Y and $f0 <> 0) then
  begin
    leftover := offset shr 24;
    offset := (offset shl 8) or ((Y shr 8) and $ff);
    Y := (Y and $ffff000f)+1;
  end;

  // ���������
  X := (opcode_ptr and intel_opcode_mask) or (X and integer($ffffff00)) or Y;

  // �����
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (addr.offset.Kind <> ckValue) then
  begin
    FillAsText();
    Result.F.HybridSize_MinMax := HybridSize_MinMax(opcode_ptr, X, @addr);
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, offset);

    // �������������� ����
    if (byte(X) = 5) then
    begin
      POpcodeCmdData(Result).Bytes[Result.Size-1] := byte(leftover);
    end;
  end;  
end;
{$else}
const
  qword_push_pop_mask = flag_extra or $ff;
  qword_push_pop_id = flag_extra or ord(qword_ptr);
asm
  // ������ (����� ������� TOpcodeAddress.IntelInspect)
  {$ifdef CPUX86}
     push eax // self
     push [ECX + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     push edx // opcode_ptr     
     mov eax, ecx // addr as Self
  {$else .CPUX64}
     mov eax, [r8 + TOpcodeAddress_offset + TOpcodeConst.F.Value]
     push rcx // self
     push rax // offset
     push rdx // opcode_reg
     mov rcx, r8 // addr as Self
  {$endif}
  call TOpcodeAddress.IntelInspect

  // ������������ X
  // if (opcode_ptr and flag_extra <> 0) and (size_ptr(opcode_ptr) = qword_ptr) then System.Dec(opcode_ptr);
  // X := (ptr_intel_info[size_ptr(opcode_ptr)] and integer($ffffff00)) or (opcode_reg and intel_opcode_mask);
  {$ifdef CPUX86}
  pop edx
  {$else .CPUX64}
  pop rdx
  {$endif}
  mov ecx, edx
  and edx, qword_push_pop_mask
  and ecx, intel_opcode_mask
  cmp edx, qword_push_pop_id
  jne @after_extra
  dec edx
  @after_extra:
  movzx edx, dl
  {$ifdef CPUX86}
     mov edx, [offset ptr_intel_info + edx*4]
  {$else .CPUX64}
     lea r11, [ptr_intel_info]
     mov edx, [r11 + rdx*4]
  {$endif}
  and edx, $ffffff00
  or edx, ecx

  // ��������, ������� (��� sib)
  test al, $f0
  {$ifdef CPUX86}
  pop ecx
  {$else .CPUX64}
  pop rcx
  {$endif}
  jz @sib_done
    cmp al, $f4
    jne @sib_std
    {$ifdef CPUX86}
      push offset @finalize_byte
      push [esp+4]
      mov [esp+8], ecx
    {$else .CPUX64}
      lea r11, [@finalize_byte]
      push r11
      push [rsp+8]
      mov [rsp+16], rcx
    {$endif}
    @sib_std:
    shl ecx, 8
    mov cl, ah
    and eax, $ffff000f
    inc eax
  @sib_done:
  or edx, eax

  // �����
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     mov r8, rcx
     pop rcx
  {$endif}
  jmp AddSmartBinaryCmd

  // ��������� (�����������) ����
@finalize_byte:
  {$ifdef CPUX86}
     pop ecx
     movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
     shr ecx, 24
     mov [eax + TOpcodeCmdData.bytes + edx - 1], cl
  {$else .CPUX64}
     pop rcx
     movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
     shr ecx, 24
     mov [rax + TOpcodeCmdData.bytes + rdx - 1], cl
  {$endif}
end;
{$endif}

// ��� ���������: ptr, addr
// �������� dec byte ptr [ecx*4] | push dword ptr [esp]
procedure TOpcodeBlock_Intel.PRE_cmd_ptr_addr(const opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (addr.offset.Kind = ckValue) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, opcode_ptr and flag_x64 <> 0, P.Proc);
    {$endif}
    cmd_ptr_addr_value(opcode_ptr, addr{$ifdef OPCODE_MODES},cmd{$endif});
  end else
  diffcmd_addr(opcode_ptr, addr, cmd_ptr_addr_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

// ��� ���������: reg, reg
// �������� mov esi, ebx | add bh, cl | test ax, dx
function TOpcodeBlock_Intel.cmd_reg_reg(const base_opcode_reg, base_v_reg: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  src_ax_eax_rax_mask = intel_modrm_src_index or intel_nonbyte_mask;
  dest_ax_eax_rax_mask = intel_modrm_dest_index or intel_nonbyte_mask;
{$ifndef OPCODE_FASTEST}
var
  X, Y: integer;
  opcode_reg, v_reg: integer;
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // cmd �������, �������
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    Result := AddCmdText('%s %s, %s', [cmd, reg_intel_names[byte(base_opcode_reg)], reg_intel_names[byte(base_v_reg)]]);
    exit;
  end;
  {$endif}

  opcode_reg := base_opcode_reg;
  v_reg := base_v_reg;

  // ��� imul � add ���� �������� ������� ���������
  if (opcode_reg and flag_extra <> 0) then
  begin
    X := opcode_reg;
    opcode_reg := (opcode_reg and integer($ffffff00)) or (v_reg and $ff);
    v_reg := X;
  end;

  // ������� ����������
  X := reg_intel_info[byte(opcode_reg)];
  Y := reg_intel_info[byte(v_reg)];

  // ������ ������ ��� xchg ax/eax/rax
  if (byte(opcode_reg shr 8) = $86) then
  begin
    if (X and src_ax_eax_rax_mask = intel_nonbyte_mask) then
    begin
      X := Y xor intel_nonbyte_mask;
      opcode_reg := $00900000;
      Y := 0;
    end else
    if (Y and dest_ax_eax_rax_mask = intel_nonbyte_mask) then
    begin
      X := X xor intel_nonbyte_mask;
      opcode_reg := $00900000;
      Y := 0;
    end;
  end;

  // ��������� (������ ��������)
  Result := AddSmartBinaryCmd((opcode_reg and intel_opcode_mask) or
                              (X and intel_modrm_dest_mask) or (Y and intel_modrm_src_mask), 0);
end;
{$else}
asm
  // ����������
  {$ifdef CPUX86}
     push eax
  {$else .CPUX64}
     xchg rcx, r8 // Self := r8, v_reg := rcx
  {$endif}

  // � ������ imul/add
  test edx, flag_extra
  jz @after_extra
    xchg dl, cl
  @after_extra:

  // �������������� X(eax)/Y(ecx)
  mov eax, edx
  and ecx, $ff
  and eax, $ff
  {$ifdef CPUX86}
     mov ecx, [offset reg_intel_info + ecx*4]
     mov eax, [offset reg_intel_info + eax*4]
  {$else .CPUX64}
     lea r9, [reg_intel_info]
     mov ecx, [r9 + rcx*4]
     mov eax, [r9 + rax*4]
  {$endif}

  // ������ ������ ��� xchg ax/eax/rax
  cmp dh, $86
  jne @calculate
  {$ifdef CPUX86}
     push ebx
  {$else .CPUX64}
     xchg rbx, r9
  {$endif}
     @param_src_test:
        mov ebx, eax
        and ebx, src_ax_eax_rax_mask
        cmp ebx, intel_nonbyte_mask
        jne @param_dest_test
        mov eax, ecx
     jmp @xchg_params
     @param_dest_test:
        mov ebx, ecx
        and ebx, dest_ax_eax_rax_mask
        cmp ebx, intel_nonbyte_mask
        jne @after_xchg
  @xchg_params:
     xor eax, intel_nonbyte_mask
     mov edx, $00900000
     xor ecx, ecx
  @after_xchg:
  {$ifdef CPUX86}
     pop ebx
  {$else .CPUX64}
     xchg rbx, r9
  {$endif}

  // ������� ���������� (edx)
  @calculate:
  and edx, intel_opcode_mask
  and eax, intel_modrm_dest_mask
  and ecx, intel_modrm_src_mask
  or edx, eax
  or edx, ecx

  // ��������
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     xchg rcx, r8
  {$endif}

  // ������
  jmp AddSmartBinaryCmd
end;
{$endif}


const
  optimize_test_byte: array[al..dil] of reg_x64 = (al,cl,dl,bl,ah,ch,dh,bh,al,cl,dl,
  bl,sp,bp,si,di,al,cl,dl,bl,sp,bp,si,di,r8b,r9b,r10b,r11b,r12b,r13b,r14b,r15b,r8b,
  r9b,r10b,r11b,r12b,r13b,r14b,r15b,al,cl,dl,bl,spl,bpl,sil,dil,r8b,r9b,r10b,r11b,
  r12b,r13b,r14b,r15b,r8b,r9b,r10b,r11b,r12b,r13b,r14b,r15b,spl,bpl,sil,dil);

  optimize_test_word: array[al..dil] of reg_x64 = (al,cl,dl,bl,ah,ch,dh,bh,ax,cx,
  dx,bx,sp,bp,si,di,ax,cx,dx,bx,sp,bp,si,di,r8w,r9w,r10w,r11w,r12w,r13w,r14w,r15w,
  r8w,r9w,r10w,r11w,r12w,r13w,r14w,r15w,ax,cx,dx,bx,sp,bp,si,di,r8w,r9w,r10w,r11w,
  r12w,r13w,r14w,r15w,r8b,r9b,r10b,r11b,r12b,r13b,r14b,r15b,spl,bpl,sil,dil);


// ��� ���������: reg, const_32
// �������� cmp edx, 15 | and r8, $ff | test ebx, $0100
function TOpcodeBlock_Intel.cmd_reg_const_value(const base_opcode_reg: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  dif_spl_sp = spl-sp;
  dif_rax_eax = rax-eax;
  dif_r8_r8d = r8-r8d;
{$ifndef OPCODE_FAST}
var
  REG: integer;
  X: integer;
  imm_size: integer;
  value: integer;
  opcode_reg: integer;

  // cmd �������, ���������(%s ��� %d)
  {$ifdef OPCODE_MODES}

  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
    buf_const: const_32;
  begin
    if (v_const.Kind = ckValue) then
    begin
      buf_const.Kind := ckValue;
      buf_const.Value := value;
    end else
    begin
      buf_const := v_const;
    end;

    buffer.Const32(buf_const);
    Result := AddCmdText('%s %s, %s', [cmd, reg_intel_names[REG], buffer.value.S]);
  end;
  {$endif}
begin
  REG := base_opcode_reg and $ff;
  opcode_reg := base_opcode_reg;

  // ����������� ��� test, and, mov
  {$ifdef OPCODE_MODES}
    value := v_const.Value;
    if (v_const.Kind <> ckValue) then value := low(integer);
  {$else}
    value := v_const;
  {$endif}
  if (value >= 0) then
  case byte(opcode_reg shr 8) of
    $A8: begin
           // test
           if (value <> 0) and (value and $ffff00ff = 0) and (optimize_test_byte[REG] in [al..bl]) then
           begin
             REG := optimize_test_byte[REG] + 4;
             value := value shr 8;
           end else
           case value of
              0..$ff: begin
                        REG := optimize_test_byte[REG];
                        if (opcode_reg and flag_x64 <> 0) and (byte(REG) in [sp..di]) then REG := REG + dif_spl_sp;
                      end;
        $0100..$ffff: begin
                        REG := optimize_test_word[REG];
                      end;
           else
             if (REG in [rax..rdi]) then REG := REG - dif_rax_eax;
           end;
         end;
    $24: begin
           // and
           if (REG in [rax..rdi]) then REG := REG - dif_rax_eax;
         end;
    $00: begin
           // mov
           if (REG in [r8..r15]) then REG := REG - dif_r8_r8d
           else
           if (REG in [rax..rdi]) then REG := REG - dif_rax_eax;
         end;
  end;
  opcode_reg := (opcode_reg and integer($ffffff00)) or REG;


  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  // ����������
  X := reg_intel_info[byte(opcode_reg)];

  // ������� ������ � ������� ��������
  if (opcode_reg and $ff00 = 0) then
  begin
    // ������ ������ ��� ������� mov
    imm_size := byte(X);
    opcode_reg := opcode_reg or ((X and intel_nonbyte_mask) shl 11);
    X := X and (not intel_nonbyte_mask);

    if (imm_size = 8) then
    begin
      X := (opcode_reg and intel_opcode_mask) or (X and intel_modrm_dest_mask) or imm_size;
      {$ifdef OPCODE_MODES}
      if (P.Proc.Mode = omHybrid) and (v_const.Kind <> ckValue) then
      begin
        FillAsText();
        // ������ ��������� ������ ��������
        Result.F.HybridSize_MinMax := HybridSize_MinMax(base_opcode_reg, X, nil);
      end else
      {$endif}
      begin
        Result := AddSmartBinaryCmd(X, value);
        pinteger(@POpcodeCmdData(Result).Bytes[Result.Size-sizeof(integer)])^ := -1;
      end;  
      exit;
    end;
  end else
  begin
    // ������ ��������
    if (byte(X) = 1) then imm_size := 1
    else
    begin
      imm_size := 4;
      if (opcode_reg and flag_extra = 0) and (value >= -128) and (value <= 127) then
      begin
        imm_size := 1;
        X := X or $0200;
      end else
      if (byte(X) = 2) then
      begin
        imm_size := 2;
      end;
    end;

    // �����
    if (X and intel_modrm_dest_index = 0) and (X and $0200 = 0) then
    begin
      // ������ ������ ��� al/ax/eax/rax
      opcode_reg := opcode_reg or (X and intel_nonbyte_mask);
      opcode_reg := (opcode_reg and integer($ff000000)) or ((opcode_reg and $0000ff00) shl 8);
      X := X and $ffff00ff;
    end else
    begin
      // ����������� ������
      if (opcode_reg and flag_extra <> 0{test}) then opcode_reg := (opcode_reg and $ffff00ff) or $F600
      else opcode_reg := (opcode_reg and $ffff00ff) or $8000;
    end;
 end;

  // ���������
  X := (opcode_reg and intel_opcode_mask) or (X and intel_modrm_dest_mask) or imm_size;
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (v_const.Kind <> ckValue) then
  begin
    FillAsText();

    // ������ ������������� Min (���������)
    value := 0;
    if (v_const.Kind = ckCondition) and (base_opcode_reg and $ff00 <> 0{�� mov}) and
       (opcode_reg and flag_extra = 0{�� test}) then
    begin
      case byte(reg_intel_info[byte(base_opcode_reg)]) of
        1: {imm_size = 1 byte only};
        2: begin
             // imm_size = 1 || 2 bytes
             if (REG <> ax{� ������ ax ������ �� 1 ���� �� ����� �� ��� ����� ��������}) then value := 1;
           end;
      else
        // imm_size = 1 || 4 bytes
        value := 3;
      end;
    end;

    // MinMax � ������ ������ ������������� Min
    Result.F.HybridSize_MinMax := HybridSize_MinMax(base_opcode_reg, X, nil)-value;
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, value);
  end;  
end;
{$else}
const
  reg_rax = rax;
  reg_sp = sp;
  X_IMM_MASK = intel_modrm_dest_mask or $ff;
asm
  // ����������
  {$ifdef CPUX86}
     push eax
  {$else .CPUX64}
     xchg rcx, r8 // Self := r8, v_reg := rcx
  {$endif}

  // opcode_reg - edx
  // X � imm_size - eax
  // value - ecx

  // ����������� ��� test, and, mov
  test ecx, ecx
  jl @after_optimize
  movzx eax, dl
  cmp dh, $A8
  je @opt_test
  cmp dh, $24
  je @opt_and  
  test dh, dh
  jnz @after_optimize
  @opt_mov:
    sub eax, reg_rax
    cmp eax, 15
    ja @after_optimize
    cmp eax, 7
    jbe @rax_rdi_to_eax
    sub edx, dif_r8_r8d
    jmp @after_optimize
  @opt_test:
  {$ifdef CPUX86}
     movzx eax, byte ptr [optimize_test_byte + eax]
  {$else .CPUX64}
     lea r11, [optimize_test_byte]
     movzx eax, byte ptr [r11 + rax]
  {$endif}
     test ecx, ecx
     jz @test_case
     test ecx, $ffff00ff
     jnz @test_case
     cmp al, 3{bl}
     ja @test_case
       add eax, 4
       shr ecx, 8
       jmp @reg_correction
     @test_case:
       cmp ecx, $ffff
       ja @test_4
       cmp ecx, $ff
       ja @test_2
     @test_1:
       test edx, flag_x64
       jz @reg_correction
       sub eax, reg_sp
       cmp eax, 3
       jbe @sp_di_to_spl
       add eax, reg_sp
       jmp @reg_correction
       @sp_di_to_spl:
       add eax, reg_sp + dif_spl_sp
       jmp @reg_correction
     @test_2:
       movzx eax, dl
       {$ifdef CPUX86}
          movzx eax, byte ptr [optimize_test_word + eax]
       {$else .CPUX64}
          lea r11, [optimize_test_word]
          movzx eax, byte ptr [r11 + rax]
       {$endif}
       jmp @reg_correction
     @test_4:
       movzx eax, dl
       sub eax, reg_rax
       cmp eax, 7
       ja @after_optimize
       jmp @rax_rdi_to_eax
  @reg_correction:
    and edx, $ffffff00
    or edx, eax
    jmp @after_optimize
  @opt_and:
    sub eax, reg_rax
    cmp eax, 7
    ja @after_optimize
  @rax_rdi_to_eax:
    sub edx, dif_rax_eax
  @after_optimize:

  // ����������
  movzx eax, dl
  {$ifdef CPUX86}
     mov eax, dword ptr [reg_intel_info + eax*4]
  {$else .CPUX64}
     lea r11, [reg_intel_info]
     mov eax, [r11 + rax*4]
  {$endif}

  // ������� ������ � ������� ��������
  test dh, dh
  jnz @opcode_standard
    // ������ ������ ��� mov
    test eax, intel_nonbyte_mask
    jz @opcode_done
    and eax, not intel_nonbyte_mask
    or edx, $080000

    // ���� ������ ��������� ������ ���� 8 ����
    cmp al, 8
    jne @opcode_done
    {$ifdef CPUX86}
       push [esp] // copy eax
       mov [esp+4], offset  @mov_8_finalize
    {$else .CPUX64}
       lea r11, [@mov_8_finalize]
       push r11
    {$endif}
    jmp @opcode_done
    @mov_8_finalize:
      {$ifdef CPUX86}
         movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
         mov dword ptr [eax + TOpcodeCmdData.bytes + edx - 4], $ffffffff
      {$else .CPUX64}
         movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
         mov dword ptr [rax + TOpcodeCmdData.bytes + rdx - 4], $ffffffff
      {$endif}
    ret
  @opcode_standard:
    // ����������� ������ (�� mov)
    @opcode_size:
      cmp al, 1
      je @opcode_choose_mode
        test edx, flag_extra
        lea ecx, [ecx+128]
        jnz @opcode_retrieve_value
        cmp ecx, 255
        ja @opcode_retrieve_value
        and eax, $ffffff00
        add ecx, -128
        or eax, $0201
        jmp @opcode_choose_mode
      @opcode_retrieve_value:
        add ecx, -128
      @opcode_size_2_4:
        cmp al, 2
        je @opcode_choose_mode
        and eax, $ffffff00
        or eax, 4
    @opcode_choose_mode:
      test eax, intel_modrm_dest_index or $0200
      jnz @opcode_not_eax
    @opcode_eax:
      {$ifdef CPUX86}
         push eax
      {$else .CPUX64}
         mov r9, rax
      {$endif}
         and eax, intel_nonbyte_mask
         or edx, eax
         mov eax, edx
         and edx, $0000ff00
         and eax, $ff000000
         shl edx, 8
         or edx, eax
      {$ifdef CPUX86}
         pop eax
      {$else .CPUX64}
         mov rax, r9
      {$endif}
      and eax, $ffff00ff
    jmp @opcode_done
    @opcode_not_eax:
      and edx, $fff00ff
      test edx, flag_extra
      jz @opcode_cmd_80
        or edx, $F600
        jmp @opcode_done
      @opcode_cmd_80:
        or edx, $8000
  @opcode_done:

  // ���������
  and edx, intel_opcode_mask
  and eax, X_IMM_MASK
  or edx, eax    

  // ��������
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     xchg rcx, r8
  {$endif}

  // ������
  jmp AddSmartBinaryCmd
end;
{$endif}


// ��� ���������: reg, const_32
// �������� cmp edx, 15 | and r8, $ff | test ebx, $0100
procedure TOpcodeBlock_Intel.PRE_cmd_reg_const(const opcode_reg: integer; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (v_const.Kind = ckValue) then
  begin
    // �������� ��� ckValue ������ �� �����
    cmd_reg_const_value(opcode_reg, {$ifdef OPCODE_MODES}v_const,cmd{$else}v_const.Value{$endif});
  end else
  diffcmd_const32(opcode_reg, v_const, cmd_reg_const_value{$ifdef OPCODE_MODES},cmd{$endif});
end;


// ��� ���������: reg, const_32 | reg, cl
// ������ ��� ��������� ������ rcl,rcr,rol,ror,sal,sar,shl,shr
function TOpcodeBlock_Intel.shift_reg_const_value(const opcode_reg: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
{$ifndef OPCODE_FAST}
var
  X: integer;
  value: integer;

  // cmd �������, cl
  // ���
  // cmd �������, %d | %s  
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
    const_value: PShortString;
  begin
    if (opcode_reg and flag_extra <> 0{cl}) then const_value := PShortString(@STR_CL)
    else const_value := buffer.Const32(v_const);

    Result := AddCmdText('%s %s, %s', [cmd, reg_intel_names[byte(opcode_reg)], const_value^]);
  end;
  {$endif}

begin
  {$ifdef OPCODE_MODES}
    value := v_const.Value;
    if (v_const.Kind <> ckValue) then value := low(integer);
  {$else}
    value := v_const;
  {$endif}

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  // ���������� �� ��������
  X := reg_intel_info[byte(opcode_reg)];

  // ���������
  X := (opcode_reg and intel_opcode_mask) or (X and intel_modrm_dest_mask);

  // ������ ���������, ��������� (��� 1)
  if (opcode_reg and flag_extra = 0{imm8}) then
  begin
    if (value = 1) then X := X + $1000 {C0-->D0}
    else X := X + 1{value_size = 1};
  end;

  // �����
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (opcode_reg and flag_extra = 0{���������}) and (v_const.Kind <> ckValue) then
  begin
    FillAsText();
    Result.F.HybridSize_MinMax := HybridSize_MinMax(opcode_reg, X, nil) -
                                  ord((opcode_reg and flag_extra = 0{imm8}) and (v_const.Kind = ckCondition));
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, value);
  end;  
end;
{$else}
const
  value_1_correction = $1000-1;
asm
  {$ifdef CPUX86}
     push eax
  {$endif}

  // ���������� �� ��������
  movzx eax, dl
  {$ifdef CPUX86}
    mov eax, [offset reg_intel_info + eax*4]
  {$else .CPUX64}
    lea r11, [reg_intel_info]
    mov eax, [r11 + rax*4]
  {$endif}
  and eax, intel_modrm_dest_mask

  // ������ ���������, ��������� (��� 1)
  test edx, flag_extra
  jnz @imm_done
    {$ifdef CPUX86}
      cmp ecx, 1
      lea eax, [eax+1]
    {$else .CPUX64}
      cmp r8d, 1
      lea rax, [rax+1]
    {$endif}
    jne @imm_done
    add eax, value_1_correction
  @imm_done:   

  // �����
  and edx, intel_opcode_mask
  or edx, eax
  {$ifdef CPUX86}
     pop eax
  {$endif}
  jmp AddSmartBinaryCmd
end;
{$endif}

// ��� ���������: reg, const_32 | reg, cl
// ������ ��� ��������� ������ rcl,rcr,rol,ror,sal,sar,shl,shr
procedure TOpcodeBlock_Intel.PRE_shift_reg_const(const opcode_reg: integer; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (v_const.Kind = ckValue) then
  begin
    // �������� ��� ckValue ������ �� �����
    shift_reg_const_value(opcode_reg, {$ifdef OPCODE_MODES}v_const,cmd{$else}v_const.Value{$endif});
  end else
  diffcmd_const32(opcode_reg, v_const, shift_reg_const_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

// ��� ���������: reg, addr ��� addr, reg. ����������� ������������ �� ������
// �������� add esi, [ebp-$14] ��� xchg [offset variable + ecx*2 + 6], dx
function  TOpcodeBlock_Intel.cmd_reg_addr_value(const opcode_reg: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
{$ifndef OPCODE_FAST}
var
  X, Y: integer;
  offset, leftover: integer;

  // cmd �������, �����
  // ���
  // cmd �����, �������  
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
    reg: pansichar;
  begin
    buffer.IntelAddress(opcode_reg, addr);
    reg := reg_intel_names[byte(opcode_reg)];

    if (opcode_reg and $0200 <> 0) then
       Result := AddCmdText('%s %s, %s', [cmd, reg, buffer.value.S])
    else
       Result := AddCmdText('%s %s, %s', [cmd, buffer.value.S, reg]);
  end;
  {$endif}
begin

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  // ����� ����������
  X := reg_intel_info[byte(opcode_reg)];
  Y := addr.IntelInspect(opcode_reg);

  // ��������, ������� (��� sib)
  leftover := 0;
  offset := addr.offset.Value;
  if (Y and $f0 <> 0) then
  begin
    leftover := offset shr 24;
    offset := (offset shl 8) or ((Y shr 8) and $ff);
    Y := (Y and $ffff000f)+1;
  end;

  // ���������
  X := (opcode_reg and intel_opcode_mask) or (X and intel_modrm_src_mask) or Y;

  // �����
  if (X and $ff00 = 0) then
  begin
    // ������ ������ (add m8, r8)
    X := X or $0100;
    {$ifdef OPCODE_MODES}
    if (P.Proc.Mode = omHybrid) and (addr.offset.Kind <> ckValue) then
    begin
      FillAsText();
      Result.F.HybridSize_MinMax := HybridSize_MinMax(opcode_reg, X, @addr);
      exit;
    end else
    {$endif}
    begin
      Result := AddSmartBinaryCmd(X, offset);
      POpcodeCmdData(Result).Bytes[Result.Size-byte(X)-2] := 0;
    end;
  end else
  begin
    {$ifdef OPCODE_MODES}
    if (P.Proc.Mode = omHybrid) and (addr.offset.Kind <> ckValue) then
    begin
      FillAsText();
      Result.F.HybridSize_MinMax := HybridSize_MinMax(opcode_reg, X, @addr);
      exit;
    end else
    {$endif}
    begin
      Result := AddSmartBinaryCmd(X, offset);
    end;  
  end;

  // �������������� ����
  if (byte(X) = 5) then
  begin
    POpcodeCmdData(Result).Bytes[Result.Size-1] := byte(leftover);
  end;
end;
{$else}
asm
  // ������ (����� ������� TOpcodeAddress.IntelInspect)
  {$ifdef CPUX86}
     push ebx // �����
     push eax // self
     push [ECX + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     push edx // opcode_reg
     mov eax, ecx // addr as Self
  {$else .CPUX64}
     push rbx // �����
     mov eax, [r8 + TOpcodeAddress_offset + TOpcodeConst.F.Value]
     push rcx // self
     push rax // offset
     push rdx // opcode_reg
     mov rcx, r8 // addr as Self
  {$endif}
  call TOpcodeAddress.IntelInspect
  // ������� ����������
  // Y - eax, edx - X, opcode_reg - ecx, ebx - ����� (leftover)
  {$ifdef CPUX86}
     pop ecx // opcode_reg
  {$else .CPUX64}
     pop rcx // opcode_reg
  {$endif}

  // X := reg_intel_info[opcode_reg and $ff];
  // X := (opcode_reg and intel_opcode_mask) or (X and intel_modrm_src_mask){ or Y};
  movzx edx, cl
  xor ebx, ebx
  {$ifdef CPUX86}
     mov edx, [offset reg_intel_info + edx*4]
  {$else .CPUX64}
     lea r11, [reg_intel_info]
     mov edx, [r11 + rdx*4]
  {$endif}
  and ecx, intel_opcode_mask
  and edx, intel_modrm_src_mask
  or edx, ecx

  // ���������� offset � ecx/
  // if (Y and $f0 <> 0{������������ sib}) then ���������������� leftover, offset, Y
  test al, $f0
  {$ifdef CPUX86}
    pop ecx
  {$else}
    pop r8
  {$endif}
  jz @add_Y
    {$ifdef CPUX64}
       mov rcx, r8
    {$endif}
       mov ebx, ecx
       shl ecx, 8
       shr ebx, 24
       mov cl, ah
    and eax, $ffff000f
    {$ifdef CPUX64}
       mov r8, rcx
    {$endif}
    inc eax
@add_Y:
  or edx, eax

  // ���������� �������� self
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     pop rcx
  {$endif}

  // ������ �������� ������
  test dh, dh
  jnz @std_look_adv_size
  @mode_add_m8r8:
    mov bh, dl
    {$ifdef CPUX86}
       push offset @finalize_add_m8r8
    {$else .CPUX64}
       lea r11, [@finalize_add_m8r8]
       push r11
    {$endif}
    or edx, $0100
    jmp AddSmartBinaryCmd
  @std_look_adv_size:
    cmp dl, 5
    jne @std_call_proc
    {$ifdef CPUX86}
       push offset @finalize_leftover
    {$else .CPUX64}
       lea r11, [@finalize_leftover]
       push r11
    {$endif}
    jmp AddSmartBinaryCmd
  @std_call_proc:
  // ���������� ebx/rbx
  {$ifdef CPUX86}
     pop ebx
  {$else .CPUX64}
     pop rbx
  {$endif}
  jmp AddSmartBinaryCmd
@finalize_add_m8r8:
  movzx ecx, bh
  {$ifdef CPUX86}
     movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
     sub edx, ecx
     mov byte ptr [eax + TOpcodeCmdData.bytes + edx - 2], 0
  {$else .CPUX64}
     movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
     sub edx, ecx
     mov byte ptr [rax + TOpcodeCmdData.bytes + rdx - 2], 0
  {$endif}

  add edx, ecx
  cmp ecx, 5
  je @fill_leftover
  {$ifdef CPUX86}
     pop ebx
  {$else .CPUX64}
     pop rbx
  {$endif}
  ret
@finalize_leftover:
   {$ifdef CPUX86}
      movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
   {$else .CPUX64}
      movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
   {$endif}
@fill_leftover:
   {$ifdef CPUX86}
      mov [eax + TOpcodeCmdData.bytes + edx - 1], bl
      pop ebx
   {$else .CPUX64}
      mov [rax + TOpcodeCmdData.bytes + rdx - 1], bl
      pop rbx
   {$endif}
end;
{$endif}

// ��� ���������: reg, addr ��� addr, reg. ����������� ������������ �� ������
// �������� add esi, [ebp-$14] ��� xchg [offset variable + ecx*2 + 6], dx
procedure TOpcodeBlock_Intel.PRE_cmd_reg_addr(const opcode_reg: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (addr.offset.Kind = ckValue) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, opcode_reg and flag_x64 <> 0, P.Proc);
    {$endif}
    cmd_reg_addr_value(opcode_reg, addr{$ifdef OPCODE_MODES},cmd{$endif});
  end else
  diffcmd_addr(opcode_reg, addr, cmd_reg_addr_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

// ��� ���������: ptr, addr, const_32
// �������� cmp byte ptr [eax+ebx*2-12], 0 ��� sbb qword ptr [r12 + rdx], $17
// ��������� ��� �� ������: rcl,rcr,rol,ror,sal,sar,shl,shr
function TOpcodeBlock_Intel.cmd_ptr_addr_const_value(const opcode_ptr: integer; const addr: TOpcodeAddress; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
{$ifndef OPCODE_FAST}
var
  X, Y: integer;
  offset, left_over_info: integer;
  Dest: pinteger;
  value: integer;

  // cmd + PtrToStr() + ptr �����, %d | %s  
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
    const_value: PShortString;
    str_ptr: PShortString;
  begin
    buffer.IntelAddress(opcode_ptr, addr);

    if (opcode_ptr and flag_extra <> 0) and (byte(opcode_ptr shr 8) <> $D2) then const_value := PShortString(@STR_CL)
    else const_value := buffer.Const32(v_const, 1);

    if (false{!}) then str_ptr := PShortString(@STR_NULL)
    else str_ptr := buffer.SizePtr(opcode_ptr, 1 + ord(pointer(const_value) <> @STR_CL));

    // cmd ptr addr, cl/const
    Result := AddCmdText('%s %s%s, %s', [cmd, str_ptr^, buffer.value.S, const_value^]);
  end;
  {$endif}
begin
  {$ifdef OPCODE_MODES}
    value := v_const.Value;
    if (v_const.Kind <> ckValue) then value := low(integer);
  {$else}
    value := v_const;
  {$endif}

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  X := ptr_intel_info[size_ptr(opcode_ptr)];
  Y := addr.IntelInspect(opcode_ptr);

  // ������ ��������� � �������������� �������� �������
  if (opcode_ptr and flag_extra <> 0) then
  begin
    // ������: rcl,rcr,rol,ror,sal,sar,shl,shr
    X := X and $ffffff00;
    if (byte(opcode_ptr shr 8) <> $D2{cmd addr, cl}) then
    begin
      if (value = 1) then X := X + $1000 {C0-->D0}
      else X := X + 1{value_size = 1};
    end;
  end else
  begin
    // ����������� ������: adc,add,and,cmp,mov,or,sbb,sub,test,xor
    if (byte(X) <> 1) then
    begin
      if (byte(opcode_ptr shr 8) = $80{�� mov/test}) and (value >= -128) and (value <= 127) then
      begin
        X := (X and $ffffff00) or $0201;
      end else
      if (byte(X) <> 2) then
      begin
        X := (X and $ffffff00) or 4;
      end;
    end;
  end;

  // offset, sib, ������ value+sib
  offset := addr.offset.Value;
  left_over_info := (X and $ff) shl 16;
  X := X + (Y and $0f{������ �ffset});
  if (Y and $f0 <> 0{sib}) then
  begin
    if (Y and $0f = 4) then
    begin
      left_over_info := left_over_info + (offset shr 24) + $010100
    end;

    offset := (offset shl 8) or ((Y shr 8) and $ff);
    X := X + 1;
  end;

  // ����� � �������� � ������
  X := (opcode_ptr and intel_opcode_mask) or X or (Y and integer($ffff0000));
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and ((addr.offset.Kind <> ckValue) or (v_const.Kind <> ckValue)) then
  begin
    FillAsText();

    // ������ ������������� Min (���������)
    value := 0;
    if (v_const.Kind = ckCondition) then
    begin
      if (opcode_ptr and flag_extra <> 0) then
      begin
        // ��� ���������
        if (byte(opcode_ptr shr 8) <> $D2{imm8}) then value := 1;
      end else
      if (byte(opcode_ptr shr 8) = $80) then
      begin
        // �� mov/test
        case size_ptr(opcode_ptr) of
          byte_ptr: {imm_size = 1 byte only};
          word_ptr: begin
                      // imm_size = 1 || 2 bytes
                      value := 1;
                    end;
        else
          // imm_size = 1 || 4 bytes
          value := 3;
        end;
      end;
    end;

    // MinMax � ������ ������ ������������� Min
    Result.F.HybridSize_MinMax := HybridSize_MinMax(opcode_ptr, X, @addr)-value;
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, offset);

    // "�����������" ���� offset � value
    Dest := pinteger(@POpcodeCmdData(Result).Bytes[Result.Size - (left_over_info shr 16)]);
    if (left_over_info and $ff00 <> 0) then
    begin
      Dest^ := left_over_info;
      System.Inc(NativeInt(Dest));
    end;
    Dest^ := value;
  end;  
end;
{$else}
asm
  // ������ (����� ������� TOpcodeAddress.IntelInspect)
  {$ifdef CPUX86}
     push ebx // �����
     mov ebp, v_const // value
     push eax // self
     push edx // opcode_ptr
     push [ECX + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     mov eax, ecx // addr as Self
  {$else .CPUX64}
     push rbp
     push rbx // �����
     mov rbp, r9 // value
     mov eax, [r8 + TOpcodeAddress_offset + TOpcodeConst.F.Value]
     push rcx // self
     push rdx // opcode_ptr
     push rax // offset
     mov rcx, r8 // addr as Self
  {$endif}
  mov ebx, edx
  call TOpcodeAddress.IntelInspect

  // eax - Y, ebx - opcode_ptr, ecx - �����
  // X(edx) := ptr_intel_info[size_ptr(opcode_ptr)];
  movzx edx, bl
  test ebx, flag_extra
  {$ifdef CPUX86}
     mov edx, [offset ptr_intel_info + edx*4]
  {$else .CPUX64}
     lea rcx, [ptr_intel_info]
     mov edx, [rcx + rdx*4]
  {$endif}

  // ������ ��������� � �������������� �������� �������
  // ��� ����������� ������ � ��� �������
  jz @cmd_std
  @cmd_shift:
    and edx, $ffffff00
    cmp bh, $D2
    je @cmd_done
    cmp ebp, 1
    {$ifdef CPUX86}
       lea ecx, [edx+$1000]
       lea edx, [edx+1]
    {$else .CPUX64}
       lea rcx, [rdx+$1000]
       lea rdx, [rdx+1]
    {$endif}
    cmove edx, ecx
    jmp @cmd_done
  @cmd_std:
    cmp dl, 1
    {$ifdef CPUX86}
       lea ecx, [ebp+128]
    {$else .CPUX64}
       lea rcx, [rbp+128]
    {$endif}
    je @cmd_done
    cmp ecx, 255
    ja @cmd_std_2_4
    cmp bh, $80
    jne @cmd_std_2_4
  @cmd_std_1:
    and edx, $ffffff00
    or edx, $0201
    jmp @cmd_done
  @cmd_std_2_4:
    cmp dl, 2
    je @cmd_done
    and edx, $ffffff00
    or edx, 4
  @cmd_done:

  // offset, sib, ������ value+sib
  mov ecx, eax
  movzx ebx, dl
  and ecx, $f
  shl ebx, 16
  test eax, $f0
  {$ifdef CPUX86}
    lea edx, [edx+ecx]
  {$else .CPUX64}
    lea rdx, [rdx+rcx]
  {$endif}
  jz @sib_no
  @sib_using:
    cmp ecx, 4
    {$ifdef CPUX86}
      pop ecx
    {$else .CPUX64}
      pop rcx
    {$endif}
    jne @sib_std
      ror ecx, 24
      mov bl, cl
      rol ecx, 24
      add ebx, $010100
    @sib_std:
    shl ecx, 8
    inc edx
    mov cl, ah
  jmp @sib_done
  @sib_no:
    {$ifdef CPUX86}
      pop ecx
    {$else .CPUX64}
      pop rcx
    {$endif}
  @sib_done:

  // opcode_ptr - [esp/rsp],  Y - eax, X - edx, offset - ecx, left_over_info - ebx
  // �����
  and eax, $ffff0000
  or edx, eax
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     pop rax
     mov r8, rcx
  {$endif}
  and eax, intel_opcode_mask
  or edx, eax
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     pop rcx
  {$endif}
  call AddSmartBinaryCmd

  // Dest := pinteger(@Result.Data.Bytes[Result.Size - (left_over_info shr 16)]);
  // if (left_over_info and $ff00 <> 0) then ...
  mov ecx, ebx
  {$ifdef CPUX86}
     movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
  {$else .CPUX64}
     movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
  {$endif}
  shr ecx, 16
  {$ifdef CPUX86}
     neg ecx
  {$else .CPUX64}
     neg rcx
  {$endif}
  test bh, bh
  {$ifdef CPUX86}
     lea edx, [TOpcodeCmdData.bytes + edx+ecx]
  {$else .CPUX64}
     lea rdx, [TOpcodeCmdData.bytes + rdx+rcx]
  {$endif}
  jz @fill_value
  @fill_over_byte:
  {$ifdef CPUX86}
     mov [eax + edx], ebx
  {$else .CPUX64}
     mov [rax + rdx], ebx
  {$endif}
    inc edx
  @fill_value:
  {$ifdef CPUX86}
     mov [eax + edx], ebp
  {$else .CPUX64}
     mov [rax + rdx], ebp
  {$endif}

  // ������� ebx/rbx
  {$ifdef CPUX86}
     pop ebx
  {$else .CPUX64}
     pop rbx
     pop rbp
  {$endif}
end;
{$endif}

// ��� ���������: ptr, addr, const_32
// �������� cmp byte ptr [eax+ebx*2-12], 0 ��� sbb qword ptr [r12 + rdx], $17
// ��������� ��� �� ������: rcl,rcr,rol,ror,sal,sar,shl,shr
procedure TOpcodeBlock_Intel.PRE_cmd_ptr_addr_const(const opcode_ptr: integer; const addr: TOpcodeAddress; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (addr.offset.Kind = ckValue) and (v_const.Kind = ckValue) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, opcode_ptr and flag_x64 <> 0, P.Proc);
       // �������� ��� ckValue-��������� ������ �� �����
    {$endif}
    cmd_ptr_addr_const_value(opcode_ptr, addr,{$ifdef OPCODE_MODES}v_const,cmd{$else}v_const.Value{$endif});
  end else
  diffcmd_addr_const(opcode_ptr, addr, v_const, cmd_ptr_addr_const_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

// ��� ���������: reg, reg, const_32/cl
// ������ ������� shld | shrd | imul
// reg1 - ������� ����, reg2 ������ �� 16 ���
function TOpcodeBlock_Intel.cmd_reg_reg_const_value(const base_reg1_opcode_reg2: integer; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  opcode_mask = integer(intel_opcode_mask and $ff00ffff);
  modrm_reg_reg = $C00000;
  modrm_src_mask = integer(intel_modrm_src_mask and $ffff00ff);
  modrm_dest_mask = integer(intel_modrm_dest_mask and $ffff00ff);
{$ifndef OPCODE_FAST}
var
  X, Y: integer;
  imm_size: integer;
  value: integer;
  reg1_opcode_reg2: integer;

  // cmd �������, �������, cl | %d | %s  
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
    const_value: PShortString;
  begin
    if (byte(base_reg1_opcode_reg2 shr 8) in [$A5{shld_cl},$AD{shrd_cl}]) then const_value := PShortString(@STR_CL)
    else const_value := buffer.Const32(v_const);

    Result := AddCmdText('%s %s, %s, %s', [cmd, reg_intel_names[byte(base_reg1_opcode_reg2)], reg_intel_names[byte(base_reg1_opcode_reg2 shr 16)], const_value^]);
  end;
  {$endif}
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  reg1_opcode_reg2 := base_reg1_opcode_reg2;
  {$ifdef OPCODE_MODES}
    value := v_const.Value;
    if (v_const.Kind <> ckValue) then value := low(integer);
  {$else}
    value := v_const;
  {$endif}

  // ������������ � �����������
  X := reg_intel_info[byte(reg1_opcode_reg2)];
  Y := reg_intel_info[byte(reg1_opcode_reg2 shr 16)];

  // ������ ���������, ��������� X/Y
  if (reg1_opcode_reg2 and flag_extra <> 0) then
  begin
    // imul (src � dest ������-�� �������� �������)
    imm_size := X;
    X := Y;
    Y := imm_size;

    if (value >= -128) and (value <= 127) then
    begin
      reg1_opcode_reg2 := reg1_opcode_reg2 or $0200;
      imm_size := 1;
    end else
    if (byte(X) = 2) then imm_size := 2
    else imm_size := 4;
  end else
  begin
    // shld / shrd
    // 1. ��� cl �������� - 0
    imm_size := ((reg1_opcode_reg2 shr 8) xor 1) and 1;
  end;

  // �����
  X := modrm_reg_reg or (reg1_opcode_reg2 and opcode_mask)
       or (X and modrm_dest_mask) or (Y and modrm_src_mask)
       or imm_size;
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (v_const.Kind <> ckValue) then
  begin
    FillAsText();

    // ������ ������������� Min (���������)
    value := 0;
    if (v_const.Kind = ckCondition) then
    begin
      if (base_reg1_opcode_reg2 and flag_extra <> 0) then
      begin
        // imul (������������� �� �������� ��� 8-������ ���������)
        if (X and flag_word_ptr <> 0) then value := 1
        else value := 3;
      end else
      begin
        // shld / shrd
        if not (byte(base_reg1_opcode_reg2 shr 8) in [$A5{shld_cl},$AD{shrd_cl}]) then value := 1;
      end;
    end;

    // MinMax � ������ ������ ������������� Min
    Result.F.HybridSize_MinMax := HybridSize_MinMax(base_reg1_opcode_reg2, X, nil)-value;
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, value);
  end;  
end;
{$else}
const
  // ����� � X ��������� ����� imm_size
  modrm_dest_imm_mask = modrm_dest_mask or $ff;
asm
  // ������
  {$ifdef CPUX86}
     push esi
     push ebx
  {$else .CPUX64}
     xchg rsi, r9
     xchg rbx, r10
  {$endif}

  // ������������ � �����������
  // ebx - X, esi - Y
  {$ifdef CPUX64}
    lea r11, [reg_intel_info]
  {$endif}
  mov esi, edx
  movzx ebx, dl
  shr esi, 16
  {$ifdef CPUX86}
     mov ebx, [offset reg_intel_info + ebx*4]
  {$else .CPUX64}
     mov ebx, [r11 + rbx*4]
  {$endif}
  and esi, $ff
  {} test edx, flag_extra
  {$ifdef CPUX86}
     mov esi, [offset reg_intel_info + esi*4]
  {$else .CPUX64}
     mov esi, [r11 + rsi*4]
  {$endif}

  // ������ ���������, ��������� X/Y
  // test edx, flag_extra
  jz @cmd_shift
  @cmd_imul:
    // value += 128
    {$ifdef CPUX86}
       sub ecx, -128
    {$else .CPUX64}
       sub r8, -128
    {$endif}
    xchg ebx, esi
    {$ifdef CPUX86}
       cmp ecx, 255
    {$else .CPUX64}
       cmp r8, 255
    {$endif}
    ja @cmd_imul_2_4
      // imm_size = 1
      mov bl, 1
      // value -= 128
      {$ifdef CPUX86}
         add ecx, -128
      {$else .CPUX64}
         add r8, -128
      {$endif}
      or edx, $0200
    jmp @cmd_finish
    @cmd_imul_2_4:
      cmp bl, 2
      {$ifdef CPUX86}
         lea ecx, [ecx - 128]
      {$else .CPUX64}
         lea r8, [r8 - 128]
      {$endif}
      je @cmd_finish
      mov bl, 4
      jmp @cmd_finish
  @cmd_shift:
    // cl (0) ��� const (1)
    test dh, 1
    setz bl
  @cmd_finish:

  // �����
  and edx, opcode_mask
  and ebx, modrm_dest_imm_mask
  and esi, modrm_src_mask
  {$ifdef CPUX86}
     lea edx, [edx + ebx + modrm_reg_reg]
  {$else .CPUX64}
     lea rdx, [rdx + rbx + modrm_reg_reg]
  {$endif}
  or edx, esi
  {$ifdef CPUX86}
     pop ebx
     pop esi
  {$else .CPUX64}
     xchg rbx, r10
     xchg rsi, r9
  {$endif}
  jmp AddSmartBinaryCmd
end;
{$endif}


// ��� ���������: reg, reg, const_32/cl
// ������ ������� shld | shrd | imul
// reg1 - ������� ����, reg2 ������ �� 16 ���
procedure TOpcodeBlock_Intel.PRE_cmd_reg_reg_const(const reg1_opcode_reg2: integer; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (v_const.Kind = ckValue) then
  begin
    // �������� ��� ckValue ������ �� �����
    cmd_reg_reg_const_value(reg1_opcode_reg2, {$ifdef OPCODE_MODES}v_const,cmd{$else}v_const.Value{$endif});
  end else
  diffcmd_const32(reg1_opcode_reg2, v_const, cmd_reg_reg_const_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

// ��� ���������(shld,shrd): addr, reg, const_32/cl
// ��� ��� imul: reg, addr, const_32
function TOpcodeBlock_Intel.cmd_addr_reg_const_value(const base_opcode_reg: integer; const addr: TOpcodeAddress; const v_const: opused_const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  modrm_src_mask = integer(intel_modrm_src_mask and (not intel_nonbyte_mask)) or $ff;
{$ifndef OPCODE_FAST}
var
  X, Y: integer;
  offset, left_over_info: integer;
  Dest: pinteger;
  opcode_reg: integer;
  value: integer;

  // cmd �����, �������, cl | %d | %s
  // ���
  // imul �������, �����, %d | %s
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    reg_name: pansichar;
    buffer: TOpcodeTextBuffer;
    const_value: PShortString;
  begin
    reg_name := reg_intel_names[byte(base_opcode_reg)];
    buffer.IntelAddress(base_opcode_reg, addr);

    if (base_opcode_reg and flag_extra = 0) and (byte(base_opcode_reg shr 8) in [$A5{shld_cl},$AD{shrd_cl}]) then const_value := PShortString(@STR_CL)
    else const_value := buffer.Const32(v_const, 1);

    if (base_opcode_reg and flag_extra = 0) then
    begin
      // cmd �����, �������, cl | %d | %s
      Result := AddCmdText('%s %s, %s, %s', [cmd, buffer.value.S, reg_name, const_value^]);
    end else
    begin
      // imul �������, �����, %d | %s
      Result := AddCmdText('%s %s, %s, %s', [cmd, reg_name, buffer.value.S, const_value^]);
    end;
  end;
  {$endif}
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  opcode_reg := base_opcode_reg;
  {$ifdef OPCODE_MODES}
    value := v_const.Value;
    if (v_const.Kind <> ckValue) then value := low(integer);
  {$else}
    value := v_const;
  {$endif}

  X := reg_intel_info[byte(opcode_reg)] and modrm_src_mask;
  Y := addr.IntelInspect(opcode_reg);

  // ������ ���������
  if (opcode_reg and flag_extra <> 0) then
  begin
    // imul (src � dest ������-�� �������� �������)
    if (value >= -128) and (value <= 127) then
    begin
      opcode_reg := opcode_reg or $0200;
      X := (X and $ffffff00) + 1;
    end else
    if (byte(X) <> 2) then X := (X and $ffffff00) + 4;
  end else
  begin
    // shld / shrd
    // 1. ��� cl �������� - 0
    X := (X and integer($ffffff00)) + (((opcode_reg shr 8) xor 1) and 1);
  end;

  // offset, sib, ������ value+sib
  offset := addr.offset.Value;
  left_over_info := (X and $ff) shl 16;
  X := X + (Y and $0f{������ �ffset});
  if (Y and $f0 <> 0{sib}) then
  begin
    if (Y and $0f = 4) then
    begin
      left_over_info := left_over_info + (offset shr 24) + $010100
    end;

    offset := (offset shl 8) or ((Y shr 8) and $ff);
    X := X + 1;
  end;

  // ����� � �������� � ������
  X := (opcode_reg and intel_opcode_mask) or X  or (Y and integer($ffff0000));
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and ((addr.offset.Kind <> ckValue) or (v_const.Kind <> ckValue)) then
  begin
    FillAsText();

    // ������ ������������� Min (���������)
    value := 0;
    if (v_const.Kind = ckCondition) then
    begin
      if (base_opcode_reg and flag_extra <> 0) then
      begin
        // imul (������������� �� �������� ��� 8-������ ���������)
        if (X and flag_word_ptr <> 0) then value := 1
        else value := 3;
      end else
      begin
        // shld / shrd
        if not (byte(base_opcode_reg shr 8) in [$A5{shld_cl},$AD{shrd_cl}]) then value := 1;
      end;
    end;

    // MinMax � ������ ������ ������������� Min
    Result.F.HybridSize_MinMax := HybridSize_MinMax(base_opcode_reg, X, @addr)-value;
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, offset);

    // "�����������" ���� offset � value
    Dest := pinteger(@POpcodeCmdData(Result).Bytes[Result.Size - (left_over_info shr 16)]);
    if (left_over_info and $ff00 <> 0) then
    begin
      Dest^ := left_over_info;
      System.Inc(NativeInt(Dest));
    end;
    Dest^ := value;
  end;  
end;
{$else}
asm
  // ������ (����� ������� TOpcodeAddress.IntelInspect)
  {$ifdef CPUX86}
     push ebx // �����
     mov ebp, v_const // value
     push eax // self
     push edx // opcode_reg
     push [ECX + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     mov eax, ecx // addr as Self
  {$else .CPUX64}
     push rbp
     push rbx // �����
     mov rbp, r9 // value
     mov eax, [r8 + TOpcodeAddress_offset + TOpcodeConst.F.Value]
     push rcx // self
     push rdx // opcode_reg
     push rax // offset
     mov rcx, r8 // addr as Self
  {$endif}
  mov ebx, edx
  call TOpcodeAddress.IntelInspect

  // eax - Y, ebx - opcode_reg, ecx - �����
  // X := reg_intel_info[byte(opcode_reg)] and modrm_src_mask;
  movzx edx, bl
  {$ifdef CPUX86}
     mov edx, [offset reg_intel_info + edx*4]
  {$else .CPUX64}
     lea rcx, [reg_intel_info]
     mov edx, [rcx + rdx*4]
  {$endif}
  and edx, modrm_src_mask

  // ������ ���������
  test ebx, flag_extra
  {$ifdef CPUX86}
     lea ecx, [ebp+128]
  {$else .CPUX64}
     lea rcx, [rbp+128]
  {$endif}
  jz @cmd_shift
  @cmd_imul:
    cmp ecx, 255
    ja @cmd_imul_2_4
      // imm_size = 1
      mov dl, 1
      {$ifdef CPUX86}
         or byte ptr [esp+4+1], $02
      {$else .CPUX64}
         or byte ptr [rsp+8+1], $02
      {$endif}
    jmp @cmd_finish
    @cmd_imul_2_4:
      cmp dl, 2
      je @cmd_finish
      mov dl, 4
      jmp @cmd_finish
  @cmd_shift:
    // cl (0) ��� const (1)
    test bh, 1
    setz dl
  @cmd_finish: 

  // offset, sib, ������ value+sib
  mov ecx, eax
  movzx ebx, dl
  and ecx, $f
  shl ebx, 16
  test eax, $f0
  {$ifdef CPUX86}
    lea edx, [edx+ecx]
  {$else .CPUX64}
    lea rdx, [rdx+rcx]
  {$endif}
  jz @sib_no
  @sib_using:
    cmp ecx, 4
    {$ifdef CPUX86}
      pop ecx
    {$else .CPUX64}
      pop rcx
    {$endif}
    jne @sib_std
      ror ecx, 24
      mov bl, cl
      rol ecx, 24
      add ebx, $010100
    @sib_std:
    shl ecx, 8
    inc edx
    mov cl, ah
  jmp @sib_done
  @sib_no:
    {$ifdef CPUX86}
      pop ecx
    {$else .CPUX64}
      pop rcx
    {$endif}
  @sib_done:

  // opcode_ptr - [esp/rsp],  Y - eax, X - edx, offset - ecx, left_over_info - ebx
  // �����
  and eax, $ffff0000
  or edx, eax
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     pop rax
     mov r8, rcx
  {$endif}
  and eax, intel_opcode_mask
  or edx, eax
  {$ifdef CPUX86}
     pop eax
  {$else .CPUX64}
     pop rcx
  {$endif}
  call AddSmartBinaryCmd

  // Dest := pinteger(@Result.Data.Bytes[Result.Size - (left_over_info shr 16)]);
  // if (left_over_info and $ff00 <> 0) then ...
  mov ecx, ebx
  {$ifdef CPUX86}
     movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
  {$else .CPUX64}
     movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
  {$endif}
  shr ecx, 16
  {$ifdef CPUX86}
     neg ecx
  {$else .CPUX64}
     neg rcx
  {$endif}
  test bh, bh
  {$ifdef CPUX86}
     lea edx, [TOpcodeCmdData.bytes + edx+ecx]
  {$else .CPUX64}
     lea rdx, [TOpcodeCmdData.bytes + rdx+rcx]
  {$endif}
  jz @fill_value
  @fill_over_byte:
  {$ifdef CPUX86}
     mov [eax + edx], ebx
  {$else .CPUX64}
     mov [rax + rdx], ebx
  {$endif}
    inc edx
  @fill_value:
  {$ifdef CPUX86}
     mov [eax + edx], ebp
  {$else .CPUX64}
     mov [rax + rdx], ebp
  {$endif}

  // ������� ebx/rbx
  {$ifdef CPUX86}
     pop ebx
  {$else .CPUX64}
     pop rbx
     pop rbp
  {$endif}
end;
{$endif}

// ��� ���������(shld,shrd): addr, reg, const_32/cl
// ��� ��� imul: reg, addr, const_32
procedure TOpcodeBlock_Intel.PRE_cmd_addr_reg_const(const opcode_reg: integer; const addr: TOpcodeAddress; const v_const: const_32{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (addr.offset.Kind = ckValue) and (v_const.Kind = ckValue) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, opcode_reg and flag_x64 <> 0, P.Proc);
       // �������� ��� ckValue-��������� ������ �� �����
    {$endif}
    cmd_addr_reg_const_value(opcode_reg, addr,{$ifdef OPCODE_MODES}v_const,cmd{$else}v_const.Value{$endif});
  end else
  diffcmd_addr_const(opcode_reg, addr, v_const, cmd_addr_reg_const_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

// ��� ���������: reg, reg
// ��� movzx � movsx
function TOpcodeBlock_Intel.movszx_reg_reg(const opcode_reg: integer; v_reg: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  reg_mask = intel_modrm_src_mask and (not intel_nonbyte_mask);
  v_reg_mask = intel_modrm_dest_mask and (not flag_word_ptr);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    Result := AddCmdText('%s %s, %s', [cmd, reg_intel_names[byte(opcode_reg)], reg_intel_names[byte(v_reg)]]);
    exit;
  end;
  {$endif}

  Result := AddSmartBinaryCmd(
            (opcode_reg and intel_opcode_mask) or
            (reg_intel_info[byte(opcode_reg)] and reg_mask) or
            (reg_intel_info[byte(v_reg)] and v_reg_mask), 0);
end;
{$else}
asm
  {$ifdef CPUX86}
     movzx ecx, cl
     push ebx
     mov ecx, [offset reg_intel_info + ecx*4]
     movzx ebx, dl
     and ecx, v_reg_mask
     mov ebx, [offset reg_intel_info + ebx*4]
     and edx, intel_opcode_mask
     and ebx, reg_mask
     or edx, ecx
     or edx, ebx
     pop ebx    
  {$else .CPUX64}
     movzx rax, r8b
     lea r11, [reg_intel_info]
     xchg rbx, r9
     mov eax, [r11 + rax*4]
     movzx ebx, dl
     and eax, v_reg_mask
     mov ebx, [r11 + rbx*4]
     and edx, intel_opcode_mask
     and ebx, reg_mask
     or edx, eax
     or edx, ebx
     xchg rbx, r9
  {$endif}

  jmp AddSmartBinaryCmd
end;
{$endif}

// ��� ���������: reg, ptr, addr
// ��� movzx � movsx
function TOpcodeBlock_Intel.movszx_reg_ptr_addr_value(const reg_opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  opcode_mask = intel_opcode_mask and integer($ff00ffff);
  reg_mask = intel_modrm_src_mask and (not intel_nonbyte_mask);
  ptr_mask = intel_modrm_dest_mask and (not flag_word_ptr);
{$ifndef OPCODE_FAST}
var
  X, Y: integer;
  offset, leftover: integer;

  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
    str_ptr: PShortString;
  begin
    buffer.IntelAddress(reg_opcode_ptr, addr);

    if (false{!}) then str_ptr := PShortString(@STR_NULL)
    else str_ptr := buffer.SizePtr(reg_opcode_ptr shr 16, 1);

    Result := AddCmdText('%s %s, %s%s', [cmd,
                         reg_intel_names[byte(reg_opcode_ptr)],
                         str_ptr^, buffer.value.S]);
  end;
  {$endif}
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  // �����, sib
  Y := addr.IntelInspect(reg_opcode_ptr);  

  // ����� ����������
  X := (reg_opcode_ptr and opcode_mask) or
       (reg_intel_info[byte(reg_opcode_ptr)] and reg_mask) or
       (ptr_intel_info[size_ptr(reg_opcode_ptr shr 16)] and ptr_mask);

  // ��������, ������� (��� sib)
  leftover := 0;
  offset := addr.offset.Value;
  if (Y and $f0 <> 0) then
  begin
    leftover := offset shr 24;
    offset := (offset shl 8) or ((Y shr 8) and $ff);
    Y := (Y and $ffff000f)+1;
  end;

  // �����
  X := X or Y;
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (addr.offset.Kind <> ckValue) then
  begin
    FillAsText();
    Result.F.HybridSize_MinMax := HybridSize_MinMax(reg_opcode_ptr, X, @addr);
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, offset);

    // �������������� ����
    if (byte(Y) = 5) then
    begin
      POpcodeCmdData(Result).Bytes[Result.Size-1] := byte(leftover);
    end;
  end;  
end;
{$else}
asm
  // ������ (����� ������� TOpcodeAddress.IntelInspect)
  {$ifdef CPUX86}
     push ebx // �����
     push eax // self
     push [ECX + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     mov eax, ecx // addr as Self
  {$else .CPUX64}
     push rbx // �����
     push rcx // self
     push [R8 + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     mov rcx, r8 // addr as Self
  {$endif}
  mov ebx, edx
  call TOpcodeAddress.IntelInspect

  // X := (reg_opcode_ptr and opcode_mask) or
  //      (reg_intel_info[byte(reg_opcode_ptr)] and reg_mask) or
  //      (ptr_intel_info[size_ptr(reg_opcode_ptr shr 16)] and ptr_mask);
  mov edx, ebx
  movzx ecx, bl
  shr ebx, 16
  and edx, opcode_mask
  movzx ebx, bl
  {$ifdef CPUX86}
     mov ecx, [offset reg_intel_info + ecx*4]
     mov ebx, [offset ptr_intel_info + ebx*4]
  {$else .CPUX64}
     lea r10, [reg_intel_info]
     lea r11, [ptr_intel_info]
     mov ecx, [r10 + rcx*4]
     mov ebx, [r11 + rbx*4]
  {$endif}
  and ecx, reg_mask
  and ebx, ptr_mask
  or edx, ecx
  or edx, ebx

  // offset, sib, ������ value+sib
  // (� �����: offset, self, ebx/rbx). eax - Y. edx - X
  test al, $f0
  {$ifdef CPUX86}
    pop ecx
  {$else .CPUX64}
    pop rcx
  {$endif}
  jz @sib_done
    mov ebx, ecx
    shl ecx, 8
    inc eax
    shr ebx, 24
    mov cl, ah
    and eax, $ffff000f
  @sib_done:
  {$ifdef CPUX64}
    xchg r8, rcx
  {$endif}
  or edx, eax

  // 2 �������� ������: ������� � � ������������ �����
  cmp al, 5
  je @call_over_byte
  @call_std:
    {$ifdef CPUX86}
       pop eax
       pop ebx
    {$else .CPUX64}
       pop rcx
       pop rbx
    {$endif}
    jmp AddSmartBinaryCmd
  @call_over_byte:
    {$ifdef CPUX86}
       pop eax
    {$else .CPUX64}
       pop rcx
    {$endif}
    call AddSmartBinaryCmd

    mov ecx, ebx
    {$ifdef CPUX86}
       movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
       pop ebx
       mov [EAX + TOpcodeCmdData.bytes + edx - 1], cl
    {$else .CPUX64}
       movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
       pop rbx
       mov [RAX + TOpcodeCmdData.bytes + rdx - 1], cl
    {$endif}
end;
{$endif}

// ��� ���������: reg, ptr, addr
// ��� movzx � movsx
procedure TOpcodeBlock_Intel.PRE_movszx_reg_ptr_addr(const reg_opcode_ptr: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (addr.offset.Kind = ckValue) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, reg_opcode_ptr and flag_x64 <> 0, P.Proc);
    {$endif}
    movszx_reg_ptr_addr_value(reg_opcode_ptr, addr{$ifdef OPCODE_MODES},cmd{$endif});
  end else
  diffcmd_addr(reg_opcode_ptr, addr, movszx_reg_ptr_addr_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

// ������� setcc r8 | cmovcc reg_wd, reg_wd
// � ����������: ����� extra � x64 | v_reg/0 | cc | reg
// extra - cmovcc
function TOpcodeBlock_Intel.setcmov_cc_regs(const params: integer{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  CMOVCC_OPCODE = flag_0f or ($C040 shl 8);
  SETCC_OPCODE = flag_0f or ($C090 shl 8);
  modrm_src_mask = intel_modrm_src_mask and (not intel_nonbyte_mask);
  modrm_dest_mask = intel_modrm_dest_mask and (not intel_nonbyte_mask);
{$ifndef OPCODE_FASTEST}
var
  X: integer;
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    if (params and flag_extra <> 0) then
    begin
      // cmovcc
      Result := AddCmdText('%s%s %s, %s', [cmd, cc_intel_names[byte(params shr 8)]+2,
                        reg_intel_names[byte(params)], reg_intel_names[byte(params shr 16)]]);
    end else
    begin
      // setcc
      Result := AddCmdText('%s%s %s', [cmd, cc_intel_names[byte(params shr 8)]+2,
                        reg_intel_names[byte(params)]]);
    end;
    exit;
  end;
  {$endif}

  if (params and flag_extra <> 0) then
  begin
    // cmovcc
    X := CMOVCC_OPCODE or
        (reg_intel_info[byte(params)] and modrm_src_mask) or
        (reg_intel_info[byte(params shr 16)] and modrm_dest_mask) or
        (ord(cc_intel_info[intel_cc(params shr 8)]) shl 8);
  end else
  begin
    // setcc
    X := SETCC_OPCODE or
        (reg_intel_info[byte(params)] and modrm_dest_mask) or
        (ord(cc_intel_info[intel_cc(params shr 8)]) shl 8);
  end;

  // ���������
  Result := AddSmartBinaryCmd(X, 0);
end;
{$else}
const
  OFFSETED_FLAG = flag_extra shr 16;
asm
  {$ifdef CPUX86}
     push ebx
  {$else .CPUX64}
     xchg rax, rcx
     xchg rbx, r8
     lea r10, [cc_intel_info]
     lea r11, [reg_intel_info]
  {$endif}

  movzx ebx, dh
  movzx ecx, dl
  shr edx, 16
  {$ifdef CPUX86}
     movzx ebx, byte ptr [cc_intel_info + ebx]
     test edx, OFFSETED_FLAG
     mov ecx, [offset reg_intel_info + ecx*4]
  {$else .CPUX64}
     movzx ebx, byte ptr [r10 + rbx]
     test edx, OFFSETED_FLAG
     mov ecx, [r11 + rcx*4]
  {$endif}
  jz @setcc
  @cmovcc:
     movzx edx, dl
     shl ebx, 8
    {$ifdef CPUX86}
       mov edx, [offset reg_intel_info + edx*4]
    {$else .CPUX64}
       mov edx, [r11 + rdx*4]
    {$endif}
     and ecx, modrm_src_mask
     and edx, modrm_dest_mask
     lea ecx, [ebx + ecx + CMOVCC_OPCODE]
     or edx, ecx
  jmp @call
  @setcc:
     and ecx, modrm_dest_mask
     shl ebx, 8
     lea edx, [ecx + ebx + SETCC_OPCODE]
@call:
  {$ifdef CPUX86}
     pop ebx
  {$else .CPUX64}
     xchg rax, rcx
     xchg rbx, r8
  {$endif}
  jmp AddSmartBinaryCmd
end;
{$endif}

// ������� setcc addr8 | cmovcc reg_wd, addr
// � ����������: ����� extra � x64 | 0 | 0/reg ��� movcc | cc 
// extra - cmovcc
function TOpcodeBlock_Intel.setcmov_cc_addr_value(const params: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif}): POpcodeCmd;
const
  CMOVCC_OPCODE = flag_0f or ($40 shl 8);
  SETCC_OPCODE = flag_0f or ($90 shl 8);
  reg_mask = intel_modrm_src_mask and (not intel_nonbyte_mask);
{$ifndef OPCODE_FAST}
var
  X, Y: integer;
  offset, leftover: integer;

  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    cc_name: pansichar;
    buffer: TOpcodeTextBuffer;
  begin
    cc_name := cc_intel_names[byte(params)]+2;
    buffer.IntelAddress(params, addr);

    if (params and flag_extra <> 0) then
    begin
      // cmovcc
      Result := AddCmdText('%s%s %s, %s', [cmd, cc_name, reg_intel_names[byte(params shr 8)], buffer.value.S]);
    end else
    begin
      // setcc
      Result := AddCmdText('%s%s %s', [cmd, cc_name, buffer.value.S]);
    end;
  end;
  {$endif}

begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  // ����� ����������
  X := (ord(cc_intel_info[intel_cc(params)]) shl 8);
  if (params and flag_extra <> 0) then
  begin
    // cmovcc
    X := X or CMOVCC_OPCODE or (reg_intel_info[byte(params shr 8)] and reg_mask);
  end else
  begin
    // setcc
    X := X or SETCC_OPCODE;
  end;

  // �����, sib
  Y := addr.IntelInspect(params);

  // ��������, ������� (��� sib)
  leftover := 0;
  offset := addr.offset.Value;
  if (Y and $f0 <> 0) then
  begin
    leftover := offset shr 24;
    offset := (offset shl 8) or ((Y shr 8) and $ff);
    Y := (Y and $ffff000f)+1;
  end;

  // �����
  X := X or Y;
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (addr.offset.Kind <> ckValue) then
  begin
    FillAsText();
    Result.F.HybridSize_MinMax := HybridSize_MinMax(params, X, @addr);
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, offset);

    // �������������� ����
    if (byte(Y) = 5) then
    begin
      POpcodeCmdData(Result).Bytes[Result.Size-1] := byte(leftover);
    end;
  end;  
end;
{$else}
asm
  // ������ (����� ������� TOpcodeAddress.IntelInspect)
  {$ifdef CPUX86}
     push ebx // �����
     push eax // self
     push [ECX + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     mov eax, ecx // addr as Self
  {$else .CPUX64}
     push rbx // �����
     push rcx // self
     push [R8 + TOpcodeAddress_offset + TOpcodeConst.F.Value] // offset
     mov rcx, r8 // addr as Self
  {$endif}
  mov ebx, edx
  call TOpcodeAddress.IntelInspect

  // ����� ���������� X := (ord(cc_intel_info[intel_cc(params)]) shl 8);
  // if (params and flag_extra <> 0) then cmovcc/setcc
  movzx edx, bl
  movzx ecx, bh
  test ebx, flag_extra
  {$ifdef CPUX86}
     movzx edx, byte ptr [cc_intel_info + edx]
  {$else .CPUX64}
     lea r9, [cc_intel_info]
     movzx edx, byte ptr [r9 + rdx]
  {$endif}
  jz @setcc
  @cmovcc:
     //X := (X shl 8) or CMOVCC_OPCODE or (reg_intel_info[byte(params shr 8)] and reg_mask);
    {$ifdef CPUX86}
       mov ecx, [offset reg_intel_info + ecx*4]
    {$else .CPUX64}
       lea r9, [reg_intel_info]
       mov ecx, [r9 + rcx*4]
    {$endif}
     shl edx, 8
     and ecx, reg_mask
    {$ifdef CPUX86}
       lea edx, [edx + ecx + CMOVCC_OPCODE]
    {$else .CPUX64}
       lea rdx, [rdx + rcx + CMOVCC_OPCODE]
    {$endif}
  jmp @cc_done
  @setcc:
     shl edx, 8
     or edx, SETCC_OPCODE
  @cc_done:

  // offset, sib, ������ value+sib
  // (� �����: offset, self, ebx/rbx). eax - Y. edx - X
  test al, $f0
  {$ifdef CPUX86}
    pop ecx
  {$else .CPUX64}
    pop rcx
  {$endif}
  jz @sib_done
    mov ebx, ecx
    shl ecx, 8
    inc eax
    shr ebx, 24
    mov cl, ah
    and eax, $ffff000f
  @sib_done:
  {$ifdef CPUX64}
    xchg r8, rcx
  {$endif}  
  or edx, eax

  // 2 �������� ������: ������� � � ������������ �����
  cmp al, 5
  je @call_over_byte
  @call_std:
    {$ifdef CPUX86}
       pop eax
       pop ebx
    {$else .CPUX64}
       pop rcx
       pop rbx
    {$endif}
    jmp AddSmartBinaryCmd
  @call_over_byte:
    {$ifdef CPUX86}
       pop eax
    {$else .CPUX64}
       pop rcx
    {$endif}
    call AddSmartBinaryCmd

    mov ecx, ebx
    {$ifdef CPUX86}
       movzx edx, word ptr [EAX].TOpcodeCmd.F.Size
       pop ebx
       mov [EAX + TOpcodeCmdData.bytes + edx - 1], cl
    {$else .CPUX64}
       movzx edx, word ptr [RAX].TOpcodeCmd.F.Size
       pop rbx
       mov [RAX + TOpcodeCmdData.bytes + rdx - 1], cl
    {$endif}
end;
{$endif}

// ������� setcc addr8 | cmovcc reg_wd, addr
procedure TOpcodeBlock_Intel.PRE_setcmov_cc_addr(const params: integer; const addr: TOpcodeAddress{$ifdef OPCODE_MODES};const cmd: ShortString{$endif});
begin
  {$ifdef OPCODE_TEST}
    // todo ��������
  {$endif}

  // ��������� ���������� ��� ����������� �������
  // ��� ������� �����
  if (addr.offset.Kind = ckValue) then
  begin
    {$ifdef OPCODE_TEST}
       test_intel_address(addr, params and flag_x64 <> 0, P.Proc);
    {$endif}
    setcmov_cc_addr_value(params, addr{$ifdef OPCODE_MODES},cmd{$endif});
  end else
  diffcmd_addr(params, addr, setcmov_cc_addr_value{$ifdef OPCODE_MODES},cmd{$endif});
end;

procedure TOpcodeBlock_Intel.aaa;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.aad;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.aam;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.aas;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.daa;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.das;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.f2xm1;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fabs;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fadd(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fadd(d, s: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.faddp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fchs;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fclex;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcmov(cc: intel_cc; st_dest: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcom(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcom(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcomi(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcomip(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcomp(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcomp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcompp;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fcos;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fdecstp;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fdiv(d, s: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fdiv(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fdivp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fdivr(d, s: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fdivr(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fdivrp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.ffree;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fiadd(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.ficom(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.ficomp(ptr: size_ptr;
  const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fidiv(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fidivr(ptr: size_ptr;
  const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fild(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fimul(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fincstp;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fist(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fistp(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fisub(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fisubr(ptr: size_ptr;
  const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fld(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fld(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fld1;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fldl2e;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fldl2t;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fldlg2;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fldln2;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fldpi;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fldz;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fmul(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fmul(d, s: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fmulp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fnclex;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fnop;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fpatan;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fprem;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fprem1;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fptan;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.frndint;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.frstor;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fscale;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsin;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsincos;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsqrt;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fst(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fst(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fstp(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fstp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fstsw_ax;
begin
  cmd_single($E0DF9B{$ifdef OPCODE_MODES}, 'fstsw ax'{$endif});
end;

procedure TOpcodeBlock_Intel.fnstsw_ax;
begin
  cmd_single($E0DF{$ifdef OPCODE_MODES}, 'fnstsw ax'{$endif});
end;

procedure TOpcodeBlock_Intel.fsub(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsub(d, s: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsubp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsubr(d, s: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsubr(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fsubrp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.ftst;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fucom(ptr: size_ptr; const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fucom(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fucomi(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fucomip(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fucomp(ptr: size_ptr;
  const addr: address_x86);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fucomp(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fucompp;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fwait;
begin
  raise_not_realized();
end;

// cmp b/w/d/(q)
procedure TOpcodeBlock_Intel.cmpsb(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A6{cmpsb};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_cmpsb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.cmpsw(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A766{cmpsw};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_cmpsw{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.cmpsd(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A7{cmpsd};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_cmpsd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

// in b/w/d/(q)
procedure TOpcodeBlock_Intel.insb(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $6C{insb};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_insb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.insw(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $6D66{insw};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_insw{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.insd(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $6D{insd};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_insd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

// sca b/w/d/(q)
procedure TOpcodeBlock_Intel.scasb(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AE{scasb};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_scasb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.scasw(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AF66{scasw};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_scasw{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.scasd(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AF{scasd};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_scasd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

// sto b/w/d/(q)
procedure TOpcodeBlock_Intel.stosb(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AA{stosb};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_stosb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.stosw(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AB66{stosw};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_stosw{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.stosd(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AB{stosd};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_stosd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

// lod b/w/d/(q)
procedure TOpcodeBlock_Intel.lodsb(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AC{lodsb};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_lodsb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.lodsw(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AD66{lodsw};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_lodsw{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.lodsd(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AD{lodsd};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_lodsd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

// mov b/w/d/(q)
procedure TOpcodeBlock_Intel.movsb(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A4{movsb};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_movsb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.movsw(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A566{movsw};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_movsw{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_Intel.movsd(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A5{movsd};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_movsd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE          
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}


procedure TOpcodeBlock_Intel.fxam;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fxch(st: index8);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fxtract;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fyl2x;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.fyl2xp1;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.hlt;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.invd;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.invlpg;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.iret;
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_Intel.lahf;
begin
  raise_not_realized();
end;

{$ifdef OPCODE_MODES}
procedure TOpcodeBlock_Intel.call(ProcName: pansichar);
{$ifdef PUREPASCAL}
begin
  cmd_textjump_proc(-2{call}, ProcName);
end;
{$else}
asm
  {$ifdef CPUX86} 
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}
  mov dl, -2
  jmp cmd_textjump_proc
end;
{$endif}

procedure TOpcodeBlock_Intel.j(cc: intel_cc; ProcName: pansichar);
{$ifdef PUREPASCAL}
begin
  cmd_textjump_proc(shortint(cc), ProcName);
end;
{$else}
asm
  jmp cmd_textjump_proc
end;
{$endif}

procedure TOpcodeBlock_Intel.jmp(ProcName: pansichar);
{$ifdef PUREPASCAL}
begin
  cmd_cmd_textjump_proc(-1{jmp}, ProcName);
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}
  or edx, -1
  jmp cmd_textjump_proc
end;
{$endif}
{$endif}

procedure TOpcodeBlock_Intel.leave;
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    AddCmdText(PShortString(@cmd_leave)).F.ModeParam := ord(cmLeave) + ((128{�����}+1{leave}) shl 8);
  end else
  {$endif}
  begin
    // cmLeave ������� �� ������ ����������� � ������� ��������� ��������� (����� ����� ������ ������)
    P.Proc.FLastBinaryCmd := NO_CMD;

    // ���������
    AddSmartBinaryCmd($00c90000, 0).F.ModeParam := ord(cmLeave) + ((0{��������}+1{leave}) shl 8);
  end;
end;

procedure TOpcodeBlock_Intel.pause;
{$ifndef OPCODE_FAST}
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    AddCmdText(PShortString(@cmd_pause));
  end else
  {$endif}
  begin
    AddSmartBinaryCmd($0090F300, 0);
  end;
end;
{$else}
asm
  mov edx, $0090F300
  jmp AddSmartBinaryCmd
end;
{$endif}

procedure TOpcodeBlock_Intel.push(const v_const: const_32);
const
  OPCODE = $686A{push imm8(6A) | imm32(68)};
begin
  if (v_const.Kind = ckValue) then
  begin
    // ����� �����
    cmd_const_value(OPCODE, {$ifdef OPCODE_MODES}v_const,cmd_push{$else}v_const.Value{$endif});
  end else
  begin
    // ������� �����
    diffcmd_const32(OPCODE, v_const, cmd_const_value{$ifdef OPCODE_MODES},cmd_push{$endif});
  end;
end;

procedure TOpcodeBlock_Intel.ret(const count: word=0);
var
  Result: POpcodeCmd;
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    if (count = 0) then Result := AddCmdText(PShortString(@cmd_ret))
    else Result := AddCmdText('ret %d', [count]);

    Result.F.Param := 128{�����}+0{ret(n)};
  end else
  {$endif}
  begin
    // cmLeave ������� �� ������ ����������� � ������� ��������� ��������� (����� ����� ������ ������)
    P.Proc.FLastBinaryCmd := NO_CMD;

    // ���������
    if (count = 0) then Result := AddSmartBinaryCmd($00c30000, 0)
    else Result := AddSmartBinaryCmd($00c20002, count);

    // Result.F.Param := 0{��������}+0{ret(n)};
  end;

  // ���������, ��� ������� cmLeave
  Result.F.Mode := cmLeave;
end;

procedure TOpcodeBlock_Intel.ud2;
const
  OPCODE = $0B0F{ud2};
{$ifndef OPCODE_FAST}
begin
  cmd_single(OPCODE{$ifdef OPCODE_MODES},cmd_ud2{$endif});
end;
{$else}
asm
  mov edx, OPCODE
  jmp cmd_single
end;
{$endif}

procedure TOpcodeBlock_Intel.wait;
begin
  raise_not_realized();
end;



{ TOpcodeBlock_x86 }


function TOpcodeBlock_x86.AppendBlock: POpcodeBlock_x86;
const
  BLOCK_SIZE = sizeof(TOpcodeBlock);
{$ifdef PUREPASCAL}
begin
  Result := POpcodeBlock_x86(inherited AppendBlock(BLOCK_SIZE));
end;
{$else}
asm
  mov edx, BLOCK_SIZE
  jmp TOpcodeBlock.AppendBlock
end;
{$endif}

// adc
procedure TOpcodeBlock_x86.adc(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C010{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.adc(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($D014{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.adc(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($10{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.adc(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($10{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.adc(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($1080{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock adc
procedure TOpcodeBlock_x86.lock_adc(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($10{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_adc{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_adc(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_lock or ($1080{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_adc{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// add
procedure TOpcodeBlock_x86.add(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = flag_extra or ($C002{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.add(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($C004{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.add(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($00{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.add(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($00{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.add(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($0080{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock add
procedure TOpcodeBlock_x86.lock_add(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($00{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_add{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_add(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_lock or ($0080{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_add{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// and
procedure TOpcodeBlock_x86.and_(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C020{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.and_(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($E024{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.and_(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($20{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.and_(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($20{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.and_(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($2080{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock and
procedure TOpcodeBlock_x86.lock_and(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($20{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_and{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_and(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_lock or ($2080{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_and{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// bswap
procedure TOpcodeBlock_x86.bswap(reg: reg_x86_dwords);
const
  OPCODE = ($C80E{bswap} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_bswap{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

// call
procedure TOpcodeBlock_x86.call(block: POpcodeBlock_x86);
{$ifdef PUREPASCAL}
begin
  cmd_jump_block(-2{call}, block);
end;
{$else}
asm
  {$ifdef CPUX86} 
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}
  mov dl, -2
  jmp cmd_jump_block
end;
{$endif}

procedure TOpcodeBlock_x86.call(blocks: POpcodeSwitchBlock; index: reg_x86_addr; offset: integer=0);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_x86.call(reg: reg_x86_addr);
const
  OPCODE = ($D0FE{call} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_call{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.call(const addr: address_x86);
const
  OPCODE = ($10FF{call} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_call{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

// cmovcc
procedure TOpcodeBlock_x86.cmov(cc: intel_cc; reg: reg_x86_wd; v_reg: reg_x86_wd);
const
  FLAGS = flag_extra;
{$ifndef OPCODE_FASTEST}
begin
  setcmov_cc_regs(FLAGS or (ord(cc) shl 8) or byte(reg) or (ord(v_reg) shl 16){$ifdef OPCODE_MODES},cmd_cmov{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
     movzx ebp, v_reg
     movzx ecx, cl
     shl ebp, 16
     shl edx, 8
     lea ecx, [ecx + ebp + FLAGS]
     pop ebp
     add edx, ecx
     pop ecx
     mov [esp], ecx
  {$else .CPUX64}
     movzx r9, r9b // v_reg
     movzx r8, r8b
     shl r9, 16
     shl edx, 8
     lea r8, [r8 + r9 + FLAGS]
     add rdx, r8
  {$endif}
  jmp setcmov_cc_regs
end;
{$endif}

procedure TOpcodeBlock_x86.cmov(cc: intel_cc; reg: reg_x86_wd; const addr: address_x86);
const
  FLAGS = flag_extra;
{$ifndef OPCODE_FASTEST}
begin
  PRE_setcmov_cc_addr(FLAGS or ord(cc) or (ord(reg) shl 8), addr{$ifdef OPCODE_MODES},cmd_cmov{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
     movzx ecx, cl
     movzx edx, dl
     shl ecx, 8
     mov ebp, addr
     lea edx, [edx + ecx + FLAGS]
     mov ecx, [esp+4] // ret
     add esp, 8
     mov [esp], ecx
     cmp byte ptr [EBP + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     xchg ecx, ebp
     mov ebp, [esp-8]
  {$else .CPUX64}
     movzx r8, r8b
     movzx edx, dl
     shl r8, 8
     cmp byte ptr [R9 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     lea rdx, [rdx + r8 + FLAGS]
     xchg r8, r9
  {$endif}
  je setcmov_cc_addr_value
  jmp PRE_setcmov_cc_addr
end;
{$endif}



// cmp
procedure TOpcodeBlock_x86.cmp(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C038{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.cmp(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($F83C{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.cmp(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($38{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.cmp(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($38{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.cmp(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($3880{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// dec
procedure TOpcodeBlock_x86.dec(reg: reg_x86);
const
  OPCODE = flag_extra or ($C8FE{dec} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_dec{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.dec(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($08FE{dec} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_dec{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// lock dec
procedure TOpcodeBlock_x86.lock_dec(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_lock or ($08FE{dec} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_dec{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// div
procedure TOpcodeBlock_x86.div_(reg: reg_x86);
const
  OPCODE = ($F0F6{div} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_div{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.div_(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($30F6{div} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_div{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// idiv
procedure TOpcodeBlock_x86.idiv(reg: reg_x86);
const
  OPCODE = ($F8F6{idiv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_idiv{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.idiv(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($38F6{idiv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_idiv{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// imul
procedure TOpcodeBlock_x86.imul(reg: reg_x86);
const
  OPCODE = ($E8F6{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.imul(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($28F6{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

procedure TOpcodeBlock_x86.imul(reg: reg_x86_wd; v_reg: reg_x86_wd);
const
  OPCODE = flag_0f or flag_extra or ($C0AE{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.imul(reg: reg_x86_wd; const addr: address_x86);
const
  OPCODE = flag_0f or flag_extra or $0200 or ($AE{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.imul(reg: reg_x86_wd; const v_const: const_32);
begin
  // ������� ������� imul r, imm
  // �������������� � ���� ������� imul r, r, imm
  //
  // � ���� ����� ������� (� ����������) ��� ������
  // �������� cmd_reg_const_value()
  imul(reg, reg, v_const);
end;

procedure TOpcodeBlock_x86.imul(reg1, reg2: reg_x86_wd; const v_const: const_32);
const
  OPCODE = flag_extra or ($69{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_reg_const((ord(reg2) shl 16) or OPCODE or byte(reg1), v_const{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    shl ecx, 16
    cmp [EBP].TOpcodeConst.FKind, ckValue
    lea edx, [edx + ecx + OPCODE]
    mov ecx, [esp+4] // ret
    mov [esp+8], ecx
    xchg ecx, ebp
    mov ebp, [esp]
    lea esp, [esp+8]
  {$else .CPUX64}
    movzx eax, r8b
    xchg r8, r9
    shl eax, 16
    cmp [R8].TOpcodeConst.FKind, ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jne PRE_cmd_reg_reg_const
  {$ifdef CPUX86}
    mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
    mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.imul(reg: reg_x86_wd; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($69{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg), addr, v_const{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_addr_reg_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_addr_reg_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_addr_reg_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_addr_reg_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_addr_reg_const_value
  {$endif}
end;
{$endif}

// inc
procedure TOpcodeBlock_x86.inc(reg: reg_x86);
const
  OPCODE = flag_extra or ($C0FE{inc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_inc{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.inc(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($00FE{inc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_inc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// lock inc
procedure TOpcodeBlock_x86.lock_inc(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_lock or ($00FE{inc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_inc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// jcc
procedure TOpcodeBlock_x86.j(cc: intel_cc; block: POpcodeBlock_x86);
{$ifdef PUREPASCAL}
begin
  cmd_jump_block(shortint(cc), block);
end;
{$else}
asm
  jmp cmd_jump_block
end;
{$endif}

// jmp
procedure TOpcodeBlock_x86.jmp(block: POpcodeBlock_x86);
{$ifdef PUREPASCAL}
begin
  cmd_jump_block(-1{jmp}, block);
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}
  or edx, -1
  jmp cmd_jump_block
end;
{$endif}

procedure TOpcodeBlock_x86.jmp(blocks: POpcodeSwitchBlock; index: reg_x86_addr; offset: integer=0);
begin
  raise_not_realized();
end;

procedure TOpcodeBlock_x86.jmp(reg: reg_x86_addr);
const
  OPCODE = ($E0FE{jmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_jmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.jmp(const addr: address_x86);
const
  OPCODE = ($20FF{jmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_jmp{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

// lea
procedure TOpcodeBlock_x86.lea(reg: reg_x86_addr; const addr: address_x86);
const
  OPCODE = ($8D{lea} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_lea{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// mov
procedure TOpcodeBlock_x86.mov(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C088{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.mov(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($B000{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.mov(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($88{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.mov(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($88{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.mov(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($00C6{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// movsx
procedure TOpcodeBlock_x86.movsx(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = flag_0f or ($C0BE{movsx} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  movszx_reg_reg(OPCODE or byte(reg), byte(v_reg){$ifdef OPCODE_MODES},cmd_movsx{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp movszx_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.movsx(reg: reg_x86; ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_0f or ($BE{movsx} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_movszx_reg_ptr_addr(ord(reg) or (ord(ptr) shl 16) or OPCODE,
                          addr{$ifdef OPCODE_MODES},cmd_movsx{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    movzx edx, dl
    mov ebp, [ebp+8] // addr
    shl ecx, 16
    cmp byte ptr [EBP + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + ecx + OPCODE]

    mov ecx, [esp+4]
    lea esp, [esp + 8]
    xchg ecx, ebp
    mov [esp], ebp
    mov ebp, [esp-8]
  {$else .CPUX64}
    movzx eax, r8b
    movzx edx, dl
    xchg r8, r9
    shl eax, 16
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  je movszx_reg_ptr_addr_value
  jmp PRE_movszx_reg_ptr_addr
end;
{$endif}

// movzx
procedure TOpcodeBlock_x86.movzx(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = flag_0f or ($C0B6{movsx} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  movszx_reg_reg(OPCODE or byte(reg), byte(v_reg){$ifdef OPCODE_MODES},cmd_movzx{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp movszx_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.movzx(reg: reg_x86; ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_0f or ($B6{movsx} shl 8);
{$ifndef OPCODE_FASTEST}  
begin
  PRE_movszx_reg_ptr_addr(ord(reg) or (ord(ptr) shl 16) or OPCODE,
                          addr{$ifdef OPCODE_MODES},cmd_movzx{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    movzx edx, dl
    mov ebp, [ebp+8] // addr
    shl ecx, 16
    cmp byte ptr [EBP + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + ecx + OPCODE]

    mov ecx, [esp+4]
    lea esp, [esp + 8]
    xchg ecx, ebp
    mov [esp], ebp
    mov ebp, [esp-8]
  {$else .CPUX64}
    movzx eax, r8b
    movzx edx, dl
    xchg r8, r9
    shl eax, 16
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  je movszx_reg_ptr_addr_value
  jmp PRE_movszx_reg_ptr_addr
end;
{$endif}

// mul
procedure TOpcodeBlock_x86.mul(reg: reg_x86);
const
  OPCODE = ($E0F6{mul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_mul{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.mul(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($20F6{mul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_mul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// neg
procedure TOpcodeBlock_x86.neg(reg: reg_x86);
const
  OPCODE = ($D8F6{neg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_neg{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.neg(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($18F6{neg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_neg{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_neg(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_lock or ($18F6{neg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_neg{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// not
procedure TOpcodeBlock_x86.not_(reg: reg_x86);
const
  OPCODE = ($D0F6{not} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_not{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.not_(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($10F6{not} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_not{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// lock not
procedure TOpcodeBlock_x86.lock_not(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_lock or ($10F6{not} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_not{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// or
procedure TOpcodeBlock_x86.or_(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C008{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.or_(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($C80C{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.or_(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($08{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.or_(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($08{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.or_(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($0880{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock or
procedure TOpcodeBlock_x86.lock_or(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($08{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_or{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_or(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_lock or ($0880{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_or{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// pop
procedure TOpcodeBlock_x86.pop(reg: reg_x86_wd);
const
  OPCODE = ($5800{pop} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_pop{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.pop(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($008F{pop} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_pop{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// push
procedure TOpcodeBlock_x86.push(reg: reg_x86_wd);
const
  OPCODE = ($5000{push} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_push{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x86.push(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = ($30FF{push} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_push{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// rcl
procedure TOpcodeBlock_x86.rcl_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($D0D2{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_rcl{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.rcl(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($D0C0{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_rcl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.rcl_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($10D2{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_rcl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.rcl(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($10C0{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_rcl{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// rcr
procedure TOpcodeBlock_x86.rcr_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($D8D2{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_rcr{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.rcr(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($D8C0{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_rcr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.rcr_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($18D2{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_rcr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.rcr(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($18C0{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_rcr{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// rol
procedure TOpcodeBlock_x86.rol_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($C0D2{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_rol{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.rol(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($C0C0{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_rol{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.rol_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($00D2{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_rol{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.rol(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($00C0{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_rol{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// ror
procedure TOpcodeBlock_x86.ror_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($C8D2{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_ror{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.ror(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($C8C0{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_ror{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.ror_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($08D2{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_ror{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.ror(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($08C0{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_ror{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// sal
procedure TOpcodeBlock_x86.sal_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($E0D2{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_sal{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.sal(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($E0C0{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sal{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.sal_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($20D2{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_sal{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.sal(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($20C0{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sal{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// sar
procedure TOpcodeBlock_x86.sar_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($F8D2{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_sar{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.sar(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($F8C0{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sar{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.sar_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($38D2{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_sar{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.sar(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($38C0{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sar{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// sbb
procedure TOpcodeBlock_x86.sbb(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C018{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.sbb(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($D81C{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.sbb(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($18{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.sbb(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($18{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.sbb(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($1880{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock sbb
procedure TOpcodeBlock_x86.lock_sbb(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($18{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_sbb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_sbb(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_lock or ($1880{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_sbb{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// setcc
procedure TOpcodeBlock_x86.set_(cc: intel_cc; reg: reg_x86_bytes);
{$ifndef OPCODE_FASTEST}
begin
  setcmov_cc_regs((ord(cc) shl 8) or byte(reg){$ifdef OPCODE_MODES},cmd_set{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
     movzx ecx, cl
     shl edx, 8
     or edx, ecx
  {$else .CPUX64}
     movzx r8, r8b
     shl edx, 8
     or rdx, r8
  {$endif}
  jmp setcmov_cc_regs
end;
{$endif}

procedure TOpcodeBlock_x86.set_(cc: intel_cc; const addr: address_x86);
{$ifndef OPCODE_FASTEST}
begin
  PRE_setcmov_cc_addr(ord(cc), addr{$ifdef OPCODE_MODES},cmd_set{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
     cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  {$else .CPUX64}
     cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  {$endif}
  movzx edx, dl
  je setcmov_cc_addr_value
  jmp PRE_setcmov_cc_addr
end;
{$endif}  

// shl
procedure TOpcodeBlock_x86.shl_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($E0D2{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shl{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shl_(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($E0C0{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_shl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shl_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($20D2{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.shl_(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($20C0{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_shl{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// shr
procedure TOpcodeBlock_x86.shr_cl(reg: reg_x86);
const
  OPCODE = flag_extra or ($E8D2{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shr{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shr_(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($E8C0{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_shr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shr_cl(ptr: size_ptr; const addr: address_x86);
const
  OPCODE = flag_extra or ($28D2{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x86.shr_(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($28C0{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_shr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// shld
procedure TOpcodeBlock_x86.shld_cl(reg1, reg2: reg_x86);
const
  OPCODE = flag_0f or ($A5{shld_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ���������
  {$endif}
  cmd_reg_reg_const_value((ord(reg2) shl 16) or OPCODE or byte(reg1), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shld{$else}0{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    movzx edx, dl
    shl ecx, 16
    lea edx, [edx + ecx + OPCODE]
  {$else .CPUX64}
    movzx eax, r8b
    movzx edx, dl
    shl eax, 16
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shld(reg1, reg2: reg_x86; const v_const: const_32);
const
  OPCODE = flag_0f or ($A4{shld} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_reg_const((ord(reg2) shl 16) or OPCODE or byte(reg1), v_const{$ifdef OPCODE_MODES},cmd_shld{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    shl ecx, 16
    cmp [EBP].TOpcodeConst.FKind, ckValue
    lea edx, [edx + ecx + OPCODE]
    mov ecx, [esp+4] // ret
    mov [esp+8], ecx
    xchg ecx, ebp
    mov ebp, [esp]
    lea esp, [esp+8]
  {$else .CPUX64}
    movzx eax, r8b
    xchg r8, r9
    shl eax, 16
    cmp [R8].TOpcodeConst.FKind, ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jne PRE_cmd_reg_reg_const
  {$ifdef CPUX86}
    mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
    mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shld_cl(const addr: address_x86; reg2: reg_x86);
const
  OPCODE = flag_0f or ($A5{shld_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shld{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    push [esp]
    or ecx, OPCODE
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [esp+4], offset ZERO_CONST_32
    xchg edx, ecx
  {$else .CPUX64}
    lea rax, [ZERO_CONST_32]
    movzx r8, r8b
    push [rsp]
    or r8d, OPCODE
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [rsp+8], rax
    xchg rdx, r8
  {$endif}
  je cmd_addr_reg_const_value
  jmp PRE_cmd_addr_reg_const
end;
{$endif}

procedure TOpcodeBlock_x86.shld(const addr: address_x86; reg2: reg_x86; const v_const: const_32);
const
  OPCODE = flag_0f or ($A4{shld} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, v_const{$ifdef OPCODE_MODES},cmd_shld{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea ecx, [ecx + OPCODE]
    xchg edx, ecx
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_addr_reg_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_addr_reg_const
  {$else .CPUX64}
    movzx r8, r8b
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea r8, [r8 + OPCODE]
    xchg rdx, r8
    jne PRE_cmd_addr_reg_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_addr_reg_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_addr_reg_const_value
  {$endif}
end;
{$endif}

// shrd
procedure TOpcodeBlock_x86.shrd_cl(reg1, reg2: reg_x86);
const
  OPCODE = flag_0f or ($AD{shrd_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ���������
  {$endif}
  cmd_reg_reg_const_value((ord(reg2) shl 16) or OPCODE or byte(reg1), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shrd{$else}0{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    movzx edx, dl
    shl ecx, 16
    lea edx, [edx + ecx + OPCODE]
  {$else .CPUX64}
    movzx eax, r8b
    movzx edx, dl
    shl eax, 16
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shrd(reg1, reg2: reg_x86; const v_const: const_32);
const
  OPCODE = flag_0f or ($AC{shrd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_reg_const((ord(reg2) shl 16) or OPCODE or byte(reg1), v_const{$ifdef OPCODE_MODES},cmd_shrd{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    shl ecx, 16
    cmp [EBP].TOpcodeConst.FKind, ckValue
    lea edx, [edx + ecx + OPCODE]
    mov ecx, [esp+4] // ret
    mov [esp+8], ecx
    xchg ecx, ebp
    mov ebp, [esp]
    lea esp, [esp+8]
  {$else .CPUX64}
    movzx eax, r8b
    xchg r8, r9
    shl eax, 16
    cmp [R8].TOpcodeConst.FKind, ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jne PRE_cmd_reg_reg_const
  {$ifdef CPUX86}
    mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
    mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.shrd_cl(const addr: address_x86; reg2: reg_x86);
const
  OPCODE = flag_0f or ($AD{shrd_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shrd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    push [esp]
    or ecx, OPCODE
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [esp+4], offset ZERO_CONST_32
    xchg edx, ecx
  {$else .CPUX64}
    lea rax, [ZERO_CONST_32]
    movzx r8, r8b
    push [rsp]
    or r8d, OPCODE
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [rsp+8], rax
    xchg rdx, r8
  {$endif}
  je cmd_addr_reg_const_value
  jmp PRE_cmd_addr_reg_const
end;
{$endif}

procedure TOpcodeBlock_x86.shrd(const addr: address_x86; reg2: reg_x86; const v_const: const_32);
const
  OPCODE = flag_0f or ($AC{shrd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, v_const{$ifdef OPCODE_MODES},cmd_shrd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea ecx, [ecx + OPCODE]
    xchg edx, ecx
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_addr_reg_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_addr_reg_const
  {$else .CPUX64}
    movzx r8, r8b
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea r8, [r8 + OPCODE]
    xchg rdx, r8
    jne PRE_cmd_addr_reg_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_addr_reg_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_addr_reg_const_value
  {$endif}
end;
{$endif}

// sub
procedure TOpcodeBlock_x86.sub(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C028{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.sub(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($E82C{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.sub(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($28{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.sub(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($28{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.sub(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($2880{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock sub
procedure TOpcodeBlock_x86.lock_sub(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($28{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_sub{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_sub(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_lock or ($2880{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_sub{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// test
procedure TOpcodeBlock_x86.test(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C084{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.test(reg: reg_x86; const v_const: const_32);
const
  OPCODE = flag_extra or ($C0A8{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.test(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($84{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.test(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($84{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.test(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($00F6{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// xadd
procedure TOpcodeBlock_x86.xadd(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = flag_0f or ($C0C0{xadd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_xadd{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.xadd(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_0f or ($C0{xadd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_xadd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// lock xadd
procedure TOpcodeBlock_x86.lock_xadd(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or flag_0f or ($C0{xadd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_xadd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// xchg
procedure TOpcodeBlock_x86.xchg(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C086{xchg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_xchg{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.xchg(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($86{xchg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_xchg{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// lock xchg
procedure TOpcodeBlock_x86.lock_xchg(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($86{xchg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_xchg{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// xor
procedure TOpcodeBlock_x86.xor_(reg: reg_x86; v_reg: reg_x86);
const
  OPCODE = ($C030{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x86.xor_(reg: reg_x86; const v_const: const_32);
const
  OPCODE = ($F034{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x86.xor_(reg: reg_x86; const addr: address_x86);
const
  OPCODE = $0200 or ($30{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.xor_(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = ($30{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.xor_(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = ($3080{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock xor
procedure TOpcodeBlock_x86.lock_xor(const addr: address_x86; v_reg: reg_x86);
const
  OPCODE = flag_lock or ($30{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_xor{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x86.lock_xor(ptr: size_ptr; const addr: address_x86; const v_const: const_32);
const
  OPCODE = flag_lock or ($3080{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_xor{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// FPU � ������
procedure TOpcodeBlock_x86.fbld(const addr: address_x86);
const
  OPCODE = ($20DF{fbld} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fbld{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fbstp(const addr: address_x86);
const
  OPCODE = ($30DF{fbstp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fbstp{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fldcw(const addr: address_x86);
const
  OPCODE = ($28D9{fldcw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fldcw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fldenv(const addr: address_x86);
const
  OPCODE = ($20D9{flden} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fldenv{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fsave(const addr: address_x86);
const
  OPCODE = flag_extra or ($30DD{fsave} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fsave{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fnsave(const addr: address_x86);
const
  OPCODE = ($30DD{fnsave} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnsave{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fstcw(const addr: address_x86);
const
  OPCODE = flag_extra or ($38D9{fstcw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fstcw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fnstcw(const addr: address_x86);
const
  OPCODE = ($38D9{fnstcw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnstcw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fstenv(const addr: address_x86);
const
  OPCODE = flag_extra or ($30D9{fstenv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fstenv{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fnstenv(const addr: address_x86);
const
  OPCODE = ($30D9{fnstenv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnstenv{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fstsw(const addr: address_x86);
const
  OPCODE = flag_extra or ($38DD{fstsw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fstsw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x86.fnstsw(const addr: address_x86);
const
  OPCODE = ($38DD{fnstsw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnstsw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}




{ TOpcodeBlock_x64 }

function TOpcodeBlock_x64.AppendBlock: POpcodeBlock_x64;
const
  BLOCK_SIZE = sizeof(TOpcodeBlock);
{$ifdef PUREPASCAL}
begin
  Result := POpcodeBlock_x64(inherited AppendBlock(BLOCK_SIZE));
end;
{$else}
asm
  mov edx, BLOCK_SIZE
  jmp TOpcodeBlock.AppendBlock
end;
{$endif}

// adc
procedure TOpcodeBlock_x64.adc(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C010{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.adc(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($D014{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.adc(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($10{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.adc(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($10{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.adc(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($1080{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_adc{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock adc
procedure TOpcodeBlock_x64.lock_adc(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($10{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_adc{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.lock_adc(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_lock or ($1080{adc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_adc{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// add
procedure TOpcodeBlock_x64.add(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($C002{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.add(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($C004{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.add(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($00{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.add(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($00{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.add(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($0080{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_add{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock add
procedure TOpcodeBlock_x64.lock_add(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($00{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_add{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.lock_add(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_lock or ($0080{add} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_add{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// and
procedure TOpcodeBlock_x64.and_(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C020{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.and_(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($E024{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.and_(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($20{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.and_(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($20{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.and_(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($2080{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_and{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock and
procedure TOpcodeBlock_x64.lock_and(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($20{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_and{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.lock_and(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_lock or ($2080{and} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_and{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// ���� 4 �����, ���� 8
procedure TOpcodeBlock_x64.bswap(reg: reg_x64_dq);
const
  OPCODE = flag_x64 or ($C80E{bswap} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_bswap{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

// call
procedure TOpcodeBlock_x64.call(block: POpcodeBlock_x64);
{$ifdef PUREPASCAL}
begin
  cmd_jump_block(-2{call}, block);
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}
  mov dl, -2
  jmp cmd_jump_block
end;
{$endif}

procedure TOpcodeBlock_x64.call(blocks: POpcodeSwitchBlock; index: reg_x64_addr; offset: integer=0{$ifdef OPCODE_MODES};buffer: reg_x64_addr=r11{$endif}); 
begin
  raise_not_realized;
end;

procedure TOpcodeBlock_x64.call(reg: reg_x64_addr);
const
  OPCODE = flag_x64 or ($D0FE{call} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_call{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.call(const addr: address_x64);
const
  OPCODE = flag_x64 or ($10FF{call} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_call{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

// cmov
procedure TOpcodeBlock_x64.cmov(cc: intel_cc; reg: reg_x64_wdq; v_reg: reg_x64_wdq);
const
  FLAGS = flag_x64 or flag_extra;
{$ifndef OPCODE_FASTEST}
begin
  setcmov_cc_regs(FLAGS or (ord(cc) shl 8) or byte(reg) or (ord(v_reg) shl 16){$ifdef OPCODE_MODES},cmd_cmov{$endif})
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
     movzx ebp, v_reg
     movzx ecx, cl
     shl ebp, 16
     shl edx, 8
     lea ecx, [ecx + ebp + FLAGS]
     pop ebp
     add edx, ecx
     pop ecx
     mov [esp], ecx
  {$else .CPUX64}
     movzx r9, r9b // v_reg
     movzx r8, r8b
     shl r9, 16
     shl edx, 8
     lea r8, [r8 + r9 + FLAGS]
     add rdx, r8
  {$endif}
  jmp setcmov_cc_regs
end;
{$endif}


procedure TOpcodeBlock_x64.cmov(cc: intel_cc; reg: reg_x64_wdq; const addr: address_x64);
const
  FLAGS = flag_x64 or flag_extra;
{$ifndef OPCODE_FASTEST}
begin
  PRE_setcmov_cc_addr(FLAGS or ord(cc) or (ord(reg) shl 8), addr{$ifdef OPCODE_MODES},cmd_cmov{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
     movzx ecx, cl
     movzx edx, dl
     shl ecx, 8
     mov ebp, addr
     lea edx, [edx + ecx + FLAGS]
     mov ecx, [esp+4] // ret
     add esp, 8
     mov [esp], ecx
     cmp byte ptr [EBP + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     xchg ecx, ebp
     mov ebp, [esp-8]
  {$else .CPUX64}
     movzx r8, r8b
     movzx edx, dl
     shl r8, 8
     cmp byte ptr [R9 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     lea rdx, [rdx + r8 + FLAGS]
     xchg r8, r9
  {$endif}
  je setcmov_cc_addr_value
  jmp PRE_setcmov_cc_addr
end;
{$endif}

// cmp
procedure TOpcodeBlock_x64.cmp(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C038{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.cmp(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($F83C{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.cmp(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($38{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.cmp(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($38{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.cmp(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($3880{cmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_cmp{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// dec
procedure TOpcodeBlock_x64.dec(reg: reg_x64);
const
  OPCODE = flag_x64 or ($C8FE{dec} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_dec{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.dec(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($08FE{dec} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_dec{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// lock dec
procedure TOpcodeBlock_x64.lock_dec(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_lock or ($08FE{dec} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_dec{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// div
procedure TOpcodeBlock_x64.div_(reg: reg_x64);
const
  OPCODE = flag_x64 or ($F0F6{div} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_div{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.div_(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($30F6{div} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_div{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// idiv
procedure TOpcodeBlock_x64.idiv(reg: reg_x64);
const
  OPCODE = flag_x64 or ($F8F6{idiv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_idiv{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.idiv(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($38F6{idiv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_idiv{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// imul
procedure TOpcodeBlock_x64.imul(reg: reg_x64);
const
  OPCODE = flag_x64 or ($E8F6{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.imul(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($28F6{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

procedure TOpcodeBlock_x64.imul(reg: reg_x64_wdq; v_reg: reg_x64_wdq);
const
  OPCODE = flag_x64 or flag_0f or flag_extra or ($C0AE{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.imul(reg: reg_x64_wdq; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_0f or flag_extra or $0200 or ($AE{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.imul(reg: reg_x64_wdq; const v_const: const_32);
begin
  // ������� ������� imul r, imm
  // �������������� � ���� ������� imul r, r, imm
  //
  // � ���� ����� ������� (� ����������) ��� ������
  // �������� cmd_reg_const_value()
  imul(reg, reg, v_const);
end;

procedure TOpcodeBlock_x64.imul(reg1, reg2: reg_x64_wdq; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($69{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_reg_const((ord(reg2) shl 16) or OPCODE or byte(reg1), v_const{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    shl ecx, 16
    cmp [EBP].TOpcodeConst.FKind, ckValue
    lea edx, [edx + ecx + OPCODE]
    mov ecx, [esp+4] // ret
    mov [esp+8], ecx
    xchg ecx, ebp
    mov ebp, [esp]
    lea esp, [esp+8]
  {$else .CPUX64}
    movzx eax, r8b
    xchg r8, r9
    shl eax, 16
    cmp [R8].TOpcodeConst.FKind, ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jne PRE_cmd_reg_reg_const
  {$ifdef CPUX86}
    mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
    mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.imul(reg: reg_x64_wdq; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($69{imul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg), addr, v_const{$ifdef OPCODE_MODES},cmd_imul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_addr_reg_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_addr_reg_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_addr_reg_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_addr_reg_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_addr_reg_const_value
  {$endif}
end;
{$endif}

// inc
procedure TOpcodeBlock_x64.inc(reg: reg_x64);
const
  OPCODE = flag_x64 or ($C0FE{inc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_inc{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.inc(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($00FE{inc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_inc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// lock inc
procedure TOpcodeBlock_x64.lock_inc(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_lock or ($00FE{inc} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_inc{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// jcc
procedure TOpcodeBlock_x64.j(cc: intel_cc; block: POpcodeBlock_x64);
{$ifdef PUREPASCAL}
begin
  cmd_jump_block(shortint(cc), block);
end;
{$else}
asm
  jmp cmd_jump_block
end;
{$endif}

// jmp
procedure TOpcodeBlock_x64.jmp(block: POpcodeBlock_x64);
{$ifdef PUREPASCAL}
begin
  cmd_jump_block(-1{jmp}, block);
end;
{$else}
asm
  {$ifdef CPUX86} 
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}
  or edx, -1
  jmp cmd_jump_block
end;
{$endif}

procedure TOpcodeBlock_x64.jmp(blocks: POpcodeSwitchBlock; index: reg_x64_addr; offset: integer=0{$ifdef OPCODE_MODES};buffer: reg_x64_addr=r11{$endif});
begin
  raise_not_realized;
end;

procedure TOpcodeBlock_x64.jmp(reg: reg_x64_addr);
const
  OPCODE = flag_x64 or ($E0FE{jmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_jmp{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.jmp(const addr: address_x64);
const
  OPCODE = flag_x64 or ($20FF{jmp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_jmp{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

// lea
procedure TOpcodeBlock_x64.lea(reg: reg_x64_addr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($8D{lea} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_lea{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// mov
procedure TOpcodeBlock_x64.mov(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C088{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.mov(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($B000{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.mov(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($88{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.mov(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($88{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.mov(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($00C6{mov} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_mov{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// ��� ���������: reg, const_64
// ���� ����������� ������ ��� mov
// PRE-���������� �������� �� �����
function TOpcodeBlock_x64.cmd_reg_const_value64(const opcode_reg: integer; const v_const: opused_const_64{$ifdef OPCODE_MODES}; const cmd: ShortString{$endif}): POpcodeCmd;
const
  dif_rax_eax = rax-eax;
  dif_r8_r8d = r8-r8d;
  high_dword = int64(high(dword));
var
  REG, X, Y: integer;

  // cmd �������, ���������(%s ��� %d)
  {$ifdef OPCODE_MODES}
  procedure FillAsText();
  var
    buffer: TOpcodeTextBuffer;
  begin
    buffer.Const64(v_const);
    Result := AddCmdText('%s %s, %s', [cmd, reg_intel_names[REG], buffer.value.S]);
  end;
  {$endif}
begin
  REG := byte(opcode_reg);

  // ����������� reg 8 --> 4
  if (REG in [rax..r15]) and
     {$ifdef OPCODE_MODES}
     (P.Proc.Mode = omBinary) and (v_const.Kind = ckValue) and
     ((v_const.Value >= 0) and (v_const.Value <= high_dword)) then
     {$else}
     ((v_const >= 0) and (v_const <= high_dword)) then
     {$endif}
  begin
    if (REG in [r8..r15]) then REG := REG - dif_r8_r8d
    else
    {if (REG in [rax..rdi]) then }REG := REG - dif_rax_eax;
  end;

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    FillAsText();
    exit;
  end;
  {$endif}

  // ����������� ����������� �� cmd_reg_const_value
  X := reg_intel_info[REG];
  Y := opcode_reg or ((X and intel_nonbyte_mask) shl 11);
  X := X and (not intel_nonbyte_mask);
  X := (Y and intel_opcode_mask) or (X and intel_modrm_dest_mask) or byte(X);

  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omHybrid) and (v_const.Kind <> ckValue) then
  begin
    FillAsText();
    // ������ ��������� ������ ��������
    Result.F.HybridSize_MinMax := HybridSize_MinMax(opcode_reg, X, nil);
  end else
  {$endif}
  begin
    Result := AddSmartBinaryCmd(X, {4 ������� �����}{$ifdef OPCODE_MODES}v_const.Value{$else}v_const{$endif});

    if (byte(X){imm_size} = 8) then
    pint64(@POpcodeCmdData(Result).Bytes[Result.Size-sizeof(int64)])^ := {$ifdef OPCODE_MODES}v_const.Value{$else}v_const{$endif};
  end;
end;

procedure TOpcodeBlock_x64.mov(reg: reg_x64{reg_x64_qwords}; const v_const: const_64);
const
  OPCODE = flag_x64 or ($B000{mov} shl 8);
var
  opcode_reg: integer;
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
    // � ��� ����� ����������, �������� �� �� ��� ������� ���� ��������
  {$endif}

  opcode_reg := OPCODE or ord(reg);
  if (v_const.Kind = ckValue) then
  begin
    // ����� �����
    cmd_reg_const_value64(opcode_reg, {$ifdef OPCODE_MODES}v_const,cmd_mov{$else}v_const.Value{$endif});
  end else
  begin
    // ������� �����
    diffcmd_const64(opcode_reg, v_const, cmd_reg_const_value64{$ifdef OPCODE_MODES},cmd_mov{$endif});
  end;
end;

// movsx
procedure TOpcodeBlock_x64.movsx(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE_MAIN = flag_x64 or flag_0f or ($C0BE{movsx} shl 8);
  OPCODE_ALTER = flag_x64 or ($C063{movsxd, �� � ���������� �������� � movsx} shl 8);
{$ifndef OPCODE_FASTEST}
var
  OPCODE: integer;
  {$ifdef OPCODE_MODES}cmd: pshortstring;{$endif}
begin
  {$ifdef OPCODE_MODES}cmd := pshortstring(@cmd_movsx);{$endif}
  OPCODE := OPCODE_MAIN;

  // if (byte(reg_intel_info[byte(reg)]) = 8) and (byte(reg_intel_info[byte(v_reg)]) = 4) then
  if (reg in [rax..r15]) and (v_reg in [eax..r15d]) then
  begin
    {$ifdef OPCODE_MODES}cmd := pshortstring(@cmd_movsxd);{$endif}
    OPCODE := OPCODE_ALTER;
  end;

  movszx_reg_reg(OPCODE or byte(reg), byte(v_reg){$ifdef OPCODE_MODES},cmd^{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
     cmp byte ptr [offset reg_intel_info + edx*4], 8
     movzx ecx, cl
     jne @call_std
     cmp byte ptr [offset reg_intel_info + ecx*4], 4
     jne @call_std
  {$else .CPUX64}
     lea r11, [reg_intel_info]
     movzx eax, r8b
     cmp byte ptr [r11 + rdx*4], 8
     jne @call_std
     cmp byte ptr [r11 + rax*4], 4
     jne @call_std
  {$endif}
  or edx, OPCODE_ALTER
  jmp movszx_reg_reg
@call_std:
  or edx, OPCODE_MAIN
  jmp movszx_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.movsx(reg: reg_x64; ptr: size_ptr; const addr: address_x64);
const
  OPCODE_MAIN = flag_x64 or flag_0f or ($BE{movsx} shl 8);
  OPCODE_ALTER = flag_x64 or ($63{movsxd, �� � ���������� �������� � movsx} shl 8);
  OPCODE_DIF_MAIN_ALTER = OPCODE_MAIN-OPCODE_ALTER;
{$ifndef OPCODE_FASTEST}
var
  reg_opcode_ptr: integer;
  {$ifdef OPCODE_MODES}cmd: pshortstring;{$endif}
begin
  {$ifdef OPCODE_MODES}cmd := pshortstring(@cmd_movsx);{$endif}
  reg_opcode_ptr := OPCODE_MAIN;

  // if (byte(reg_intel_info[byte(reg)]) = 8) and (ptr = dword_ptr) then
  if (reg in [rax..r15]) and (ptr = dword_ptr) then
  begin
    {$ifdef OPCODE_MODES}cmd := pshortstring(@cmd_movsxd);{$endif}
    reg_opcode_ptr := OPCODE_ALTER;
  end;

  // cmd_movsx
  reg_opcode_ptr := reg_opcode_ptr or ord(reg) or (ord(ptr) shl 16);
  PRE_movszx_reg_ptr_addr(reg_opcode_ptr, addr{$ifdef OPCODE_MODES},cmd^{$endif});
end;
{$else}
const
  rax_value = rax;
  dword_ptr_offseted = ord(dword_ptr) shl 16;
asm
  movzx edx, dl
  {$ifdef CPUX86}
     mov ebp, addr
     movzx ecx, cl
     add esp, 8
     sub edx, rax_value
     shl ecx, 16
  {$else .CPUX64}
     movzx eax, r8b
     sub edx, rax_value
     shl eax, 16
  {$endif}
  cmp edx, 15
  {$ifdef CPUX86}
     lea edx, [edx+rax_value]
  {$else .CPUX64}
     lea rdx, [rdx+rax_value]
  {$endif}
  ja @opcode_main
  {$ifdef CPUX86}
     cmp ecx, dword_ptr_offseted
  {$else .CPUX64}
     cmp eax, dword_ptr_offseted
  {$endif}
  jne @opcode_main
@opcode_alter:
  sub edx, OPCODE_DIF_MAIN_ALTER
@opcode_main:
  {$ifdef CPUX86}
     lea edx, [edx + ecx + OPCODE_MAIN]
     mov ecx, [esp-4] // ret
     cmp byte ptr [EBP + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     mov [esp], ecx
     mov ecx, [esp-8]
     xchg ecx, ebp
  {$else .CPUX64}
     cmp byte ptr [r9 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     lea rdx, [rdx + rax + OPCODE_MAIN]
     xchg r8, r9
  {$endif}
  je movszx_reg_ptr_addr_value
  jmp PRE_movszx_reg_ptr_addr
end;
{$endif}


// movzx
procedure TOpcodeBlock_x64.movzx(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE_MAIN = flag_x64 or flag_0f or ($C0B6{movsx} shl 8);
  OPCODE_ALTER = flag_x64 or ($C088{mov} shl 8);
  dif_rax_eax = rax-eax;
  OPCODE_ALTER_DIF = OPCODE_ALTER - dif_rax_eax;
{$ifndef OPCODE_FASTEST}
var
  info_reg, info_vreg: integer;
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ���������
  {$endif}

  info_reg := reg_intel_info[byte(reg)];
  if (byte(info_reg) = 8) then
  begin
    info_vreg := reg_intel_info[byte(v_reg)];

    if (byte(info_vreg) = 4) then
    begin
      cmd_reg_reg(OPCODE_ALTER_DIF+ord(reg), v_reg{$ifdef OPCODE_MODES},cmd_mov{$endif});
      exit;
    end else
    if ((info_reg or info_vreg) and rex_RXB = 0) then
    System.Dec(reg, dif_rax_eax);
  end;

  movszx_reg_reg(OPCODE_MAIN or byte(reg), byte(v_reg){$ifdef OPCODE_MODES},cmd_movzx{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    push ebx
    mov ebx, [offset reg_intel_info + edx*4]
  {$else .CPUX64}
    xchg rbx, r9
    lea r11, [reg_intel_info]
    mov ebx, [r11 + rdx*4]
  {$endif}
  cmp bl, 8
  jne @call_std
    and ebx, $ffffff00
  {$ifdef CPUX86}
    movzx ecx, cl
    or ebx, [offset reg_intel_info + ecx*4]
  {$else .CPUX64}
    movzx eax, r8b
    or ebx, [r11 + rax*4]
  {$endif}
  cmp bl, 4
  jne @call_std_check_correcttion

  add edx, OPCODE_ALTER_DIF
  {$ifdef CPUX86}
    pop ebx
  {$else .CPUX64}
    xchg rbx, r9
  {$endif}
  jmp cmd_reg_reg
@call_std_check_correcttion:
  test ebx, rex_RXB
  {$ifdef CPUX86}
    lea ebx, [edx - dif_rax_eax]
  {$else .CPUX64}
    lea rbx, [rdx - dif_rax_eax]
  {$endif}
  cmovz edx, ebx
@call_std:
  or edx, OPCODE_MAIN
  {$ifdef CPUX86}
    pop ebx
  {$else .CPUX64}
    xchg rbx, r9
  {$endif}
  jmp movszx_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.movzx(reg: reg_x64; ptr: size_ptr; const addr: address_x64);
const
  OPCODE_MAIN = flag_x64 or flag_0f or ($B6{movsx} shl 8);
  OPCODE_ALTER = flag_x64 or $0200 or ($88{mov} shl 8);
  dif_rax_eax = rax-eax;
  OPCODE_ALTER_DIF = OPCODE_ALTER - dif_rax_eax;
{$ifndef OPCODE_FASTEST}
var
  info_reg, reg_opcode_ptr: integer;
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}

  info_reg := reg_intel_info[byte(reg)];
  if (byte(info_reg) = 8) then
  begin
    if (ptr = dword_ptr) then
    begin
      // mov
      reg_opcode_ptr := OPCODE_ALTER_DIF + ord(reg);
      PRE_cmd_reg_addr(reg_opcode_ptr, addr{$ifdef OPCODE_MODES},cmd_mov{$endif});
      exit;
    end else
    if (info_reg and rex_RXB = 0) then
    System.Dec(reg, dif_rax_eax);
  end;

  // movzx
  reg_opcode_ptr := OPCODE_MAIN or ord(reg) or (ord(ptr) shl 16);
  PRE_movszx_reg_ptr_addr(reg_opcode_ptr, addr{$ifdef OPCODE_MODES},cmd_movzx{$endif});
end;
{$else}
const
  rax_value = rax;
  dword_ptr_offseted = ord(dword_ptr) shl 16;
asm
  movzx edx, dl
  {$ifdef CPUX86}
     mov ebp, addr
     movzx ecx, cl
     add esp, 8
     sub edx, rax_value
     shl ecx, 16
  {$else .CPUX64}
     movzx eax, r8b
     sub edx, rax_value
     shl eax, 16
     lea r10, [reg_intel_info]
  {$endif}
  cmp edx, 15
  {$ifdef CPUX86}
     lea edx, [edx+rax_value]
  {$else .CPUX64}
     lea rdx, [rdx+rax_value]
  {$endif}
  ja @call_main
  {$ifdef CPUX86}
     cmp ecx, dword_ptr_offseted
  {$else .CPUX64}
     cmp eax, dword_ptr_offseted
  {$endif}
  jne @call_main_try_correction
@call_mov:
  {$ifdef CPUX86}
     mov ecx, [esp-4] // ret
     cmp byte ptr [EBP + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     mov [esp], ecx
     mov ecx, [esp-8]
     lea edx, [edx + OPCODE_ALTER_DIF]
     xchg ecx, ebp
  {$else .CPUX64}
     cmp byte ptr [r9 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     lea rdx, [rdx + OPCODE_ALTER_DIF]
     xchg r8, r9
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
@call_main_try_correction:
  {$ifdef CPUX86}
     test [offset reg_intel_info + edx*4], rex_RXB
  {$else .CPUX64}
     test [r10 + rdx*4], rex_RXB
  {$endif}
  jnz @call_main
  sub edx, dif_rax_eax
@call_main:
  {$ifdef CPUX86}
     lea edx, [edx + ecx + OPCODE_MAIN]
     mov ecx, [esp-4] // ret
     cmp byte ptr [EBP + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     mov [esp], ecx
     mov ecx, [esp-8]
     xchg ecx, ebp
  {$else .CPUX64}
     cmp byte ptr [r9 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     lea rdx, [rdx + rax + OPCODE_MAIN]
     xchg r8, r9
  {$endif}
  je movszx_reg_ptr_addr_value
  jmp PRE_movszx_reg_ptr_addr
end;
{$endif}



// mul
procedure TOpcodeBlock_x64.mul(reg: reg_x64);
const
  OPCODE = flag_x64 or ($E0F6{mul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_mul{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.mul(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($20F6{mul} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_mul{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// neg
procedure TOpcodeBlock_x64.neg(reg: reg_x64);
const
  OPCODE = flag_x64 or ($D8F6{neg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_neg{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.neg(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($18F6{neg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_neg{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// lock neg
procedure TOpcodeBlock_x64.lock_neg(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_lock or ($18F6{neg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_neg{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// not
procedure TOpcodeBlock_x64.not_(reg: reg_x64);
const
  OPCODE = flag_x64 or ($D0F6{not} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_not{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.not_(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or ($10F6{not} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_not{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// lock not
procedure TOpcodeBlock_x64.lock_not(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_lock or ($10F6{not} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_lock_not{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// or
procedure TOpcodeBlock_x64.or_(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C008{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.or_(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($C80C{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.or_(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($08{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.or_(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($08{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.or_(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($0880{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_or{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock or
procedure TOpcodeBlock_x64.lock_or(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($08{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_or{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.lock_or(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_lock or ($0880{or} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_or{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// pop
procedure TOpcodeBlock_x64.pop(reg: reg_x64_wq);
const
  OPCODE = flag_x64 or ($5800{pop} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_pop{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.pop(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($008F{pop} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_pop{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// push
procedure TOpcodeBlock_x64.push(reg: reg_x64_wq);
const
  OPCODE = flag_x64 or ($5000{push} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg(OPCODE or byte(reg){$ifdef OPCODE_MODES},cmd_push{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg
end;
{$endif}

procedure TOpcodeBlock_x64.push(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($30FF{push} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr(OPCODE or byte(ptr), addr{$ifdef OPCODE_MODES},cmd_push{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86} 
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_ptr_addr_value
  jmp PRE_cmd_ptr_addr
end;
{$endif}

// rcl
procedure TOpcodeBlock_x64.rcl_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($D0D2{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_rcl{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.rcl(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($D0C0{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_rcl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.rcl_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($10D2{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_rcl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.rcl(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($10C0{rcl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_rcl{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// rcr
procedure TOpcodeBlock_x64.rcr_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($D8D2{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_rcr{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.rcr(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($D8C0{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_rcr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.rcr_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($18D2{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_rcr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.rcr(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($18C0{rcr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_rcr{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// rol
procedure TOpcodeBlock_x64.rol_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($C0D2{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_rol{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.rol(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($C0C0{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_rol{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.rol_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($00D2{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_rol{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.rol(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($00C0{rol} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_rol{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// ror
procedure TOpcodeBlock_x64.ror_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($C8D2{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_ror{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.ror(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($C8C0{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_ror{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.ror_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($08D2{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_ror{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.ror(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($08C0{ror} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_ror{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// sal
procedure TOpcodeBlock_x64.sal_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($E0D2{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_sal{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.sal(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($E0C0{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sal{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.sal_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($20D2{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_sal{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.sal(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($20C0{sal} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sal{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// sar
procedure TOpcodeBlock_x64.sar_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($F8D2{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_sar{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.sar(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($F8C0{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sar{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.sar_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($38D2{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_sar{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.sar(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($38C0{sar} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sar{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// sbb
procedure TOpcodeBlock_x64.sbb(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C018{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.sbb(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($D81C{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.sbb(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($18{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.sbb(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($18{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.sbb(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($1880{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sbb{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock sbb
procedure TOpcodeBlock_x64.lock_sbb(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($18{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_sbb{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.lock_sbb(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_lock or ($1880{sbb} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_sbb{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// setcc
procedure TOpcodeBlock_x64.set_(cc: intel_cc; reg: reg_x64_bytes);
const
  FLAGS = flag_x64;
{$ifndef OPCODE_FASTEST}
begin
  setcmov_cc_regs(FLAGS or (ord(cc) shl 8) or byte(reg){$ifdef OPCODE_MODES},cmd_set{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
     movzx ecx, cl
     shl edx, 8
     lea edx, [edx + ecx + FLAGS]
  {$else .CPUX64}
     movzx r8, r8b
     shl edx, 8
     lea rdx, [rdx + r8 + FLAGS]
  {$endif}
  jmp setcmov_cc_regs
end;
{$endif}

procedure TOpcodeBlock_x64.set_(cc: intel_cc; const addr: address_x64);
const
  FLAGS = flag_x64;
{$ifndef OPCODE_FASTEST}
begin
  PRE_setcmov_cc_addr(FLAGS or ord(cc), addr{$ifdef OPCODE_MODES},cmd_set{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
     cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     lea edx, [edx + FLAGS]
  {$else .CPUX64}
     cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
     lea rdx, [rdx + FLAGS]
  {$endif}
  je setcmov_cc_addr_value
  jmp PRE_setcmov_cc_addr
end;
{$endif}

// shl
procedure TOpcodeBlock_x64.shl_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($E0D2{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shl{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shl_(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($E0C0{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_shl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shl_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($20D2{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shl{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.shl_(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($20C0{shl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_shl{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// shr
procedure TOpcodeBlock_x64.shr_cl(reg: reg_x64);
const
  OPCODE = flag_x64 or flag_extra or ($E8D2{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ��������
  {$endif}
  shift_reg_const_value(OPCODE or byte(reg), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shr{$else}0{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shr_(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($E8C0{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_shift_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_shr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_shift_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp shift_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shr_cl(ptr: size_ptr; const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($28D2{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shr{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  push [esp]
  lea edx, [edx + OPCODE]
  mov [esp+4], offset ZERO_CONST_32
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  mov r9, offset ZERO_CONST_32
  {$endif}
  je cmd_ptr_addr_const_value
  jmp PRE_cmd_ptr_addr_const
end;
{$endif}

procedure TOpcodeBlock_x64.shr_(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($28C0{shr} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_shr{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// shld
procedure TOpcodeBlock_x64.shld_cl(reg1, reg2: reg_x64);
const
  OPCODE = flag_x64 or flag_0f or ($A5{shld_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ���������
  {$endif}
  cmd_reg_reg_const_value((ord(reg2) shl 16) or OPCODE or byte(reg1), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shld{$else}0{$endif});
end;
{$else}    
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    movzx edx, dl
    shl ecx, 16
    lea edx, [edx + ecx + OPCODE]
  {$else .CPUX64}
    movzx eax, r8b
    movzx edx, dl
    shl eax, 16
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shld(reg1, reg2: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_0f or ($A4{shld} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_reg_const((ord(reg2) shl 16) or OPCODE or byte(reg1), v_const{$ifdef OPCODE_MODES},cmd_shld{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    shl ecx, 16
    cmp [EBP].TOpcodeConst.FKind, ckValue
    lea edx, [edx + ecx + OPCODE]
    mov ecx, [esp+4] // ret
    mov [esp+8], ecx
    xchg ecx, ebp
    mov ebp, [esp]
    lea esp, [esp+8]
  {$else .CPUX64}
    movzx eax, r8b
    xchg r8, r9
    shl eax, 16
    cmp [R8].TOpcodeConst.FKind, ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jne PRE_cmd_reg_reg_const
  {$ifdef CPUX86}
    mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
    mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shld_cl(const addr: address_x64; reg2: reg_x64);
const
  OPCODE = flag_x64 or flag_0f or ($A5{shld_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shld{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    push [esp]
    or ecx, OPCODE
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [esp+4], offset ZERO_CONST_32
    xchg edx, ecx
  {$else .CPUX64}
    lea rax, [ZERO_CONST_32]
    movzx r8, r8b
    push [rsp]
    or r8d, OPCODE
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [rsp+8], rax
    xchg rdx, r8
  {$endif}
  je cmd_addr_reg_const_value
  jmp PRE_cmd_addr_reg_const
end;
{$endif}

procedure TOpcodeBlock_x64.shld(const addr: address_x64; reg2: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_0f or ($A4{shld} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, v_const{$ifdef OPCODE_MODES},cmd_shld{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea ecx, [ecx + OPCODE]
    xchg edx, ecx
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_addr_reg_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_addr_reg_const
  {$else .CPUX64}
    movzx r8, r8b
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea r8, [r8 + OPCODE]
    xchg rdx, r8
    jne PRE_cmd_addr_reg_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_addr_reg_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_addr_reg_const_value
  {$endif}
end;
{$endif}

// shrd
procedure TOpcodeBlock_x64.shrd_cl(reg1, reg2: reg_x64);
const
  OPCODE = flag_x64 or flag_0f or ($AD{shrd_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  {$ifdef OPCODE_TEST}
    // todo �������� ���������
  {$endif}
  cmd_reg_reg_const_value((ord(reg2) shl 16) or OPCODE or byte(reg1), {$ifdef OPCODE_MODES}ZERO_CONST_32,cmd_shrd{$else}0{$endif});
end;
{$else}    
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    movzx edx, dl
    shl ecx, 16
    lea edx, [edx + ecx + OPCODE]
  {$else .CPUX64}
    movzx eax, r8b
    movzx edx, dl
    shl eax, 16
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shrd(reg1, reg2: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_0f or ($AC{shrd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_reg_const((ord(reg2) shl 16) or OPCODE or byte(reg1), v_const{$ifdef OPCODE_MODES},cmd_shrd{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    shl ecx, 16
    cmp [EBP].TOpcodeConst.FKind, ckValue
    lea edx, [edx + ecx + OPCODE]
    mov ecx, [esp+4] // ret
    mov [esp+8], ecx
    xchg ecx, ebp
    mov ebp, [esp]
    lea esp, [esp+8]
  {$else .CPUX64}
    movzx eax, r8b
    xchg r8, r9
    shl eax, 16
    cmp [R8].TOpcodeConst.FKind, ckValue
    lea rdx, [rdx + rax + OPCODE]
  {$endif}
  jne PRE_cmd_reg_reg_const
  {$ifdef CPUX86}
    mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
    mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.shrd_cl(const addr: address_x64; reg2: reg_x64);
const
  OPCODE = flag_x64 or flag_0f or ($AD{shrd_cl} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, ZERO_CONST_32{$ifdef OPCODE_MODES},cmd_shrd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    push [esp]
    or ecx, OPCODE
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [esp+4], offset ZERO_CONST_32
    xchg edx, ecx
  {$else .CPUX64}
    lea rax, [ZERO_CONST_32]
    movzx r8, r8b
    push [rsp]
    or r8d, OPCODE
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    mov [rsp+8], rax
    xchg rdx, r8
  {$endif}
  je cmd_addr_reg_const_value
  jmp PRE_cmd_addr_reg_const
end;
{$endif}

procedure TOpcodeBlock_x64.shrd(const addr: address_x64; reg2: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_0f or ($AC{shrd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr_reg_const(OPCODE or byte(reg2), addr, v_const{$ifdef OPCODE_MODES},cmd_shrd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    movzx ecx, cl
    mov ebp, [esp+8] // v_const
    cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea ecx, [ecx + OPCODE]
    xchg edx, ecx
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_addr_reg_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_addr_reg_const
  {$else .CPUX64}
    movzx r8, r8b
    cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea r8, [r8 + OPCODE]
    xchg rdx, r8
    jne PRE_cmd_addr_reg_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_addr_reg_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_addr_reg_const_value
  {$endif}
end;
{$endif}

// sub
procedure TOpcodeBlock_x64.sub(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C028{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.sub(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($E82C{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.sub(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($28{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.sub(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($28{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.sub(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($2880{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_sub{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock sub
procedure TOpcodeBlock_x64.lock_sub(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($28{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_sub{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.lock_sub(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_lock or ($2880{sub} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_sub{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// test
procedure TOpcodeBlock_x64.test(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C084{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.test(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_extra or ($C0A8{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.test(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($84{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.test(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($84{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.test(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($00F6{test} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_test{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// xadd
procedure TOpcodeBlock_x64.xadd(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_0f or ($C0C0{xadd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_xadd{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.xadd(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_0f or ($C0{xadd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_xadd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// lock xadd
procedure TOpcodeBlock_x64.lock_xadd(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or flag_0f or ($C0{xadd} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_xadd{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// xchg
procedure TOpcodeBlock_x64.xchg(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C086{xchg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_xchg{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.xchg(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($86{xchg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_xchg{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// lock xchg
procedure TOpcodeBlock_x64.lock_xchg(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($86{xchg} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_xchg{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

// xor
procedure TOpcodeBlock_x64.xor_(reg: reg_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($C030{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  cmd_reg_reg(OPCODE or byte(reg), v_reg{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  movzx edx, dl
  or edx, OPCODE
  jmp cmd_reg_reg
end;
{$endif}

procedure TOpcodeBlock_x64.xor_(reg: reg_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($F034{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_const(OPCODE or byte(reg), v_const{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp [ECX].TOpcodeConst.FKind, ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp [R8].TOpcodeConst.FKind, ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  jne PRE_cmd_reg_const

  {$ifdef CPUX86}
  mov ecx, [ECX].TOpcodeConst.F.Value
  {$else .CPUX64}
  mov r8d, [R8].TOpcodeConst.F.Value
  {$endif}
  jmp cmd_reg_const_value
end;
{$endif}

procedure TOpcodeBlock_x64.xor_(reg: reg_x64; const addr: address_x64);
const
  OPCODE = flag_x64 or $0200 or ($30{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(reg), addr{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.xor_(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or ($30{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.xor_(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or ($3080{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_xor{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

// lock xor
procedure TOpcodeBlock_x64.lock_xor(const addr: address_x64; v_reg: reg_x64);
const
  OPCODE = flag_x64 or flag_lock or ($30{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_reg_addr(OPCODE or byte(v_reg), addr{$ifdef OPCODE_MODES},cmd_lock_xor{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
    xchg edx, ecx
  {$else .CPUX64}
    xchg rdx, r8
  {$endif}

  movzx edx, dl
  {$ifdef CPUX86}
  cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea edx, [edx + OPCODE]
  {$else .CPUX64}
  cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  lea rdx, [rdx + OPCODE]
  {$endif}
  je cmd_reg_addr_value
  jmp PRE_cmd_reg_addr
end;
{$endif}

procedure TOpcodeBlock_x64.lock_xor(ptr: size_ptr; const addr: address_x64; const v_const: const_32);
const
  OPCODE = flag_x64 or flag_lock or ($3080{xor} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_ptr_addr_const(OPCODE or byte(ptr), addr, v_const{$ifdef OPCODE_MODES},cmd_lock_xor{$endif});
end;
{$else}    
asm
  movzx edx, dl
  {$ifdef CPUX86}
    mov ebp, [esp+8] // v_const
    cmp byte ptr [ECX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea edx, [edx + OPCODE]
    jne @call_std
    cmp [EBP].TOpcodeConst.FKind, ckValue
    mov ebp, [EBP].TOpcodeConst.F.Value
    jne @call_std
    mov [esp+8], ebp // value
    pop ebp
    jmp cmd_ptr_addr_const_value
    @call_std:
    pop ebp
    jmp PRE_cmd_ptr_addr_const
  {$else .CPUX64}
    cmp byte ptr [R8 + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
    lea rdx, [rdx + OPCODE]
    jne PRE_cmd_ptr_addr_const
    cmp [R9].TOpcodeConst.FKind, ckValue
    jne PRE_cmd_ptr_addr_const
    mov r9d, [R9].TOpcodeConst.F.Value
    jmp cmd_ptr_addr_const_value
  {$endif}
end;
{$endif}

procedure TOpcodeBlock_x64.cmpsq(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A748{cmpsq};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_cmpsq{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_x64.insq(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $6D48{insq};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_insq{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_x64.scasq(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AF48{scasq};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_scasq{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_x64.stosq(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AB48{stosq};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_stosq{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_x64.lodsq(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $AD48{lodsq};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_lodsq{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

procedure TOpcodeBlock_x64.movsq(reps: intel_rep=REP_SINGLE);
const
  OPCODE = $A548{movsq};
{$ifndef OPCODE_FASTEST}
begin
  cmd_rep_bwdq(reps, OPCODE{$ifdef OPCODE_MODES}, cmd_movsq{$endif});
end;
{$else}
asm
  {$ifdef CPUX86}
  mov ecx, OPCODE
  {$else .CPUX64}
  mov r8d, OPCODE
  {$endif}
  jmp cmd_rep_bwdq
end;
{$endif}

// FPU � ������
procedure TOpcodeBlock_x64.fbld(const addr: address_x64);
const
  OPCODE = flag_x64 or ($20DF{fbld} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fbld{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fbstp(const addr: address_x64);
const
  OPCODE = flag_x64 or ($30DF{fbstp} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fbstp{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fldcw(const addr: address_x64);
const
  OPCODE = flag_x64 or ($28D9{fldcw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fldcw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fldenv(const addr: address_x64);
const
  OPCODE = flag_x64 or ($20D9{flden} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fldenv{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fsave(const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($30DD{fsave} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fsave{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fnsave(const addr: address_x64);
const
  OPCODE = flag_x64 or ($30DD{fnsave} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnsave{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fstcw(const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($38D9{fstcw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fstcw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fnstcw(const addr: address_x64);
const
  OPCODE = flag_x64 or ($38D9{fnstcw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnstcw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fstenv(const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($30D9{fstenv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fstenv{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fnstenv(const addr: address_x64);
const
  OPCODE = flag_x64 or ($30D9{fnstenv} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnstenv{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fstsw(const addr: address_x64);
const
  OPCODE = flag_x64 or flag_extra or ($38DD{fstsw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fstsw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}

procedure TOpcodeBlock_x64.fnstsw(const addr: address_x64);
const
  OPCODE = flag_x64 or ($38DD{fnstsw} shl 8);
{$ifndef OPCODE_FASTEST}
begin
  PRE_cmd_addr(OPCODE, addr{$ifdef OPCODE_MODES},cmd_fnstsw{$endif})
end;
{$else}
asm
  {$ifdef CPUX86}
  cmp byte ptr [EDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov ecx, OPCODE
  xchg edx, ecx
  {$else .CPUX64}
  cmp byte ptr [RDX + TOpcodeAddress_offset + TOpcodeConst.FKind], ckValue
  mov r8d, OPCODE
  xchg rdx, r8
  {$endif}
  je cmd_addr_value
  jmp PRE_cmd_addr
end;
{$endif}




{ TOpcodeBlock_ARM }

const
  arm_cc_to_intel: array[arm_cc] of intel_cc = (_e{eq}, _ne{ne}, _nc{cs}, _ae{hs=cs},
                   _c{cc}, _b{lo=cc}, _s{mi}, _ns{pl}, _o{vs}, _no{vc}, _a{hi},
                   _be{ls}, _ge{ge}, _l{lt}, _g{gt}, _le{le});


function TOpcodeBlock_ARM.AppendBlock: POpcodeBlock_ARM;
const
  BLOCK_SIZE = sizeof(TOpcodeBlock);
{$ifdef PUREPASCAL}
begin
  Result := POpcodeBlock_ARM(inherited AppendBlock(BLOCK_SIZE));
end;
{$else}
asm
  mov edx, BLOCK_SIZE
  jmp TOpcodeBlock.AppendBlock
end;
{$endif}

procedure TOpcodeBlock_ARM.b{jmp}(block: POpcodeBlock_ARM);
begin
  cmd_jump_block(-1{jmp}, block);
end;

procedure TOpcodeBlock_ARM.b{jcc}(cc: arm_cc; block: POpcodeBlock_ARM);
begin
  {$ifdef OPCODE_TEST}if (ord(cc) > ord(high(arm_cc))) then raise_parameter;{$endif}
  cmd_jump_block(shortint(arm_cc_to_intel[cc]), block);
end;

procedure TOpcodeBlock_ARM.bl{call}(block: POpcodeBlock_ARM);
begin
  cmd_jump_block(-2{call}, block);
end;

{$ifdef OPCODE_MODES}
procedure TOpcodeBlock_ARM.b{jmp}(ProcName: pansichar);
begin
  cmd_textjump_proc(-1{jmp}, ProcName);
end;

procedure TOpcodeBlock_ARM.b{jcc}(cc: arm_cc; ProcName: pansichar);
begin
  {$ifdef OPCODE_TEST}if (ord(cc) > ord(high(arm_cc))) then raise_parameter;{$endif}
  cmd_textjump_proc(shortint(arm_cc_to_intel[cc]), ProcName);
end;

procedure TOpcodeBlock_ARM.bl{call}(ProcName: pansichar);
begin
  cmd_textjump_proc(-2{call}, ProcName);
end;
{$endif}


{ TOpcodeBlock_VM }

function TOpcodeBlock_VM.AppendBlock: POpcodeBlock_VM;
const
  BLOCK_SIZE = sizeof(TOpcodeBlock);
{$ifdef PUREPASCAL}
begin
  Result := POpcodeBlock_VM(inherited AppendBlock(BLOCK_SIZE));
end;
{$else}
asm
  mov edx, BLOCK_SIZE
  jmp TOpcodeBlock.AppendBlock
end;
{$endif}



{ TOpcodeProc_Intel }

// ������������� �������, ������� ������������ ��� ���������� ����� ��� ��������: ret(n)
// ��������, ����������� � ������������� ������� ���������� �������
(*
procedure TOpcodeBlock_Intel.ret(const count: word=0);
var
  Result: POpcodeCmd;
begin
  {$ifdef OPCODE_MODES}
  if (P.Proc.Mode = omAssembler) then
  begin
    if (count = 0) then Result := AddCmdText(PShortString(@cmd_ret))
    else Result := AddCmdText('ret %d', [count]);

    Result.F.Param := 128{�����}+0{ret(n)};
  end else
  {$endif}
  begin
    // cmLeave ������� �� ������ ����������� � ������� ��������� ��������� (����� ����� ������ ������)
    P.Proc.FLastBinaryCmd := nil;

    // ���������
    if (count = 0) then Result := AddSmartBinaryCmd($00c30000, 0)
    else Result := AddSmartBinaryCmd($00c20002, count);

    // Result.F.Param := 0{��������}+0{ret(n)};
  end;

  // ���������, ��� ������� cmLeave
  Result.F.Mode := cmLeave;
end;
*)
procedure TOpcodeProc_Intel_FillLastRetCmd(var Storage: TFixupedStorage; const count: word);
{$ifdef OPCODE_MODES}
const
  RET_FMT: array[0..5] of ansichar = 'ret %d';
{$endif}
begin
  {$ifdef OPCODE_MODES}
  if (Storage.Proc.Mode = omAssembler) then
  begin
    if (count = 0) then
    begin
      // Storage.LastRetCmd.Str := @cmd_ret;
      Storage.LastRetCmd.Str := PShortString(@cmd_ret);
    end else
    begin
      // Storage.LastRetCmd.Str := Format('ret %d', [count]);
      pbyte(@Storage.LastRetCmd.Chars)^ := SysUtils.FormatBuf(Storage.LastRetCmd.Chars[1], sizeof(Storage.LastRetCmd.Chars)-sizeof(byte),
                               RET_FMT, Length(RET_FMT), [count]);
      Storage.LastRetCmd.Str := PShortString(@Storage.LastRetCmd.Chars);
    end;

    Storage.LastRetCmd.Cmd.F.ModeParam := ord(cmLeave) + ((128{�����}+0{ret(n)}) shl 8);
  end else
  {$endif}
  begin
    if (count = 0) then
    begin
      Storage.LastRetCmd.c3 := $c3;
      Storage.LastRetCmd.Cmd.F.Size := 1;
    end else
    begin
      Storage.LastRetCmd.c2 := $c2;
      Storage.LastRetCmd.i16 := count;
      Storage.LastRetCmd.Cmd.F.Size := 3;
    end;

    Storage.LastRetCmd.Cmd.F.ModeParam := ord(cmLeave) + ((0{��������}+0{ret(n)}) shl 8);
  end;
end;

// �������, ������� ���������� ��� ���������� x86 � x64 (�� ������� TOpcodeProc_Intel)
// ������ ������� - ��������� �������� ������ ��� ��������� �������� � ��� �������
procedure IntelRealizeBinaryJumps(var Storage: TFixupedStorage);
const
  SMALL_JMP = $EB;
  SMALL_JCC = $70;

  BIG_CALL = $E8;
  BIG_JMP = $E9;
  BIG_JCC = $800F;        
var
  Block: PFixupedBlock;
  i: integer;
  Offset: integer;
begin
  Block := pointer(Storage.Blocks);
  for i := 0 to Storage.BlocksCount-1 do
  begin
    case Block.Kind of
  fkGlobalJumpBlock: {$ifdef OPCODE_MODES}if (Storage.Mode = omBinary) then{$endif}
                     begin
                       // ��������
                       pword(@Block.JumpBuffer)^ := 0;
                       pinteger(@Block.JumpBuffer[2])^ := 0;

                       // �����������
                       case Block.cc_ex of
                      -2{call}: begin
                                  Block.JumpBuffer[0] := BIG_CALL;
                                end;
                       -1{jmp}: begin
                                  Block.JumpBuffer[0] := BIG_JMP;
                                end;
                       else
                         {jcc}
                         pword(@Block.JumpBuffer)^ := BIG_JCC;
                       end;
                     end;
   fkLocalJumpBlock: begin
                       if (Block.Size = SMALL_JUMP_SIZE) then
                       begin
                         // ����� ������
                         // ������� ��������
                         Block.JumpBuffer[1] := Block.JumpOffset - SMALL_JUMP_SIZE;

                         // ����� ������� ������ �������� ����
                         if (Block.cc_ex = -1{jmp}) then Block.JumpBuffer[0] := SMALL_JMP
                         else Block.JumpBuffer[0] := SMALL_JCC + cc_intel_info[intel_cc(Block.cc_ex)];
                       end else
                       begin
                         // ������� ������
                         Offset := Block.JumpOffset - SMALL_JUMP_SIZE;
                         case Block.cc_ex of
                        -2{call}: begin
                                    Block.JumpBuffer[0] := BIG_CALL;
                                    pinteger(@Block.JumpBuffer[1])^ := Offset;
                                  end;
                         -1{jmp}: begin
                                    Block.JumpBuffer[0] := BIG_JMP;
                                    pinteger(@Block.JumpBuffer[1])^ := Offset;
                                  end;
                         else
                           {jcc}
                           pword(@Block.JumpBuffer)^ := BIG_JCC + ord(cc_intel_info[intel_cc(Block.cc_ex)]) shl 8;
                           pinteger(@Block.JumpBuffer[2])^ := Offset;
                         end;
                       end;
                     end;
           fkInline: begin
                       // � �������(� �������� � ��������) ��� ������������������ ��������
                       // ���� ��������� �������� ������ (����� ��� ���� � �����)
                       if (Block.cc_ex >= 0) then
                       begin
                         pword(@Block.InlineBlocks[Block.InlineBlocksCount])^ :=
                               SMALL_JCC + (ord(cc_intel_info[intel_cc(Block.cc_ex)]) shl 8);
                       end;
                     end;
    end;

    inc(Block);
  end;
end;

procedure TOpcodeProc_Intel_Callback(const Mode: integer; var Storage: TFixupedStorage);
var
  i: integer;
begin
  case Mode of
    0: // ��������� �������������� ������� �� ������� JumpsInfo
       with Storage.JumpsInfo do
       begin
         FillChar(small_sizes, sizeof(small_sizes), {#2}SMALL_JUMP_SIZE);
         small_sizes[-2{call}] := 5;
         FillChar(big_sizes, sizeof(big_sizes), #6);
         big_sizes[-2{call}] := 5;
         big_sizes[-1{jmp}] := 5;
         for i := 0 to ord(high(intel_cc)) do
         begin
           // jcc
           low_ranges[i] := -126;
           high_ranges[i] := 131;
         end;
         low_ranges[-1{jmp}] := -126;
         high_ranges[-1{jmp}] := 130;
         low_ranges[-2{call}] := 0;
         high_ranges[-2{call}] := 0;

        {$ifdef OPCODE_MODES}
           names := pointer(@cc_intel_names);
        {$endif}
       end;
    1: begin
         // ��������� ��������� LastRetCmd
         TOpcodeProc_Intel_FillLastRetCmd(Storage, Storage.Proc.RetN);
       end;
    2: begin
         // �������� ���������� �������
         IntelRealizeBinaryJumps(Storage);
       end;
  end;
end;

constructor TOpcodeProc_Intel.Create(const AHeap: TOpcodeHeap=nil{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode=omBinary{$endif});
begin
  inherited;
  @FCallback := @TOpcodeProc_Intel_Callback;
end;

{ TOpcodeProc_ARM }

procedure TOpcodeProc_ARM_Callback(const Mode: integer; var Storage: TFixupedStorage);
begin
  case Mode of
    0: begin
         // ��������� �������������� ������� �� ������� JumpsInfo
         // todo
       end;
    1: begin
         // ��������� ��������� LastRetCmd
         // todo
       end;
    2: begin
         // �������� ���������� �������
         // todo
       end;
  end;
end;

constructor TOpcodeProc_ARM.Create(const AHeap: TOpcodeHeap=nil{$ifdef OPCODE_MODES}; const AMode: TOpcodeMode=omBinary{$endif});
begin
  inherited;
  @FCallback := @TOpcodeProc_ARM_Callback;
end;


{ TOpcodeProc_VM }

procedure TOpcodeProc_VM_Callback(const Mode: integer; var Storage: TFixupedStorage);
begin
  case Mode of
    0: begin
         // ��������� �������������� ������� �� ������� JumpsInfo
         // todo
       end;
    1: begin
         // ��������� ��������� LastRetCmd
         // todo
       end;
    2: begin
         // �������� ���������� �������
         // todo
       end;
  end;
end;

constructor TOpcodeProc_VM.Create(const AHeap: TOpcodeHeap{$ifdef OPCODE_MODES};const AMode: TOpcodeMode{$endif});
begin
  inherited;
  @FCallback := @TOpcodeProc_VM_Callback;
end;

{ TOpcodeStorage_x86 }

{$ifdef CPUX86}
constructor TOpcodeStorage_x86.CreateJIT(const AHeap: TOpcodeHeap);
begin
  FJIT := true;
  Create(AHeap {������ Binary});
end;
{$endif}

function TOpcodeStorage_x86.CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_x86;
begin
  Result := TOpcodeProc_x86(InternalCreateProc(TOpcodeProc_x86, @TOpcodeProc_Intel_Callback, AOwnHeap));
end;


{ TOpcodeStorage_x64 }

{$ifdef CPUX64}
constructor TOpcodeStorage_x64.CreateJIT(const AHeap: TOpcodeHeap);
begin
  FJIT := true;
  Create(AHeap {������ Binary});
end;
{$endif}

function TOpcodeStorage_x64.CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_x64;
begin
  Result := TOpcodeProc_x64(InternalCreateProc(TOpcodeProc_x64, @TOpcodeProc_Intel_Callback, AOwnHeap));
end;


{ TOpcodeStorage_ARM }

function TOpcodeStorage_ARM.CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_ARM;
begin
  Result := TOpcodeProc_ARM(InternalCreateProc(TOpcodeProc_ARM, @TOpcodeProc_ARM_Callback, AOwnHeap));
end;

{ TOpcodeStorage_VM }

function TOpcodeStorage_VM.CreateProc(const AOwnHeap: boolean=false): TOpcodeProc_VM;
begin
  Result := TOpcodeProc_VM(InternalCreateProc(TOpcodeProc_VM, @TOpcodeProc_VM_Callback, AOwnHeap));
end;


end.
