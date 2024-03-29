
--Backend/Murphi/MurphiModular/Constants/GenConst
  ---- System access constants
  const
    ENABLE_QS: true;
    VAL_COUNT: 1;
    ADR_COUNT: 2;
  
  ---- System network constants
    O_NET_MAX: 6;
    U_NET_MAX: 10;
    O_NET_MAX_snp: 18;  
  ---- SSP declaration constants
    NrCachesL1C1: 2;
  
--Backend/Murphi/MurphiModular/GenTypes
  type
    ----Backend/Murphi/MurphiModular/Types/GenAdrDef
    Address: 0..1;
    ClValue: 0..VAL_COUNT;
    
    ----Backend/Murphi/MurphiModular/Types/Enums/GenEnums
      ------Backend/Murphi/MurphiModular/Types/Enums/SubEnums/GenAccess
      PermissionType: enum {
        load, 
        store, 
        evict, 
        none
      };
      
      ------Backend/Murphi/MurphiModular/Types/Enums/SubEnums/GenMessageTypes
      MessageType: enum {
        CleanUniqueL1C1, 
        CompAckL1C1, 
        ReadSharedL1C1, 
        SnpResp_IL1C1, 
        EvictL1C1, 
        SnpResp_S_Fwded_SL1C1, 
        CompData_SL1C1, 
        SnpResp_O_Fwded_SL1C1, 
        SnpRespData_I_PDL1C1, 
        WriteBackFullL1C1, 
        CBWR_Data_O_PDL1C1, 
        CBWR_Data_IL1C1, 
        CBWR_Data_M_PDL1C1, 
        CompData_EL1C1, 
        Comp_EL1C1, 
        SnpSharedFwdL1C1, 
        SnpCleanInvalidL1C1, 
        Comp_IL1C1, 
        CompDBIDRespL1C1
      };
      
      ------Backend/Murphi/MurphiModular/Types/Enums/SubEnums/GenArchEnums
      s_directoryL1C1: enum {
        directoryL1C1_UCE_WriteBackFull,
        directoryL1C1_UCE_ReadShared_SnpResp_O_Fwded_S,
        directoryL1C1_UCE_ReadShared_SnpResp_I,
        directoryL1C1_UCE_ReadShared,
        directoryL1C1_UCE_CleanUnique_SnpResp_I,
        directoryL1C1_UCE_CleanUnique_SnpRespData_I_PD,
        directoryL1C1_UCE_CleanUnique,
        directoryL1C1_UCE,
        directoryL1C1_S_WriteBackFull,
        directoryL1C1_S_ReadShared,
        directoryL1C1_S_CleanUnique_SnpResp_I,
        directoryL1C1_S_CleanUnique,
        directoryL1C1_S,
        directoryL1C1_O_WriteBackFull,
        directoryL1C1_O_ReadShared_SnpResp_O_Fwded_S,
        directoryL1C1_O_ReadShared,
        directoryL1C1_O_CleanUnique_SnpResp_I,
        directoryL1C1_O_CleanUnique_SnpRespData_I_PD,
        directoryL1C1_O_CleanUnique,
        directoryL1C1_O,
        directoryL1C1_M_WriteBackFull,
        directoryL1C1_M_ReadShared_SnpResp_O_Fwded_S,
        directoryL1C1_M_ReadShared,
        directoryL1C1_M_CleanUnique_SnpRespData_I_PD,
        directoryL1C1_M_CleanUnique,
        directoryL1C1_M,
        directoryL1C1_I_x_E_WriteBackFull,
        directoryL1C1_I_ReadShared,
        directoryL1C1_I_CleanUnique,
        directoryL1C1_I,
        directoryL1C1_E_WriteBackFull,
        directoryL1C1_E_ReadShared_SnpResp_S_Fwded_S,
        directoryL1C1_E_ReadShared_SnpResp_O_Fwded_S,
        directoryL1C1_E_ReadShared,
        directoryL1C1_E_CleanUnique_SnpResp_I,
        directoryL1C1_E_CleanUnique_SnpRespData_I_PD,
        directoryL1C1_E_CleanUnique,
        directoryL1C1_E
      };
      
      s_cacheL1C1: enum {
        cacheL1C1_UCE_load,
        cacheL1C1_UCE_evict_x_I,
        cacheL1C1_UCE_evict,
        cacheL1C1_UCE,
        cacheL1C1_S_store,
        cacheL1C1_S_evict_x_I,
        cacheL1C1_S_evict,
        cacheL1C1_S,
        cacheL1C1_O_store,
        cacheL1C1_O_evict_SnpCleanInvalid,
        cacheL1C1_O_evict,
        cacheL1C1_O,
        cacheL1C1_M_evict_SnpCleanInvalid,
        cacheL1C1_M_evict,
        cacheL1C1_M,
        cacheL1C1_I_store,
        cacheL1C1_I_load,
        cacheL1C1_I,
        cacheL1C1_E_evict_x_I,
        cacheL1C1_E_evict,
        cacheL1C1_E
      };
      
    ----Backend/Murphi/MurphiModular/Types/GenMachineSets
      -- Cluster: C1
      OBJSET_directoryL1C1: enum{directoryL1C1};
      OBJSET_directory1L1C1: enum{directory1L1C1};
      -- OBJSET_cacheL1C1: enum{cache0, cache1, cache2};
      OBJSET_cacheL1C1: scalarset(NrCachesL1C1);
      
      Machines: union{OBJSET_directoryL1C1, OBJSET_directory1L1C1, OBJSET_cacheL1C1};
    
    ----Backend/Murphi/MurphiModular/Types/GenCheckTypes
      ------Backend/Murphi/MurphiModular/Types/CheckTypes/GenPermType
        acc_type_obj: multiset[3] of PermissionType;
        PermMonitor: array[Machines] of array[Address] of acc_type_obj;
      
    
    ----Backend/Murphi/MurphiModular/Types/GenMessage
      Message: record
        adr: Address;
        mtype: MessageType;
        src: Machines;
        dst: Machines;
        cl: ClValue;
      end;
      
    ----Backend/Murphi/MurphiModular/Types/GenNetwork
      NET_Ordered: array[0..1] of array[0..O_NET_MAX-1] of Message;
      NET_Ordered_cnt: array[0..1] of 0..O_NET_MAX;
      NET_Unordered: array[Machines] of multiset[U_NET_MAX] of Message;

      NET_Ordered_snp: array[0..1] of array[0..O_NET_MAX_snp-1] of Message;
      NET_Ordered_cnt_snp: array[0..1] of 0..O_NET_MAX_snp;

-------------buf--------------------------------
      FIFO: record
        Queue: array[0..1] of Message; -- FIFO should be size 1
        QueueInd: 0..2;
        end;

      OBJ_FIFO: array[Machines] of FIFO;
-------------buf--------------------------------


    ----Backend/Murphi/MurphiModular/Types/GenMachines
      v_cacheL1C1: multiset[NrCachesL1C1] of Machines;
      cnt_v_cacheL1C1: 0..NrCachesL1C1;


      ENTRY_directoryL1C1: record
        State: s_directoryL1C1;
        cl: ClValue;
        acksReceivedL1C1: 0..NrCachesL1C1;
        acksExpectedL1C1: 0..NrCachesL1C1;
        cacheL1C1: v_cacheL1C1;
        ownerL1C1: Machines;
      end;
      
      MACH_directoryL1C1: record
        cb: array[Address] of ENTRY_directoryL1C1;
      end;
      
      OBJ_directoryL1C1: array[OBJSET_directoryL1C1] of MACH_directoryL1C1;
      OBJ_directory1L1C1: array[OBJSET_directory1L1C1] of MACH_directoryL1C1;
      
      ENTRY_cacheL1C1: record
        State: s_cacheL1C1;
        cl: ClValue;
      end;
      
      MACH_cacheL1C1: record
        cb: array[Address] of ENTRY_cacheL1C1;
      end;
      
      OBJ_cacheL1C1: array[OBJSET_cacheL1C1] of MACH_cacheL1C1;
    

  var
    --Backend/Murphi/MurphiModular/GenVars
    -- vndf
      snp: NET_Ordered_snp;
      cnt_snp: NET_Ordered_cnt_snp;
      rsp: NET_Ordered;
      cnt_rsp: NET_Ordered_cnt;
      req: NET_Ordered;
      cnt_req: NET_Ordered_cnt;
      dat: NET_Ordered;
      cnt_dat: NET_Ordered_cnt;

