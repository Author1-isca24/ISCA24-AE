import os
import sys
import pprint
import networkx as nx
import itertools
import matplotlib.pyplot as plt
import csv
from utils import *

if len(sys.argv) > 1:
    protocol_name = sys.argv[1]
    print("Your input protocol is:", protocol_name)
else:
    print("Please specify the protocol you want to analyze. You have the following choices:")
    print("Input 'MOSI' and 'MOESI' for Table1-(2)")
    print("Input 'CHI' for Table1-(4)")
    print("Input 'MSI_nonblocking_cache' and 'MESI_nonblocking_cache' for Table1-(5)")
    print("Input 'MSI_blocking_cache' and 'MESI_blocking_cache' for Table1-(6)")

path_to_script = os.path.abspath(__file__)
path_to_murphi = os.path.dirname(path_to_script)

# default: MSI - cache sometimes blocks
file_name = 'MSI_blocking_cache'
table_name = '/Table1-(5)/algorithm'

# Table I - (2) - MOSI - cache sometimes blocks
if protocol_name == 'MOSI':
    file_name = 'MOSI'
    table_name = '/Table1-(2)/algorithm/'

# Table I - (2) - MOESI - cache sometimes blocks
elif protocol_name == 'MOESI':
    file_name = 'MOESI'
    table_name = '/Table1-(2)/algorithm/'

# Table I - (4) - CHI - cache sometimes blocks
elif protocol_name == 'CHI':
    file_name = 'CHI'
    table_name = '/Table1-(4)/algorithm/'

# Table I - (5) - MSI - cache sometimes blocks
elif protocol_name == 'MSI_nonblocking_cache':
    file_name = 'MSI_nonblocking_cache'
    table_name = '/Table1-(5)/algorithm/'
    # protocol_table = (path_to_murphi + '/Table1_5/MSI_blocking_cache.csv')

# Table I - (5) - MESI - cache sometimes blocks
elif protocol_name == 'MESI_nonblocking_cache':
    file_name = 'MESI_nonblocking_cache'
    table_name = '/Table1-(5)/algorithm/'

# Table I - (6) - MSI - cache never blocks
elif protocol_name == 'MSI_blocking_cache':
    file_name = 'MSI_blocking_cache'
    table_name = '/Table1-(6)/algorithm/'
    # protocol_table = (path_to_murphi + '/Table1_5/MSI_nonblocking_cache.csv')

# Table I - (6) - MESI - cache never blocks
elif protocol_name == 'MESI_blocking_cache':
    file_name = 'MESI_blocking_cache'
    table_name = '/Table1-(6)/algorithm/'


print("############################################")
print(f"Protocol analyze for {protocol_name} starts")

# path_to_murphi = '/Users/apple/Desktop/Duke_Project'
result_file_name = ('vn_assign_' + file_name + '.txt')
max_vn = 2

# full_text store the whole murphi codes
full_text = []

# necessary information from the protocol
all_state = []
cause_dict = {}
stall_dict = {}
allmsg_dict = {}
wait_dict = {}
queue_dict = {}
MessageType = []

# Get the murphi code to do the basic parse
with open(path_to_murphi + table_name + file_name + '.m', 'r') as f:
    line1 = f.readline()
    while line1:
        full_text.append(line1)
        line1 = f.readline()

# Parse the basic information of the protocol: cache states and message types
if protocol_name in ['MSI_blocking_cache', 'MOESI', 'CHI']:
    get_StateL1C1(full_text, all_state)
if protocol_name in ['MSI_nonblocking_cache', 'MOSI', 'MESI_blocking_cache', 'MSI_nonblocking_cache', 'MESI_nonblocking_cache']:
    get_State(full_text, all_state)

get_MessageType(full_text, MessageType) 

# Based on the 2 information, initialize the 2 dict to build the graph
stall_dict, allmsg_dict = StallDict_Initial(all_state, stall_dict, allmsg_dict)
wait_dict, queue_dict = WaitGraph_Initial(MessageType, wait_dict, queue_dict)

# Parse the basic information of the protocol: stalling messages, all messages 
# and construct the queue_dict based on these two messages

# method 1: re-run the murphi file for several times
# get_Stallmsg(full_text, stall_dict, MessageType, path_to_murphi, file_name, queue_dict, allmsg_dict) 

# method 2: input the protocol table in csv
# stall_dict, queue_dict, allmsg_dict = get_stall_csv(protocol_table, stall_dict, queue_dict, allmsg_dict)

# method 3: input the stall_dict and murphi file
# input the stall_dict

