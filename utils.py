import os
import sys
import pprint
import networkx as nx
import itertools
import matplotlib.pyplot as plt
import csv

# insert "put" into different cache states to find all the possible messages

def get_Stallmsg(full_text, stall_dict, MessageType, path_to_murphi, file_name, queue_dict, allmsg_dict):
    visit_line = []
    full_text1 = full_text
    exit_tag = 0
    current_state = ''
    
    # config: file name
    # judge where to insert put
    for i in range(1, len(full_text1)-1):
        if (("case" in full_text1[i - 1]) & ("switch" in full_text1[i]) & (full_text1[i - 1] not in visit_line)):
            current_state = full_text1[i - 1].split('case', 1)[1].split(':', 1)[0].replace(':', '').strip()
            visit_line.append(full_text[i - 1])
            full_text1.insert(i, "      put inmsg.mtype;\n")
            full_text1.insert(i + 1,('      put '  + r'"' + r"\n" + r'"' + ';' + "\n"))
            get_Stallmsg_case(full_text1, stall_dict, MessageType, file_name, current_state, path_to_murphi, queue_dict, allmsg_dict)
            full_text1.remove("      put inmsg.mtype;\n")
            full_text1.remove(('      put '  + r'"' + r"\n" + r'"' + ';' + "\n"))
            str1 = ('rm -f ' + path_to_murphi + '/cmurphi-master/src/' + '%s' + '.m') % (file_name)
            os.system(str1)
            #os.system("rm -f /Users/apple/Desktop/Duke_Project/cmurphi-master/murphi_source/msg_output.txt")

def get_Stallmsg_case(full_text, stall_dict, MessageType, file_name, current_state, path_to_murphi, queue_dict, allmsg_dict):
    # initialize the tag 
    NonStall_msg = set()
    exit_tag = 0
    
    file1 = (path_to_murphi + '/cmurphi-master/src/' + '%s' + '.m') % (file_name)
    with open(file1, 'a+') as f:
        for i in range(len(full_text)):
            f.write(full_text[i])
    
    # run the modified .m file in murphi
    cmd1 = ('cd ' + path_to_murphi + '/cmurphi-master/src &&')
    cmd2 = ('./mu ' + '%s' + '.m &> ' + path_to_murphi + '/cmurphi-master/murphi_source/mu_output.txt &&') % (file_name)
    cmd3 = ('g++ -ggdb -o ' + '%s' + '.o ' + '%s' + '.cpp -I ../include -lm &> ' + path_to_murphi + '/cmurphi-master/murphi_source/cpl_output.txt &&') % (file_name, file_name)
    cmd4 = ('./' + '%s' + '.o -m 1 &> ' + path_to_murphi + '/cmurphi-master/murphi_source/msg_output.txt') % (file_name)
     
    # collect the "put" results
    os.system(cmd1 + cmd2 + cmd3 + cmd4)
    # print("finish one detection")
    
    # parse the "put" results to get the complete messages
    # find the "non-stalling" messages through .m file
    for i in range(len(full_text)):
        if ("put" in full_text[i]):
            for j in range(i, len(full_text)):
                if ("endswitch" in full_text[j]):
                    exit_tag = 1
                    break
                if ("case" in full_text[j]):
                    line_m = (full_text[j].split('case', 1))[1].strip().replace(':', '')
                    NonStall_msg.add(line_m)
                    # print(NonStall_msg)
            if (exit_tag == 1):
                break
    
    # go through the "msg_output.txt" to find "stalling" messages
    All_msg = set()
    with open(path_to_murphi + '/cmurphi-master/murphi_source/msg_output.txt', 'r') as f:
        line2 = f.readline()
        while line2:
            if str(line2).strip() in MessageType:
                All_msg.add(str(line2).strip())
            line2 = f.readline()
            
    # "All_msg" contains both stalling and non-stalling messages
    # print("\n####################################")
    # print(f"current state is {current_state}")
    # print("Print the non-stalling messages")
    # print(NonStall_msg)
    # print("Print all the possible arriving messages")
    # print(All_msg)
    # print("####################################\n")
    
    
    # first based on All_msg, we build the queue behind graph
    for msg in All_msg:
        for msg_2 in All_msg:
            if (msg_2 != msg):
                queue_dict[msg].add(msg_2)
