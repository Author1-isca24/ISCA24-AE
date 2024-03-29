import os
import sys
from pathlib import Path

# read the murphi result text files
def analyze_txt_files(directory, part_index):

    path = Path(directory)
    deadlock_cnt = 0
    complete_cnt = 0
    if not path.exists() or not path.is_dir():
        print(f"Directory does not exist or is not a directory: {directory}")
        return

    with open('murphi_results.csv', mode='a') as file1:
        for txt_file in path.glob('*.txt'):

            with txt_file.open('r') as file:
                lines = file.readlines()
                last_line = lines[-1] if lines else ""
            
                content = ''.join(lines)
                if "Deadlocked state found." in content:
                    str1 = f'{txt_file.name} is deadlock'
                    print(f"{txt_file.name} is deadlock")
                    deadlock_cnt += 1
                    file1.write(str1+ '\n')
                elif "No error found." in content:
                    str1 = f'{txt_file.name} completes without error'
                    print(f"{txt_file.name} completes without error")
                    complete_cnt += 1
                    file1.write(str1+ '\n')

                elif "current level" in last_line:
                    level = last_line.split("current level")[-1].replace('.', '').strip()
                    if (int(level) >= 48):
                        str1 = f'{txt_file.name} reaches level {level} without error'
                        complete_cnt += 1
                        print(f"{txt_file.name} reaches level {level} without error")
                        file1.write(str1+ '\n')
                    else:
                        str1 = f'{txt_file.name} reaches level {level} without error, you may need run it longer\n'
                        print(f"{txt_file.name} reaches level {level} without error, you may need run it longer\n")
                        file1.write(str1+ '\n')
    
        if part_index == '2':
            if (deadlock_cnt >= 2):
                str1 = f'The above results successfully reproduce the results in Table1-({part_index})'
                print(f"\nThe above results successfully reproduce the results in Table1-({part_index})\n")
                file1.write(str1+ '\n')

            if ((deadlock_cnt <= 2) and (complete_cnt <= 0)):
                str1 = f'In your current results, all the reproduced results have no error and match the results in Table1-({part_index})'
                print(str1)
                file1.write(str1+ '\n')
                    
        if part_index == '4':
            if (complete_cnt >= 6):
                str1 = f'The above results successfully reproduce the results in Table1-({part_index})'
                print(f"\nThe above results successfully reproduce the results in Table1-({part_index})\n")
                file1.write(str1+ '\n')

            if ((deadlock_cnt <= 0) and (complete_cnt <= 6)):
                str1 = f'In your current results, all the reproduced results have no error and match the results in Table1-({part_index})'
                print(str1)
                file1.write(str1+ '\n')
                
        if part_index == '5':
            if (complete_cnt >= 12):
                str1 = f'The above results successfully reproduce the results in Table1-({part_index})'
                print(f"\nThe above results successfully reproduce the results in Table1-({part_index})\n")
                file1.write(str1+ '\n')

            if ((deadlock_cnt <= 0) and (complete_cnt <= 12)):
                str1 = f'In your current results, all the reproduced results have no error and match the results in Table1-({part_index})'
                print(str1)
                file1.write(str1+ '\n')

        if part_index == '6':
            if (deadlock_cnt >= 2):
                str1 = f'The above results successfully reproduce the results in Table1-({part_index})'
                print(f"\nThe above results successfully reproduce the results in Table1-({part_index})\n")
                file1.write(str1+ '\n')

            if ((deadlock_cnt <= 2) and (complete_cnt <= 0)):
                str1 = f'In your current results, all the reproduced results have no error and match the results in Table1-({part_index})'
                print(str1)
                file1.write(str1+ '\n')

if len(sys.argv) > 1:
    part_index = sys.argv[1]
else:
    print("Please specify the part of the results you want to extract")
    
if (part_index == '2') or (part_index == '4') or (part_index == '5') or (part_index == '6'):
    path_to_script = os.path.abspath(__file__)
    path_to_top = os.path.dirname(path_to_script)
    target_dir = f"/Table1-({part_index})/murphi"
    path_to_target_dir = path_to_top + target_dir
    analyze_txt_files(path_to_target_dir, part_index)
    print('The corresponding model-checking results are written to murphi_results.csv')

elif (part_index == 'all'):
    exp_list = ['2', '4', '5', '6']
    for exp in exp_list:
        part_index = exp
        path_to_script = os.path.abspath(__file__)
        path_to_top = os.path.dirname(path_to_script)
        target_dir = f"/Table1-({part_index})/murphi"
        path_to_target_dir = path_to_top + target_dir
        analyze_txt_files(path_to_target_dir, part_index)

    print('All the model-checking results are written to murphi_results.csv')