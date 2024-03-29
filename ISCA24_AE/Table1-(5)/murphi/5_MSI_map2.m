
const
  ENABLE_QS: true;  VAL_COUNT: 1;
  ADR_COUNT: 2;

  O_NET_MAX: 6; -- can be reduced to 4 (to reduce the verification time), 6, 12
  U_NET_MAX: 4;
  O_NET_MAX_fwd: 12;


  NrCaches: 2;


type
Access: enum {
  none,
  load,
  store
};

MessageType: enum { 
  Fwd_GetM,
  Fwd_GetS,
  GetM,
  GetM_Ack_AD,
  GetM_Ack_D,
  GetS,
  GetS_Ack,
  Inv,
  Inv_Ack,
  PutM,
  PutS,
  Put_Ack,
  Upgrade,
  WB
};


s_cache: enum { 
  cache_I,
  cache_I_load,
  cache_I_load__Inv_I,
  cache_I_store,
  cache_I_store_GetM_Ack_AD,
  cache_I_store_GetM_Ack_AD__Fwd_GetM_I,
  cache_I_store_GetM_Ack_AD__Fwd_GetS_S,
  cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I,
  cache_I_store__Fwd_GetM_I,
  cache_I_store__Fwd_GetS_S,
  cache_I_store__Fwd_GetS_S__Inv_I,
  cache_M,
  cache_M_evict,
  cache_M_evict_Fwd_GetM,
  cache_S,
  cache_S_evict,
  cache_S_store,
  cache_S_store_GetM_Ack_AD,
  cache_S_store_GetM_Ack_AD__Fwd_GetS_S,
  cache_S_store__Fwd_GetS_S
};


s_directory: enum { 
  directory_I,
  directory_M,
  directory_M_GetS,
  directory_S
};


Address: 0..1;
ClValue: 0..VAL_COUNT;

OBJSET_cache0: scalarset(1);
OBJSET_cache1: scalarset(1);

-- OBJSET_cache0: enum{cache0};
-- OBJSET_cache1: enum{cache1};

-- should modify all the related codes
-- OBJSET_cache1: enum{cache0, cache1, cache2};

-- OBJSET_cache: union{OBJSET_cache0, OBJSET_cache1};
-- 2 directories
OBJSET_directory0: enum{directory0};
OBJSET_directory1: enum{directory1};
-- OBJSET_directory: union{OBJSET_directory0, OBJSET_directory1};
-- OBJSET_directory: enum{directory0, directory1};

Machines: union{OBJSET_cache0, OBJSET_cache1, OBJSET_directory0, OBJSET_directory1};
-- Machines: union{OBJSET_cache0, OBJSET_cache1, OBJSET_directory};


v_NrCaches_OBJSET_cache0: multiset[NrCaches] of OBJSET_cache0;
cnt_v_NrCaches_OBJSET_cache0: 0..NrCaches;
v_NrCaches_OBJSET_cache1: multiset[NrCaches] of OBJSET_cache1;
cnt_v_NrCaches_OBJSET_cache1: 0..NrCaches;
-- 	Maximum size of MultiSet (i_directory0[directory0].CL[0].cache) exceeded.

Message: record
  adr: Address;
  mtype: MessageType;
  src: Machines;
  dst: Machines;
  acksExpected: 0..NrCaches;
  -- acksExpected: 0..2;
  cl: ClValue;
end;

-- FIFO: record
--   Queue: array[0..1] of Message; -- FIFO should be size 1
--   QueueInd: 0..1+1;
-- end;

FIFO: record
  Queue: array[0..1] of Message; -- FIFO should be size 1
  QueueInd: 0..2;
end;

Buffer: record
  Queue: array[0..1] of Message;
  QueueInd: 0..2;
end;

ENTRY_cache: record
  State: s_cache;
  Defermsg: Buffer;
  Perm: Access;
  cl: ClValue;
  acksReceived: 0..NrCaches;
  acksExpected: 0..NrCaches;
end;

-- Modified due to ID
ENTRY_directory0: record
  State: s_directory;
  Defermsg: Buffer;
  Perm: Access;
  cl: ClValue;
  cache0: v_NrCaches_OBJSET_cache0;
  cache: v_NrCaches_OBJSET_cache1;
  owner: Machines;
end;

ENTRY_directory1: record
  State: s_directory;
  Defermsg: Buffer;
  Perm: Access;
  cl: ClValue;
  cache0: v_NrCaches_OBJSET_cache0;
  cache: v_NrCaches_OBJSET_cache1;
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

-- Modified due to ID
-- OBJ_cache: array[OBJSET_cache] of MACH_cache;
OBJ_cache0: array[OBJSET_cache0] of MACH_cache;
OBJ_cache1: array[OBJSET_cache1] of MACH_cache;

-- Modified due to ID
-- OBJ_directory: array[OBJSET_directory] of MACH_directory;
OBJ_directory0: array[OBJSET_directory0] of MACH_directory0;
OBJ_directory1: array[OBJSET_directory1] of MACH_directory1;

-- OBJ_Ordered: array[Machines] of array[0..O_NET_MAX-1] of Message; -- two buffers
-- Now we have source: all machines; destination: 2 buffers
-- Goal: reduce the verification space
OBJ_Ordered: array[0..1] of array[0..O_NET_MAX-1] of Message; -- two buffers
-- OBJ_Ordered: array[Machines] of array[0..O_NET_MAX-1] of Message; -- two buffers
OBJ_Orderedcnt: array[0..1] of 0..O_NET_MAX;
-- OBJ_Orderedcnt: array[Machines] of 0..O_NET_MAX;
OBJ_Unordered: array[Machines] of multiset[U_NET_MAX] of Message;