# Table I - (2) - MOSI - cache sometimes blocks
if protocol_name == 'MOSI':
    stall_dict = {'cache_I': set(),
 'cache_I_load': {'Inv'},
 'cache_I_store': {'Fwd_GetM_M', 'Fwd_GetS_M'},
 'cache_I_store_GetM_Ack_AD': {'Fwd_GetM_M', 'Fwd_GetS_M'},
 'cache_M': set(),
 'cache_M_evict': set(),
 'cache_M_evict_Fwd_GetM_M': set(),
 'cache_O': set(),
 'cache_O_store': {'Fwd_GetM_M', 'Fwd_GetS_M'},
 'cache_O_store_GetM_Ack_AD': {'Fwd_GetM_M', 'Fwd_GetS_M'},
 'cache_S': set(),
 'cache_S_evict': set(),
 'directory_I': set(),
 'directory_M': set(),
 'directory_O': set(),
 'directory_S': set()}

# Table I - (2) - MOESI - cache sometimes blocks
elif protocol_name == 'MOESI':
    stall_dict = {'cacheL1C1_E': set(),
 'cacheL1C1_E_evict': set(),
 'cacheL1C1_I': set(),
 'cacheL1C1_I_load': {'Inv'},
 'cacheL1C1_I_store': {'Fwd_GetM_E', 'Fwd_GetS_E'},
 'cacheL1C1_I_store_GetM_Ack_AD': {'Fwd_GetM_E', 'Fwd_GetS_E'},
 'cacheL1C1_M': set(),
 'cacheL1C1_M_evict': set(),
 'cacheL1C1_O': set(),
 'cacheL1C1_O_evict': set(),
 'cacheL1C1_O_store': {'Fwd_GetM_E', 'Fwd_GetS_E'},
 'cacheL1C1_O_store_GetM_Ack_AD': {'Fwd_GetM_E', 'Fwd_GetS_E'},
 'cacheL1C1_S': set(),
 'cacheL1C1_S_evict': set(),
 'cacheL1C1_S_store': {'Fwd_GetM_E', 'Fwd_GetS_E'},
 'cacheL1C1_S_store_GetM_Ack_AD': {'Fwd_GetM_E', 'Fwd_GetS_E'},
 'directoryL1C1_E': set(),
 'directoryL1C1_I': set(),
 'directoryL1C1_M': set(),
 'directoryL1C1_O': set(),
 'directoryL1C1_S': set()}
   
# Table I - (4) - CHI - cache sometimes blocks
elif protocol_name == 'CHI':
    stall_dict = {'cacheL1C1_E': set(),
 'cacheL1C1_E_evict': set(),
 'cacheL1C1_E_evict_x_I': set(),
 'cacheL1C1_I': set(),
 'cacheL1C1_I_load': set(),
 'cacheL1C1_I_store': set(),
 'cacheL1C1_M': set(),
 'cacheL1C1_M_evict': set(),
 'cacheL1C1_M_evict_SnpCleanInvalid': set(),
 'cacheL1C1_O': set(),
 'cacheL1C1_O_evict': set(),
 'cacheL1C1_O_evict_SnpCleanInvalid': set(),
 'cacheL1C1_O_store': set(),
 'cacheL1C1_S': set(),
 'cacheL1C1_S_evict': set(),
 'cacheL1C1_S_evict_x_I': set(),
 'cacheL1C1_S_store': set(),
 'cacheL1C1_UCE': set(),
 'cacheL1C1_UCE_evict': set(),
 'cacheL1C1_UCE_evict_x_I': set(),
 'cacheL1C1_UCE_load': set(),
 'directoryL1C1_E': set(),
 'directoryL1C1_E_CleanUnique': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_E_CleanUnique_SnpRespData_I_PD': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_E_CleanUnique_SnpResp_I': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_E_ReadShared': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_E_ReadShared_SnpResp_O_Fwded_S': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_E_ReadShared_SnpResp_S_Fwded_S': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_E_WriteBackFull': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_I': set(),
 'directoryL1C1_I_CleanUnique': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_I_ReadShared': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_I_x_E_WriteBackFull': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_M': set(),
 'directoryL1C1_M_CleanUnique': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_M_CleanUnique_SnpRespData_I_PD': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_M_ReadShared': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_M_ReadShared_SnpResp_O_Fwded_S': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_M_WriteBackFull': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_O': set(),
 'directoryL1C1_O_CleanUnique': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_O_CleanUnique_SnpRespData_I_PD': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_O_CleanUnique_SnpResp_I': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_O_ReadShared': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_O_ReadShared_SnpResp_O_Fwded_S': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_O_WriteBackFull': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_S': set(),
 'directoryL1C1_S_CleanUnique': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_S_CleanUnique_SnpResp_I': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_S_ReadShared': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_S_WriteBackFull': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_UCE': set(),
 'directoryL1C1_UCE_CleanUnique': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_UCE_CleanUnique_SnpRespData_I_PD': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_UCE_CleanUnique_SnpResp_I': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_UCE_ReadShared': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_UCE_ReadShared_SnpResp_I': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_UCE_ReadShared_SnpResp_O_Fwded_S': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'},
 'directoryL1C1_UCE_WriteBackFull': {'CleanUniqueL1C1', 'EvictL1C1', 'ReadSharedL1C1', 'WriteBackFullL1C1'}}

