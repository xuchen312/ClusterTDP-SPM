# ClusterTDP-SPM

**ClusterTDP-SPM** is an SPM extension for estimating true discovery proportion (TDP) with the **ClusterTDP** approach, which is based on cluster extent thresholding using Gaussian random field theory implemented in SPM.

## Introduction

Cluster extent inference is one of the most popular approaches for detecting activations in fMRI. Although being powerful in general, this approach suffers from the so-called spatial specificity paradox. That is, each significant cluster contains at least one active voxel, but the location or amount of signal is unknown. The new method **ClusterTDP** (Goeman et al., 2023) complements and improves upon the current RFT-based cluster extent inference by quantifying the signal with a TDP estimate for every region.

## Installation

### Prerequisites

* Please download and install Matlab. For macOS users, you could edit the ```.bash_profile``` file and add Matlab to the ```PATH``` by appending
  ``` r
  export PATH=/Applications/MATLAB_***.app/bin:$PATH
  ```
  where the installed Matlab version ```MATLAB_***``` can be found by running ```matlabroot``` in Matlab.

* Please download SPM12 and add it to the Matlab search path. You could follow either
  
  + **HOME -> Set Path -> Add Folder...**
  
  + Run the following line in Matlab
    ``` r
    addpath(genpath('.../spm12'));
    ```
  
### Installing ClusterTDP-SPM

* Please download the latest version of ClusterTDP-SPM with
  ``` r
  git clone https://github.com/xuchen312/ClusterTDP-SPM.git
  ```

* Please add the folder for the ClusterTDP-SPM toolbox to the Matlab search path by following either
  
  + **HOME -> Set Path -> Add Folder...**
  
  + Run the below script from Matlab console
    ```r
    addpath(genpath('.../ClusterTDP-SPM'))
    ```

## Implementation

* Navigate to the folder for the ClusterTDP-SPM toolbox with
  ```r
  cd .../ClusterTDP-SPM
  ```
  
* Launch Matlab, or execute Matlab from the Terminal (command prompt) without the full desktop GUI while still allowing to display graphs with the command
  ```r
  matlab -nodesktop -nosplash
  ```
  
* Conduct the ClusterTDP inference by running the function ```spm_clusterTDP``` with at most two input arguments in the console, using either
  
  + ```spm_clusterTDP``` to interactively query ```SPM``` and select the desired cluster thresholding options on the pop-up GUI interface
    
  + ```spm_clusterTDP(xSPM)``` if an input ```xSPM``` structure is already loaded into the workspace or could be loaded using ```load()``` function
    
  + ```spm_clusterTDP(file)``` if you would like to write the result summary table to a CSV file named, e.g., ```ClusTab.csv```
    
  + ```spm_clusterTDP(xSPM, file)``` if ```xSPM``` is available and the output CSV file name ```file``` is specified

  Please note the input argument ```xSPM``` should have the input structure detailed in ```spm_getSPM.m```. In addition, some outputs of the ClusterTDP inference can be returned for interactive exploration of the results in the control panel with, e.g.,
  ```r
  [hReg,xSPM,SPM,TabDat] = spm_clusterTDP;
  ```

* Alternatively, the above steps could be executed from the Terminal (command prompt) and quit Matlab in the end with, e.g.,
  ```r
  matlab -nodesktop -nosplash -r "cd('.../ClusterTDP-SPM'); spm_clusterTDP; exit"
  ```

## Result Display

The main **ClusterTDP-SPM** results are summarised with a result table ```TabDat``` that can be printed on the Matlab console, visualised from the graphics window in SPM, returned to the workspace, and exported to a CSV file. An example of such summary tables is as below.
```
Statistics: p-values adjusted for search volume
================================================================================
set	set	cluster	cluster	cluster	cluster	peak	peak	peak	peak	peak	
p	c	p(FWE)	p(FDR)	k	TDP(lb)	p(FWE)	p(FDR)	T	Z	p(unc)	x,y,z {mm}
--------------------------------------------------------------------------------
0.000	2	0.000	0.000	248	0.742	0.000	0.061	 11.90	 6.30	0.000	 58 -14  4 	
						0.001	0.187	  9.72	 5.76	0.000	 56 -22 -4 	
						0.005	0.333	  8.96	 5.54	0.000	 48 -30  0 	
		0.000	0.000	185	0.730	0.001	0.165	  9.98	 5.83	0.000	-58 -14  0 	
						0.002	0.234	  9.42	 5.68	0.000	-54 -30  6 	
						0.004	0.314	  9.09	 5.58	0.000	-56 -22  4 	

table shows 3 local maxima more than 8.0mm apart
--------------------------------------------------------------------------------
Height threshold: T = 7.73, p = 0.000 (0.050)
Extent threshold: k = 10 voxels, p = 0.002 (0.000)
Expected voxels per cluster, <k> = 0.897
Expected number of clusters, <c> = 0.00
FWEp: 7.728, FDRp: Inf, FWEc: 1, FDRc: 185
Degrees of freedom = [1.0, 19.0]
FWHM = 10.2 9.9 9.2 mm mm mm; 5.1 4.9 4.6 {voxels}
Volume: 2866384 = 358298 voxels = 2905.8 resels
Voxel size: 2.0 2.0 2.0 mm mm mm; (resel = 116.13 voxels)
================================================================================
```
Here, this summary table is highly related to the SPM12 statistics results table, and the summary variable ```TDP(lb)``` shows the lower bound of TDP bound, derived using ClusterTDP, for each significant cluster based on cluster extent inference.

## References

Goeman, J.J., Górecki, P., Monajemi, R., Chen, X., Nichols, T.E. and Weeda, W. (2023). Cluster extent inference revisited: quantification and localisation of brain activity. *Journal of the Royal Statistical Society Series B: Statistical Methodology*, 85(4):1128–1153. [[Paper](https://doi.org/10.1093/jrsssb/qkad067)]

## Found bugs, or any questions?

Please email xuchen312@gmail.com.