-------------buf--------------------------------
      buf_snp: OBJ_FIFO;
      buf_resp: OBJ_FIFO;
      buf_req: OBJ_FIFO;
      buf_dat: OBJ_FIFO;
---------------------------------------------
    
      g_perm: PermMonitor;
      i_directoryL1C1: OBJ_directoryL1C1;
      i_directory1L1C1: OBJ_directory1L1C1;
      i_cacheL1C1: OBJ_cacheL1C1;


  
--Backend/Murphi/MurphiModular/GenFunctions

  ----Backend/Murphi/MurphiModular/Functions/GenResetFunc
    procedure ResetMachine_directoryL1C1();
    begin
      for i:OBJSET_directoryL1C1 do
        for a:Address do
          i_directoryL1C1[i].cb[a].State := directoryL1C1_I;
          i_directoryL1C1[i].cb[a].cl := 0;
          undefine i_directoryL1C1[i].cb[a].cacheL1C1;
          undefine i_directoryL1C1[i].cb[a].ownerL1C1;
          i_directoryL1C1[i].cb[a].acksReceivedL1C1 := 0;
          i_directoryL1C1[i].cb[a].acksExpectedL1C1 := 0;
    
        endfor;
      endfor;

      for i:OBJSET_directory1L1C1 do
        for a:Address do
          i_directory1L1C1[i].cb[a].State := directoryL1C1_I;
          i_directory1L1C1[i].cb[a].cl := 0;
          undefine i_directory1L1C1[i].cb[a].cacheL1C1;
          undefine i_directory1L1C1[i].cb[a].ownerL1C1;
          i_directory1L1C1[i].cb[a].acksReceivedL1C1 := 0;
          i_directory1L1C1[i].cb[a].acksExpectedL1C1 := 0;
    
        endfor;
      endfor;

    end;
    
    procedure ResetMachine_cacheL1C1();
    begin
      for i:OBJSET_cacheL1C1 do
        for a:Address do
          i_cacheL1C1[i].cb[a].State := cacheL1C1_I;
          i_cacheL1C1[i].cb[a].cl := 0;
    
        endfor;
      endfor;
    end;
    
      procedure ResetMachine_();
      begin
      ResetMachine_directoryL1C1();
      ResetMachine_cacheL1C1();
      
      end;
  ----Backend/Murphi/MurphiModular/Functions/GenEventFunc
  ----Backend/Murphi/MurphiModular/Functions/GenPermFunc
    procedure Clear_perm(adr: Address; m: Machines);
    begin
      alias l_perm_set:g_perm[m][adr] do
          undefine l_perm_set;
      endalias;
    end;
    
    procedure Set_perm(acc_type: PermissionType; adr: Address; m: Machines);
    begin
      alias l_perm_set:g_perm[m][adr] do
      if MultiSetCount(i:l_perm_set, l_perm_set[i] = acc_type) = 0 then
          MultisetAdd(acc_type, l_perm_set);
      endif;
      endalias;
    end;
    
    procedure Reset_perm();
    begin
      for m:Machines do
        for adr:Address do
          Clear_perm(adr, m);
        endfor;
      endfor;
    end;
    
  
  ----Backend/Murphi/MurphiModular/Functions/GenVectorFunc
    -- .add()
    procedure AddElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 0 then
          MultiSetAdd(n, sv);
        endif;
    end;
    
    -- .del()
    procedure RemoveElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 1 then
          MultiSetRemovePred(i:sv, sv[i] = n);
        endif;
    end;
    
    -- .clear()
    procedure ClearVector_cacheL1C1(var sv:v_cacheL1C1;);
    begin
        MultiSetRemovePred(i:sv, true);
    end;
    
    -- .contains()
    function IsElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines) : boolean;
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
    function HasElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines) : boolean;
    begin
        if MultiSetCount(i:sv, true) = 0 then
          return false;
        endif;
    
        return true;
    end;
    
    -- .count()
    function VectorCount_cacheL1C1(var sv:v_cacheL1C1) : cnt_v_cacheL1C1;
    begin
        return MultiSetCount(i:sv, true);
    end;


-------------buf_func--------------------------------
-------------buf_func--------------------------------
-------------buf_func--------------------------------
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

-------------buf_func--------------------------------
-------------buf_func--------------------------------
-------------buf_func--------------------------------  



  ----Backend/Murphi/MurphiModular/Functions/GenFIFOFunc
  ----Backend/Murphi/MurphiModular/Functions/GenNetworkFunc
procedure Send_snp(msg:Message; src: Machines;);
      Assert(cnt_snp[0] < O_NET_MAX_snp) "Too many messages";
      Assert(cnt_snp[1] < O_NET_MAX_snp) "Too many messages";



      if (msg.adr = 0) then
      snp[0][cnt_snp[0]] := msg;
      cnt_snp[0] := cnt_snp[0] + 1;
      elsif (msg.adr = 1) then
      snp[0][cnt_snp[0]] := msg;
      cnt_snp[0] := cnt_snp[0] + 1;
      endif;

--     if (msg.dst = cache0) then
--       if (msg.adr = 0) then
--       snp[0][cnt_snp[0]] := msg;
--       cnt_snp[0] := cnt_snp[0] + 1;
--       else 
--       snp[0][cnt_snp[0]] := msg;
--       cnt_snp[0] := cnt_snp[0] + 1;
--       endif;
--     endif;
   
-- if (msg.dst = cache1) then
--     if (msg.adr = 0) then
--       snp[0][cnt_snp[0]] := msg;
--       cnt_snp[0] := cnt_snp[0] + 1;
--     else 
--       snp[0][cnt_snp[0]] := msg;
--       cnt_snp[0] := cnt_snp[0] + 1;
--     endif;
-- endif;

-- if (msg.dst = cache2) then
--     if (msg.adr = 0) then
--       snp[0][cnt_snp[0]] := msg;
--       cnt_snp[0] := cnt_snp[0] + 1;
--     else 
--       snp[0][cnt_snp[0]] := msg;
--       cnt_snp[0] := cnt_snp[0] + 1;
--     endif;
-- endif;

end;
    