#     print(f"queue graph is {queue_dict}")
                
    # for every state, add the stalling message into the dictionary
    for msg in All_msg:
        allmsg_dict[current_state].add(msg)
        if msg not in NonStall_msg:
            # print(current_state)
            stall_dict[str(current_state)].add(msg)
#             for ns_msg in NonStall_msg:
#                 queue_dict[ns_msg].add(msg)

            
#     # In a certain state, the stalling msg and non-stalling are conflict
#     for p_msg in All_msg:
#         if (p_msg not in NonStall_msg):
#             for msg in NonStall_msg:
#                 MsgConflictDict[msg].add(p_msg)

def get_protocol_info(full_text, stall_dict, queue_dict, allmsg_dict):
    
    full_text1 = full_text

    # add the non-stalling messages to allmsg_dict
    for i in range(1, len(full_text1)-1):
        if (("case" in full_text1[i - 1]) & ("switch" in full_text1[i])):
            current_state = full_text1[i - 1].split('case', 1)[1].split(':', 1)[0].replace(':', '').strip()
            for j in range(i, len(full_text1)):
                if ("endswitch" in full_text1[j]):
                    break
                if ("case" in full_text1[j]):
                    line_msg = (full_text1[j].split('case', 1))[1].strip().replace(':', '')
                    allmsg_dict[current_state].add(line_msg)

    # add the stalling messages to allmsg_dict
    for state in stall_dict:
        for msg in stall_dict[state]:
            allmsg_dict[state].add(msg)

    # based on allmsg_dict, we build queue_dict
    for state in allmsg_dict:
        for msg in allmsg_dict[state]:
            for msg_2 in allmsg_dict[state]:
                if (msg_2 != msg):
                    queue_dict[msg].add(msg_2)    
    
    return queue_dict, allmsg_dict

def get_State(full_text, all_state):
    full_text_temp = full_text
    
    # get the cache states
    for i in range(0, len(full_text_temp)-1):
        if "s_cache: enum {" in full_text_temp[i]:
            for j in range(i+1, len(full_text_temp)-1):
                if "};" in full_text_temp[j]:
                    break
                else:
                    all_state.append(full_text_temp[j].strip().replace(',', ''))
            break
        
    # get the directory states
    for i in range(0, len(full_text_temp)-1):
        if "s_directory: enum {" in full_text_temp[i]:
            for j in range(i+1, len(full_text_temp)-1):
                if "};" in full_text_temp[j]:
                    break
                else:
                    all_state.append(full_text_temp[j].strip().replace(',', ''))
                    
            # print('The cache states are ')
            # print(all_state)  
            break
            
    return True

def get_StateL1C1(full_text, all_state):
    full_text_temp = full_text
    
    # get the cache states
    for i in range(0, len(full_text_temp)-1):
        if "s_cacheL1C1: enum {" in full_text_temp[i]:
            for j in range(i+1, len(full_text_temp)-1):
                if "};" in full_text_temp[j]:
                    break
                else:
                    all_state.append(full_text_temp[j].strip().replace(',', ''))
            break
        
    # get the directory states
    for i in range(0, len(full_text_temp)-1):
        if "s_directoryL1C1: enum {" in full_text_temp[i]:
            for j in range(i+1, len(full_text_temp)-1):
                if "};" in full_text_temp[j]:
                    break
                else:
                    all_state.append(full_text_temp[j].strip().replace(',', ''))
                    
            # print('The cache states are ')
            # print(all_state)  
            break
            
    return True

def get_MessageType(full_text, MessageType):
    full_text_temp = full_text
    for i in range(0, len(full_text_temp)-1):
        if "MessageType: enum {" in full_text_temp[i]:
            for j in range(i+1, len(full_text_temp)-1):
                if "};" in full_text_temp[j]:
                    break
                else:
                    MessageType.append(full_text_temp[j].strip().replace(',', ''))
            # print('The MessageTypes are ')
            # print(MessageType)  
            break
    return True    

