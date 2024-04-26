# clusterTDP-SPM

**clusterTDP-SPM** is an SPM extension for estimating true discovery proportion (TDP) using random field theory (RFT)-based cluster extent inference.

## Introduction

Cluster extent thresholding is one of the most popular approaches for detecting activations in fMRI. Although being powerful in general, this approach suffers from the so-called spatial specificity paradox. That is, each significant cluster contains at least one active voxel, but the localtion or amount of signal is unknown. The new method **clusterTDP** (Goeman et al., 2023) complements and improves upon the current RFT-based cluster extent inference by quantifying the signal with a TDP estimate for every region.

## Installation

### Prerequisites

* Please first download and install Matlab. For macOS users, you could edit the ```.bash_profile``` file and add Matlab to the ```PATH``` by appending
  ``` r
  export PATH=/Applications/MATLAB_***.app/bin:$PATH
  ```
  where the installed Matlab version ```MATLAB_***``` can be found by running ```matlabroot``` in Matlab.

* Please download SPM12 and add it to the Matlab search path. You could either follow **HOME -> Set Path -> Add with Subfolders**, or simply run the following line
  ``` r
  addpath(genpath('.../spm12'));
  ```

### Installing clusterTDP-SPM

Please download the latest version of clusterTDP-SPM with
``` r
git clone https://github.com/xuchen312/clusterTDP-SPM.git
```

## Implementation

* Navigate to the folder for the clusterTDP-SPM toolbox with
  ```r
  cd .../clusterTDP-SPM
  ```
* Launch Matlab, or execute Matlab from the Terminal (command prompt) without the full desktop GUI while still allowing to display graphs with the command
  ```r
  matlab -nodesktop -nosplash
  ```
* Run the function ```spm_clusterTDP_run``` with at most two input arguments in the console, using either
  + ```spm_clusterTDP_run``` to select the desired cluster inference options on the pop-up GUI interface to derive the result table
  
  + ```spm_clusterTDP_run(xSPM)``` if ```xSPM``` is already loaded into the workspace or could be loaded using ```load()``` function
  
  + ```spm_clusterTDP_run('***.txt')``` if you would like to write the result summary table to a text file named ```***.txt```
  
  + ```spm_clusterTDP_run(xSPM, '***.txt')``` if ```xSPM``` is available and the output text file name is specified as ```***.txt```

* Alternatively, the above steps could be executed from the Terminal (command prompt) with
  ```r
  matlab -nodesktop -nosplash -r "cd('.../clusterTDP-SPM'); spm_clusterTDP_run; exit"
  ```

## Result Display

The results derived using **clusterTDP-SPM** are summarised with a result summary table and printed on the console, e.g.,
```
Statistics: cluster-level summary for search volume
          Cluster size    TDN      TDP     max(T)         [X,Y,Z]     
          ____________    ____    _____    ______    _________________

    1         5894        1083    0.184    11.899     58    -14      4
    2         4039         795    0.197     9.983    -58    -14      0
    3          276           1    0.004      7.25     52      2     52
    4          125           0        0     6.596     18     -4    -14
    5           27           0        0     5.645     10     -2     -2
    6           36           0        0     5.511    -34     12    -24
    7           72           0        0     4.989    -42     28     -2
    8          131           1    0.008     4.509    -60     16     32
    9           17           0        0     4.356     40      4    -44
    10          17           0        0     4.301     -8     -8    -12
    11          16           0        0      4.16    -48     -8     46
    12          10           0        0     4.116     28    -20     -6
    13          21           0        0     4.107      8     48     36
    14          29           0        0     4.032      8     12     60
    15          10           0        0     3.993    -36     12    -40
    16          11           0        0     3.939     10     20     58
    17          11           0        0     3.928      6    -32      0
    18          19           0        0       3.8     10    -12      8
```

where a full list of summary variables is described below.
* Index of significant clusters using RFT-based cluster extent inference
* Cluster size for each significant cluster
* Lower bound of TDN (number of true discoveries) bound for each cluster
* Lower bound of TDP bound for each cluster
* maximum statistic of peak voxel within each cluster
* [X,Y,Z] location of peak voxel within each cluster {mm}

## References

Goeman, J.J., Górecki, P., Monajemi, R., Chen, X., Nichols, T.E. and Weeda, W. (2023). Cluster extent inference revisited: quantification and localisation of brain activity. *Journal of the Royal Statistical Society Series B: Statistical Methodology*, 85(4):1128–1153. [[Paper](https://doi.org/10.1093/jrsssb/qkad067)]

## Found bugs, or any questions?

Please email xuchen312@gmail.com.