# Table I - (5) - MSI - cache never blocks
elif protocol_name == 'MSI_nonblocking_cache':
    stall_dict = {'cache_I': set(),
 'cache_I_load': set(),
 'cache_I_load__Inv_I': set(),
 'cache_I_store': set(),
 'cache_I_store_GetM_Ack_AD': set(),
 'cache_I_store_GetM_Ack_AD__Fwd_GetM_I': set(),
 'cache_I_store_GetM_Ack_AD__Fwd_GetS_S': set(),
 'cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I': set(),
 'cache_I_store__Fwd_GetM_I': set(),
 'cache_I_store__Fwd_GetS_S': set(),
 'cache_I_store__Fwd_GetS_S__Inv_I': set(),
 'cache_M': set(),
 'cache_M_evict': set(),
 'cache_M_evict_Fwd_GetM': set(),
 'cache_S': set(),
 'cache_S_evict': set(),
 'cache_S_store': set(),
 'cache_S_store_GetM_Ack_AD': set(),
 'cache_S_store_GetM_Ack_AD__Fwd_GetS_S': set(),
 'cache_S_store__Fwd_GetS_S': set(),
 'directory_I': set(),
 'directory_M': set(),
 'directory_M_GetS': {'PutS', 'GetS', 'PutM', 'GetM'},
 'directory_S': set()}

# Table I - (5) - MESI - cache never blocks
elif protocol_name == 'MESI_nonblocking_cache':
    stall_dict = {'cache_E': set(),
 'cache_E_evict': set(),
 'cache_E_evict_Fwd_GetM': set(),
 'cache_I': set(),
 'cache_I_load': set(),
 'cache_I_load__Fwd_GetM_I': set(),
 'cache_I_load__Fwd_GetS_S': set(),
 'cache_I_load__Fwd_GetS_S__Inv_I': set(),
 'cache_I_load__Inv_I': set(),
 'cache_I_store': set(),
 'cache_I_store_GetM_Ack_AD': set(),
 'cache_I_store_GetM_Ack_AD__Fwd_GetM_I': set(),
 'cache_I_store_GetM_Ack_AD__Fwd_GetS_S': set(),
 'cache_I_store_GetM_Ack_AD__Fwd_GetS_S__Inv_I': set(),
 'cache_I_store__Fwd_GetM_I': set(),
 'cache_I_store__Fwd_GetS_S': set(),
 'cache_I_store__Fwd_GetS_S__Inv_I': set(),
 'cache_M': set(),
 'cache_M_evict': set(),
 'cache_S': set(),
 'cache_S_evict': set(),
 'cache_S_store': set(),
 'cache_S_store_GetM_Ack_AD': set(),
 'cache_S_store_GetM_Ack_AD__Fwd_GetS_S': set(),
 'cache_S_store__Fwd_GetS_S': set(),
 'directory_E': set(),
 'directory_E_GetS':{'PutS', 'GetS', 'PutM', 'GetM', 'PutE'},
 'directory_I': set(),
 'directory_M': set(),
 'directory_S': set()}

# Table I - (6) - MSI - cache sometimes blocks
elif protocol_name == 'MSI_blocking_cache':
    stall_dict = {'cacheL1C1_I': set(),
 'cacheL1C1_I_load': {'InvL1C1'},
 'cacheL1C1_I_store': {'Fwd_GetML1C1', 'Fwd_GetSL1C1'},
 'cacheL1C1_I_store_GetM_Ack_AD': {'Fwd_GetML1C1', 'Fwd_GetSL1C1'},
 'cacheL1C1_M': set(),
 'cacheL1C1_M_evict': set(),
 'cacheL1C1_M_evict_x_I': set(),
 'cacheL1C1_S': set(),
 'cacheL1C1_S_evict': set(),
 'cacheL1C1_S_evict_x_I': set(),
 'cacheL1C1_S_store': {'Fwd_GetML1C1', 'Fwd_GetSL1C1'},
 'cacheL1C1_S_store_GetM_Ack_AD': {'Fwd_GetML1C1', 'Fwd_GetSL1C1'},
 'directoryL1C1_I': set(),
 'directoryL1C1_M': set(),
 'directoryL1C1_M_GetS': {'PutSL1C1', 'GetSL1C1', 'PutML1C1', 'GetML1C1'},
 'directoryL1C1_S': set()}   

