#  Determining the Minimum Number of Virtual Networks for Different Coherence Protocols
This is the artifact for this paper. Our artifact provides:

- The code for the algorithm to determine the minimum number of VNs
- Generation of mappings from message types to VNs in Python
- The (formal) protocols in Murphi corresponding to the results in Table I. 

It outputs the analysis results for the input protocol. Our artifact leverages the CMurphi infrastructure to verify the protocols. We also provide scripts to:
 1. Run the algorithm and the model checking for all protocols in part (2), (4), (5) and (6) of Table I;
 2. Run the algorithm and the model checking for a single protocol in part (2), (4), (5) and (6) of Table I.

## Hardware dependencies and Expected Times
The algorithm to determine the minimum number of VNs will complete in two minutes and doesn't require any advanced processor. For model checking, any PC with at least 200GB of RAM suffices to run most tests and we are using Intel Xeon Gold 6226 processor. For parts (2) and (5), the run time is about 20~40 minutes. For part (4), it will require about 72 * 6 = 432 hours, i.e. about 18 days. Part (6) is expected to complete in about 72 * 12 = 864 hours, or about 36 days (Note: the huge run time is further discussed in step2 of "Experiment workflow").

## Software dependencies
- Linux distribution (e.g. Ubuntu 20.04)
- Python 3.8 or higher
- Networkx 2.5.1 (Python package)
- CMurphi 5.4.9.1

## CMurphi setup
First, get the CMurphi of version 5.4.9.1
```
git clone https://github.com/Errare-humanum-est/CMurphi.git
```
To install CMuprhi run from the parent directory:
```
cd src && make
```

## Datasets
Corresponding protocols in part (2), (4), (5) and (6) of Table I are used as inputs to our algorithm. 

## Experiment workflow
### Step1: Run algorithm for all protocols in part (2), (4), (5) and (6) of Table I
Option1: run-all: Run algorithm for all the protocols
```
./run_all_algorithm.sh
```

Option2: run-single: Run algorithm for a single protocol
For part (2):
```
python3 main.py MOSI
python3 main.py MOESI
```
For part (4):
```
python3 main.py CHI
```

For part (5):
```
python3 main.py MSI_nonblocking_cache
python3 main.py MESI_nonblocking_cache
```

For part (6):
```
python3 main.py MSI_blocking_cache
python3 main.py MESI_blocking_cache
```

### Expected results for Step1:
For run-all, it outputs the results exactly corresponding to Table I.
For run-single, for part (2) and (6), the algorithm will stop since they are class 2 protocols. For part (4) and (5), the algorithm generates new virtual network mappings for 2 virtual networks.


### Step2: Run Murphi-based model-checking to verify our algorithm results
Option1: run-all: Run algorithm for all the protocols. The run-all option runs all the model-checking experiments for part (2), (4), (5) and (6) in Table I, so it has a huge run time.
```
./run_all_murphi.sh
```
Option2: run-single: Run algorithm for all the protocols. In this option, We provide a command-line input for part (4) and (5) to let the user define the run time for each sub-task(explained in the following note). And since part (2) and (6) are to find the deadlock, they complete quickly(20~40 minutes), so they don't need a input for run time.

For part (2): 
```
./run_single_murphi.sh 2
```
For part (4): Since part (4) has 6 sub-tasks, we provide 6 command-line inputs to set the run time for each subtask.
```
./run_single_murphi.sh 4 d1 d2 d3 d4 d5 d6
```

For part (5):Since part (5) has 12 sub-tasks, we provide 12 command-line inputs to set the run time for each subtask.
```
./run_single_murphi.sh 5 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12
```

For part (6):
```
./run_single_murphi.sh 6
```

Note: The input durations for parts (4) and (5) are in the unit of "day" (24 hours). 

Example usage: Run the first sub-task in part (4) for 12 hours, and others for 36 hours:
```
./run_single_murphi.sh 4 0.5 1.5 1.5 1.5 1.5 1.5
```

### Note: The explanation of run time and why "run-all" and "run-single"
For every protocol in parts (2) and (6) of Table I, since they are finding the deadlock, they take much less time to run, which is about 20~40 minutes.

Every protocol in parts (4) and (5) of Table I, consists of several sub-verification tasks(we call it sub-task later). Each sub-task takes about 72 hours to complete or run to the bound level 48. While part (4), the CHI protocol has 6 sub-tasks, it takes about 72*6 hours to complete. And also for part (5), the MSI and MESI protocol, which has 6 sub-tasks each, take about 72 * 12 hours to complete.

So in the run-all option, we set a default run time of 72 hours for each sub-task to do a very complete verification.

Since the model-checking process takes lots of time to complete, we provide the run-single option to let the user define the run time for each sub-task.

### Expected results for Step2 and model-checking result extraction:
A "result-extract" script is embedded in both the `run-all` and `run-single` options. This "result-extract" script automatically extracts the results of the Murphi-based model-checking. There are three kinds of results: 
1. The protocol deadlocks; 
2. The model checking reaches a certain bound level(50) and the protocol has no deadlock; 
3. The model checking completes and the protocol has no deadlock.

Finally, both `run-all` and `run-single` will show: For protocols in part (2) and (6), they deadlock (result 1). For protocols in part (4) and (5), they either complete or reache the bound level of 50 without error/deadlock(result 2 or 3).

Since it needs some specific knowledge to understand the model-checking results, we also provide a script to extract results from Murphi-generated result text files.

To extract all the results: 
```
python3 result_extract_murphi.py all
```
To extract results for a single experiment in part (2), (4), (5) or (6)
```
python3 result_extract_murphi.py 2
python3 result_extract_murphi.py 4
python3 result_extract_murphi.py 5
python3 result_extract_murphi.py 6
```

This script will judge if the results match these expectations (if they reproduce Table I) and write it to murphi_result.csv.