OBJ_Ordered_fwd: array[0..1] of array[0..O_NET_MAX_fwd-1] of Message;
OBJ_Orderedcnt_fwd: array[0..1] of 0..O_NET_MAX_fwd;


OBJ_FIFO: array[Machines] of FIFO;

var 
  -- Modified due to ID
  i_cache0: OBJ_cache0;
  i_cache1: OBJ_cache1;
  
  -- Modified due to ID
  -- i_directory: OBJ_directory;
  i_directory0: OBJ_directory0;
  i_directory1: OBJ_directory1;

  fwd: OBJ_Ordered_fwd;
  cnt_fwd: OBJ_Orderedcnt_fwd;
  -- resp: OBJ_Unordered;
  -- req: OBJ_Unordered;
  resp: OBJ_Ordered;
  cnt_resp: OBJ_Orderedcnt;
  req: OBJ_Ordered; -- should also modify the send function 
  cnt_req: OBJ_Orderedcnt;

  buf_fwd: OBJ_FIFO;
  buf_resp: OBJ_FIFO;
  buf_req: OBJ_FIFO;


function PushQueue(var f: OBJ_FIFO; n:Machines; msg:Message): boolean;
begin
  alias p:f[n] do
  alias q: p.Queue do
  alias qind: p.QueueInd do
    
    -- if (qind<=1) then
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

function Resp(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue) : Message;
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

-- function RespAck(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue; acksExpected: 0..NrCaches) : Message;
function RespAck(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue; acksExpected: 0..NrCaches) : Message;
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

procedure Send_fwd(msg:Message);

  Assert(cnt_fwd[0] < O_NET_MAX_fwd) "Too many fwd messages";
  Assert(cnt_fwd[1] < O_NET_MAX_fwd) "Too many fwd messages";

  -- fwd[0][cnt_fwd[0]] := msg;
  -- cnt_fwd[0] := cnt_fwd[0] + 1;


  if IsMember(msg.dst, OBJSET_cache0) then
    if (msg.adr = 0) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
    elsif (msg.adr = 1) then
     fwd[1][cnt_fwd[1]] := msg;
     cnt_fwd[1] := cnt_fwd[1] + 1;
    endif;
  endif;

  if IsMember(msg.dst, OBJSET_cache1) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_directory0) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_directory1) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
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

  Assert(cnt_fwd[0] < O_NET_MAX_fwd) "Too many resp messages";
  Assert(cnt_fwd[1] < O_NET_MAX_fwd) "Too many resp messages";
 
  if IsMember(msg.dst, OBJSET_cache0) then
    if (msg.adr = 0) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
    elsif (msg.adr = 1) then
     fwd[1][cnt_fwd[1]] := msg;
     cnt_fwd[1] := cnt_fwd[1] + 1;
    endif;
  endif;

  if IsMember(msg.dst, OBJSET_cache1) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_directory0) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_directory1) then
     fwd[0][cnt_fwd[0]] := msg;
     cnt_fwd[0] := cnt_fwd[0] + 1;
  endif;


end;

procedure Pop_resp(n:0..1); -- modify
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
  -- Assert (cnt_resp[n] > 0) "Trying to advance empty Q";
  -- for i := 0 to cnt_resp[n]-1 do
  --   if i < cnt_resp[n]-1 then
  --     resp[n][i] := resp[n][i+1];
  --   else
  --     undefine resp[n][i];
  --   endif;
  -- endfor;
  -- cnt_resp[n] := cnt_resp[n] - 1;
end;


-- procedure Send_resp(msg:Message;);
--   Assert (MultiSetCount(i:resp[msg.dst], true) < U_NET_MAX) "Too many messages";
--   MultiSetAdd(msg, resp[msg.dst]);
-- end;

procedure Send_req(msg:Message);

  Assert(cnt_req[0] < O_NET_MAX) "Too many req messages";
  Assert(cnt_req[1] < O_NET_MAX) "Too many req messages";


  if IsMember(msg.dst, OBJSET_directory0) then
    req[0][cnt_req[0]] := msg;
    cnt_req[0] := cnt_req[0] + 1;
  endif;

  if IsMember(msg.dst, OBJSET_cache0) then
    req[0][cnt_req[0]] := msg;
    cnt_req[0] := cnt_req[0] + 1;
  endif;


  if IsMember(msg.dst, OBJSET_cache1) then
    -- if (msg.adr = 0) then
      req[0][cnt_req[0]] := msg;
      cnt_req[0] := cnt_req[0] + 1;
    -- else
    --   req[1][cnt_req[1]] := msg;
    --   cnt_req[1] := cnt_req[1] + 1;
    -- endif;
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


----- Cache Operation -----

procedure Multicast_fwd_v_NrCaches_OBJSET_cache0(var msg: Message; dst:v_NrCaches_OBJSET_cache0;);
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

procedure Multicast_fwd_v_NrCaches_OBJSET_cache1(var msg: Message; dst:v_NrCaches_OBJSET_cache1;);
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


----- Cache Operation -----
procedure Multicast_resp_v_NrCaches_OBJSET_cache0(var msg: Message; dst:v_NrCaches_OBJSET_cache0;);
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


procedure Multicast_resp_v_NrCaches_OBJSET_cache1(var msg: Message; dst:v_NrCaches_OBJSET_cache1;);
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

----- Cache Operation -----

procedure Multicast_req_v_NrCaches_OBJSET_cache0(var msg: Message; dst:v_NrCaches_OBJSET_cache0;);
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

procedure Multicast_req_v_NrCaches_OBJSET_cache1(var msg: Message; dst:v_NrCaches_OBJSET_cache1;);
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

----- Cache Operation -----