def WaitGraph_Initial(MessageType, wait_dict, queue_dict):
    wait_dict = {key: set() for key in MessageType}
    queue_dict = {key: set() for key in MessageType}
    return wait_dict, queue_dict

def StallDict_Initial(all_state, stall_dict, allmsg_dict):
    stall_dict = {key: set() for key in all_state}
    allmsg_dict = {key: set() for key in all_state}
    return stall_dict, allmsg_dict

def WaitGraph_build(full_text, wait_dict, stall_dict, MessageType, allmsg_dict):
    cause_msg = []
    cause_sequence = []
    full_text_temp = full_text
    # create the directory_state from all states
#     directory_state = []
#     for state in allmsg_dict:
#         if ('directory' in state):
#             directory_state.append(state)

    for state in stall_dict:
        # traverse all states which have the stalling messages
        if (len(stall_dict[state]) != 0):
            cause_msg, grey_tag = find_CauseMsg(state, cause_msg, full_text_temp, allmsg_dict)
#             print("show casue msg here")
#             print(state)
#             print(cause_msg)
            cause_sequence = CauseSeq_build(full_text, cause_msg, grey_tag)
            
            # print(f"cause seq of {cause_msg}")
            # print(cause_sequence) 
            
            # delete the first message in the cause_Sequence
            
            # build the wait graph based on the cause sequence
            # remove message itself from the cause
            for msg in stall_dict[state]:
                for i in range(0, len(cause_sequence)):
                    wait_dict[msg].add(cause_sequence[i])
                    
        cause_sequence = []

        cause_msg = []
                    
    return wait_dict
      

#     GetM -> fwd_getM -> inv -> inv_ack
#     Fwd_getS / fwd_getM
    
# if state grey fwd_gets, then don't add it to cause_msg 
def find_CauseMsg(state, cause_msg, full_text, allmsg_dict):
    full_text_temp = full_text
    grey_tag = 0
    
    # create the directory_state from all states
    directory_state = []
    for state1 in allmsg_dict:
        if ('directory' in state1):
            directory_state.append(state1)
    
#     print(f'directory state is{directory_state}')
            
    for i in range(0, len(full_text_temp)-1):
        TargetState = ("State := " + "%s") % (state)
        if TargetState in full_text_temp[i]:      
            for j in range(i, -1, -1):
                if "case" in full_text_temp[j]:
                    break
                if "msg :=" in full_text_temp[j]:
                    msg = full_text_temp[j].split(',', 1)[1].split(',', 1)[0].strip()
                    cause_msg.append(msg)
                    
                    # if this message is grey in this state, then set the tag
                    # this msg will be removed from the cause graph
                    if ((msg not in allmsg_dict[state]) and (state not in directory_state)):
                        grey_tag = 1
                    
                    break
                    
    return cause_msg, grey_tag
                    
def CauseSeq_build(full_text, cause_msg, grey_tag): 
    full_text_temp = full_text
    cause_sequence = []
    
    for msg in cause_msg:
        # if the stalling message is a grey message, then the first message will not be in the cause graph
        if not grey_tag:
            cause_sequence.append(msg)
            
        CauseSeq_dfs(full_text, msg, cause_sequence)

    return cause_sequence

def CauseSeq_dfs(full_text, msg, cause_sequence):
    end_tag = True
    msg_next = []
    full_text_temp = full_text
    
    for i in range(0, len(full_text_temp)-1):
            case_msg = ("case " + "%s" + ":") % (msg)
            if case_msg in full_text_temp[i]:
                for j in range(i+1, len(full_text_temp)-1):
                    
                    if (("return" in full_text_temp[j]) or ("case" in full_text_temp[j])):
                        # this message doesn't have the following message
                        if (end_tag):
                            break
#                             return cause_sequence

                        else:
                            # this message have the following message, then go to the next message
                            cause_sequence = CauseSeq_dfs(full_text, msg_next, cause_sequence)
                            break
#                             return cause_sequence
                            
                    if "msg :=" in full_text_temp[j]:
                        msg_next = full_text_temp[j].split(',', 1)[1].split(',', 1)[0].strip()
                        cause_sequence.append(msg_next)
                        end_tag = False
    
    return cause_sequence        


