# clusterTDP-SPM

**clusterTDP-SPM** is an SPM extension for estimating true discovery proportion (TDP) using random field theory (RFT)-based cluster extent inference.

## Introduction

Cluster extent thresholding is one of the most popular approaches for detecting activations in fMRI. Although being powerful in general, this approach suffers from the so-called spatial specificity paradox. That is, each significant cluster contains at least one active voxel, but the localtion or amount of signal is unknown. The new method **clusterTDP** (Goeman et al., 2023) complements and improves upon the current RFT-based cluster extent inference by quantifying the signal with a TDP estimate for every region.

## Installation

### Prerequisites

* Please first download and install Matlab. For macOS users, you could edit your ```.bash_profile``` file and simply add Matlab to the ```PATH``` by appending
  ``` r
  export PATH=/Applications/MATLAB_***.app/bin:$PATH
  ```
  where the installed Matlab version can be found by running ```matlabroot``` in Matlab.

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

* Launch Matlab, or execuate Matlab from the Terminal (command prompt) without the full desktop GUI while still allowing to disply graphs with the command
  ```r
  matlab -nodesktop -nosplash
  ```
* Navigate to the folder for the clusterTDP-SPM toolbox with
  ```r
  cd .../clusterTDP-SPM
  ```
* Run the below script in the console, and select the desired cluster inference options on the pop-up GUI interface to derive the result table.
  ``` r
  spm_clusterTDP_run
  ```
* Alternatively, you could execuate the script with
  ```r
  matlab -nodesktop -nosplash -r "spm_clusterTDP_run"
  ```

## References

Goeman, J.J., Górecki, P., Monajemi, R., Chen, X., Nichols, T.E. and Weeda, W. (2023). Cluster extent inference revisited: quantification and localisation of brain activity. *Journal of the Royal Statistical Society Series B: Statistical Methodology*, 85(4):1128–1153. [[Paper](https://doi.org/10.1093/jrsssb/qkad067)]

## Found bugs, or any questions?

Please email xuchen312@gmail.com.