procedure AddElement_v_NrCaches_OBJSET_cache0(var sv:v_NrCaches_OBJSET_cache0; n:OBJSET_cache0);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 0 then
      MultiSetAdd(n, sv);
    endif;
end;


procedure AddElement_v_NrCaches_OBJSET_cache1(var sv:v_NrCaches_OBJSET_cache1; n:OBJSET_cache1);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 0 then
      MultiSetAdd(n, sv);
    endif;
end;

----- Cache Operation -----

procedure RemoveElement_v_NrCaches_OBJSET_cache0(var sv:v_NrCaches_OBJSET_cache0; n:OBJSET_cache0);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 1 then
      MultiSetRemovePred(i:sv, sv[i] = n);
    endif;
end;


procedure RemoveElement_v_NrCaches_OBJSET_cache1(var sv:v_NrCaches_OBJSET_cache1; n:OBJSET_cache1);
begin
    if MultiSetCount(i:sv, sv[i] = n) = 1 then
      MultiSetRemovePred(i:sv, sv[i] = n);
    endif;
end;


----- Cache Operation -----

procedure ClearVector_v_NrCaches_OBJSET_cache0(var sv:v_NrCaches_OBJSET_cache0;);
begin
    MultiSetRemovePred(i:sv, true);
end;

procedure ClearVector_v_NrCaches_OBJSET_cache1(var sv:v_NrCaches_OBJSET_cache1;);
begin
    MultiSetRemovePred(i:sv, true);
end;


----- Cache Operation -----

function IsElement_v_NrCaches_OBJSET_cache0(var sv:v_NrCaches_OBJSET_cache0; n:OBJSET_cache0) : boolean;
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

function IsElement_v_NrCaches_OBJSET_cache1(var sv:v_NrCaches_OBJSET_cache1; n:OBJSET_cache1) : boolean;
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

----- Cache Operation -----

function HasElement_v_NrCaches_OBJSET_cache0(var sv:v_NrCaches_OBJSET_cache0; n:OBJSET_cache0) : boolean;
begin
    if MultiSetCount(i:sv, true) = 0 then
      return false;
    endif;

    return true;
end;

function HasElement_v_NrCaches_OBJSET_cache1(var sv:v_NrCaches_OBJSET_cache1; n:OBJSET_cache1) : boolean;
begin
    if MultiSetCount(i:sv, true) = 0 then
      return false;
    endif;

    return true;
end;

----- Cache Operation -----

function VectorCount_v_NrCaches_OBJSET_cache0(var sv:v_NrCaches_OBJSET_cache0) : cnt_v_NrCaches_OBJSET_cache0;
begin
    return MultiSetCount(i:sv, IsMember(sv[i], OBJSET_cache0));
end;

function VectorCount_v_NrCaches_OBJSET_cache1(var sv:v_NrCaches_OBJSET_cache1) : cnt_v_NrCaches_OBJSET_cache1;
begin
    return MultiSetCount(i:sv, IsMember(sv[i], OBJSET_cache1));
end;

----- Cache Operation -----

procedure i_cache_Defermsg0(msg:Message; adr: Address; m:OBJSET_cache0);
begin
	alias cle: i_cache0[m].CL[adr] do
	alias q: cle.Defermsg.Queue do
	alias qind: cle.Defermsg.QueueInd do

	if (qind<=2) then
      q[qind]:=msg;
      qind:=qind+1;
    endif;

	endalias;
	endalias;
	endalias;
end;

procedure i_cache_Defermsg1(msg:Message; adr: Address; m:OBJSET_cache1);
begin
	alias cle: i_cache1[m].CL[adr] do
	alias q: cle.Defermsg.Queue do
	alias qind: cle.Defermsg.QueueInd do

	if (qind<=2) then
      q[qind]:=msg;
      qind:=qind+1;
    endif;

	endalias;
	endalias;
	endalias;
end;

----- Cache Operation -----

procedure i_cache_SendDefermsg0(adr: Address; m:OBJSET_cache0);
begin
  alias cle: i_cache0[m].CL[adr] do
  alias q: cle.Defermsg.Queue do
  alias qind: cle.Defermsg.QueueInd do

  for i := 0 to qind-1 do
  		--i_cache_Updatemsg(q[i], adr, m);
  		Send_resp(q[i]);
        undefine q[i];
    endfor;

   qind := 0;

  endalias;
  endalias;
  endalias;
end;

procedure i_cache_SendDefermsg1(adr: Address; m:OBJSET_cache1);
begin
  alias cle: i_cache1[m].CL[adr] do
  alias q: cle.Defermsg.Queue do
  alias qind: cle.Defermsg.QueueInd do

  for i := 0 to qind-1 do
  		--i_cache_Updatemsg(q[i], adr, m);
  		Send_resp(q[i]);
        undefine q[i];
    endfor;

   qind := 0;

  endalias;
  endalias;
  endalias;
end;

-----------------------------cache function end-----------------------------------
-----------------------------cache function end-----------------------------------
-----------------------------cache function end-----------------------------------
function Func_cache0(inmsg:Message; m:OBJSET_cache0) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_cache0[m].CL[adr] do
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
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_load__Inv_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_load__Inv_I:
switch inmsg.mtype
  case GetS_Ack:
    cle.cl := inmsg.cl;
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_I_store:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    cle.State := cache_I_store__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);

    cle.State := cache_I_store__Fwd_GetS_S;
    cle.Perm := none;

  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
        
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

   -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD__Fwd_GetM_I:
switch inmsg.mtype
  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;

    
    i_cache_SendDefermsg0(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD__Fwd_GetS_S:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg0(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I:
switch inmsg.mtype
  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg0(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;    

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store__Fwd_GetM_I:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg0(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg0(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store__Fwd_GetM_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_store__Fwd_GetS_S:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg0(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg0(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store__Fwd_GetS_S;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_store__Fwd_GetS_S__Inv_I:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg0(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg0(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_M:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    
    i_cache_SendDefermsg0(adr, m);
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);

    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    
    i_cache_SendDefermsg0(adr, m);
    cle.State := cache_S;
    cle.Perm := load;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_M_evict:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    
    i_cache_SendDefermsg0(adr, m);
    cle.State := cache_M_evict_Fwd_GetM;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);

    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    
    i_cache_SendDefermsg0(adr, m);
    cle.State := cache_S_evict;
    cle.Perm := none;

  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_M_evict_Fwd_GetM:
switch inmsg.mtype
  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_S:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_S_evict:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_M_evict_Fwd_GetM;
    cle.Perm := none;

  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_S_store:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    cle.State := cache_I_store__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    cle.State := cache_S_store__Fwd_GetS_S;
    cle.Perm := load;

  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD;
    cle.Perm := load;
    endif;

  case GetM_Ack_D:
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_S_store;
    cle.Perm := load;

   else return false;
endswitch;

case cache_S_store_GetM_Ack_AD:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg0(msg, adr, m);
    cle.State := cache_S_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := load;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD;
    cle.Perm := load;
    endif;

   else return false;
endswitch;

case cache_S_store_GetM_Ack_AD__Fwd_GetS_S:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg0(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := load;
    endif;

   else return false;
endswitch;

case cache_S_store__Fwd_GetS_S:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg0(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := load;
    endif;

  case GetM_Ack_D:
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg0(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_S_store__Fwd_GetS_S;
    cle.Perm := load;

   else return false;
endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;



-----------------------------cache function end-----------------------------------
-----------------------------cache function end-----------------------------------
-----------------------------cache function end-----------------------------------
function Func_cache1(inmsg:Message; m:OBJSET_cache1) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_cache1[m].CL[adr] do
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
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_load__Inv_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_load__Inv_I:
switch inmsg.mtype
  case GetS_Ack:
    cle.cl := inmsg.cl;
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_I_store:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    cle.State := cache_I_store__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);

    cle.State := cache_I_store__Fwd_GetS_S;
    cle.Perm := none;

  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
        
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

   -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD__Fwd_GetM_I:
switch inmsg.mtype
  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;

    
    i_cache_SendDefermsg1(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD__Fwd_GetS_S:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg1(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I:
switch inmsg.mtype
  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg1(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;    

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case cache_I_store__Fwd_GetM_I:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg1(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg1(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;


  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store__Fwd_GetM_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_store__Fwd_GetS_S:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg1(adr, m);

    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg1(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store__Fwd_GetS_S;
    cle.Perm := none;

   else return false;
endswitch;

case cache_I_store__Fwd_GetS_S__Inv_I:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg1(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;
    endif;

  case GetM_Ack_D:
    cle.cl := inmsg.cl;
    cle.State := cache_I;
    cle.Perm := none;
    
    i_cache_SendDefermsg1(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_I_store__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

   else return false;
endswitch;

case cache_M:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    
    i_cache_SendDefermsg1(adr, m);
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);

    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    
    i_cache_SendDefermsg1(adr, m);
    cle.State := cache_S;
    cle.Perm := load;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_M_evict:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    
    i_cache_SendDefermsg1(adr, m);
    cle.State := cache_M_evict_Fwd_GetM;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);

    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    
    i_cache_SendDefermsg1(adr, m);
    cle.State := cache_S_evict;
    cle.Perm := none;

  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_M_evict_Fwd_GetM:
switch inmsg.mtype
  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_S:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_S_evict:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_M_evict_Fwd_GetM;
    cle.Perm := none;

  case Put_Ack:
    cle.State := cache_I;
    cle.Perm := none;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

   else return false;
endswitch;

case cache_S_store:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    cle.State := cache_I_store__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    cle.State := cache_S_store__Fwd_GetS_S;
    cle.Perm := load;

  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD;
    cle.Perm := load;
    endif;

  case GetM_Ack_D:
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_S_store;
    cle.Perm := load;

   else return false;
endswitch;

case cache_S_store_GetM_Ack_AD:
switch inmsg.mtype
  case Fwd_GetM:
    msg := Resp(adr,GetM_Ack_D,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetM_I;
    cle.Perm := none;

  case Fwd_GetS:
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,WB,m,directory0,cle.cl);
    else
    msg := Resp(adr,WB,m,directory1,cle.cl);
    endif;

    -- msg := Resp(adr,WB,m,directory,cle.cl);
    
    i_cache_Defermsg1(msg, adr, m);
    cle.State := cache_S_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := load;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_M;
    cle.Perm := store;
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD;
    cle.Perm := load;
    endif;

   else return false;
endswitch;

case cache_S_store_GetM_Ack_AD__Fwd_GetS_S:
switch inmsg.mtype
  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg1(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := load;
    endif;

   else return false;
endswitch;

case cache_S_store__Fwd_GetS_S:
switch inmsg.mtype
  case GetM_Ack_AD:
    cle.acksExpected := inmsg.acksExpected;
    if (cle.acksExpected=cle.acksReceived) then
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg1(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

    else
    cle.State := cache_S_store_GetM_Ack_AD__Fwd_GetS_S;
    cle.Perm := load;
    endif;

  case GetM_Ack_D:
    cle.State := cache_S;
    cle.Perm := load;
    
    i_cache_SendDefermsg1(adr, m);
    cle.acksReceived := 0;
    cle.acksExpected := 0;

  case Inv:
    msg := Resp(adr,Inv_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := cache_I_store__Fwd_GetS_S__Inv_I;
    cle.Perm := none;

  case Inv_Ack:
    cle.acksReceived := cle.acksReceived+1;
    cle.State := cache_S_store__Fwd_GetS_S;
    cle.Perm := load;

   else return false;
endswitch;

endswitch;
  endalias;
  endalias;

return true;
end;

-----------------------------cache function end-----------------------------------
-----------------------------cache function end-----------------------------------
-----------------------------cache function end-----------------------------------


procedure i_directory_Defermsg0(msg:Message; adr: Address; m:OBJSET_directory0);
begin
	alias cle: i_directory0[m].CL[adr] do
	alias q: cle.Defermsg.Queue do
	alias qind: cle.Defermsg.QueueInd do

	-- if (qind<=2) then
  if (qind<=2) then
      q[qind]:=msg;
      qind:=qind+1;
    endif;

	endalias;
	endalias;
	endalias;
end;

procedure i_directory_Defermsg1(msg:Message; adr: Address; m:OBJSET_directory1);
begin
	alias cle: i_directory1[m].CL[adr] do
	alias q: cle.Defermsg.Queue do
	alias qind: cle.Defermsg.QueueInd do

	if (qind<= 2) then
    -- if (qind<=1) then
      q[qind]:=msg;
      qind:=qind+1;
    endif;

	endalias;
	endalias;
	endalias;
end;


procedure i_directory_SendDefermsg0(adr: Address; m:OBJSET_directory0);
begin
  alias cle: i_directory0[m].CL[adr] do
  alias q: cle.Defermsg.Queue do
  alias qind: cle.Defermsg.QueueInd do

  for i := 0 to qind-1 do
  		--i_directory_Updatemsg(q[i], adr, m);
  		Send_resp(q[i]);
        undefine q[i];
    endfor;

   qind := 0;

  endalias;
  endalias;
  endalias;
end;

procedure i_directory_SendDefermsg1(adr: Address; m:OBJSET_directory1);
begin
  alias cle: i_directory1[m].CL[adr] do
  alias q: cle.Defermsg.Queue do
  alias qind: cle.Defermsg.QueueInd do

  for i := 0 to qind-1 do
  		--i_directory_Updatemsg(q[i], adr, m);
  		Send_resp(q[i]);
        undefine q[i];
    endfor;

   qind := 0;

  endalias;
  endalias;
  endalias;
end;


--  modified due to ID
function Func_directory0(inmsg:Message; m:OBJSET_directory0) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_directory0[m].CL[adr] do
switch cle.State

case directory_I:
switch inmsg.mtype
  case GetM:
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,(VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) + VectorCount_v_NrCaches_OBJSET_cache1(cle.cache)));
    Send_resp(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:

    if IsMember(inmsg.src, OBJSET_cache0) then
       AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    elsif IsMember(inmsg.src, OBJSET_cache1) then
       AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := directory_S;
    cle.Perm := none;

    undefine cle.owner;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);

    -- if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    -- elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    -- endif;

    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;

    undefine cle.owner;

    else
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;

    endif;

  case PutS:
    msg := Resp(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);

    if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache1(cle.cache) =0) & (VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) =0)then
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;    

    else
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;
    endif;

  case Upgrade:
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) + VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

   else return false;
endswitch;

case directory_M:
switch inmsg.mtype
  case GetM:
    msg := Request(adr,Fwd_GetM,inmsg.src,cle.owner);
    Send_fwd(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:
    msg := Request(adr,Fwd_GetS,inmsg.src,cle.owner);
    Send_fwd(msg);

      if IsMember(inmsg.src, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
          if IsMember(cle.owner, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
          else
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,cle.owner);
          endif;

    elsif IsMember(inmsg.src, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
          if IsMember(cle.owner, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,cle.owner);
          else
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
          endif;

    endif;

    -- AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    -- AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
    cle.State := directory_M_GetS;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);


    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case PutS:
    msg := Resp(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);

    if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);

    if (VectorCount_v_NrCaches_OBJSET_cache1(cle.cache)=0) & (VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) =0) then
    cle.State := directory_M;
    cle.Perm := none;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case Upgrade:
    msg := Request(adr,Fwd_GetM,inmsg.src,cle.owner);
    Send_fwd(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

   else return false;
endswitch;

case directory_M_GetS:
switch inmsg.mtype
  case WB:
    if (inmsg.src=cle.owner) then
    cle.cl := inmsg.cl;
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;

    else
    cle.State := directory_M_GetS;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_S:
switch inmsg.mtype
  case GetM:
    if (IsElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src) | IsElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src) ) then
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
  

    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);
    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);

    else
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);
    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);
    endif;

  case GetS:

    if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    -- AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;


  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;


    else
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;
    endif;

  case PutS:
    msg := Resp(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    if IsMember(inmsg.src, OBJSET_cache1) then
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    else
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    endif;

    if (VectorCount_v_NrCaches_OBJSET_cache1(cle.cache)=0) & (VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)=0) then
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;


    else
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;
    endif;

  case Upgrade:
    if (IsElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src) | IsElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src)) then
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);

    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);

    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);

    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);

    else
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);
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

function Func_directory1(inmsg:Message; m:OBJSET_directory1) : boolean;
var msg: Message;
begin
  alias adr: inmsg.adr do
  alias cle: i_directory1[m].CL[adr] do
switch cle.State

case directory_I:
switch inmsg.mtype
  case GetM:
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,(VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) + VectorCount_v_NrCaches_OBJSET_cache1(cle.cache)));
    Send_resp(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:

      if IsMember(inmsg.src, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
          if IsMember(cle.owner, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
          elsif IsMember(cle.owner, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,cle.owner);
          endif;

    elsif IsMember(inmsg.src, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
          if IsMember(cle.owner, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,cle.owner);
          elsif IsMember(cle.owner, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
          endif;
          
    endif;

    -- AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);

    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := directory_S;
    cle.Perm := none;

    undefine cle.owner;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);

    -- if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    -- elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    -- endif;

    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;

    undefine cle.owner;

    else
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;
    endif;

  case PutS:
    msg := Resp(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);

    if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    if (VectorCount_v_NrCaches_OBJSET_cache1(cle.cache) =0) & (VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) =0)then
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;    

    else
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;
    endif;

  case Upgrade:
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) + VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

   else return false;
endswitch;

case directory_M:
switch inmsg.mtype
  case GetM:
    msg := Request(adr,Fwd_GetM,inmsg.src,cle.owner);
    Send_fwd(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

  case GetS:
    msg := Request(adr,Fwd_GetS,inmsg.src,cle.owner);
    Send_fwd(msg);

      if IsMember(inmsg.src, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
          if IsMember(cle.owner, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
          elsif IsMember(cle.owner, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,cle.owner);
          endif;

    elsif IsMember(inmsg.src, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
          if IsMember(cle.owner, OBJSET_cache0) then
          AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,cle.owner);
          elsif IsMember(cle.owner, OBJSET_cache1) then
          AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
          endif;
          
    endif;

    -- AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    -- AddElement_v_NrCaches_OBJSET_cache1(cle.cache,cle.owner);
    cle.State := directory_M_GetS;
    cle.Perm := none;

  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    
    -- if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    -- elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    -- endif;

    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case PutS:
    msg := Resp(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);

    if IsMember(inmsg.src, OBJSET_cache0) then
       RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    elsif IsMember(inmsg.src, OBJSET_cache1) then
       RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    -- RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);

    if (VectorCount_v_NrCaches_OBJSET_cache1(cle.cache)=0) & (VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0) =0) then
    cle.State := directory_M;
    cle.Perm := none;

    else
    cle.State := directory_M;
    cle.Perm := none;
    endif;

  case Upgrade:
    msg := Request(adr,Fwd_GetM,inmsg.src,cle.owner);
    Send_fwd(msg);
    cle.owner := inmsg.src;
    cle.State := directory_M;
    cle.Perm := none;

   else return false;
endswitch;

case directory_M_GetS:
switch inmsg.mtype
  case WB:
    if (inmsg.src=cle.owner) then
    cle.cl := inmsg.cl;
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;

    else
    cle.State := directory_M_GetS;
    cle.Perm := none;
    endif;

   else return false;
endswitch;

case directory_S:
switch inmsg.mtype
  case GetM:
    if (IsElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src) | IsElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src) ) then
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);
    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);

    else
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);
    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);
    endif;

  case GetS:
    if IsMember(inmsg.src, OBJSET_cache0) then
        AddElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    elsif IsMember(inmsg.src, OBJSET_cache1) then
        AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    -- AddElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    msg := Resp(adr,GetS_Ack,m,inmsg.src,cle.cl);
    Send_resp(msg);
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;


  case PutM:
    msg := Ack(adr,Put_Ack,m,inmsg.src);
    Send_fwd(msg);
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    if (cle.owner=inmsg.src) then
    cle.cl := inmsg.cl;
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;


    else
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;
    endif;

  case PutS:
    msg := Resp(adr,Put_Ack,m,inmsg.src,cle.cl);
    Send_fwd(msg);
    if IsMember(inmsg.src, OBJSET_cache0) then
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);
    else
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    endif;

    if (VectorCount_v_NrCaches_OBJSET_cache1(cle.cache)=0) & (VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)=0)then
    cle.State := directory_I;
    cle.Perm := none;
    undefine cle.owner;


    else
    cle.State := directory_S;
    cle.Perm := none;
    undefine cle.owner;
    endif;

  case Upgrade:
    if (IsElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src) |   IsElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src)) then
    RemoveElement_v_NrCaches_OBJSET_cache1(cle.cache,inmsg.src);
    RemoveElement_v_NrCaches_OBJSET_cache0(cle.cache0,inmsg.src);

    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);

    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);

    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);

    else
    msg := RespAck(adr,GetM_Ack_AD,m,inmsg.src,cle.cl,VectorCount_v_NrCaches_OBJSET_cache0(cle.cache0)+VectorCount_v_NrCaches_OBJSET_cache1(cle.cache));
    Send_resp(msg);
    cle.State := directory_M;
    cle.Perm := none;
    msg := Ack(adr,Inv,inmsg.src,inmsg.src);
    Multicast_fwd_v_NrCaches_OBJSET_cache1(msg,cle.cache);
    Multicast_fwd_v_NrCaches_OBJSET_cache0(msg,cle.cache0);
    cle.owner := inmsg.src;
    ClearVector_v_NrCaches_OBJSET_cache1(cle.cache);
    ClearVector_v_NrCaches_OBJSET_cache0(cle.cache0);
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

