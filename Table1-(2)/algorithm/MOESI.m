--Murphi.ModularMurphi.GenConst

const
  ENABLE_QS: true;  VAL_COUNT: 1;
  ADR_COUNT: 2;

  O_NET_MAX: 6;
  U_NET_MAX: 6;
  O_NET_MAX_fwd: 18;
  
  NrCaches: 3;
--Murphi.ModularMurphi.GenEnums
type
Access: enum {
  none,
  load,
  store
};

MessageType: enum { 
  Fwd_GetM,
  Fwd_GetM_E,
  Fwd_GetM_O,
  Fwd_GetS,
  Fwd_GetS_E,
  Fwd_GetS_O,
  GetM,
  GetM_Ack_AD,
  GetM_Ack_D,
  GetS,
  GetS_Ack,
  Inv,
  Inv_Ack,
  PutE,
  PutM,
  PutS,
  Put_Ack
};

s_cacheL1C1: enum { 
  cacheL1C1_E,
  cacheL1C1_E_evict,
  cacheL1C1_I,
  cacheL1C1_I_load,
  cacheL1C1_I_store,
  cacheL1C1_I_store_GetM_Ack_AD,
  cacheL1C1_M,
  cacheL1C1_M_evict,
  cacheL1C1_O,
  cacheL1C1_O_evict,
  cacheL1C1_O_store,
  cacheL1C1_O_store_GetM_Ack_AD,
  cacheL1C1_S,
  cacheL1C1_S_evict,
  cacheL1C1_S_store,
  cacheL1C1_S_store_GetM_Ack_AD
};


s_directoryL1C1: enum { 
  directoryL1C1_E,
  directoryL1C1_I,
  directoryL1C1_M,
  directoryL1C1_O,
  directoryL1C1_S
};

--Murphi.ModularMurphi.GenObjSets
Address: 0..1;
ClValue: 0..VAL_COUNT;

OBJSET_cacheL1C1: enum{cache0, cache1, cache2};
OBJSET_directoryL1C1: enum{directoryL1C1};
OBJSET_directory2: enum{directory2};


C1Machines: union{OBJSET_cacheL1C1, OBJSET_directoryL1C1};
Machines: union{OBJSET_cacheL1C1, OBJSET_directoryL1C1, OBJSET_directory2};

--Murphi.ModularMurphi.GenNetworkObj
Message: record
  adr: Address;
  mtype: MessageType;
  src: Machines;
  dst: Machines;
  acksExpected: 0..NrCaches;
  cl: ClValue;
end;

FIFO: record
  Queue: array[0..1] of Message;
  QueueInd: 0..1+1;
end;

OBJ_Ordered: array[0..1] of array[0..O_NET_MAX-1] of Message;
OBJ_Orderedcnt: array[0..1] of 0..O_NET_MAX;

OBJ_Ordered_fwd: array[0..1] of array[0..O_NET_MAX_fwd-1] of Message;
OBJ_Orderedcnt_fwd: array[0..1] of 0..O_NET_MAX_fwd;

OBJ_Unordered: array[Machines] of multiset[U_NET_MAX] of Message;
OBJ_FIFO: array[Machines] of FIFO;

--Murphi.ModularMurphi.GenAccessType

v_MACH_MULTISET: multiset[5] of Machines;
cnt_MACH_MULTISET: 0..5;

Access_machine: record
  store: array[Address] of v_MACH_MULTISET;
  load: array[Address] of v_MACH_MULTISET;
end;

--Murphi.ModularMurphi.GenMachObj
v_directoryL1C1_NrCaches_Machines: multiset[NrCaches] of Machines;
cnt_v_directoryL1C1_NrCaches_Machines: 0..NrCaches;

ENTRY_cacheL1C1: record
  State: s_cacheL1C1;
  clL1C1: ClValue;
  acksReceivedL1C1: 0..NrCaches;
  acksExpectedL1C1: 0..NrCaches;
end;

MACH_cacheL1C1: record
  CL: array[Address] of ENTRY_cacheL1C1;
end;

OBJ_cacheL1C1: array[OBJSET_cacheL1C1] of MACH_cacheL1C1;

ENTRY_directoryL1C1: record
  State: s_directoryL1C1;
  clL1C1: ClValue;
  cacheL1L1C1: v_directoryL1C1_NrCaches_Machines;
  ownerL1C1: Machines;
end;

ENTRY_directory2: record
  State: s_directoryL1C1;
  clL1C1: ClValue;
  cacheL1L1C1: v_directoryL1C1_NrCaches_Machines;
  ownerL1C1: Machines;
end;


MACH_directoryL1C1: record
  CL: array[Address] of ENTRY_directoryL1C1;
end;

MACH_directory2: record
  CL: array[Address] of ENTRY_directory2;
end;

OBJ_directoryL1C1: array[OBJSET_directoryL1C1] of MACH_directoryL1C1;
OBJ_directory2: array[OBJSET_directory2] of MACH_directory2;

--Murphi.ModularMurphi.GenLockType
--Murphi.ModularMurphi.GenVars
var 
  i_cacheL1C1: OBJ_cacheL1C1;
  i_directoryL1C1: OBJ_directoryL1C1;
  i_directory2: OBJ_directory2;

  g_access: Access_machine;

  fwd: OBJ_Ordered_fwd;
  cnt_fwd: OBJ_Orderedcnt_fwd;
  resp: OBJ_Ordered;
  cnt_resp: OBJ_Orderedcnt;
  req: OBJ_Ordered;
  cnt_req: OBJ_Orderedcnt;

  buf_fwd: OBJ_FIFO;
  buf_resp: OBJ_FIFO;
  buf_req: OBJ_FIFO;