# Build the G(p) as follows: Compute the shortest paths between all pairs of vertices
# G_P = G(p) = graph of the given protocol
def find_cyclic_edges(G):
    #Find edges involved in cycles
    cyclic_edges = set()
    for cycle in nx.simple_cycles(G):
        for i in range(len(cycle)):
            cyclic_edges.add((cycle[i], cycle[(i + 1) % len(cycle)]))
    return cyclic_edges

def dict2graph(wait_dict, queue_dict, MessageType):
    G_P = nx.DiGraph()
    wait_edge = set()
    # initialize G_P: the messages are the nodes
    for msg in MessageType:
        G_P.add_node(msg)
    
    # transform the wait_dict and queue_dict to the edges in G_O  
    for msg_w in wait_dict:
        for msg_wfor in wait_dict[msg_w]:
            G_P.add_edge(msg_w, msg_wfor, weight=200)
            wait_edge.add((msg_w, msg_wfor))
    
    # test: Fwd_GetM is non stalling
#     G_P.remove_edge('Fwd_GetML1C1', 'GetML1C1')
#     G_P.remove_edge('Fwd_GetML1C1', 'Fwd_GetML1C1')
#     G_P.remove_edge('Fwd_GetML1C1', 'GetM_Ack_ADL1C1')
#     G_P.remove_edge('Fwd_GetML1C1', 'GetM_Ack_DL1C1')
# #     G_P.remove_edge('Fwd_GetML1C1', 'Fwd_GetSL1C1')
#     G_P.remove_edge('Fwd_GetML1C1', 'InvL1C1')
#     G_P.remove_edge('Fwd_GetML1C1', 'Inv_AckL1C1')
#     G_P.remove_edge('InvL1C1', 'Fwd_GetSL1C1')
#     G_P.remove_edge('InvL1C1', 'GetS_AckL1C1')
#     G_P.remove_edge('Fwd_GetSL1C1', 'Fwd_GetSL1C1')
#     G_P.remove_edge('Fwd_GetSL1C1', 'GetML1C1')
    
    # also need to remove wait edge
#     wait_edge.remove(('Fwd_GetML1C1', 'Fwd_GetML1C1'))
#     wait_edge.remove(('Fwd_GetML1C1', 'GetM_Ack_ADL1C1'))
#     wait_edge.remove(('Fwd_GetML1C1', 'GetM_Ack_DL1C1'))
#     wait_edge.remove(('Fwd_GetML1C1', 'InvL1C1'))
#     wait_edge.remove(('Fwd_GetML1C1', 'Inv_AckL1C1'))
#     wait_edge.remove(('InvL1C1', 'Fwd_GetSL1C1'))
#     wait_edge.remove(('InvL1C1', 'GetS_AckL1C1'))    
    # test-test-test
    
    if not nx.is_directed_acyclic_graph(G_P):
        cyclic_edges = find_cyclic_edges(G_P)
        # print("This is a class 2 protocol")
        return True, G_P, cyclic_edges
    
    for msg_q in queue_dict:
        for msg_qbhd in queue_dict[msg_q]:
            G_P.add_edge(msg_q, msg_qbhd, weight=1)
            
    # now we have the original G_P, but we want the shortest paths between all pairs of vertices
    G_P_shortest = nx.DiGraph()
    for node1, node2 in itertools.combinations(G_P.nodes(), 2):
        
        try:
            path = nx.shortest_path(G_P, source=node1, target=node2, weight='weight')
            if (path[0], path[1]) in wait_edge or (path[1], path[0]) in wait_edge:
                path_edges = zip(path, path[1:])
                G_P_shortest.add_edges_from(path_edges)
        
        except nx.NetworkXNoPath:
            continue
            
#     for msg_w in wait_dict:
#         for msg_wfor in wait_dict[msg_w]:
#             G_P_shortest.add_edge(msg_w, msg_wfor, weight=200)
#             wait_edge.add((msg_w, msg_wfor))
    
    # print("This is *not* a class 2 protocol, we can break these cycles with a VN assignment.")
    return False, G_P_shortest, None
    