-- modified due to ID

procedure SEND_cache_I_load1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do

    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,GetS,m,directory0);
    else
    msg := Request(adr,GetS,m,directory1);
    endif;

    -- msg := Request(adr,GetS,m,directory);
    Send_req(msg);
    cle.State := cache_I_load;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_I_store1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do

    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,GetM,m,directory0);
    else
    msg := Request(adr,GetM,m,directory1);
    endif;

    -- msg := Request(adr,GetM,m,directory);
    Send_req(msg);
    cle.acksReceived := 0;
    cle.State := cache_I_store;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_M_evict1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,PutM,m,directory0,cle.cl);
    else
    msg := Resp(adr,PutM,m,directory1,cle.cl);
    endif;
    
    -- msg := Resp(adr,PutM,m,directory,cle.cl);

    Send_req(msg);
    cle.State := cache_M_evict;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_M_load1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do
    cle.State := cache_M;
    cle.Perm := store;
endalias;
end;

-- modified due to ID

procedure SEND_cache_M_store1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do
    cle.State := cache_M;
    cle.Perm := store;
endalias;
end;

-- modified due to ID

procedure SEND_cache_S_evict1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do
    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,PutS,m,directory0);
    else
    msg := Request(adr,PutS,m,directory1);
    endif;

    -- msg := Request(adr,PutS,m,directory);
    Send_req(msg);
    cle.State := cache_S_evict;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_S_load1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do
    cle.State := cache_S;
    cle.Perm := load;
    cle.acksReceived := 0;
    cle.acksExpected := 0;
