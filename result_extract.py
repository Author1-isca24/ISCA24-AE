import os
import sys

protocol_dict = {'MOSI': '(2)',
'MOESI' : '(2)',
'CHI' : '(4)',
'MSI_nonblocking_cache' : '(5)',
'MESI_nonblocking_cache' : '(5)',
'MSI_blocking_cache' : '(6)',
'MESI_blocking_cache' : '(6)'

}

def judge_class2(full_text):
    for line in full_text:
        if ("Program Exit" in line):
            return True
        
        if ('not a class 2' in line):
            return False

def find_result_file(full_text):
    for line in full_text:
        if "The assignment results are written to" in line:
            address = line.split('to', 1)[1].replace(':', '').strip()
            return address

path_to_script = os.path.abspath(__file__)
path_to_murphi = os.path.dirname(path_to_script)
full_text = []

print('\n---------The summary of the algorithm for all the protocol is as follows-----------:')

with open('algorithm_results.csv', mode='a') as file:

    for protocol in protocol_dict:
        full_text = []
        with open(path_to_murphi + '/' + protocol + '_result.txt', 'r') as f:
            line1 = f.readline()
            while line1:
                full_text.append(line1)
                line1 = f.readline()
        
        str1 = f'-- For the protocol {protocol} in Table I - {protocol_dict[protocol]}:'
        print(str1)
        file.write(str1 + '\n')

        if (judge_class2(full_text)):
            str1 = 'It is a class 2 protocol! The algorithm stops!'
            print(str1)
            file.write(str1 + '\n')
        else:
            str1 = 'It is not a class 2 protocol!'
            print(str1)
            file.write(str1 + '\n')
            address = find_result_file(full_text)

            str1 = f'The assignment reuslts for 2 virtual networks are written to {address}'
            print(str1)
            file.write(str1 + '\n')
    
        f.close()


print('\n---------The above summary is written to ISCA24_AE/algorithm_results.csv-----------:')