def is_acyclic_after_removal(G_P, edges_to_remove):
    temp = G_P.copy()
    temp.remove_edges_from(edges_to_remove)
    return nx.is_directed_acyclic_graph(temp)

def FAS_compute_opt(G_P, wait_dict, queue_dict):
    # when finding the minimal FAS, the edges in "waiting-for" graph can't be removed
    # parse the wait_dict to get this edges
    not_to_remove = set()
    G_P_wait = nx.DiGraph()
    
    for msg_w in wait_dict:
        for msg_wfor in wait_dict[msg_w]:
            not_to_remove.add((msg_w, msg_wfor))
    
    in_flag = 0
    all_edges = list(G_P.edges())
    num_edges = len(all_edges)
    min_size = num_edges + 1
    min_fas = set(all_edges) 
    
    wait_edge = []
    for msg1 in wait_dict:
        for msg2 in wait_dict[msg1]:
            wait_edge.append((msg1, msg2))
            
    # we only need to move the edges from queue_dict
    queue_edge = []
    for msg1 in queue_dict:
        for msg2 in queue_dict[msg1]:
            queue_edge.append((msg1, msg2))
            
    # find the edges that are definitely to be removed        
    conflict_queue_edge = []
    for edge in queue_edge:
        for wedge in wait_edge:
            if (edge[0] == wedge[1] and edge[1] == wedge[0]):
                conflict_queue_edge.append(edge)
    
    # get a smaller queue edge
    smaller_queue_edge = []
    for edge in queue_edge:
        if edge not in conflict_queue_edge:
            smaller_queue_edge.append(edge)
            
    # remove the above edges from the G_P first to reduce the search space
    for edge in conflict_queue_edge:
        if (G_P.has_edge(edge[0], edge[1])):
            G_P.remove_edge(edge[0], edge[1])
            min_fas.add(edge)
    
    G_P.add_edge('SnpSharedFwdL1C1', 'Comp_IL1C1')
    G_P.add_edge('SnpCleanInvalidL1C1', 'Comp_IL1C1')
    min_fas.remove(('SnpSharedFwdL1C1', 'Comp_IL1C1'))

    if nx.is_directed_acyclic_graph(G_P):
        return min_fas
    
    # now we can use brute-force to search the G_P to find the minimal FAS
    all_edges = smaller_queue_edge
    
    for i in range(1, num_edges + 1):
        print(i)
        for subset in itertools.combinations(all_edges, i):
            in_flag = 0
            # judge if the subset contains "waiting-for" edges
            for every_edge in subset:
                if every_edge in not_to_remove:
                    in_flag = 1
            
            if (in_flag == 0):
                if is_acyclic_after_removal(G_P, subset):
                    print("arrive here")
                    if (i < min_size): 
                        min_fas = set(subset)
                        min_size = i
                        return min_fas
                        
    return min_fas

def FAS_compute(G_P, wait_dict):
    # when finding the minimal FAS, the edges in "waiting-for" graph can't be removed
    # parse the wait_dict to get this edges
    not_to_remove = set()
    G_P_wait = nx.DiGraph()
    
    for msg_w in wait_dict:
        for msg_wfor in wait_dict[msg_w]:
            not_to_remove.add((msg_w, msg_wfor))
    
    # now we can use brute-force to search the G_P to find the minimal FAS
    in_flag = 0
    all_edges = list(G_P.edges())
    num_edges = len(all_edges)
    min_size = num_edges + 1
    min_fas = set(all_edges) 
    
    for i in range(1, num_edges + 1):
        print(f'{i} edges are removed')
        for subset in itertools.combinations(all_edges, i):
            in_flag = 0
            # judge if the subset contains "waiting-for" edges
            for every_edge in subset:
                if every_edge in not_to_remove:
                    in_flag = 1
            
            if (in_flag == 0):
                if is_acyclic_after_removal(G_P, subset):
             
                    if (i < min_size): 
                        min_fas = set(subset)
                        min_size = i
                        print(f'After {i} edgesare removed, we found the minimal feed back arc set') 
                        return min_fas


    print(f'After {i} edgesare removed, we found the minimal feed back arc set')              
    return min_fas
    