procedure Pop_snp(n:0..1;);
    begin
      Assert (cnt_snp[n] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_snp[n]-1 do
        if i < cnt_snp[n]-1 then
          snp[n][i] := snp[n][i+1];
        else
          undefine snp[n][i];
        endif;
      endfor;
      cnt_snp[n] := cnt_snp[n] - 1;
    end;
    

procedure Send_rsp(msg:Message; src: Machines;);
      Assert(cnt_snp[0] < O_NET_MAX_snp) "Too many messages";
      Assert(cnt_snp[1] < O_NET_MAX_snp) "Too many messages";


      if (msg.adr = 0) then
      snp[0][cnt_snp[0]] := msg;
      cnt_snp[0] := cnt_snp[0] + 1;
      elsif (msg.adr = 1) then
      snp[0][cnt_snp[0]] := msg;
      cnt_snp[0] := cnt_snp[0] + 1;
      endif;

  -- if IsMember(msg.dst, OBJ_directoryL1C1) then
  --   rsp[0][cnt_rsp[0]] := msg;
  --   cnt_rsp[0] := cnt_rsp[0] + 1;
  -- endif;

  -- if IsMember(msg.dst, OBJSET_cacheL1C1) then
  --   if (msg.adr = 0) then
  --     rsp[0][cnt_rsp[0]] := msg;
  --     cnt_rsp[0] := cnt_rsp[0] + 1;
  --   else
  --     rsp[1][cnt_rsp[1]] := msg;
  --     cnt_rsp[1] := cnt_rsp[1] + 1;
  --   endif;
  -- endif;

  -- if IsMember(msg.dst, OBJ_directory1L1C1) then
  --   rsp[1][cnt_rsp[1]] := msg;
  --   cnt_rsp[1] := cnt_rsp[1] + 1;
  -- endif;

    end;
    
procedure Pop_rsp(n:0..1;);
    begin
      -- Assert (cnt_rsp[n] > 0) "Trying to advance empty Q";
      -- for i := 0 to cnt_rsp[n]-1 do
      --   if i < cnt_rsp[dst]-1 then
      --     rsp[n][i] := rsp[n][i+1];
      --   else
      --     undefine rsp[n][i];
      --   endif;
      -- endfor;
      -- cnt_rsp[n] := cnt_rsp[n] - 1;

      Assert (cnt_snp[n] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_snp[n]-1 do
        if i < cnt_snp[n]-1 then
          snp[n][i] := snp[n][i+1];
        else
          undefine snp[n][i];
        endif;
      endfor;
      cnt_snp[n] := cnt_snp[n] - 1;
    end;
    
procedure Send_req(msg:Message; src: Machines;);
      Assert(cnt_req[0] < O_NET_MAX) "Too many messages";
      Assert(cnt_req[1] < O_NET_MAX) "Too many messages";
      -- req[msg.dst][cnt_req[msg.dst]] := msg;
      -- cnt_req[msg.dst] := cnt_req[msg.dst] + 1;

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

  if IsMember(msg.dst, OBJSET_directory1L1C1) then
    req[1][cnt_req[1]] := msg;
    cnt_req[1] := cnt_req[1] + 1;
  endif;

end;
    
    procedure Pop_req(n:0..1;);
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
    
procedure Send_dat(msg:Message; src: Machines;);
      Assert(cnt_snp[0] < O_NET_MAX_snp) "Too many messages";
      Assert(cnt_snp[1] < O_NET_MAX_snp) "Too many messages";


      if (msg.adr = 0) then
      snp[0][cnt_snp[0]] := msg;
      cnt_snp[0] := cnt_snp[0] + 1;
      elsif (msg.adr = 1) then
      snp[0][cnt_snp[0]] := msg;
      cnt_snp[0] := cnt_snp[0] + 1;
      endif;
      
  -- if IsMember(msg.dst, OBJ_directoryL1C1) then
  --   dat[0][cnt_dat[0]] := msg;
  --   cnt_dat[0] := cnt_dat[0] + 1;
  -- endif;

  -- if IsMember(msg.dst, OBJSET_cacheL1C1) then
  --   if (msg.adr = 0) then
  --     dat[0][cnt_dat[0]] := msg;
  --     cnt_dat[0] := cnt_dat[0] + 1;
  --   else
  --     dat[1][cnt_dat[1]] := msg;
  --     cnt_dat[1] := cnt_dat[1] + 1;
  --   endif;
  -- endif;

  -- if IsMember(msg.dst, OBJ_directory1L1C1) then
  --   dat[1][cnt_dat[1]] := msg;
  --   cnt_dat[1] := cnt_dat[1] + 1;
  -- endif;

    end;
    
procedure Pop_dat(n:0..1;);
    begin
      -- Assert (cnt_dat[n] > 0) "Trying to advance empty Q";
      -- for i := 0 to cnt_dat[n]-1 do
      --   if i < cnt_dat[n]-1 then
      --     dat[n][i] := dat[n][i+1];
      --   else
      --     undefine dat[n][i];
      --   endif;
      -- endfor;
      -- cnt_dat[n] := cnt_dat[n] - 1;
      Assert (cnt_snp[n] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_snp[n]-1 do
        if i < cnt_snp[n]-1 then
          snp[n][i] := snp[n][i+1];
        else
          undefine snp[n][i];
        endif;
      endfor;
      cnt_snp[n] := cnt_snp[n] - 1;
    end;
    
    procedure Multicast_snp_v_cacheL1C1(var msg: Message; dst_vect: v_cacheL1C1; src: Machines;);
    begin
          for n:Machines do
              if n!=msg.src then
                if MultiSetCount(i:dst_vect, dst_vect[i] = n) = 1 then
                  msg.dst := n;
                  Send_snp(msg, src);
                endif;
              endif;
          endfor;
    end;
    
    function req_network_ready(): boolean;
    begin
          -- for dst:Machines do
          for n:0..1 do
            for src: Machines do
              if cnt_req[n] >= (O_NET_MAX-4) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;

    function rsp_network_ready(): boolean;
    begin
          -- for dst:Machines do
          for n:0..1 do
            for src: Machines do
              if cnt_rsp[n] >= (O_NET_MAX-4) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;

    function snp_network_ready(): boolean;
    begin
          -- for dst:Machines do
          for n:0..1 do
            for src: Machines do
              if cnt_snp[n] >= (O_NET_MAX-4) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;

    function dat_network_ready(): boolean;
    begin
          -- for dst:Machines do
          for n:0..1 do
            for src: Machines do
              if cnt_dat[n] >= (O_NET_MAX-4) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;

    function network_ready(): boolean;
    begin
            if !req_network_ready() then
            return false;
          endif;
    
    
          if !rsp_network_ready() then
            return false;
          endif;
    
    
          if !snp_network_ready() then
            return false;
          endif;
    
    
          if !dat_network_ready() then
            return false;
          endif;
    
    
    
      return true;
    end;
    
    procedure Reset_NET_();
    begin
      
      undefine req;
      -- for dst:Machines do
      for n:0..1 do
          cnt_req[n] := 0;
      endfor;
      
      undefine dat;
      -- for dst:Machines do
      for n:0..1 do
          cnt_dat[n] := 0;
      endfor;
      
      undefine rsp;
      -- for dst:Machines do
      for n:0..1 do
          cnt_rsp[n] := 0;
      endfor;
      
      undefine snp;
      -- for dst:Machines do
      for n:0..1 do
          cnt_snp[n] := 0;
      endfor;

  for i:Machines do
      undefine buf_snp[i].Queue;
      buf_snp[i].QueueInd:=0;
     endfor;
  
  for i:Machines do
      undefine buf_resp[i].Queue;
      buf_resp[i].QueueInd:=0;
  endfor;
  
  for i:Machines do
      undefine buf_req[i].Queue;
      buf_req[i].QueueInd:=0;
  endfor;
    
 for i:Machines do
      undefine buf_dat[i].Queue;
      buf_dat[i].QueueInd:=0;
  endfor;

    end;
    
  
  ----Backend/Murphi/MurphiModular/Functions/GenMessageConstrFunc
    function RequestL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
    return Message;
    end;
    
    function AckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
    return Message;
    end;
    
    function RespL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
    return Message;
    end;
    
    function DatL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
      Message.cl := cl;
    return Message;
    end;
    
  

--Backend/Murphi/MurphiModular/GenStateMachines

  ----Backend/Murphi/MurphiModular/StateMachines/GenAccessStateMachines
    procedure FSM_Access_cacheL1C1_E_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      
      if (adr = 0) then
      msg := RequestL1C1(adr, EvictL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, EvictL1C1, m, directory1L1C1);
      end;

      Send_req(msg, m);
      cbe.State := cacheL1C1_E_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_E_load(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_E;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_E_store(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_I_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, ReadSharedL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, ReadSharedL1C1, m, directory1L1C1);
      end;


      Send_req(msg, m);
      cbe.State := cacheL1C1_I_load;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_I_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, CleanUniqueL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, CleanUniqueL1C1, m, directory1L1C1);
      end;

      -- msg := RequestL1C1(adr, CleanUniqueL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_I_store;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, WriteBackFullL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, WriteBackFullL1C1, m, directory1L1C1);
      end;

      -- msg := RequestL1C1(adr, WriteBackFullL1C1, m, directoryL1C1);

      Send_req(msg, m);
      cbe.State := cacheL1C1_M_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_load(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_M_store(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_O_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      if (adr = 0) then
      msg := RequestL1C1(adr, WriteBackFullL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, WriteBackFullL1C1, m, directory1L1C1);
      end;

      -- msg := RequestL1C1(adr, WriteBackFullL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_O_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_O_load(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_O;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_O_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, CleanUniqueL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, CleanUniqueL1C1, m, directory1L1C1);
      end;

      -- msg := RequestL1C1(adr, CleanUniqueL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_O_store;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, EvictL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, EvictL1C1, m, directory1L1C1);
      end;


      -- msg := RequestL1C1(adr, EvictL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_S_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_load(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_S;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, CleanUniqueL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, CleanUniqueL1C1, m, directory1L1C1);
      end;



      -- msg := RequestL1C1(adr, CleanUniqueL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_S_store;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_UCE_evict(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, EvictL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, EvictL1C1, m, directory1L1C1);
      end;


      -- msg := RequestL1C1(adr, EvictL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_UCE_evict;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_UCE_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do

      if (adr = 0) then
      msg := RequestL1C1(adr, ReadSharedL1C1, m, directoryL1C1);
      elsif (adr = 1) then
      msg := RequestL1C1(adr, ReadSharedL1C1, m, directory1L1C1);
      end;

      -- msg := RequestL1C1(adr, ReadSharedL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_UCE_load;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_UCE_store(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_M;
    endalias;
    end;
    
  ----Backend/Murphi/MurphiModular/StateMachines/GenMessageStateMachines
    function FSM_MSG_directoryL1C1(inmsg:Message; m:OBJSET_directoryL1C1) : boolean;
    var msg: Message;
    begin
      alias adr: inmsg.adr do
      alias cbe: i_directoryL1C1[m].cb[adr] do
    switch cbe.State
      case directoryL1C1_E:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,cbe.ownerL1C1);
          Send_snp(msg, m);
          --clear
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            undefine cbe.ownerL1C1;
            ClearVector_cacheL1C1(cbe.cacheL1C1);

            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_E;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;            
            return true;
          endif;
        
        case ReadSharedL1C1:
          msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
          Send_snp(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_CleanUnique:
      switch inmsg.mtype
        case SnpRespData_I_PDL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_CleanUnique_SnpRespData_I_PD;
          return true;
        
        case SnpResp_IL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_CleanUnique_SnpResp_I;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
           
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_ReadShared:
      switch inmsg.mtype
        case SnpResp_O_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        case SnpResp_S_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_ReadShared_SnpResp_S_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_ReadShared_SnpResp_S_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
       
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
            undefine cbe.ownerL1C1;
            ClearVector_cacheL1C1(cbe.cacheL1C1);


            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              ClearVector_cacheL1C1(cbe.cacheL1C1);
             undefine cbe.ownerL1C1;
            return true;
          endif;
        
        case ReadSharedL1C1:
          msg := DatL1C1(adr,CompData_EL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I_x_E_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I_CleanUnique:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I_ReadShared:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I_x_E_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,cbe.ownerL1C1);
          Send_snp(msg, m);
          --clear
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        case ReadSharedL1C1:
          msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
          Send_snp(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_CleanUnique:
      switch inmsg.mtype
        case SnpRespData_I_PDL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_CleanUnique_SnpRespData_I_PD;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_ReadShared:
      switch inmsg.mtype
        case SnpResp_O_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);

          cbe.State := directoryL1C1_M;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
  
          undefine cbe.ownerL1C1;
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          cbe.acksExpectedL1C1 := VectorCount_cacheL1C1(cbe.cacheL1C1);
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            cbe.acksExpectedL1C1 := cbe.acksExpectedL1C1-1;
            cbe.acksReceivedL1C1 := 0;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_O_CleanUnique;

              return true;
            endif;
            if (cbe.acksExpectedL1C1 != 0) then
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
                return true;
              endif;
              if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
             
                return true;
              endif;
            endif;
          endif;
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            cbe.acksReceivedL1C1 := 0;
            if (cbe.acksExpectedL1C1 != 0) then
              if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
              -- cbe.acksReceivedL1C1 := 0;
              -- cbe.acksExpectedL1C1 := 0;                
                return true;
              endif;
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
              -- cbe.acksReceivedL1C1 := 0;
              -- cbe.acksExpectedL1C1 := 0;                
                return true;
              endif;
            endif;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_O_CleanUnique;
              -- cbe.acksReceivedL1C1 := 0;
              -- cbe.acksExpectedL1C1 := 0;              
              return true;
            endif;
          endif;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_I;
              undefine cbe.ownerL1C1;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              
              return true;
            endif;
            if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_O;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
          endif;
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
            return true;
          endif;
        
        case ReadSharedL1C1:
          msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
          Send_snp(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_CleanUnique:
      switch inmsg.mtype
        case CompAckL1C1:
          if (inmsg.src = cbe.ownerL1C1) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
              
            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
            if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_E;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
          endif;
        
        case SnpRespData_I_PDL1C1:
          cbe.cl := inmsg.cl;
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique;
            return true;
          endif;
          if (cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            msg := RespL1C1(adr,Comp_EL1C1,m,inmsg.src);
            Send_rsp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique_SnpRespData_I_PD;
            return true;
          endif;
        
        case SnpResp_IL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique;
            return true;
          endif;
          if (cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            msg := RespL1C1(adr,Comp_EL1C1,m,inmsg.src);
            Send_rsp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique_SnpResp_I;

            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          if (inmsg.src = cbe.ownerL1C1) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


              return true;
            endif;
            if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              ClearVector_cacheL1C1(cbe.cacheL1C1);
              return true;
            endif;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          if !(inmsg.src = cbe.ownerL1C1) then
            if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              ClearVector_cacheL1C1(cbe.cacheL1C1);
              return true;
            endif;
            if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


              return true;
            endif;
          endif;
          if (inmsg.src = cbe.ownerL1C1) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_ReadShared:
      switch inmsg.mtype
        case SnpResp_O_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
          return true;
        
        case CBWR_Data_O_PDL1C1:
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;
          endif;
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          cbe.ownerL1C1 := inmsg.src;
          cbe.acksExpectedL1C1 := VectorCount_cacheL1C1(cbe.cacheL1C1);
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            cbe.acksReceivedL1C1 := 0;
            if (cbe.acksExpectedL1C1 != 0) then
              if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
            endif;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S_CleanUnique;
              return true;
            endif;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            cbe.acksExpectedL1C1 := cbe.acksExpectedL1C1-1;
            cbe.acksReceivedL1C1 := 0;
            if (cbe.acksExpectedL1C1 != 0) then
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
              if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
            endif;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S_CleanUnique;
              return true;
            endif;
          endif;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
            return true;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S;
             
              undefine cbe.ownerL1C1;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
              return true;
            endif;
            if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_I;
              
              undefine cbe.ownerL1C1;
              ClearVector_cacheL1C1(cbe.cacheL1C1);

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
          endif;
        
        case ReadSharedL1C1:
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_CleanUnique:
      switch inmsg.mtype
        case CompAckL1C1:
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              ClearVector_cacheL1C1(cbe.cacheL1C1);


            return true;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
        
        case SnpResp_IL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S_CleanUnique;
            return true;
          endif;
          if (cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
            Send_rsp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S_CleanUnique_SnpResp_I;
-- notsure
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;

          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_ReadShared:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,cbe.ownerL1C1);
          Send_snp(msg, m);
          --clear
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            ClearVector_cacheL1C1(cbe.cacheL1C1);

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
        
        case ReadSharedL1C1:
          if (inmsg.src = cbe.ownerL1C1) then
            msg := DatL1C1(adr,CompData_EL1C1,m,inmsg.src,cbe.cl);
            Send_dat(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE_ReadShared;
            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
            Send_snp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE_ReadShared;
            return true;
          endif;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_CleanUnique:
      switch inmsg.mtype
        case SnpRespData_I_PDL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_CleanUnique_SnpRespData_I_PD;
          return true;
        
        case SnpResp_IL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_CleanUnique_SnpResp_I;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_ReadShared:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        case SnpResp_IL1C1:
          cbe.ownerL1C1 := inmsg.src;
          msg := DatL1C1(adr,CompData_EL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_ReadShared_SnpResp_I;
          return true;
        
        case SnpResp_O_Fwded_SL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_ReadShared_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            ClearVector_cacheL1C1(cbe.cacheL1C1);

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          ClearVector_cacheL1C1(cbe.cacheL1C1);
              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

          return true;
        
        else return false;
      endswitch;
      
    endswitch;
    endalias;
    endalias;
    return false;
    end;
    
----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------
    function FSM_MSG_directory1L1C1(inmsg:Message; m:OBJSET_directory1L1C1) : boolean;
    var msg: Message;
    begin
      alias adr: inmsg.adr do
      alias cbe: i_directory1L1C1[m].cb[adr] do
    switch cbe.State
      case directoryL1C1_E:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,cbe.ownerL1C1);
          Send_snp(msg, m);
          --clear
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            undefine cbe.ownerL1C1;
            ClearVector_cacheL1C1(cbe.cacheL1C1);

            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_E;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;            
            return true;
          endif;
        
        case ReadSharedL1C1:
          msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
          Send_snp(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_CleanUnique:
      switch inmsg.mtype
        case SnpRespData_I_PDL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_CleanUnique_SnpRespData_I_PD;
          return true;
        
        case SnpResp_IL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_CleanUnique_SnpResp_I;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
           
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_ReadShared:
      switch inmsg.mtype
        case SnpResp_O_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        case SnpResp_S_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E_ReadShared_SnpResp_S_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_ReadShared_SnpResp_S_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
       
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_E_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
            undefine cbe.ownerL1C1;
            ClearVector_cacheL1C1(cbe.cacheL1C1);


            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              ClearVector_cacheL1C1(cbe.cacheL1C1);
             undefine cbe.ownerL1C1;
            return true;
          endif;
        
        case ReadSharedL1C1:
          msg := DatL1C1(adr,CompData_EL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I_x_E_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I_CleanUnique:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
              ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I_ReadShared:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_I_x_E_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,cbe.ownerL1C1);
          Send_snp(msg, m);
          --clear
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        case ReadSharedL1C1:
          msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
          Send_snp(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_CleanUnique:
      switch inmsg.mtype
        case SnpRespData_I_PDL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_CleanUnique_SnpRespData_I_PD;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_ReadShared:
      switch inmsg.mtype
        case SnpResp_O_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_M_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_M_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);

          cbe.State := directoryL1C1_M;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   

          return true;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;   
  
          undefine cbe.ownerL1C1;
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          cbe.acksExpectedL1C1 := VectorCount_cacheL1C1(cbe.cacheL1C1);
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            cbe.acksExpectedL1C1 := cbe.acksExpectedL1C1-1;
            cbe.acksReceivedL1C1 := 0;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_O_CleanUnique;

              return true;
            endif;
            if (cbe.acksExpectedL1C1 != 0) then
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
                return true;
              endif;
              if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
             
                return true;
              endif;
            endif;
          endif;
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            cbe.acksReceivedL1C1 := 0;
            if (cbe.acksExpectedL1C1 != 0) then
              if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
              -- cbe.acksReceivedL1C1 := 0;
              -- cbe.acksExpectedL1C1 := 0;                
                return true;
              endif;
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,inmsg.src,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_O_CleanUnique;
              -- cbe.acksReceivedL1C1 := 0;
              -- cbe.acksExpectedL1C1 := 0;                
                return true;
              endif;
            endif;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_O_CleanUnique;
              -- cbe.acksReceivedL1C1 := 0;
              -- cbe.acksExpectedL1C1 := 0;              
              return true;
            endif;
          endif;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_I;
              undefine cbe.ownerL1C1;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              
              return true;
            endif;
            if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_O;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
          endif;
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
            return true;
          endif;
        
        case ReadSharedL1C1:
          msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
          Send_snp(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_CleanUnique:
      switch inmsg.mtype
        case CompAckL1C1:
          if (inmsg.src = cbe.ownerL1C1) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
              
            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
            if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_E;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
          endif;
        
        case SnpRespData_I_PDL1C1:
          cbe.cl := inmsg.cl;
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique;
            return true;
          endif;
          if (cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            msg := RespL1C1(adr,Comp_EL1C1,m,inmsg.src);
            Send_rsp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique_SnpRespData_I_PD;
            return true;
          endif;
        
        case SnpResp_IL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique;
            return true;
          endif;
          if (cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            msg := RespL1C1(adr,Comp_EL1C1,m,inmsg.src);
            Send_rsp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_O_CleanUnique_SnpResp_I;

            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          if (inmsg.src = cbe.ownerL1C1) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


              return true;
            endif;
            if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              ClearVector_cacheL1C1(cbe.cacheL1C1);
              return true;
            endif;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          if !(inmsg.src = cbe.ownerL1C1) then
            if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              ClearVector_cacheL1C1(cbe.cacheL1C1);
              return true;
            endif;
            if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
              cbe.ownerL1C1 := inmsg.src;
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


              return true;
            endif;
          endif;
          if (inmsg.src = cbe.ownerL1C1) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_M;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_ReadShared:
      switch inmsg.mtype
        case SnpResp_O_Fwded_SL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_O_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
          return true;
        
        case CBWR_Data_O_PDL1C1:
          if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;
          endif;
          if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            cbe.cl := inmsg.cl;
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          cbe.ownerL1C1 := inmsg.src;
          cbe.acksExpectedL1C1 := VectorCount_cacheL1C1(cbe.cacheL1C1);
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            cbe.acksReceivedL1C1 := 0;
            if (cbe.acksExpectedL1C1 != 0) then
              if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
            endif;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S_CleanUnique;
              return true;
            endif;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            cbe.acksExpectedL1C1 := cbe.acksExpectedL1C1-1;
            cbe.acksReceivedL1C1 := 0;
            if (cbe.acksExpectedL1C1 != 0) then
              if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
              if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
                RemoveElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,m);
                Multicast_snp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
                ClearVector_cacheL1C1(cbe.cacheL1C1);
                AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
                Clear_perm(adr, m);
                cbe.State := directoryL1C1_S_CleanUnique;
                return true;
              endif;
            endif;
            if !(cbe.acksExpectedL1C1 != 0) then
              msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
              Send_rsp(msg, m);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S_CleanUnique;
              return true;
            endif;
          endif;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
            return true;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S;
             
              undefine cbe.ownerL1C1;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
              return true;
            endif;
            if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 1) then
              RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_I;
              
              undefine cbe.ownerL1C1;
              ClearVector_cacheL1C1(cbe.cacheL1C1);

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              return true;
            endif;
          endif;
        
        case ReadSharedL1C1:
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S_ReadShared;
          return true;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_CleanUnique:
      switch inmsg.mtype
        case CompAckL1C1:
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

              ClearVector_cacheL1C1(cbe.cacheL1C1);


            return true;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
        
        case SnpResp_IL1C1:
          cbe.acksReceivedL1C1 := cbe.acksReceivedL1C1+1;
          if !(cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S_CleanUnique;
            return true;
          endif;
          if (cbe.acksReceivedL1C1 = cbe.acksExpectedL1C1) then
            msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
            Send_rsp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S_CleanUnique_SnpResp_I;
-- notsure
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1)) then
            ClearVector_cacheL1C1(cbe.cacheL1C1);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

            return true;

          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_ReadShared:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE:
      switch inmsg.mtype
        case CleanUniqueL1C1:
          msg := RequestL1C1(adr,SnpCleanInvalidL1C1,m,cbe.ownerL1C1);
          Send_snp(msg, m);
          --clear
          ClearVector_cacheL1C1(cbe.cacheL1C1);
          cbe.ownerL1C1 := inmsg.src;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_CleanUnique;
          return true;
        
        case EvictL1C1:
          msg := RespL1C1(adr,Comp_IL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            ClearVector_cacheL1C1(cbe.cacheL1C1);

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
        
        case ReadSharedL1C1:
          if (inmsg.src = cbe.ownerL1C1) then
            msg := DatL1C1(adr,CompData_EL1C1,m,inmsg.src,cbe.cl);
            Send_dat(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE_ReadShared;
            return true;
          endif;
          if !(inmsg.src = cbe.ownerL1C1) then
            msg := RequestL1C1(adr,SnpSharedFwdL1C1,inmsg.src,cbe.ownerL1C1);
            Send_snp(msg, m);
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE_ReadShared;
            return true;
          endif;
        
        case WriteBackFullL1C1:
          msg := RespL1C1(adr,CompDBIDRespL1C1,m,inmsg.src);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_WriteBackFull;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_CleanUnique:
      switch inmsg.mtype
        case SnpRespData_I_PDL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_CleanUnique_SnpRespData_I_PD;
          return true;
        
        case SnpResp_IL1C1:
          msg := RespL1C1(adr,Comp_EL1C1,m,cbe.ownerL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_CleanUnique_SnpResp_I;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_CleanUnique_SnpRespData_I_PD:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_CleanUnique_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_ReadShared:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;

              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        case SnpResp_IL1C1:
          cbe.ownerL1C1 := inmsg.src;
          msg := DatL1C1(adr,CompData_EL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_ReadShared_SnpResp_I;
          return true;
        
        case SnpResp_O_Fwded_SL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, cbe.ownerL1C1);
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_UCE_ReadShared_SnpResp_O_Fwded_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_ReadShared_SnpResp_I:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_E;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_ReadShared_SnpResp_O_Fwded_S:
      switch inmsg.mtype
        case CompAckL1C1:
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_O;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_UCE_WriteBackFull:
      switch inmsg.mtype
        case CBWR_Data_IL1C1:
          if !(inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_UCE;


              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
          if (inmsg.src = cbe.ownerL1C1) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            ClearVector_cacheL1C1(cbe.cacheL1C1);

              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;


            return true;
          endif;
        
        case CBWR_Data_M_PDL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_I;
          ClearVector_cacheL1C1(cbe.cacheL1C1);
              undefine cbe.ownerL1C1;
              cbe.acksReceivedL1C1 := 0;
              cbe.acksExpectedL1C1 := 0;

          return true;
        
        else return false;
      endswitch;
      
    endswitch;
    endalias;
    endalias;
    return false;
    end;
----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------
----------- directory function end--------------------------------------------------------------------



    function FSM_MSG_cacheL1C1(inmsg:Message; m:OBJSET_cacheL1C1) : boolean;
    var msg: Message;
    begin
      alias adr: inmsg.adr do
      alias cbe: i_cacheL1C1[m].cb[adr] do
    switch cbe.State
      case cacheL1C1_E:
      switch inmsg.mtype
        case SnpCleanInvalidL1C1:

      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directory1L1C1);
      end;


          -- msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpSharedFwdL1C1:

      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_S_Fwded_SL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_S_Fwded_SL1C1,m,directory1L1C1);
      end;
      
          -- msg := RespL1C1(adr,SnpResp_S_Fwded_SL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_E_evict:
      switch inmsg.mtype
        case Comp_IL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_E_evict_x_I;
          return true;
        
        case SnpSharedFwdL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_S_Fwded_SL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_S_Fwded_SL1C1,m,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_S_Fwded_SL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_S_evict;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_E_evict_x_I:
      switch inmsg.mtype
        case Comp_IL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I:
      switch inmsg.mtype
        else return false;
      endswitch;
      
      case cacheL1C1_I_load:
      switch inmsg.mtype
        case CompData_EL1C1:
          cbe.cl := inmsg.cl;
      if (adr = 0) then
          msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := AckL1C1(adr,CompAckL1C1,m,directory1L1C1);
      end;

          -- msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
          cbe.State := cacheL1C1_E;
          return true;
        
        case CompData_SL1C1:
          cbe.cl := inmsg.cl;
      if (adr = 0) then
          msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := AckL1C1(adr,CompAckL1C1,m,directory1L1C1);
      end;

          -- msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_store:
      switch inmsg.mtype
        case Comp_EL1C1:
      if (adr = 0) then
         msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
      elsif (adr = 1) then
         msg := AckL1C1(adr,CompAckL1C1,m,directory1L1C1);
      end;

          -- msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m); Set_perm(store, adr, m);
          cbe.State := cacheL1C1_UCE;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_M:
      switch inmsg.mtype
        case SnpCleanInvalidL1C1:

      if (adr = 0) then
         msg := DatL1C1(adr,SnpRespData_I_PDL1C1,m,directoryL1C1,cbe.cl);
      elsif (adr = 1) then
         msg := DatL1C1(adr,SnpRespData_I_PDL1C1,m,directory1L1C1,cbe.cl);
      end;

          -- msg := DatL1C1(adr,SnpRespData_I_PDL1C1,m,directoryL1C1,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpSharedFwdL1C1:

      if (adr = 0) then
         msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
         msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,inmsg.src,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_O;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_M_evict:
      switch inmsg.mtype
        case CompDBIDRespL1C1:
      if (adr = 0) then
         msg := DatL1C1(adr,CBWR_Data_M_PDL1C1,m,directoryL1C1,cbe.cl);
      elsif (adr = 1) then
         msg := DatL1C1(adr,CBWR_Data_M_PDL1C1,m,directory1L1C1,cbe.cl);
      end;

          -- msg := DatL1C1(adr,CBWR_Data_M_PDL1C1,m,directoryL1C1,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
         msg := DatL1C1(adr,SnpRespData_I_PDL1C1,m,directoryL1C1,cbe.cl);
      elsif (adr = 1) then
         msg := DatL1C1(adr,SnpRespData_I_PDL1C1,m,directory1L1C1,cbe.cl);
      end;

          -- msg := DatL1C1(adr,SnpRespData_I_PDL1C1,m,directoryL1C1,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_M_evict_SnpCleanInvalid;
          return true;
        
        case SnpSharedFwdL1C1:
      if (adr = 0) then
         msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
         msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,inmsg.src,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_O_evict;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_M_evict_SnpCleanInvalid:
      switch inmsg.mtype
        case CompDBIDRespL1C1:

      if (adr = 0) then
         msg := RespL1C1(adr,CBWR_Data_IL1C1,m,directoryL1C1);
      elsif (adr = 1) then
         msg := RespL1C1(adr,CBWR_Data_IL1C1,m,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,CBWR_Data_IL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_O:
      switch inmsg.mtype
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
         msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directoryL1C1,cbe.cl);
      elsif (adr = 1) then
         msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directory1L1C1,cbe.cl);
      end;

          -- msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directoryL1C1,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpSharedFwdL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_O;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_O_evict:
      switch inmsg.mtype
        case CompDBIDRespL1C1:
      if (adr = 0) then
          msg := DatL1C1(adr,CBWR_Data_O_PDL1C1,m,directoryL1C1,cbe.cl);
      elsif (adr = 1) then
          msg := DatL1C1(adr,CBWR_Data_O_PDL1C1,m,directory1L1C1,cbe.cl);
      end;

          -- msg := DatL1C1(adr,CBWR_Data_O_PDL1C1,m,directoryL1C1,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
          msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directoryL1C1,cbe.cl);
      elsif (adr = 1) then
          msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directory1L1C1,cbe.cl);
      end;

          -- msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directoryL1C1,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_O_evict_SnpCleanInvalid;
          return true;
        
        case SnpSharedFwdL1C1:

      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directory1L1C1);
      end;

          Send_rsp(msg, m);
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_O_evict;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_O_evict_SnpCleanInvalid:
      switch inmsg.mtype
        case CompDBIDRespL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,CBWR_Data_IL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,CBWR_Data_IL1C1,m,directory1L1C1);
      end;
          -- msg := RespL1C1(adr,CBWR_Data_IL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_O_store:
      switch inmsg.mtype
        case Comp_EL1C1:
      if (adr = 0) then
          msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := AckL1C1(adr,CompAckL1C1,m,directory1L1C1);
      end;

          -- msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
          cbe.State := cacheL1C1_M;
          return true;
        
        case SnpCleanInvalidL1C1:

      if (adr = 0) then
          msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directoryL1C1,cbe.cl);
      elsif (adr = 1) then
          msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directory1L1C1,cbe.cl);
      end;

          -- msg := DatL1C1(adr,SnpRespData_I_PDL1C1,inmsg.src,directoryL1C1,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_store;
          return true;
        
        case SnpSharedFwdL1C1:

      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_O_Fwded_SL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          msg := DatL1C1(adr,CompData_SL1C1,m,inmsg.src,cbe.cl);
          Send_dat(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_O_store;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S:
      switch inmsg.mtype
        case SnpCleanInvalidL1C1:

      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directory1L1C1);
      end;
          -- msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_evict:
      switch inmsg.mtype
        case Comp_IL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directory1L1C1);
      end;
      
          -- msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_S_evict_x_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_evict_x_I:
      switch inmsg.mtype
        case Comp_IL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_store:
      switch inmsg.mtype
        case Comp_EL1C1:

      if (adr = 0) then
          msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := AckL1C1(adr,CompAckL1C1,m,directory1L1C1);
      end;

          -- msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
          cbe.State := cacheL1C1_E;
          return true;
        
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directory1L1C1);
      end;
          -- msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_store;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_UCE:
      switch inmsg.mtype
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directory1L1C1);
      end;
          -- msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpSharedFwdL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directory1L1C1);
      end;
          -- msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_UCE_evict:
      switch inmsg.mtype
        case Comp_IL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_UCE_evict_x_I;
          return true;
        
        case SnpSharedFwdL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_UCE_evict_x_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_UCE_evict_x_I:
      switch inmsg.mtype
        case Comp_IL1C1:
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_UCE_load:
      switch inmsg.mtype
        case CompData_EL1C1:
          cbe.cl := inmsg.cl;
      if (adr = 0) then
          msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := AckL1C1(adr,CompAckL1C1,m,directory1L1C1);
      end;

          -- msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m); Set_perm(store, adr, m);
          cbe.State := cacheL1C1_E;
          return true;
        
        case CompData_SL1C1:
          cbe.cl := inmsg.cl;
      if (adr = 0) then
          msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := AckL1C1(adr,CompAckL1C1,m,directory1L1C1);
      end;

          -- msg := AckL1C1(adr,CompAckL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        case SnpCleanInvalidL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,m,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_IL1C1,m,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_load;
          return true;
        
        case SnpSharedFwdL1C1:
      if (adr = 0) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
      elsif (adr = 1) then
          msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directory1L1C1);
      end;

          -- msg := RespL1C1(adr,SnpResp_IL1C1,inmsg.src,directoryL1C1);
          Send_rsp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_load;
          return true;
        
        else return false;
      endswitch;
      
    endswitch;
    endalias;
    endalias;
    return false;
    end;

----------- cache function end--------------------------------------------------------------------
----------- cache function end--------------------------------------------------------------------
----------- cache function end--------------------------------------------------------------------



--Backend/Murphi/MurphiModular/GenResetFunc

  procedure System_Reset();
  begin
  Reset_perm();
  Reset_NET_();
  ResetMachine_();
  end;
  

--Backend/Murphi/MurphiModular/GenRules
  ----Backend/Murphi/MurphiModular/Rules/GenAccessRuleSet
    ruleset m:OBJSET_cacheL1C1 do
    ruleset adr:Address do
      alias cbe:i_cacheL1C1[m].cb[adr] do
    
      rule "cacheL1C1_E_evict"
        cbe.State = cacheL1C1_E & network_ready() 
      ==>
        FSM_Access_cacheL1C1_E_evict(adr, m);
        
      endrule;
    
      rule "cacheL1C1_E_load"
        cbe.State = cacheL1C1_E 
      ==>
        FSM_Access_cacheL1C1_E_load(adr, m);
        
      endrule;
    
      rule "cacheL1C1_E_store"
        cbe.State = cacheL1C1_E 
      ==>
        FSM_Access_cacheL1C1_E_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_I_store"
        cbe.State = cacheL1C1_I & network_ready() 
      ==>
        FSM_Access_cacheL1C1_I_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_I_load"
        cbe.State = cacheL1C1_I & network_ready() 
      ==>
        FSM_Access_cacheL1C1_I_load(adr, m);
        
      endrule;
    
      rule "cacheL1C1_M_load"
        cbe.State = cacheL1C1_M 
      ==>
        FSM_Access_cacheL1C1_M_load(adr, m);
        
      endrule;
    
      rule "cacheL1C1_M_store"
        cbe.State = cacheL1C1_M 
      ==>
        FSM_Access_cacheL1C1_M_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_M_evict"
        cbe.State = cacheL1C1_M & network_ready() 
      ==>
        FSM_Access_cacheL1C1_M_evict(adr, m);
        
      endrule;
    
      rule "cacheL1C1_O_load"
        cbe.State = cacheL1C1_O 
      ==>
        FSM_Access_cacheL1C1_O_load(adr, m);
        
      endrule;
    
      rule "cacheL1C1_O_store"
        cbe.State = cacheL1C1_O & network_ready() 
      ==>
        FSM_Access_cacheL1C1_O_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_O_evict"
        cbe.State = cacheL1C1_O & network_ready() 
      ==>
        FSM_Access_cacheL1C1_O_evict(adr, m);
        
      endrule;
    
      rule "cacheL1C1_S_evict"
        cbe.State = cacheL1C1_S & network_ready() 
      ==>
        FSM_Access_cacheL1C1_S_evict(adr, m);
        
      endrule;
    
      rule "cacheL1C1_S_store"
        cbe.State = cacheL1C1_S & network_ready() 
      ==>
        FSM_Access_cacheL1C1_S_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_S_load"
        cbe.State = cacheL1C1_S 
      ==>
        FSM_Access_cacheL1C1_S_load(adr, m);
        
      endrule;
    
      rule "cacheL1C1_UCE_evict"
        cbe.State = cacheL1C1_UCE & network_ready() 
      ==>
        FSM_Access_cacheL1C1_UCE_evict(adr, m);
        
      endrule;
    
      rule "cacheL1C1_UCE_store"
        cbe.State = cacheL1C1_UCE 
      ==>
        FSM_Access_cacheL1C1_UCE_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_UCE_load"
        cbe.State = cacheL1C1_UCE & network_ready() 
      ==>
        FSM_Access_cacheL1C1_UCE_load(adr, m);
        
      endrule;
    
    
      endalias;
    endruleset;
    endruleset;
    

----------------------buf_rule------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

ruleset n:Machines do
  alias p:buf_snp[n] do

      rule "buf_snp"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do
          
          if IsMember(n, OBJSET_directoryL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directoryL1C1(msg, n) then
              PopQueue(buf_snp, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory1L1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directory1L1C1(msg, n) then
              PopQueue(buf_snp, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cacheL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_cacheL1C1(msg, n) then
              PopQueue(buf_snp, n);
            endif;
          endif;
        
        endalias;

      endrule;
  endalias;
endruleset;

----------------------buf_rule------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
ruleset n:Machines do
  alias p:buf_resp[n] do

      rule "buf_resp"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do

          if IsMember(n, OBJSET_directoryL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directoryL1C1(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory1L1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directory1L1C1(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cacheL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_cacheL1C1(msg, n) then
              PopQueue(buf_resp, n);
            endif;
          endif;
        
        endalias;

      endrule;
  endalias;
endruleset;

----------------------buf_rule------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

ruleset n:Machines do
  alias p:buf_req[n] do

      rule "buf_req"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do
          
          if IsMember(n, OBJSET_directoryL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directoryL1C1(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory1L1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directory1L1C1(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cacheL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_cacheL1C1(msg, n) then
              PopQueue(buf_req, n);
            endif;
          endif;
        
        endalias;

      endrule;
  endalias;
endruleset;

----------------------buf_rule------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

ruleset n:Machines do
  alias p:buf_dat[n] do

      rule "buf_dat"
        (p.QueueInd>0)
      ==>
        alias msg:p.Queue[0] do
          
          if IsMember(n, OBJSET_directoryL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directoryL1C1(msg, n) then
              PopQueue(buf_dat, n);
            endif;
          endif;

          if IsMember(n, OBJSET_directory1L1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_directory1L1C1(msg, n) then
              PopQueue(buf_dat, n);
            endif;
          endif;
   
          if IsMember(n, OBJSET_cacheL1C1) then -- ismember should decide the id of marhicnes
            if FSM_MSG_cacheL1C1(msg, n) then
              PopQueue(buf_dat, n);
            endif;
          endif;
        
        endalias;

      endrule;
  endalias;
endruleset;

----------------------buf_rule-END------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------


  ----Backend/Murphi/MurphiModular/Rules/GenEventRuleSet
  ----Backend/Murphi/MurphiModular/Rules/GenNetworkRule


    -- ruleset dst:Machines do
    --     ruleset src: Machines do

ruleset n:0..1 do

            alias msg:req[n][0] do
              rule "Receive req"
                cnt_req[n] > 0
              ==>

            -- if IsMember(dst, OBJSET_cacheL1C1) then
            --   if FSM_MSG_cacheL1C1(msg, dst) then
            --       Pop_req(dst, src);
            --   endif;
            -- elsif IsMember(dst, OBJSET_directoryL1C1) then
            --   if FSM_MSG_directoryL1C1(msg, dst) then
            --       Pop_req(dst, src);
            --   endif;
            -- else error "unknown machine";
            -- endif;
    
             if IsMember(msg.dst, OBJSET_directoryL1C1) then
                 if PushQueue(buf_req, msg.dst, msg) then 
                    Pop_req(n);
                 endif;
             endif;

          -- if (n = 1) then
            if  IsMember(msg.dst, OBJSET_cacheL1C1)then
              if PushQueue(buf_req, msg.dst, msg) then 
                  Pop_req(n);
              endif;
            endif;

            if  IsMember(msg.dst, OBJSET_directory1L1C1) then
              if PushQueue(buf_req, msg.dst, msg) then 
                 Pop_req(n);
              endif;
            endif;



              endrule;
            endalias;


        -- endruleset;
endruleset;


ruleset n:0..1 do
    -- ruleset dst:Machines do
    --     ruleset src: Machines do


            alias msg:dat[n][0] do
              rule "Receive dat"
                cnt_dat[n] > 0
              ==>

            -- if IsMember(dst, OBJSET_cacheL1C1) then
            --   if FSM_MSG_cacheL1C1(msg, dst) then
            --       Pop_dat(dst, src);
            --   endif;
            -- elsif IsMember(dst, OBJSET_directoryL1C1) then
            --   if FSM_MSG_directoryL1C1(msg, dst) then
            --       Pop_dat(dst, src);
            --   endif;
            -- else error "unknown machine";
            -- endif;

             if IsMember(msg.dst, OBJSET_directoryL1C1) then
                 if PushQueue(buf_dat, msg.dst, msg) then 
                    Pop_dat(n);
                 endif;
             endif;

            if IsMember(msg.dst, OBJSET_cacheL1C1) then
              if PushQueue(buf_dat, msg.dst, msg) then 
                  Pop_dat(n);
              endif;
            endif;
            
            if IsMember(msg.dst, OBJSET_directory1L1C1) then
              if PushQueue(buf_dat, msg.dst, msg) then 
                 Pop_dat(n);
              endif;
            endif;
    
              endrule;
            endalias;
        endruleset;
    -- endruleset;


ruleset n:0..1 do
    -- ruleset dst:Machines do
    --     ruleset src: Machines do
            alias msg:rsp[n][0] do
              rule "Receive rsp"
                cnt_rsp[n] > 0
              ==>

            -- if IsMember(dst, OBJSET_cacheL1C1) then
            --   if FSM_MSG_cacheL1C1(msg, dst) then
            --       Pop_rsp(dst, src);
            --   endif;
            -- elsif IsMember(dst, OBJSET_directoryL1C1) then
            --   if FSM_MSG_directoryL1C1(msg, dst) then
            --       Pop_rsp(dst, src);
            --   endif;
            -- else error "unknown machine";
            -- endif;
    
             if IsMember(msg.dst, OBJSET_directoryL1C1) then
                 if PushQueue(buf_resp, msg.dst, msg) then 
                    Pop_rsp(n);
                 endif;
             endif;

          -- if (n = 1) then
            if  IsMember(msg.dst, OBJSET_cacheL1C1)then
              if PushQueue(buf_resp, msg.dst, msg) then 
                  Pop_rsp(n);
              endif;
            endif;

            if  IsMember(msg.dst, OBJSET_directory1L1C1) then
              if PushQueue(buf_resp, msg.dst, msg) then 
                 Pop_rsp(n);
              endif;
            endif;


              endrule;
            endalias;
        -- endruleset;
    endruleset;
    

ruleset n:0..1 do
    -- ruleset dst:Machines do
    --     ruleset src: Machines do
            alias msg:snp[n][0] do
              rule "Receive snp"
                cnt_snp[n] > 0
              ==>

            -- if IsMember(dst, OBJSET_cacheL1C1) then
            --   if FSM_MSG_cacheL1C1(msg, dst) then
            --       Pop_snp(dst, src);
            --   endif;
            -- elsif IsMember(dst, OBJSET_directoryL1C1) then
            --   if FSM_MSG_directoryL1C1(msg, dst) then
            --       Pop_snp(dst, src);
            --   endif;
            -- else error "unknown machine";
            -- endif;
    
          
             if IsMember(msg.dst, OBJSET_directoryL1C1) then
                 if PushQueue(buf_snp, msg.dst, msg) then 
                    Pop_snp(n);
                 endif;
             endif;

            if IsMember(msg.dst, OBJSET_cacheL1C1) then
              if PushQueue(buf_snp, msg.dst, msg) then 
                  Pop_snp(n);
              endif;
            endif;
            
            if IsMember(msg.dst, OBJSET_directory1L1C1) then
              if PushQueue(buf_snp, msg.dst, msg) then 
                 Pop_snp(n);
              endif;
            endif;


              endrule;
            endalias;
        -- endruleset;
    endruleset;

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

--Backend/Murphi/MurphiModular/GenStartStates

  startstate
    System_Reset();
  endstartstate;

--Backend/Murphi/MurphiModular/GenInvariant
