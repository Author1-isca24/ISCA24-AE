
const
  ENABLE_QS: true;  VAL_COUNT: 1;
  ADR_COUNT: 2;

  O_NET_MAX: 6;
  U_NET_MAX: 24;

  NrCaches: 3;


type
Access: enum {
  none,
  load,
  store
};

MessageType: enum { 
  Fwd_GetM,
  Fwd_GetM_M,
  Fwd_GetM_O,
  Fwd_GetS,
  Fwd_GetS_M,
  Fwd_GetS_O,
  GetM,
  GetM_Ack_AD,
  GetM_Ack_D,
  GetS,
  GetS_Ack,
  Inv,
  Inv_Ack,
  PutM,
  PutS,
  Put_Ack
};


s_cache: enum { 
  cache_I,
  cache_I_load,
  cache_I_store,
  cache_I_store_GetM_Ack_AD,
  cache_M,
  cache_M_evict,
  cache_M_evict_Fwd_GetM_M,
  cache_O,
  cache_O_store,
  cache_O_store_GetM_Ack_AD,
  cache_S,
  cache_S_evict
};


s_directory: enum { 
  directory_I,
  directory_M,
  directory_O,
  directory_S
};


Address: 0..1;
ClValue: 0..VAL_COUNT;

OBJSET_cache: enum{cache0, cache1, cache2};

OBJSET_directory0: enum{directory0};
OBJSET_directory1: enum{directory1};

Machines: union{OBJSET_cache, OBJSET_directory0, OBJSET_directory1};

v_NrCaches_OBJSET_cache: multiset[NrCaches] of OBJSET_cache;
cnt_v_NrCaches_OBJSET_cache: 0..NrCaches;

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

ENTRY_cache: record
  State: s_cache;
  Perm: Access;
  cl: ClValue;
  acksReceived: 0..NrCaches;
  acksExpected: 0..NrCaches;
end;

ENTRY_directory0: record
  State: s_directory;
  Perm: Access;
  cl: ClValue;
  cache: v_NrCaches_OBJSET_cache;
  owner: Machines;
end;

ENTRY_directory1: record
  State: s_directory;
  Perm: Access;
  cl: ClValue;
  cache: v_NrCaches_OBJSET_cache;
  owner: Machines;
end;


MACH_cache: record
  CL: array[Address] of ENTRY_cache;
end;

MACH_directory0: record
  CL: array[Address] of ENTRY_directory0;
end;

MACH_directory1: record
  CL: array[Address] of ENTRY_directory1;
end;

OBJ_cache: array[OBJSET_cache] of MACH_cache;

OBJ_directory0: array[OBJSET_directory0] of MACH_directory0;
OBJ_directory1: array[OBJSET_directory1] of MACH_directory1;

OBJ_Ordered: array[0..1] of array[0..O_NET_MAX-1] of Message;
OBJ_Orderedcnt: array[0..1] of 0..O_NET_MAX;
OBJ_Unordered: array[Machines] of multiset[U_NET_MAX] of Message;

OBJ_FIFO: array[Machines] of FIFO;


var 
  i_cache: OBJ_cache;
  i_directory0: OBJ_directory0;
  i_directory1: OBJ_directory1;

  fwd: OBJ_Ordered;
  cnt_fwd: OBJ_Orderedcnt;
  resp: OBJ_Ordered;
  cnt_resp: OBJ_Orderedcnt;
  req: OBJ_Ordered;
  cnt_req: OBJ_Orderedcnt;

  buf_fwd: OBJ_FIFO;
  buf_resp: OBJ_FIFO;
  buf_req: OBJ_FIFO;

  lock_set_cache: multiset[1] of OBJSET_cache;


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