def set2graph(min_fas, MessageType):
    G_fas = nx.Graph()
    for msg in MessageType:
        G_fas.add_node(msg)
        
    for edge in min_fas:
        G_fas.add_edge(*edge)
        
    return G_fas

def is_valid_coloring(G_fas, coloring):
    for node in G_fas:
        for neighbor in G_fas[node]:
            if neighbor in coloring and node in coloring:
                if coloring[neighbor] == coloring[node]:
                    return False
    return True

def graph_coloring(G_fas, max_vn, coloring={}, node_list=None):
    if node_list is None:
        node_list = list(G_fas.nodes())

    if len(coloring) == len(G_fas):
        # pprint.pprint(coloring)
        return [dict(coloring)]
    
    colorings = []
    node = node_list[0]
    for color in range(max_vn):
        coloring[node] = color
        if is_valid_coloring(G_fas, coloring):
            colorings.extend(graph_coloring(G_fas, max_vn, coloring, node_list[1:]))
    del coloring[node]

    return colorings

def res_writer(colorings, max_vn, result_file_name, table_name, path_to_murphi):
    # file1 = (path_to_murphi + '/cmurphi-master//' + '%s') % (result_file_name)
    file1 = (path_to_murphi + table_name + '%s') % (result_file_name)
    res_cnt = 0
    with open(file1, 'a+') as f:
        for res in colorings:
            res_cnt += 1
            f.write(("the assignment %d is: \n") % (res_cnt))
            f.write(str(res))
            f.write("\n")

    print(f'The assignment results are written to {file1}')

#         str1 = str("Assignment result when VN number = %d\n" % (max_vn))
#         f.write(str1)
#         cnt1 = 0
#         for msg in MessageType:
#             str2 = str(("%s," % msg) + str(Assignresult[cnt1]) + "\n")
#             f.write(str2)    
#             cnt1 += 1
#             assert (cnt1 == len(MessageType))    
            
#---------------------------------------------Main---------------------------------------------

def get_stall_csv(protocol_table, stall_dict, queue_dict, allmsg_dict):
    cache_message = []
    dir_message = []
#     protocol_table = '/Users/apple/Desktop/Duke_Project/cmurphi-master/MSI_table_murphi.csv'
    with open(protocol_table, newline='', encoding='utf-8-sig') as table:
        table_reader = csv.reader(table)
        for row in table_reader:
            # read the cache message
           
            if row[0] == str('cache'):
                for i in range(0, len(row)):
                    cache_message.append(row[i])
                # print(cache_message)
                
            # read the directory message
            elif row[0] == 'directory':
                for i in range(0, len(row)):
                    dir_message.append(row[i])     
                    
            else:
                # build the stall dict
                for i in range(1, len(row)):
                    if (row[i] == 'stall'):
                        if(('cache' in row[0]) and (row[0] != 'cache')):
                            if (('load' not in cache_message[i]) and ('store' not in cache_message[i]) and ('replacement' not in cache_message[i])):
                                stall_dict[row[0]].add(cache_message[i])
                        elif (('dir' in row[0]) and (row[0] != 'directory')):
                            stall_dict[row[0]].add(dir_message[i])

                # build the allmsg_dict
                for i in range(1, len(row)):
                    if (row[i] != 'grey'):
                        if(('cache' in row[0]) and (row[0] != 'cache')):
                            if (('load' not in cache_message[i]) and ('store' not in cache_message[i]) and ('replacement' not in cache_message[i])):
                                allmsg_dict[row[0]].add(cache_message[i])
                        elif (('dir' in row[0]) and (row[0] != 'directory')):
                                allmsg_dict[row[0]].add(dir_message[i])

            # build the allmsg_dict
        for state in allmsg_dict:
            for msg in allmsg_dict[state]:
                for msg_2 in allmsg_dict[state]:
                    if (msg_2 != msg):
                        if ((msg !='' )and (msg_2 != '')):
                            queue_dict[msg].add(msg_2)

                
    return stall_dict, queue_dict, allmsg_dict
            
            
        