--Murphi.ModularMurphi.GenLockFunc
--Murphi.ModularMurphi.GenAccessFunc

procedure Set_store_exe(adr: Address; n:Machines);
begin
  alias g_st:g_access.store[adr] do
    if MultiSetCount(i:g_st, g_st[i] = n) = 0 then
      MultiSetAdd(n, g_st);
    endif;
  endalias;
end;

procedure Clear_store(adr: Address; n:Machines);
begin
  alias g_st:g_access.store[adr] do
    if MultiSetCount(i:g_st, g_st[i] = n) = 1 then
      MultiSetRemovePred(i:g_st, g_st[i] = n);
    endif;
  endalias;
end;

procedure Set_load_exe(adr: Address; n:Machines);
begin
  alias g_st:g_access.load[adr] do
    if MultiSetCount(i:g_st, g_st[i] = n) = 0 then
      MultiSetAdd(n, g_st);
    endif;
  endalias;
end;

procedure Clear_load(adr: Address; n:Machines);
begin
  alias g_st:g_access.load[adr] do
    if MultiSetCount(i:g_st, g_st[i] = n) = 1 then
      MultiSetRemovePred(i:g_st, g_st[i] = n);
    endif;
  endalias;
end;

procedure Set_store(adr: Address; n:Machines);
begin
  Clear_load(adr, n);
  Set_store_exe(adr, n);
end;

procedure Set_load(adr: Address; n:Machines);
begin
  Clear_store(adr, n);
  Set_load_exe(adr, n);
end;

procedure Clear_acc(adr: Address; n:Machines);
begin
  Clear_store(adr, n);
  Clear_load(adr, n);
end;

procedure Reset_acc();
begin
  for a:Address do
    undefine g_access.store[a];
  endfor;

  for a:Address do
    undefine g_access.load[a];
  endfor;
end;

function Test_store(adr: Address; n:Machines): boolean;
begin
  alias g_st:g_access.store[adr] do
    if MultiSetCount(i:g_st, g_st[i] = n) = 1 then
      return true;
    endif;
  endalias;
  return false;
end;

function Test_load(adr: Address; n:Machines): boolean;
begin
  alias g_st:g_access.load[adr] do
    if MultiSetCount(i:g_st, g_st[i] = n) = 1 then
      return true;
    endif;
  endalias;
  return false;
end;

--Murphi.ModularMurphi.GenNetworkFunc
function PushQueue(var f: OBJ_FIFO; n:Machines; msg:Message): boolean;
begin
  alias p:f[n] do
  alias q: p.Queue do
  alias qind: p.QueueInd do

    if (qind<=1) then
      q[qind]:=msg;
      qind:=qind+1;
      return true;
    endif;

    return false;

  endalias;
  endalias;
  endalias;
end;

function GetQueue(var f: OBJ_FIFO; n:Machines): Message;
var
  msg: Message;
begin
  alias p:f[n] do
  alias q: p.Queue do
  undefine msg;

  if !isundefined(q[0].mtype) then
    return q[0];
  endif;

  return msg;
  endalias;
  endalias;
end;

procedure PopQueue(var f: OBJ_FIFO; n:Machines);
begin
  alias p:f[n] do
  alias q: p.Queue do
  alias qind: p.QueueInd do


  for i := 0 to qind-1 do
      if i < qind-1 then
        q[i] := q[i+1];
      else
        undefine q[i];
      endif;
    endfor;
    qind := qind - 1;

  endalias;
  endalias;
  endalias;
end;


procedure Send_fwd(msg:Message);
  Assert(cnt_fwd[0] < O_NET_MAX_fwd) "Too many fwd messages";
  Assert(cnt_fwd[1] < O_NET_MAX_fwd) "Too many fwd messages";

if ((msg.dst = cache0) & (msg.src = cache2) & (msg.adr = 1)) then
    fwd[0][cnt_fwd[0]] := msg;
    cnt_fwd[0] := cnt_fwd[0] + 1;
  elsif ((msg.dst = cache0) & (msg.src = cache1) & (msg.adr = 0)) then
    fwd[1][cnt_fwd[1]] := msg;
    cnt_fwd[1] := cnt_fwd[1] + 1;
  elsif ((msg.dst = cache1) & (msg.src = cache2) & (msg.adr = 0)) then
    fwd[0][cnt_fwd[0]] := msg;
    cnt_fwd[0] := cnt_fwd[0] + 1;
  elsif ((msg.dst = cache1) & (msg.src = cache0) & (msg.adr = 1)) then  
    fwd[1][cnt_fwd[1]] := msg;
    cnt_fwd[1] := cnt_fwd[1] + 1;
  else
    fwd[1][cnt_fwd[1]] := msg;
    cnt_fwd[1] := cnt_fwd[1] + 1;
  endif;

end;

procedure Pop_fwd(n:0..1); -- modify
begin
  Assert (cnt_fwd[n] > 0) "Trying to advance empty Q";
  for i := 0 to cnt_fwd[n]-1 do
    if i < cnt_fwd[n]-1 then
      fwd[n][i] := fwd[n][i+1];
    else
      undefine fwd[n][i];
    endif;
  endfor;
  cnt_fwd[n] := cnt_fwd[n] - 1;
end;

procedure Send_resp(msg:Message);
  Assert(cnt_fwd[0] < O_NET_MAX_fwd) "Too many fwd messages";
  Assert(cnt_fwd[1] < O_NET_MAX_fwd) "Too many fwd messages";
  if IsMember(msg.dst, OBJSET_directoryL1C1) then
    resp[0][cnt_resp[0]] := msg;
    cnt_resp[0] := cnt_resp[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_cacheL1C1) then
    if (msg.adr = 0) then
      resp[0][cnt_resp[0]] := msg;
      cnt_resp[0] := cnt_resp[0] + 1;
    else
      resp[1][cnt_resp[1]] := msg;
      cnt_resp[1] := cnt_resp[1] + 1;
    endif;
  endif;

  if IsMember(msg.dst, OBJSET_directory2) then
    resp[1][cnt_resp[1]] := msg;
    cnt_resp[1] := cnt_resp[1] + 1;
  endif;