endalias;
end;

-- modified due to ID

procedure SEND_cache_S_store1(adr:Address; m:OBJSET_cache1);
var msg: Message;
begin
  alias cle: i_cache1[m].CL[adr] do
    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,Upgrade,m,directory0);
    else
    msg := Request(adr,Upgrade,m,directory1);
    endif;

    -- msg := Request(adr,Upgrade,m,directory);

    Send_req(msg);
    cle.acksReceived := 0;
    cle.State := cache_S_store;
    cle.Perm := load;
endalias;
end;


----- cache send function end------------------------------------------------------------------------
----- cache send function end------------------------------------------------------------------------
----- cache send function end------------------------------------------------------------------------

procedure SEND_cache_I_load0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do

    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,GetS,m,directory0);
    else
    msg := Request(adr,GetS,m,directory1);
    endif;

    -- msg := Request(adr,GetS,m,directory);
    Send_req(msg);
    cle.State := cache_I_load;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_I_store0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do

    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,GetM,m,directory0);
    else
    msg := Request(adr,GetM,m,directory1);
    endif;

    -- msg := Request(adr,GetM,m,directory);
    Send_req(msg);
    cle.acksReceived := 0;
    cle.State := cache_I_store;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_M_evict0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do
    -- decide the src by adr
    if (adr = 0) then
    msg := Resp(adr,PutM,m,directory0,cle.cl);
    else
    msg := Resp(adr,PutM,m,directory1,cle.cl);
    endif;
    
    -- msg := Resp(adr,PutM,m,directory,cle.cl);

    Send_req(msg);
    cle.State := cache_M_evict;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_M_load0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do
    cle.State := cache_M;
    cle.Perm := store;