function Request(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
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

function Ack(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
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

function RespAck(adr: Address; mtype: MessageType; src: Machines; dst: Machines; acksExpected: 0..NrCaches) : Message;
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

function RespData(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue) : Message;
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

function RespDataAck(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue; acksExpected: 0..NrCaches) : Message;
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


 --------------------------- Send Function---------------------------------------
 --------------------------- Send Function---------------------------------------
 --------------------------- Send Function---------------------------------------

procedure Send_fwd(msg:Message);
  -- Assert(cnt_fwd[msg.dst] < O_NET_MAX) "Too many messages";
  -- fwd[msg.dst][cnt_fwd[msg.dst]] := msg;
  -- if ismember(msg.dst = obj_cache0) or (msg.dst = obj_dir0)
  -- fwd[0][cnt_fwd[0]] := msg
  Assert(cnt_fwd[0] < O_NET_MAX) "Too many fwd messages";
  Assert(cnt_fwd[1] < O_NET_MAX) "Too many fwd messages";

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

   -- cnt_resp[msg.dst] := cnt_resp[msg.dst] + 1;
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
  -- Assert(cnt_resp[msg.dst] < O_NET_MAX) "Too many messages";
  -- resp[msg.dst][cnt_resp[msg.dst]] := msg;
  -- if ismember(msg.dst = obj_cache0) or (msg.dst = obj_dir0)
  -- fwd[0][cnt_fwd[0]] := msg
  Assert(cnt_resp[0] < O_NET_MAX) "Too many resp messages";
  Assert(cnt_resp[1] < O_NET_MAX) "Too many resp messages";
  if IsMember(msg.dst, OBJSET_directory0) then
    resp[0][cnt_resp[0]] := msg;
    cnt_resp[0] := cnt_resp[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_cache) then
    if (msg.adr = 0) then
      resp[0][cnt_resp[0]] := msg;
      cnt_resp[0] := cnt_resp[0] + 1;
    else
      resp[1][cnt_resp[1]] := msg;
      cnt_resp[1] := cnt_resp[1] + 1;
    endif;
  endif;

  if IsMember(msg.dst, OBJSET_directory1) then
    resp[1][cnt_resp[1]] := msg;
    cnt_resp[1] := cnt_resp[1] + 1;
  endif;

  -- cnt_resp[msg.dst] := cnt_resp[msg.dst] + 1;
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


-- procedure Send_resp(msg:Message;);
--   Assert (MultiSetCount(i:resp[msg.dst], true) < U_NET_MAX) "Too many messages";
--   MultiSetAdd(msg, resp[msg.dst]);
-- end;

procedure Send_req(msg:Message);
  -- Assert(cnt_req[msg.dst] < O_NET_MAX) "Too many messages";
  -- req[msg.dst][cnt_req[msg.dst]] := msg;
  -- if ismember(msg.dst = obj_cache0) or (msg.dst = obj_dir0)
  -- fwd[0][cnt_fwd[0]] := msg
  Assert(cnt_req[0] < O_NET_MAX) "Too many req messages";
  Assert(cnt_req[1] < O_NET_MAX) "Too many req messages";

  if IsMember(msg.dst, OBJSET_directory0) then
    req[0][cnt_req[0]] := msg;
    cnt_req[0] := cnt_req[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_cache) then
    if (msg.adr = 0) then
      req[0][cnt_req[0]] := msg;
      cnt_req[0] := cnt_req[0] + 1;
    else
      req[1][cnt_req[1]] := msg;
      cnt_req[1] := cnt_req[1] + 1;
    endif;
  endif;

  if IsMember(msg.dst, OBJSET_directory1) then
    req[1][cnt_req[1]] := msg;
    cnt_req[1] := cnt_req[1] + 1;
  endif;

  -- cnt_req[msg.dst] := cnt_req[msg.dst] + 1;
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


 --------------------------- Send Function---------------------------------------
 --------------------------- Send Function---------------------------------------
 --------------------------- Send Function---------------------------------------


procedure Multicast_fwd_v_NrCaches_OBJSET_cache(var msg: Message; dst:v_NrCaches_OBJSET_cache;);
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

procedure Multicast_resp_v_NrCaches_OBJSET_cache(var msg: Message; dst:v_NrCaches_OBJSET_cache;);
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

procedure Multicast_req_v_NrCaches_OBJSET_cache(var msg: Message; dst:v_NrCaches_OBJSET_cache;);
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


-- .add()
procedure AddElement_v_NrCaches_OBJSET_cache(var sv:v_NrCaches_OBJSET_cache; n:OBJSET_cache);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 0 then
      MultiSetAdd(n, sv);
    endif;
end;

-- .del()
procedure RemoveElement_v_NrCaches_OBJSET_cache(var sv:v_NrCaches_OBJSET_cache; n:OBJSET_cache);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 1 then
      MultiSetRemovePred(i:sv, sv[i] = n);
    endif;
end;

-- .clear()
procedure ClearVector_v_NrCaches_OBJSET_cache(var sv:v_NrCaches_OBJSET_cache;);
begin
    MultiSetRemovePred(i:sv, true);
end;

-- .contains()
function IsElement_v_NrCaches_OBJSET_cache(var sv:v_NrCaches_OBJSET_cache; n:OBJSET_cache) : boolean;
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
function HasElement_v_NrCaches_OBJSET_cache(var sv:v_NrCaches_OBJSET_cache; n:OBJSET_cache) : boolean;
begin
    if MultiSetCount(i:sv, true) = 0 then
      return false;
    endif;

    return true;
end;

-- .count()
function VectorCount_v_NrCaches_OBJSET_cache(var sv:v_NrCaches_OBJSET_cache) : cnt_v_NrCaches_OBJSET_cache;
begin
    return MultiSetCount(i:sv, IsMember(sv[i], OBJSET_cache));
end;


function Func_cache(inmsg:Message; m:OBJSET_cache) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_cache[m].CL[adr] do
switch cle.State

case cache_I:
switch inmsg.mtype
   else return false;
endswitch;

case cache_I_load:
switch inmsg.mtype
  case GetS_Ack:
    cle.cl := inmsg.cl;
    cle.State := cache_S;
    cle.Perm := load;

   else return false;
endswitch;

case cache_I_store:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    else
    cle.State := cache_I_store_GetM_Ack_AD;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_M;
    cle.Perm := store;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD:
switch inmsg.mtype
  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    else
    cle.State := cache_I_store_GetM_Ack_AD;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_M:
switch inmsg.mtype
  case Fwd_GetM_M:
    msg := RespData(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I;
    cle.Perm := none;

  case Fwd_GetS_M:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_O;
    cle.Perm := load;

   else return false;
endswitch;

case cache_M_evict:
switch inmsg.mtype
  case Fwd_GetM_M:
    msg := RespData(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_M_evict_Fwd_GetM_M;
    cle.Perm := none;

  case Fwd_GetS_M:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_M_evict_Fwd_GetM_M;
    cle.Perm := none;

  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_M_evict_Fwd_GetM_M:
switch inmsg.mtype
  case Fwd_GetM_O:
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,inmsg.acksExpected);
    Send_resp(msg);
    cle.State := cache_M_evict_Fwd_GetM_M;
    cle.Perm := none;

  case Fwd_GetS_O:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_M_evict_Fwd_GetM_M;
    cle.Perm := none;

  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_O:
switch inmsg.mtype
  case Fwd_GetM_O:
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,inmsg.acksExpected);
    Send_resp(msg);
    cle.State := cache_I;
    cle.Perm := none;

  case Fwd_GetS_O:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_O;
    cle.Perm := load;

   else return false;
endswitch;

case cache_O_store:
switch inmsg.mtype
  case Fwd_GetM_O:
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,inmsg.acksExpected);
    Send_resp(msg);
    cle.State := cache_I_store;
    cle.Perm := none;

  case Fwd_GetS_O:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_O_store;
    cle.Perm := load;

  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    else
    cle.State := cache_O_store_GetM_Ack_AD;
    cle.Perm := load;
    endif;

  case GetM_Ack_D:
    cle.State := cache_M;
    cle.Perm := store;

  case Inv:
    msg := Ack(adr,Inv_Ack,m,inmsg.src);
    Send_resp(msg);
    cle.State := cache_I_store;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_O_store;
    cle.Perm := load;

   else return false;
endswitch;

case cache_O_store_GetM_Ack_AD:
switch inmsg.mtype
  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    else
    cle.State := cache_O_store_GetM_Ack_AD;
    cle.Perm := load;
    endif;

   else return false;
endswitch;

case cache_S:
switch inmsg.mtype
  case Inv:
    msg := Ack(adr,Inv_Ack,m,inmsg.src);
    Send_resp(msg);
    cle.State := cache_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_S_evict:
switch inmsg.mtype
  case Inv:
    msg := Ack(adr,Inv_Ack,m,inmsg.src);
    Send_resp(msg);
    cle.State := cache_M_evict_Fwd_GetM_M;
    cle.Perm := none;

  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;

   else return false;
endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;

----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------

function Func_directory1(inmsg:Message; m:OBJSET_directory1) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_directory1[m].CL[adr] do
switch cle.State

case directory_I:
switch inmsg.mtype
  case GetM:
    msg := RespData(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_S;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    else
    cle.State := directory_I;
    cle.Perm := none;
    endif;

    else
    cle.State := directory_I;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    else
    cle.State := directory_I;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_M:
switch inmsg.mtype
  case GetM:
    msg := Request(adr,Fwd_GetM_M,inmsg.src,cle.owner);
    Send_fwd(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:
    msg := Request(adr,Fwd_GetS_M,inmsg.src,cle.owner);
    Send_fwd(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_O;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_M;
    cle.Perm := none;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_O:
switch inmsg.mtype
  case GetM:
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_fwd(msg);
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);
    cle.State := directory_M;
    cle.Perm := none;

    else
    msg := RespAck(adr,Fwd_GetM_O,inmsg.src,cle.owner,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_fwd(msg);
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case GetS:
    msg := Request(adr,Fwd_GetS_O,inmsg.src,cle.owner);
    Send_fwd(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_O;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

    else
    cle.State := directory_O;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_O;
    cle.Perm := none;

    else
    cle.State := directory_O;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_S:
switch inmsg.mtype
  case GetM:
    if (IsElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src)) then
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);

    else
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);
    endif;

  case GetS:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_S;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_S;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_S;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;

----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------

function Func_directory0(inmsg:Message; m:OBJSET_directory0) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_directory0[m].CL[adr] do
switch cle.State

case directory_I:
switch inmsg.mtype
  case GetM:
    msg := RespData(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_S;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    else
    cle.State := directory_I;
    cle.Perm := none;
    endif;

    else
    cle.State := directory_I;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    else
    cle.State := directory_I;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_M:
switch inmsg.mtype
  case GetM:
    msg := Request(adr,Fwd_GetM_M,inmsg.src,cle.owner);
    Send_fwd(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:
    msg := Request(adr,Fwd_GetS_M,inmsg.src,cle.owner);
    Send_fwd(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_O;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_M;
    cle.Perm := none;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_O:
switch inmsg.mtype
  case GetM:
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_fwd(msg);
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);
    cle.State := directory_M;
    cle.Perm := none;

    else
    msg := RespAck(adr,Fwd_GetM_O,inmsg.src,cle.owner,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_fwd(msg);
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case GetS:
    msg := Request(adr,Fwd_GetS_O,inmsg.src,cle.owner);
    Send_fwd(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_O;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

    else
    cle.State := directory_O;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_O;
    cle.Perm := none;

    else
    cle.State := directory_O;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_S:
switch inmsg.mtype
  case GetM:
    if (IsElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src)) then
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);

    else
    msg := RespDataAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache(cle.cache);
    endif;

  case GetS:
    msg := RespData(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    AddElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    cle.State := directory_S;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_S;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_S;
    cle.Perm := none;

    cle.cl := inmsg.cl;
    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

  case PutS:
    msg := RespData(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache(cle.cache)=0) then
    cle.State := directory_I;
    cle.Perm := none;

    else
    cle.State := directory_S;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;



----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------

procedure SEND_cache_I_load(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do

    -- adrx
    if (adr = 0) then
    msg := Request(adr,GetS,m,directory0);
    else
    msg := Request(adr,GetS,m,directory1);
    endif;

    Send_req(msg);
    cle.State := cache_I_load;
    cle.Perm := none;
endalias;
end;


procedure SEND_cache_I_store(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do

    -- adrx
    if (adr = 0) then
    msg := Request(adr,GetM,m,directory0);
    else
    msg := Request(adr,GetM,m,directory1);
    endif;

    Send_req(msg);
    cle.acksReceived := 0;
    cle.State := cache_I_store;
    cle.Perm := none;
endalias;
end;



procedure SEND_cache_M_evict(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do

    if (adr = 0) then
    msg := RespData(adr,PutM,m,directory0,cle.cl);
    else
    msg := RespData(adr,PutM,m,directory1,cle.cl);
    endif;


    Send_req(msg);
    cle.State := cache_M_evict;
    cle.Perm := none;
endalias;
end;


procedure SEND_cache_M_load(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do
    cle.State := cache_M;
    cle.Perm := store;
endalias;
end;


procedure SEND_cache_M_store(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do
    cle.State := cache_M;
    cle.Perm := store;
endalias;
end;



procedure SEND_cache_O_evict(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do

    -- adrx
    if (adr = 0) then
    msg := RespData(adr,PutM,m,directory0,cle.cl);
    else
    msg := RespData(adr,PutM,m,directory1,cle.cl);
    endif;

    Send_req(msg);
    cle.State := cache_M_evict_Fwd_GetM_M;
    cle.Perm := none;
endalias;
end;


procedure SEND_cache_O_load(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do
    cle.State := cache_O;
    cle.Perm := load;
endalias;
end;


procedure SEND_cache_O_store(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do

    -- adrx
    if (adr = 0) then
    msg := Request(adr,GetM,m,directory0);
    else
    msg := Request(adr,GetM,m,directory1);
    endif;


    Send_req(msg);
    cle.acksReceived := 0;
    cle.State := cache_O_store;
    cle.Perm := load;
endalias;
end;



procedure SEND_cache_S_evict(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do


    if (adr = 0) then
    msg := Request(adr,PutS,m,directory0);
    else
    msg := Request(adr,PutS,m,directory1);
    endif;

    Send_req(msg);
    cle.State := cache_S_evict;
    cle.Perm := none;
endalias;
end;


procedure SEND_cache_S_load(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do
    cle.State := cache_S;
    cle.Perm := load;
endalias;
end;


procedure SEND_cache_S_store(adr:Address; m:OBJSET_cache);
var msg: Message;
begin
  alias cle: i_cache[m].CL[adr] do

    if (adr = 0) then
    msg := Request(adr,GetM,m,directory0);
    else
    msg := Request(adr,GetM,m,directory1);
    endif;



    Send_req(msg);
    cle.acksReceived := 0;
    cle.State := cache_O_store;
    cle.Perm := load;
endalias;
end;



ruleset m:OBJSET_cache do
ruleset adr:Address do
  alias cle:i_cache[m].CL[adr] do

  rule "cache_I_load"
    cle.State = cache_I
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_I_load(adr, m);
  endrule;
  
  rule "cache_I_store"
    cle.State = cache_I
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_I_store(adr, m);
  endrule;
  
  
  rule "cache_M_evict"
    cle.State = cache_M
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_M_evict(adr, m);
  endrule;
  
  rule "cache_M_load"
    cle.State = cache_M
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_M_load(adr, m);
  endrule;
  
  rule "cache_M_store"
    cle.State = cache_M
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_M_store(adr, m);
  endrule;
  
  
  rule "cache_O_evict"
    cle.State = cache_O
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_O_evict(adr, m);
  endrule;
  
  rule "cache_O_load"
    cle.State = cache_O
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_O_load(adr, m);
  endrule;
  
  rule "cache_O_store"
    cle.State = cache_O
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_O_store(adr, m);
  endrule;
  
  
  rule "cache_S_evict"
    cle.State = cache_S
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_S_evict(adr, m);
  endrule;
  
  rule "cache_S_load"
    cle.State = cache_S
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_S_load(adr, m);
  endrule;
  
  rule "cache_S_store"
    cle.State = cache_S
   & (MultiSetCount(l:lock_set_cache, true) = 0)
  ==>
    MultiSetAdd(m, lock_set_cache);
    SEND_cache_S_store(adr, m);
  endrule;
  
  
  endalias;
endruleset;
endruleset;


ruleset m:OBJSET_cache do
ruleset adr:Address do
  alias cle:i_cache[m].CL[adr] do
  rule "Unlocking cache_I"
    cle.State = cache_I & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory0 do (
        i_directory0[d].CL[adr].State = directory_I
        | i_directory0[d].CL[adr].State = directory_S
        | i_directory0[d].CL[adr].State = directory_O
        | i_directory0[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;
  
  rule "Unlocking cache_S"
    cle.State = cache_S & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory0 do (
        i_directory0[d].CL[adr].State = directory_I
        | i_directory0[d].CL[adr].State = directory_S
        | i_directory0[d].CL[adr].State = directory_O
        | i_directory0[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;
  
  rule "Unlocking cache_O"
    cle.State = cache_O & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory0 do (
        i_directory0[d].CL[adr].State = directory_I
        | i_directory0[d].CL[adr].State = directory_S
        | i_directory0[d].CL[adr].State = directory_O
        | i_directory0[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;
  
  rule "Unlocking cache_M"
    cle.State = cache_M & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory0 do (
        i_directory0[d].CL[adr].State = directory_I
        | i_directory0[d].CL[adr].State = directory_S
        | i_directory0[d].CL[adr].State = directory_O
        | i_directory0[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;
  
    rule "Unlocking cache_I"
    cle.State = cache_I & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory1 do (
        i_directory1[d].CL[adr].State = directory_I
        | i_directory1[d].CL[adr].State = directory_S
        | i_directory1[d].CL[adr].State = directory_O
        | i_directory1[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;
  
  rule "Unlocking cache_S"
    cle.State = cache_S & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory1 do (
        i_directory1[d].CL[adr].State = directory_I
        | i_directory1[d].CL[adr].State = directory_S
        | i_directory1[d].CL[adr].State = directory_O
        | i_directory1[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;
  
  rule "Unlocking cache_O"
    cle.State = cache_O & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory1 do (
        i_directory1[d].CL[adr].State = directory_I
        | i_directory1[d].CL[adr].State = directory_S
        | i_directory1[d].CL[adr].State = directory_O
        | i_directory1[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;
  
  rule "Unlocking cache_M"
    cle.State = cache_M & !(MultiSetCount(l:lock_set_cache, lock_set_cache[l] = m) = 0)
    & (forall d:OBJSET_directory1 do (
        i_directory1[d].CL[adr].State = directory_I
        | i_directory1[d].CL[adr].State = directory_S
        | i_directory1[d].CL[adr].State = directory_O
        | i_directory1[d].CL[adr].State = directory_M) endforall)
  ==>
    MultiSetRemovePred(l:lock_set_cache, true);
  endrule;


  endalias;
endruleset;
endruleset;


ruleset n:Machines do
  alias p:buf_fwd[n] do

      rule "buf_fwd"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do
          
          if IsMember(n, OBJSET_directory0) then -- ismember should decide the id of marhicnes
            if Func_directory0(msg, n) then
              PopQueue(buf_fwd, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory1) then -- ismember should decide the id of marhicnes
            if Func_directory1(msg, n) then
              PopQueue(buf_fwd, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cache) then -- ismember should decide the id of marhicnes
            if Func_cache(msg, n) then
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

          if IsMember(n, OBJSET_directory0) then -- ismember should decide the id of marhicnes
            if Func_directory0(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory1) then -- ismember should decide the id of marhicnes
            if Func_directory1(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cache) then -- ismember should decide the id of marhicnes
            if Func_cache(msg, n) then
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
          
          if IsMember(n, OBJSET_directory0) then -- ismember should decide the id of marhicnes
            if Func_directory0(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory1) then -- ismember should decide the id of marhicnes
            if Func_directory1(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;

          if IsMember(n, OBJSET_cache) then -- ismember should decide the id of marhicnes
            if Func_cache(msg, n) then
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
          -- if PushQueue(buf_fwd, n, msg) then 

            if IsMember(msg.dst, OBJSET_directory0) then
                 if PushQueue(buf_fwd, msg.dst, msg) then 
                    Pop_fwd(n);
                 endif;
             endif;


            if  IsMember(msg.dst, OBJSET_cache) then
              if PushQueue(buf_fwd, msg.dst, msg) then 
                  Pop_fwd(n);
              endif;
            endif;

            if  IsMember(msg.dst, OBJSET_directory1) then
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

             if IsMember(msg.dst, OBJSET_directory0) then
                 if PushQueue(buf_resp, msg.dst, msg) then 
                    Pop_resp(n);
                 endif;
             endif;
          -- endif;

          -- if (n = 1) then
            if  IsMember(msg.dst, OBJSET_cache)then
              if PushQueue(buf_resp, msg.dst, msg) then 
                  Pop_resp(n);
              endif;
            endif;

            if  IsMember(msg.dst, OBJSET_directory1) then
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
          -- if PushQueue(buf_fwd, n, msg) then 
          

            if IsMember(msg.dst, OBJSET_directory0) then
                 if PushQueue(buf_req, msg.dst, msg) then 
                    Pop_req(n);
                 endif;
             endif;
          -- endif;

          -- if (n = 1) then
            if IsMember(msg.dst, OBJSET_cache) then
              if PushQueue(buf_req, msg.dst, msg) then 
                  Pop_req(n);
              endif;
            endif;
            if IsMember(msg.dst, OBJSET_directory1) then
              if PushQueue(buf_req, msg.dst, msg) then 
                 Pop_req(n);
              endif;
            endif;

        endif;
      endrule;
    endalias;

endruleset;

startstate

  for i:OBJSET_directory0 do
  for a:Address do
    i_directory0[i].CL[a].State := directory_I;
    i_directory0[i].CL[a].cl := 0;

    i_directory0[i].CL[a].Perm := none;
  endfor;
  endfor;

  for i:OBJSET_directory1 do
  for a:Address do
    i_directory1[i].CL[a].State := directory_I;
    i_directory1[i].CL[a].cl := 0;

    i_directory1[i].CL[a].Perm := none;
  endfor;
  endfor;
  
  for i:OBJSET_cache do
  for a:Address do
    i_cache[i].CL[a].State := cache_I;
    i_cache[i].CL[a].acksExpected := 0;
    i_cache[i].CL[a].acksReceived := 0;
    i_cache[i].CL[a].cl := 0;
    i_cache[i].CL[a].Perm := none;
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
  
  for n:0..1 do
    cnt_fwd[n] := 0;
  endfor;

  for n:0..1 do
    cnt_req[n] := 0;
  endfor;

  for n:0..1 do
    cnt_resp[n] := 0;
  endfor;

endstartstate;


invariant "Write Serialization"
    forall c1:OBJSET_cache do
    forall c2:OBJSET_cache do
    forall a:Address do
    ( c1 != c2
    & i_cache[c1].CL[a].Perm = store )
    ->
    ( i_cache[c2].CL[a].Perm != store )
    endforall
    endforall
    endforall;