end;

procedure Pop_resp(n:0..1); -- modify
begin
  Assert (cnt_resp[n] > 0) "Trying to advance empty Q";
  for i := 0 to cnt_resp[n]-1 do
    if i < cnt_resp[n]-1 then
      resp[n][i] := resp[n][i+1];
    else
      undefine resp[n][i];
    endif;
  endfor;
  cnt_resp[n] := cnt_resp[n] - 1;
end;

procedure Send_req(msg:Message);
  Assert(cnt_req[0] < O_NET_MAX) "Too many req messages";
  Assert(cnt_req[1] < O_NET_MAX) "Too many req messages";

  if IsMember(msg.dst, OBJSET_directoryL1C1) then
    req[0][cnt_req[0]] := msg;
    cnt_req[0] := cnt_req[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_cacheL1C1) then
    if (msg.adr = 0) then
      req[0][cnt_req[0]] := msg;
      cnt_req[0] := cnt_req[0] + 1;
    else
      req[1][cnt_req[1]] := msg;
      cnt_req[1] := cnt_req[1] + 1;
    endif;
  endif;

  if IsMember(msg.dst, OBJSET_directory2) then
    req[1][cnt_req[1]] := msg;
    cnt_req[1] := cnt_req[1] + 1;
  endif;
end;

procedure Pop_req(n:0..1); -- modify
begin
  Assert (cnt_req[n] > 0) "Trying to advance empty Q";
  for i := 0 to cnt_req[n]-1 do
    if i < cnt_req[n]-1 then
      req[n][i] := req[n][i+1];
    else
      undefine req[n][i];
    endif;
  endfor;
  cnt_req[n] := cnt_req[n] - 1;
end;



procedure Multicast_fwd_v_directoryL1C1_NrCaches_Machines(var msg: Message; dst:v_directoryL1C1_NrCaches_Machines;);
begin
      for iSV:Machines do
          if iSV!=msg.src then
            if MultiSetCount(i:dst, dst[i] = iSV) = 1 then
              msg.dst := iSV;
              Send_fwd(msg);
            endif;
          endif;
      endfor;
end;

procedure Multicast_resp_v_directoryL1C1_NrCaches_Machines(var msg: Message; dst:v_directoryL1C1_NrCaches_Machines;);
begin
      for iSV:Machines do
          if iSV!=msg.src then
            if MultiSetCount(i:dst, dst[i] = iSV) = 1 then
              msg.dst := iSV;
              Send_resp(msg);
            endif;
          endif;
      endfor;
end;

procedure Multicast_req_v_directoryL1C1_NrCaches_Machines(var msg: Message; dst:v_directoryL1C1_NrCaches_Machines;);
begin
      for iSV:Machines do
          if iSV!=msg.src then
            if MultiSetCount(i:dst, dst[i] = iSV) = 1 then
              msg.dst := iSV;
              Send_req(msg);
            endif;
          endif;
      endfor;
end;


procedure Broadcast_fwd(var msg: Message;);
begin
      for iSV:Machines do
          msg.dst := iSV;
          Send_fwd(msg);
      endfor;
end;

procedure Broadcast_resp(var msg: Message;);
begin
      for iSV:Machines do
          msg.dst := iSV;
          Send_resp(msg);
      endfor;
end;

procedure Broadcast_req(var msg: Message;);
begin
      for iSV:Machines do
          msg.dst := iSV;
          Send_req(msg);
      endfor;
end;


-- .add()
procedure AddElement_v_directoryL1C1_NrCaches_Machines(var sv:v_directoryL1C1_NrCaches_Machines; n:Machines);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 0 then
      MultiSetAdd(n, sv);
    endif;
end;

-- .del()
procedure RemoveElement_v_directoryL1C1_NrCaches_Machines(var sv:v_directoryL1C1_NrCaches_Machines; n:Machines);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 1 then
      MultiSetRemovePred(i:sv, sv[i] = n);
    endif;
end;

-- .clear()
procedure ClearVector_v_directoryL1C1_NrCaches_Machines(var sv:v_directoryL1C1_NrCaches_Machines;);
begin
    MultiSetRemovePred(i:sv, true);
end;

-- .contains()
function IsElement_v_directoryL1C1_NrCaches_Machines(var sv:v_directoryL1C1_NrCaches_Machines; n:Machines) : boolean;
begin
    if MultiSetCount(i:sv, sv[i] = n) = 1 then
      return true;
    elsif MultiSetCount(i:sv, sv[i] = n) = 0 then
      return false;
    else
      Error "Multiple Entries of Sharer in SV multiset";
    endif;
  return false;
end;

-- .empty()
function HasElement_v_directoryL1C1_NrCaches_Machines(var sv:v_directoryL1C1_NrCaches_Machines; n:Machines) : boolean;
begin
    if MultiSetCount(i:sv, true) = 0 then
      return false;
    endif;

    return true;
end;

-- .count()
function VectorCount_v_directoryL1C1_NrCaches_Machines(var sv:v_directoryL1C1_NrCaches_Machines) : cnt_v_directoryL1C1_NrCaches_Machines;
begin
    return MultiSetCount(i:sv, true);
end;


function req_network_ready(): boolean;
begin
      for mach:0..1 do
          if cnt_req[mach] >= (O_NET_MAX-1) then
            return false;
          endif;
      endfor;

      return true;
end;

function AckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
var msg: Message;
begin
  msg.adr := adr;
  msg.mtype := mtype;
  msg.src := src;
  msg.dst := dst;
  msg.acksExpected := undefined;
  msg.cl := undefined;
  return msg;
end;

function RespDataAckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue; acksExpected: 0..NrCaches) : Message;
var msg: Message;
begin
  msg.adr := adr;
  msg.mtype := mtype;
  msg.src := src;
  msg.dst := dst;
  msg.acksExpected := acksExpected;
  msg.cl := cl;
  return msg;
end;

function RequestL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
var msg: Message;
begin
  msg.adr := adr;
  msg.mtype := mtype;
  msg.src := src;
  msg.dst := dst;
  msg.acksExpected := undefined;
  msg.cl := undefined;
  return msg;
end;

function RespDataL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue) : Message;
var msg: Message;
begin
  msg.adr := adr;
  msg.mtype := mtype;
  msg.src := src;
  msg.dst := dst;
  msg.acksExpected := undefined;
  msg.cl := cl;
  return msg;
end;

function RespAckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; acksExpected: 0..NrCaches) : Message;
var msg: Message;
begin
  msg.adr := adr;
  msg.mtype := mtype;
  msg.src := src;
  msg.dst := dst;
  msg.acksExpected := acksExpected;
  msg.cl := undefined;
  return msg;
end;

--Murphi.ModularMurphi.GenModStateFunc

procedure ModifyStates_cacheL1C1(Mach: Machines; Cur_state: s_cacheL1C1; Next_state: s_cacheL1C1);
begin
    alias p:i_cacheL1C1[Mach] do
      for a:Address do
          if (p.CL[a].State = Cur_state) then
              p.CL[a].State := Next_state;
          endif;
      endfor;
    endalias;
end;

procedure ModifyStates_directoryL1C1(Mach: Machines; Cur_state: s_directoryL1C1; Next_state: s_directoryL1C1);
begin
    alias p:i_directoryL1C1[Mach] do
      for a:Address do
          if (p.CL[a].State = Cur_state) then
              p.CL[a].State := Next_state;
          endif;
      endfor;
    endalias;
end;