# Table I - (6) - MESI - cache sometimes blocks
elif protocol_name == 'MESI_blocking_cache':
    stall_dict = {'cache_E': set(),
 'cache_E_evict': set(),
 'cache_E_evict_Fwd_GetM': set(),
 'cache_I': set(),
 'cache_I_load': {'Inv'},
 'cache_I_store': {'Fwd_GetM', 'Fwd_GetS'},
 'cache_I_store_GetM_Ack_AD': {'Fwd_GetM', 'Fwd_GetS'},
 'cache_M': set(),
 'cache_M_evict': set(),
 'cache_S': set(),
 'cache_S_evict': set(),
 'cache_S_store': {'Fwd_GetM', 'Fwd_GetS'},
 'cache_S_store_GetM_Ack_AD': {'Fwd_GetM', 'Fwd_GetS'},
 'directory_E': set(),
 'directory_E_GetS': {'PutS', 'GetS', 'PutM', 'GetM', 'PutE'},
 'directory_I': set(),
 'directory_M': set(),
 'directory_S': set()}

queue_dict, allmsg_dict = get_protocol_info(full_text, stall_dict, queue_dict, allmsg_dict)

# Do DFS on the cause message sequence
# here we get the "waiting-for" graph
wait_dict = WaitGraph_build(full_text, wait_dict, stall_dict, MessageType, allmsg_dict)

# Using the "waiting-for+queued-behind" we compute the G(P)
if_class2, G_P, cyclic_edges = dict2graph(wait_dict, queue_dict, MessageType)
# G_P.remove_edge('Fwd_GetML1C1', 'Fwd_GetML1C1')
pos = nx.random_layout(G_P, seed=4)
plt.figure(figsize=(12, 12))
nx.draw(G_P, pos=pos, with_labels=True, node_color='lightblue', edge_color='gray') 
nx.draw_networkx_edges(G_P, pos, edgelist=cyclic_edges, edge_color='red', width=2)
plt.savefig((file_name + '_waitgraph.png'), format='png', dpi=300)
print(f"The waiting graph is saved to {path_to_murphi}")
# plt.show()


# remove Fwd_getM and Inv wait_dict:
# wait_dict['Fwd_GetML1C1'] = set()
# wait_dict['InvL1C1'] = set()

# # Now we have G(P), we compute the minimal feedback arc set(FAS) of G(P)
# print("############################################################")
if if_class2:
    print("The protocol is a class 2 protocol, Program Exit!")
    print("The protocol information is as following:\n")
    print("1. The wait graph is")
    pprint.pprint(wait_dict)
    print(f"2. The cyclic edges in the wait graph are {cyclic_edges}\n")

    sys.exit()
else:  
    print("The protocol is not a class 2 protocol! We may re-assign the VNs to get smaller number of VNs")
    print("The protocol information is as following:")
    print("1. The wait graph is")
    pprint.pprint(wait_dict)
    print("\n")

    print("Now start to find the minimal feed back arc set")
    if protocol_name == 'CHI':
        min_fas = FAS_compute_opt(G_P, wait_dict, queue_dict)
    else:
        min_fas = FAS_compute(G_P, wait_dict)

    print(f"Finish finding the minimal feed back arc set, now start to find possible assignments for {max_vn} virtual networks\n")
# print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
# # Now we have the FAS, we use the "queued-behind" edges in that FAS to construct the conflict graph
# # actually the FAS only contains the "queued-behind"
G_fas = set2graph(min_fas, MessageType)

# add wait_graph to the G_fas
for msg_w in wait_dict:
    for msg_wfor in wait_dict[msg_w]:
        G_fas.add_edge(msg_w, msg_wfor)
        
# # Now we play the graph coloring algorithm on the conflict graph
print("Now start to find all the possible assignments")
colorings = graph_coloring(G_fas, max_vn, coloring={}, node_list=None)
# print(f"the colorings are {colorings}")
# print(f"the colorings length {len(colorings)}")

# print("------------------- The wait graph is -------------------")
# print("Hint: msg1: {msg2, msg3, msg4} means msg1 --waits--> msg2, msg3, msg4\n")
# pprint.pprint(wait_dict)
# pprint.pprint(queue_dict)
   
print(f"All the assignments for {max_vn} virtual networks are found!")   
res_writer(colorings, max_vn, result_file_name, table_name, path_to_murphi)

# print("--------------------------------------------------------- ")

print("############################################")
print(f"Protocol analyze for {protocol_name} ends")   
    # the queue behind graph
    # the stall-message relation: see the paper