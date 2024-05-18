function [lower_bound] = spm_clusterTDP_lb(CL,k,varargin)
%
% Compute lower bound of TDP lower bound based on RFT for a given cluster
%
% =========================================================================
% FORMAT: [lower_bound] = spm_clusterTDP_lb(CL,k,[d])
% -------------------------------------------------------------------------
% Inputs:
%  - CL: an nx3 matrix of [X,Y,Z] coordinates for n voxels within a cluster
%  -  k: cluster extend threshold based on RFT
%  -  d: dimensionality of the problem (optional)
%
% Outputs:
%  - lower_bound: lower bound of TDP bound
% =========================================================================
%

% check the inputs
if nargin < 2
    error('Function requires at least 2 inputs!');
elseif nargin > 2
    d = varargin{1};
else
    d = 3;
end

% calculate the optimal edge ratio
rk = RK(k,d);

range_x = range(CL(:,1)) + 3;
range_y = range(CL(:,2)) + 3;
range_z = range(CL(:,3)) + 3;
CL = CL(:,1) + range_x * CL(:,2) + range_x * range_y*CL(:,3);

neighbors_x = [0 1 0 1 0 1 0 1];
neighbors_y = [0 0 1 1 0 0 1 1];
neighbors_z = [0 0 0 0 1 1 1 1];
neighbors = neighbors_x + range_x * neighbors_y + range_x * range_y * neighbors_z;

max_i = floor(length(CL)^(1/3));
sV = length(CL) > k;
for j=0:max_i
    pruned      = CLPRUNE(CL, neighbors, j);
    pruned_plus = CLPLUS(pruned, neighbors);
    pruned_rest = setdiff(pruned_plus, pruned);
    sV = max(sV, rk * length(pruned_plus) - length(pruned_rest));
end

lower_bound = ceil(sV);

return


function rk = RK(k,d)
%
% Calculate the optimal edge ratio
%

fdks = zeros(k,1);
for i=1:k
    fdks(i) = 1-i/FDK(i,d);
end
rk = min(fdks);

return


function fdk = FDK(k,d)
%
% Calculate fdk
%

if (d==0 || k==0)
    fdk = 0;
else
    fk1d    = floor(k^(1/d));
    ldk     = floor((log(k) - d*log(fk1d)) / (log(fk1d+1) - log(fk1d)));
    bdkplus = (fk1d + 1)^(d-ldk) * (fk1d + 2)^ldk;
    bdk     = fk1d^(d-ldk) * (fk1d + 1)^ldk;
    fdk     = bdkplus + FDK(k-bdk, d-1);
end

return


function CLplus = CLPLUS(CL, neighbors)
CLplus = zeros(length(CL),length(neighbors));
for i=1:length(CL)
    for j=1:length(neighbors)
        CLplus(i,j) = CL(i) + neighbors(j);
    end
end
CLplus = unique(CLplus(:));
return

function CLmin = CLMIN(CL, neighbors)
CLrest = setdiff(CLPLUS(CL,neighbors), CL);

CLmin = zeros(length(CLrest),length(neighbors));
for i=1:length(CLrest)
    for j=1:length(neighbors)
        CLmin(i,j) = CLrest(i) - neighbors(j);
    end
end
CLmin = unique(CLmin(:));

CLmin = setdiff(CL, CLmin);
return

function CLprune = CLPRUNE(CL, neighbors, i)
for j=1:i
    CL = CLMIN(CL, neighbors);
end
for j=1:i
    CL = CLPLUS(CL, neighbors);
end
CLprune = CL;
return

function r = range(CL)
r = max(CL(:)) - min(CL(:));
return