--Murphi.ModularMurphi.GenFSMFuncObj
function Func_cacheL1C1(inmsg:Message; m:OBJSET_cacheL1C1) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_cacheL1C1[m].CL[adr] do
switch cle.State

  case cacheL1C1_E:
  switch inmsg.mtype
    case Fwd_GetM_E:
      msg := RespDataL1C1(adr,GetM_Ack_D,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
    case Fwd_GetS_E:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_O;
      Set_load(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_E_evict:
  switch inmsg.mtype
    case Put_Ack:
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
    case Fwd_GetM_E:
      msg := RespDataL1C1(adr,GetM_Ack_D,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_E_evict;
      Clear_acc(adr, m);
    
    case Fwd_GetS_E:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_O_evict;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_I:
  switch inmsg.mtype
     else return false;
  endswitch;

  case cacheL1C1_I_load:
  switch inmsg.mtype
    case GetM_Ack_D:
      cle.clL1C1 := inmsg.cl;
      cle.State := cacheL1C1_E;
      Set_store(adr, m);
    
    case GetS_Ack:
      cle.clL1C1 := inmsg.cl;
      cle.State := cacheL1C1_S;
      Set_load(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_I_store:
  switch inmsg.mtype
    case GetM_Ack_AD:
      cle.acksExpectedL1C1 := inmsg.acksExpected;
      if(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_M;
        Set_store(adr, m);
      elsif!(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_I_store_GetM_Ack_AD;
        Clear_acc(adr, m);
      endif;
    
    case GetM_Ack_D:
      cle.clL1C1 := inmsg.cl;
      cle.State := cacheL1C1_M;
      Set_store(adr, m);
    
    case Inv_Ack:
      cle.acksReceivedL1C1 := cle.acksReceivedL1C1+1;
      cle.State := cacheL1C1_I_store;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_I_store_GetM_Ack_AD:
  switch inmsg.mtype
    case Inv_Ack:
      cle.acksReceivedL1C1 := cle.acksReceivedL1C1+1;
      if(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_M;
        Set_store(adr, m);
      elsif!(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_I_store_GetM_Ack_AD;
        Clear_acc(adr, m);
      endif;
    
     else return false;
  endswitch;

  case cacheL1C1_M:
  switch inmsg.mtype
    case Fwd_GetM_E:
      msg := RespDataL1C1(adr,GetM_Ack_D,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
    case Fwd_GetS_E:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_O;
      Set_load(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_M_evict:
  switch inmsg.mtype
    case Put_Ack:
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
    case Fwd_GetM_E:
      msg := RespDataL1C1(adr,GetM_Ack_D,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_M_evict;
      Clear_acc(adr, m);
    
    case Fwd_GetS_E:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_O_evict;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_O:
  switch inmsg.mtype
    case Fwd_GetS_O:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_O;
      Set_load(adr, m);
    
    case Fwd_GetM_O:
      msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,inmsg.acksExpected);
      Send_resp(msg);
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_O_evict:
  switch inmsg.mtype
    case Fwd_GetS_O:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_O_evict;
      Clear_acc(adr, m);
    
    case Put_Ack:
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
    case Fwd_GetM_O:
      msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,inmsg.acksExpected);
      Send_resp(msg);
      cle.State := cacheL1C1_O_evict;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_O_store:
  switch inmsg.mtype
    case Fwd_GetS_O:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.State := cacheL1C1_O_store;
      Set_load(adr, m);
    
    case GetM_Ack_D:
      cle.State := cacheL1C1_M;
      Set_store(adr, m);
    
    case Inv_Ack:
      cle.acksReceivedL1C1 := cle.acksReceivedL1C1+1;
      cle.State := cacheL1C1_O_store;
      Set_load(adr, m);
    
    case GetM_Ack_AD:
      cle.acksExpectedL1C1 := inmsg.acksExpected;
      if(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_M;
        Set_store(adr, m);
      elsif!(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_O_store_GetM_Ack_AD;
        Set_load(adr, m);
      endif;
    
    case Fwd_GetM_O:
      msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,inmsg.acksExpected);
      Send_resp(msg);
      cle.State := cacheL1C1_I_store;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_O_store_GetM_Ack_AD:
  switch inmsg.mtype
    case Inv_Ack:
      cle.acksReceivedL1C1 := cle.acksReceivedL1C1+1;
      if(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_M;
        Set_store(adr, m);
      elsif!(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_O_store_GetM_Ack_AD;
        Set_load(adr, m);
      endif;
    
     else return false;
  endswitch;

  case cacheL1C1_S:
  switch inmsg.mtype
    case Inv:
      msg := AckL1C1(adr,Inv_Ack,m,inmsg.src);
      Send_resp(msg);
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_S_evict:
  switch inmsg.mtype
    case Put_Ack:
      cle.State := cacheL1C1_I;
      Clear_acc(adr, m);
    
    case Inv:
      msg := AckL1C1(adr,Inv_Ack,m,inmsg.src);
      Send_resp(msg);
      cle.State := cacheL1C1_S_evict;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_S_store:
  switch inmsg.mtype
    case GetM_Ack_AD:
      cle.acksExpectedL1C1 := inmsg.acksExpected;
      if(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_M;
        Set_store(adr, m);
      elsif!(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_S_store_GetM_Ack_AD;
        Set_load(adr, m);
      endif;
    
    case GetM_Ack_D:
      cle.State := cacheL1C1_M;
      Set_store(adr, m);
    
    case Inv_Ack:
      cle.acksReceivedL1C1 := cle.acksReceivedL1C1+1;
      cle.State := cacheL1C1_S_store;
      Set_load(adr, m);
    
    case Inv:
      msg := AckL1C1(adr,Inv_Ack,m,inmsg.src);
      Send_resp(msg);
      cle.State := cacheL1C1_I_store;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case cacheL1C1_S_store_GetM_Ack_AD:
  switch inmsg.mtype
    case Inv_Ack:
      cle.acksReceivedL1C1 := cle.acksReceivedL1C1+1;
      if(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_M;
        Set_store(adr, m);
      elsif!(cle.acksExpectedL1C1=cle.acksReceivedL1C1) then
        cle.State := cacheL1C1_S_store_GetM_Ack_AD;
        Set_load(adr, m);
      endif;
    
     else return false;
  endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;

----------- directory function start--------------------------------------------------------------------
----------- directory function start--------------------------------------------------------------------
----------- directory function start--------------------------------------------------------------------


function Func_directoryL1C1(inmsg:Message; m:OBJSET_directoryL1C1) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_directoryL1C1[m].CL[adr] do
switch cle.State

  case directoryL1C1_E:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      else
      cle.State := directoryL1C1_E;
      Clear_acc(adr, m);
      endif;
    
    case GetM:
      msg := RequestL1C1(adr,Fwd_GetM_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
    
    case GetS:
      msg := RequestL1C1(adr,Fwd_GetS_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_I:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
        endif;
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      else
      cle.State := directoryL1C1_I;
      Clear_acc(adr, m);
      endif;
    
    case GetM:
      msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
      Send_resp(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
    
    case GetS:
      msg := RespDataL1C1(adr,GetM_Ack_D,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_E;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_M:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      else
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
      endif;
    
    case GetM:
      msg := RequestL1C1(adr,Fwd_GetM_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
    
    case GetS:
      msg := RequestL1C1(adr,Fwd_GetS_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_O:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_O;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_O;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
    case GetM:
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_fwd(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        msg := RespAckL1C1(adr,Fwd_GetM_O,inmsg.src,cle.ownerL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_fwd(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      endif;
    
    case GetS:
      msg := RequestL1C1(adr,Fwd_GetS_O,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_S:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
      endif;
    
    case GetM:
      if(IsElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src)) then
        RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
        msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_resp(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      elsif!(IsElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src)) then
        msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_resp(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      endif;
    
    case GetS:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_S;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;


----------- directory function start--------------------------------------------------------------------
----------- directory function start--------------------------------------------------------------------
----------- directory function start--------------------------------------------------------------------

function Func_directory2(inmsg:Message; m:OBJSET_directory2) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_directory2[m].CL[adr] do
switch cle.State

  case directoryL1C1_E:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_E;
        Clear_acc(adr, m);
      else
      cle.State := directoryL1C1_E;
      Clear_acc(adr, m);
      endif;
    
    case GetM:
      msg := RequestL1C1(adr,Fwd_GetM_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
    
    case GetS:
      msg := RequestL1C1(adr,Fwd_GetS_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_I:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
        endif;
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      else
      cle.State := directoryL1C1_I;
      Clear_acc(adr, m);
      endif;
    
    case GetM:
      msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
      Send_resp(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
    
    case GetS:
      msg := RespDataL1C1(adr,GetM_Ack_D,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_E;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_M:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_M;
        Clear_acc(adr, m);
      else
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
      endif;
    
    case GetM:
      msg := RequestL1C1(adr,Fwd_GetM_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      cle.ownerL1C1 := inmsg.src;
      cle.State := directoryL1C1_M;
      Clear_acc(adr, m);
    
    case GetS:
      msg := RequestL1C1(adr,Fwd_GetS_E,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_O:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_O;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        cle.clL1C1 := inmsg.cl;
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_I;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_O;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
    case GetM:
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_fwd(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        msg := RespAckL1C1(adr,Fwd_GetM_O,inmsg.src,cle.ownerL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_fwd(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      endif;
    
    case GetS:
      msg := RequestL1C1(adr,Fwd_GetS_O,inmsg.src,cle.ownerL1C1);
      Send_fwd(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_O;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

  case directoryL1C1_S:
  switch inmsg.mtype
    case PutE:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(cle.ownerL1C1=inmsg.src) then
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
          cle.State := directoryL1C1_S;
          Clear_acc(adr, m);
        else
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
        endif;
      elsif!(cle.ownerL1C1=inmsg.src) then
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
      endif;
    
    case PutM:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
      endif;
    
    case PutS:
      msg := AckL1C1(adr,Put_Ack,m,inmsg.src);
      Send_fwd(msg);
      RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_I;
        Clear_acc(adr, m);
      elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)=0) then
        cle.State := directoryL1C1_S;
        Clear_acc(adr, m);
      endif;
    
    case GetM:
      if(IsElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src)) then
        RemoveElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
        msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_resp(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      elsif!(IsElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src)) then
        msg := RespDataAckL1C1(adr,GetM_Ack_AD,m,inmsg.src,cle.clL1C1,VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1));
        Send_resp(msg);
        if(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          msg := AckL1C1(adr,Inv,inmsg.src,inmsg.src);
          Multicast_fwd_v_directoryL1C1_NrCaches_Machines(msg,cle.cacheL1L1C1);
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        elsif!(VectorCount_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1)!=0) then
          cle.ownerL1C1 := inmsg.src;
          ClearVector_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1);
          cle.State := directoryL1C1_M;
          Clear_acc(adr, m);
        endif;
      endif;
    
    case GetS:
      msg := RespDataL1C1(adr,GetS_Ack,m,inmsg.src,cle.clL1C1);
      Send_resp(msg);
      AddElement_v_directoryL1C1_NrCaches_Machines(cle.cacheL1L1C1,inmsg.src);
      cle.State := directoryL1C1_S;
      Clear_acc(adr, m);
    
     else return false;
  endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;



----------- directory function start--------------------------------------------------------------------
----------- directory function start--------------------------------------------------------------------
----------- directory function start--------------------------------------------------------------------



--Murphi.ModularMurphi.GenAccessSendFunc
procedure SEND_cacheL1C1_E_load(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do
  cle.State := cacheL1C1_E;
  Set_store(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_E_store(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do
  cle.State := cacheL1C1_M;
  Set_store(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_E_evict(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do
  msg := AckL1C1(adr,PutE,m,directoryL1C1);
  Send_req(msg);
  cle.State := cacheL1C1_E_evict;
  Clear_acc(adr, m);

endalias;
end;



procedure SEND_cacheL1C1_I_load(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do

    if (adr = 0) then
    msg := RequestL1C1(adr,GetS,m,directoryL1C1);
    else
    msg := RequestL1C1(adr,GetS,m,directory2);
    endif;

  -- msg := RequestL1C1(adr,GetS,m,directoryL1C1);
  Send_req(msg);
  cle.State := cacheL1C1_I_load;
  Clear_acc(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_I_store(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do

    if (adr = 0) then
    msg := RequestL1C1(adr,GetM,m,directoryL1C1);
    else
    msg := RequestL1C1(adr,GetM,m,directory2);
    endif;

  -- msg := RequestL1C1(adr,GetM,m,directoryL1C1);
  Send_req(msg);
  cle.acksReceivedL1C1 := 0;
  cle.State := cacheL1C1_I_store;
  Clear_acc(adr, m);

endalias;
end;



procedure SEND_cacheL1C1_M_load(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do
  cle.State := cacheL1C1_M;
  Set_store(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_M_store(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do
  cle.State := cacheL1C1_M;
  Set_store(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_M_evict(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do

    if (adr = 0) then
    msg := RespDataL1C1(adr,PutM,m,directoryL1C1,cle.clL1C1);
    else
    msg := RespDataL1C1(adr,PutM,m,directory2,cle.clL1C1);
    endif;

  -- msg := RespDataL1C1(adr,PutM,m,directoryL1C1,cle.clL1C1);
  Send_req(msg);
  cle.State := cacheL1C1_M_evict;
  Clear_acc(adr, m);

endalias;
end;



procedure SEND_cacheL1C1_O_load(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do
  cle.State := cacheL1C1_O;
  Set_load(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_O_store(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do

    if (adr = 0) then
    msg := RequestL1C1(adr,GetM,m,directoryL1C1);
    else
    msg := RequestL1C1(adr,GetM,m,directory2);
    endif;

  -- msg := RequestL1C1(adr,GetM,m,directoryL1C1);
  Send_req(msg);
  cle.acksReceivedL1C1 := 0;
  cle.State := cacheL1C1_O_store;
  Set_load(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_O_evict(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do

    if (adr = 0) then
    msg := RespDataL1C1(adr,PutM,m,directoryL1C1,cle.clL1C1);
    else
    msg := RespDataL1C1(adr,PutM,m,directory2,cle.clL1C1);
    endif;

  -- msg := RespDataL1C1(adr,PutM,m,directoryL1C1,cle.clL1C1);
  Send_req(msg);
  cle.State := cacheL1C1_O_evict;
  Clear_acc(adr, m);

endalias;
end;



procedure SEND_cacheL1C1_S_load(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do
  cle.State := cacheL1C1_S;
  Set_load(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_S_store(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do

    if (adr = 0) then
    msg := RequestL1C1(adr,GetM,m,directoryL1C1);
    else
    msg := RequestL1C1(adr,GetM,m,directory2);
    endif;

  -- msg := RequestL1C1(adr,GetM,m,directoryL1C1);
  Send_req(msg);
  cle.acksReceivedL1C1 := 0;
  cle.State := cacheL1C1_S_store;
  Set_load(adr, m);

endalias;
end;


procedure SEND_cacheL1C1_S_evict(adr:Address; m:OBJSET_cacheL1C1);
var msg: Message;
begin
  alias cle: i_cacheL1C1[m].CL[adr] do

    if (adr = 0) then
    msg := RequestL1C1(adr,PutS,m,directoryL1C1);
    else
    msg := RequestL1C1(adr,PutS,m,directory2);
    endif;

  -- msg := RequestL1C1(adr,PutS,m,directoryL1C1);
  Send_req(msg);
  cle.State := cacheL1C1_S_evict;
  Clear_acc(adr, m);

endalias;
end;



--Murphi.ModularMurphi.GenAccessRuleset
ruleset m:OBJSET_cacheL1C1 do
ruleset adr:Address do
  alias cle:i_cacheL1C1[m].CL[adr] do

  rule "cacheL1C1_E_load"
    cle.State = cacheL1C1_E
  ==>
    SEND_cacheL1C1_E_load(adr, m);
  endrule;
  
  rule "cacheL1C1_E_store"
    cle.State = cacheL1C1_E
  ==>
    SEND_cacheL1C1_E_store(adr, m);
  endrule;
  
  rule "cacheL1C1_E_evict"
    cle.State = cacheL1C1_E
   & req_network_ready()
  ==>
    SEND_cacheL1C1_E_evict(adr, m);
  endrule;
  
  
  rule "cacheL1C1_I_load"
    cle.State = cacheL1C1_I
   & req_network_ready()
  ==>
    SEND_cacheL1C1_I_load(adr, m);
  endrule;
  
  rule "cacheL1C1_I_store"
    cle.State = cacheL1C1_I
   & req_network_ready()
  ==>
    SEND_cacheL1C1_I_store(adr, m);
  endrule;
  
  
  rule "cacheL1C1_M_load"
    cle.State = cacheL1C1_M
  ==>
    SEND_cacheL1C1_M_load(adr, m);
  endrule;
  
  rule "cacheL1C1_M_store"
    cle.State = cacheL1C1_M
  ==>
    SEND_cacheL1C1_M_store(adr, m);
  endrule;
  
  rule "cacheL1C1_M_evict"
    cle.State = cacheL1C1_M
   & req_network_ready()
  ==>
    SEND_cacheL1C1_M_evict(adr, m);
  endrule;
  
  
  rule "cacheL1C1_O_load"
    cle.State = cacheL1C1_O
  ==>
    SEND_cacheL1C1_O_load(adr, m);
  endrule;
  
  rule "cacheL1C1_O_store"
    cle.State = cacheL1C1_O
   & req_network_ready()
  ==>
    SEND_cacheL1C1_O_store(adr, m);
  endrule;
  
  rule "cacheL1C1_O_evict"
    cle.State = cacheL1C1_O
   & req_network_ready()
  ==>
    SEND_cacheL1C1_O_evict(adr, m);
  endrule;
  
  
  rule "cacheL1C1_S_load"
    cle.State = cacheL1C1_S
  ==>
    SEND_cacheL1C1_S_load(adr, m);
  endrule;
  
  rule "cacheL1C1_S_store"
    cle.State = cacheL1C1_S
   & req_network_ready()
  ==>
    SEND_cacheL1C1_S_store(adr, m);
  endrule;
  
  rule "cacheL1C1_S_evict"
    cle.State = cacheL1C1_S
   & req_network_ready()
  ==>
    SEND_cacheL1C1_S_evict(adr, m);
  endrule;
  
  
  endalias;
endruleset;
endruleset;

--Murphi.ModularMurphi.GenNetworkRules


ruleset n:Machines do
  alias p:buf_fwd[n] do

      rule "buf_fwd"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do

        -- if IsMember(n, OBJSET_cacheL1C1) then
        -- if Func_cacheL1C1(msg, n) then
        --   PopQueue(buf_fwd, n);
        -- endif;
        -- elsif IsMember(n, OBJSET_directoryL1C1) then
        -- if Func_directoryL1C1(msg, n) then
        --   PopQueue(buf_fwd, n);
        -- endif;
        -- else error "unknown machine";
        -- endif;

          if IsMember(n, OBJSET_directoryL1C1) then -- ismember should decide the id of marhicnes
            if Func_directoryL1C1(msg, n) then
              PopQueue(buf_fwd, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory2) then -- ismember should decide the id of marhicnes
            if Func_directory2(msg, n) then
              PopQueue(buf_fwd, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cacheL1C1) then -- ismember should decide the id of marhicnes
            if Func_cacheL1C1(msg, n) then
              PopQueue(buf_fwd, n);
            endif;
          endif;      

        endalias;

      endrule;
  endalias;
endruleset;



ruleset n:Machines do
  alias p:buf_resp[n] do

      rule "buf_resp"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do

        -- if IsMember(n, OBJSET_cacheL1C1) then
        -- if Func_cacheL1C1(msg, n) then
        --   PopQueue(buf_resp, n);
        -- endif;
        -- elsif IsMember(n, OBJSET_directoryL1C1) then
        -- if Func_directoryL1C1(msg, n) then
        --   PopQueue(buf_resp, n);
        -- endif;
        -- else error "unknown machine";
        -- endif;
        
          if IsMember(n, OBJSET_directoryL1C1) then -- ismember should decide the id of marhicnes
            if Func_directoryL1C1(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;

          if IsMember(n,OBJSET_directory2) then -- ismember should decide the id of marhicnes
            if Func_directory2(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;
   
          if IsMember(n,  OBJSET_cacheL1C1) then -- ismember should decide the id of marhicnes
            if Func_cacheL1C1(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;




        endalias;

      endrule;
  endalias;
endruleset;

ruleset n:Machines do
  alias p:buf_req[n] do

      rule "buf_req"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do

        -- if IsMember(n, OBJSET_cacheL1C1) then
        -- if Func_cacheL1C1(msg, n) then
        --   PopQueue(buf_req, n);
        -- endif;
        -- elsif IsMember(n, OBJSET_directoryL1C1) then
        -- if Func_directoryL1C1(msg, n) then
        --   PopQueue(buf_req, n);
        -- endif;
        -- else error "unknown machine";
        -- endif;
        
          if IsMember(n, OBJSET_directoryL1C1) then -- ismember should decide the id of marhicnes
            if Func_directoryL1C1(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;

          if IsMember(n,OBJSET_directory2) then -- ismember should decide the id of marhicnes
            if Func_directory2(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cacheL1C1) then -- ismember should decide the id of marhicnes
            if Func_cacheL1C1(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;



        endalias;

      endrule;
  endalias;
endruleset;

ruleset n:0..1 do
    alias msg:fwd[n][0] do
      rule "Receive fwd"
        cnt_fwd[n] > 0
      ==>
        -- With input queues
        if (ENABLE_QS) then

            if IsMember(msg.dst, OBJSET_directoryL1C1) then
                 if PushQueue(buf_fwd, msg.dst, msg) then 
                    Pop_fwd(n);
                 endif;
             endif;


            if  IsMember(msg.dst, OBJSET_cacheL1C1) then
              if PushQueue(buf_fwd, msg.dst, msg) then 
                  Pop_fwd(n);
              endif;
            endif;

            if  IsMember(msg.dst, OBJSET_directory2) then
              if PushQueue(buf_fwd, msg.dst, msg) then 
                 Pop_fwd(n);
              endif;
            endif;

        

        endif;
      endrule;
    endalias;

endruleset;

ruleset n:0..1 do
    alias msg:resp[n][0] do
      rule "Receive resp"
        cnt_resp[n] > 0
      ==>
        -- With input queues
        if (ENABLE_QS) then

            if IsMember(msg.dst, OBJSET_directoryL1C1) then
                 if PushQueue(buf_resp, msg.dst, msg) then 
                    Pop_resp(n);
                 endif;
             endif;


            if  IsMember(msg.dst, OBJSET_cacheL1C1) then
              if PushQueue(buf_resp, msg.dst, msg) then 
                  Pop_resp(n);
              endif;
            endif;

            if  IsMember(msg.dst, OBJSET_directory2) then
              if PushQueue(buf_resp, msg.dst, msg) then 
                 Pop_resp(n);
              endif;
            endif;
        

        endif;
      endrule;
    endalias;

endruleset;

ruleset n:0..1 do
    alias msg:req[n][0] do
      rule "Receive req"
        cnt_req[n] > 0
      ==>
        -- With input queues
        if (ENABLE_QS) then


            if IsMember(msg.dst, OBJSET_directoryL1C1) then
                 if PushQueue(buf_req, msg.dst, msg) then 
                    Pop_req(n);
                 endif;
             endif;


            if  IsMember(msg.dst, OBJSET_cacheL1C1) then
              if PushQueue(buf_req, msg.dst, msg) then 
                  Pop_req(n);
              endif;
            endif;

            if  IsMember(msg.dst, OBJSET_directory2) then
              if PushQueue(buf_req, msg.dst, msg) then 
                 Pop_req(n);
              endif;
            endif;
        

        endif;
      endrule;
    endalias;

endruleset;
--Murphi.ModularMurphi.GenStartStates
startstate

  for i:OBJSET_cacheL1C1 do
  for a:Address do
    i_cacheL1C1[i].CL[a].State := cacheL1C1_I;
    i_cacheL1C1[i].CL[a].acksExpectedL1C1 := 0;
    i_cacheL1C1[i].CL[a].acksReceivedL1C1 := 0;
    i_cacheL1C1[i].CL[a].clL1C1 := 0;
  endfor;
  endfor;
  
  for i:OBJSET_directoryL1C1 do
  for a:Address do
    i_directoryL1C1[i].CL[a].State := directoryL1C1_I;
    i_directoryL1C1[i].CL[a].clL1C1 := 0;
  endfor;
  endfor;
  
   for i:OBJSET_directory2 do
  for a:Address do
    i_directory2[i].CL[a].State := directoryL1C1_I;
    i_directory2[i].CL[a].clL1C1 := 0;
  endfor;
  endfor;
  
  for i:Machines do
      undefine buf_fwd[i].Queue;
      buf_fwd[i].QueueInd:=0;
  endfor;
  
  for i:Machines do
      undefine buf_resp[i].Queue;
      buf_resp[i].QueueInd:=0;
  endfor;
  
  for i:Machines do
      undefine buf_req[i].Queue;
      buf_req[i].QueueInd:=0;
  endfor;
  
  undefine fwd;
 for n:0..1 do
    cnt_fwd[n] := 0;
  endfor;

  
  undefine resp;
  for n:0..1 do
    cnt_req[n] := 0;
  endfor;
  
  undefine req;
  for n:0..1 do
    cnt_resp[n] := 0;
  endfor;
  
  Reset_acc();
  

endstartstate;
--Murphi.ModularMurphi.GenInvar

invariant "Single Writer"
  forall a:Address do
    !MultiSetCount(i:g_access.store[a], true) > 1
  endforall;



invariant "Exclusive Write"
  forall a:Address do
    MultiSetCount(i:g_access.store[a], true) > 0
    ->
    MultiSetCount(i:g_access.load[a], true) = 0
  endforall;