endalias;
end;

-- modified due to ID

procedure SEND_cache_M_store0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do
    cle.State := cache_M;
    cle.Perm := store;
endalias;
end;

-- modified due to ID

procedure SEND_cache_S_evict0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do
    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,PutS,m,directory0);
    else
    msg := Request(adr,PutS,m,directory1);
    endif;

    -- msg := Request(adr,PutS,m,directory);
    Send_req(msg);
    cle.State := cache_S_evict;
    cle.Perm := none;
endalias;
end;

-- modified due to ID

procedure SEND_cache_S_load0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do
    cle.State := cache_S;
    cle.Perm := load;
    cle.acksReceived := 0;
    cle.acksExpected := 0;
endalias;
end;

-- modified due to ID

procedure SEND_cache_S_store0(adr:Address; m:OBJSET_cache0);
var msg: Message;
begin
  alias cle: i_cache0[m].CL[adr] do
    -- decide the src by adr
    if (adr = 0) then
    msg := Request(adr,Upgrade,m,directory0);
    else
    msg := Request(adr,Upgrade,m,directory1);
    endif;

    -- msg := Request(adr,Upgrade,m,directory);

    Send_req(msg);
    cle.acksReceived := 0;
    cle.State := cache_S_store;
    cle.Perm := load;
endalias;
end;

----- cache send function end------------------------------------------------------------------------
----- cache send function end------------------------------------------------------------------------
----- cache send function end------------------------------------------------------------------------


-- modifeid due to ID
ruleset m:OBJSET_cache1 do
ruleset adr:Address do
  alias cle:i_cache1[m].CL[adr] do

  rule "cache_I_load"
    cle.State = cache_I
  
  ==>
    SEND_cache_I_load1(adr, m);
  endrule;
  
  rule "cache_I_store"
    cle.State = cache_I
  
  ==>
    SEND_cache_I_store1(adr, m);
  endrule;
  
  
  rule "cache_M_evict"
    cle.State = cache_M
  
  ==>
    SEND_cache_M_evict1(adr, m);
  endrule;
  
  rule "cache_M_load"
    cle.State = cache_M
  
  ==>
    SEND_cache_M_load1(adr, m);
  endrule;
  
  rule "cache_M_store"
    cle.State = cache_M
  
  ==>
    SEND_cache_M_store1(adr, m);
  endrule;
  
  
  rule "cache_S_evict"
    cle.State = cache_S
  
  ==>
    SEND_cache_S_evict1(adr, m);
  endrule;
  
  rule "cache_S_load"
    cle.State = cache_S
  
  ==>
    SEND_cache_S_load1(adr, m);
  endrule;
  
  rule "cache_S_store"
    cle.State = cache_S
  
  ==>
    SEND_cache_S_store1(adr, m);
  endrule;
  
  
  endalias;
endruleset;
endruleset;

----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------

ruleset m:OBJSET_cache0 do
ruleset adr:Address do
  alias cle:i_cache0[m].CL[adr] do

  rule "cache_I_load"
    cle.State = cache_I
  
  ==>
    SEND_cache_I_load0(adr, m);
  endrule;
  
  rule "cache_I_store"
    cle.State = cache_I
  
  ==>
    SEND_cache_I_store0(adr, m);
  endrule;
  
  
  rule "cache_M_evict"
    cle.State = cache_M
  
  ==>
    SEND_cache_M_evict0(adr, m);
  endrule;
  
  rule "cache_M_load"
    cle.State = cache_M
  
  ==>
    SEND_cache_M_load0(adr, m);
  endrule;
  
  rule "cache_M_store"
    cle.State = cache_M
  
  ==>
    SEND_cache_M_store0(adr, m);
  endrule;
  
  
  rule "cache_S_evict"
    cle.State = cache_S
  
  ==>
    SEND_cache_S_evict0(adr, m);
  endrule;
  
  rule "cache_S_load"
    cle.State = cache_S
  
  ==>
    SEND_cache_S_load0(adr, m);
  endrule;
  
  rule "cache_S_store"
    cle.State = cache_S
  
  ==>
    SEND_cache_S_store0(adr, m);
  endrule;
  
  
  endalias;
endruleset;
endruleset;

----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------
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

          if IsMember(n, OBJSET_cache0) then -- ismember should decide the id of marhicnes
            if Func_cache0(msg, n) then
              PopQueue(buf_fwd, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cache1) then -- ismember should decide the id of marhicnes
            if Func_cache1(msg, n) then
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

          if IsMember(n, OBJSET_cache0) then -- ismember should decide the id of marhicnes
            if Func_cache0(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cache1) then -- ismember should decide the id of marhicnes
            if Func_cache1(msg, n) then
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
        (p.QueueInd>0) & (cnt_fwd[0] < O_NET_MAX-4) & (cnt_fwd[1] < O_NET_MAX-4)
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

          if IsMember(n, OBJSET_cache0) then -- ismember should decide the id of marhicnes
            if Func_cache0(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cache1) then -- ismember should decide the id of marhicnes
            if Func_cache1(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;
        
        endalias;

      endrule;
  endalias;
endruleset;


----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------

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

          if IsMember(msg.dst, OBJSET_cache0) then -- ismember should decide the id of marhicnes
              if PushQueue(buf_resp, msg.dst, msg) then 
                  Pop_resp(n);
              endif;
          endif;

            if  IsMember(msg.dst, OBJSET_cache1)then
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
        (cnt_req[n] > 0 )& (cnt_fwd[0] < O_NET_MAX-4) & (cnt_fwd[1] < O_NET_MAX-4)
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

          if IsMember(msg.dst, OBJSET_cache0) then -- ismember should decide the id of marhicnes
              if PushQueue(buf_req, msg.dst, msg) then 
                  Pop_req(n);
              endif;
          endif;

            if IsMember(msg.dst, OBJSET_cache1) then
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

-- ruleset n:0..1 do -- the number of routers
-- ruleset n:Machines do
  ruleset n:0..1 do
    alias msg:fwd[n][0] do
      rule "Receive fwd"
        cnt_fwd[n] > 0
      ==>
        -- With input queues
        if (ENABLE_QS) then

             if IsMember(msg.dst, OBJSET_directory0) then
                 if PushQueue(buf_fwd, msg.dst, msg) then 
                    Pop_fwd(n);
                 endif;
             endif;
          -- endif;

          if IsMember(msg.dst, OBJSET_cache0) then -- ismember should decide the id of marhicnes
              if PushQueue(buf_fwd, msg.dst, msg) then 
                  Pop_fwd(n);
              endif;
          endif;

          -- if (n = 1) then
            if  IsMember(msg.dst, OBJSET_cache1) then
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

----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------
----- cache rule end------------------------------------------------------------------------


-- modified due to ID
startstate

  for i:OBJSET_directory0 do
  for a:Address do
    i_directory0[i].CL[a].State := directory_I;
    i_directory0[i].CL[a].cl := 0;
    i_directory0[i].CL[a].Defermsg.QueueInd := 0;
    i_directory0[i].CL[a].Perm := none;
  endfor;
  endfor;

  for i:OBJSET_directory1 do
  for a:Address do
    i_directory1[i].CL[a].State := directory_I;
    i_directory1[i].CL[a].cl := 0;
    i_directory1[i].CL[a].Defermsg.QueueInd := 0;
    i_directory1[i].CL[a].Perm := none;
  endfor;
  endfor;
  
  for i:OBJSET_cache0 do
  for a:Address do
    i_cache0[i].CL[a].State := cache_I;
    i_cache0[i].CL[a].acksExpected := 0;
    i_cache0[i].CL[a].acksReceived := 0;
    i_cache0[i].CL[a].cl := 0;
    i_cache0[i].CL[a].Defermsg.QueueInd := 0;
    i_cache0[i].CL[a].Perm := none;
  endfor;
  endfor;

  for i:OBJSET_cache1 do
  for a:Address do
    i_cache1[i].CL[a].State := cache_I;
    i_cache1[i].CL[a].acksExpected := 0;
    i_cache1[i].CL[a].acksReceived := 0;
    i_cache1[i].CL[a].cl := 0;
    i_cache1[i].CL[a].Defermsg.QueueInd := 0;
    i_cache1[i].CL[a].Perm := none;
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
  

  undefine resp;
  
  undefine req;
  
  undefine fwd;

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

-- modified due to ID
invariant "Write Serialization"
    forall c1:OBJSET_cache0 do
    forall c2:OBJSET_cache0 do
    forall a:Address do
    ( c1 != c2
    & i_cache0[c1].CL[a].Perm = store )
    ->
    ( i_cache0[c2].CL[a].Perm != store )
    endforall
    endforall
    endforall;

invariant "Write Serialization"
    forall c1:OBJSET_cache1 do
    forall c2:OBJSET_cache1 do
    forall a:Address do
    ( c1 != c2
    & i_cache1[c1].CL[a].Perm = store )
    ->
    ( i_cache1[c2].CL[a].Perm != store )
    endforall
    endforall
    endforall;
