function varargout = spm_clusterTDP(varargin)
%
% Run clusterTDP inference
%
% =========================================================================
% FORMAT:             spm_clusterTDP([xSPM,file])
%         [ClusTab] = spm_clusterTDP([xSPM,file])
% -------------------------------------------------------------------------
% Inputs (optional):
%  - xSPM: structure containing SPM, distribution & filtering details
%  - file: output text file name (e.g. ***.txt)
%
% Outputs (optional):
%  - ClusTab: result summary table
% =========================================================================
%

%-Check input arguments
%----------------------------------------------------------------------
if nargin > 1
    if isstruct(varargin{1})
        xSPM = varargin{1};
    else
        error('1st input should be a structure.');
    end
    if ischar(varargin{2})
        file = varargin{2};
    else
        error('2nd input should be a character array.');
    end
elseif nargin == 1
    if isstruct(varargin{1})
        xSPM = varargin{1};
    elseif ischar(varargin{1})
        file = varargin{1};
    else
        error('Unrecognised input format: should be a structure or a character array.');
    end
end

%-Check output file name
%----------------------------------------------------------------------
if exist('file','var')
    [~,~,fext] = fileparts(file);
    if isempty(fext)
        file = strcat(file,'.txt');
    elseif ~strcmpi(fext,'.txt')
        error('Unexpected output file extension: %s',fext);
    end
end

%-Compute xSPM & extract data from xSPM
%----------------------------------------------------------------------
if exist('xSPM','var')
    try                                 % xSPM: evaluated/thresholded structure
        xyzs = xSPM.XYZ';
        dims = xSPM.DIM';
        mat  = xSPM.M;
        zval = xSPM.Z;
        kval = xSPM.uc(3);
    catch
        [SPM,xSPM] = spm_getSPM(xSPM);  % xSPM: input structure

        xyzs = xSPM.XYZ';
        dims = xSPM.DIM';
        mat  = xSPM.M;
        zval = xSPM.Z;
        kval = xSPM.uc(3);
    end
else
    [SPM,xSPM] = spm_getSPM;            % no xSPM & query SPM interactively

    xyzs = xSPM.XYZ';
    dims = xSPM.DIM';
    mat  = xSPM.M;
    zval = xSPM.Z;
    kval = xSPM.uc(3);
end

%-Find clusters
%----------------------------------------------------------------------
[clus,stat] = deal(zeros(dims));
for i=1:size(xyzs,1)
    clus(xyzs(i,1),xyzs(i,2),xyzs(i,3)) = 1;
    stat(xyzs(i,1),xyzs(i,2),xyzs(i,3)) = zval(i);
end
[L,NUM] = spm_bwlabel(clus);

%-Compute lower bound of TDN lower bound for each cluster
%----------------------------------------------------------------------
[sz,lb,mz] = deal(zeros(NUM,1));
for i=1:NUM
    sz(i) = sum(L(:)==i);                            % 1) cluster size

    [x,y,z] = ind2sub(dims,find(L==i));
    %lb(i) = spm_clusterTDP_lb([x y z],ceil(kval));
    lb(i) = spm_clusterTDP_lb([x y z],round(kval));  % 2) TDN lower bound

    mz(i) = max(stat(L(:)==i));                      % 3) max(T)
end

%-Sort local maxima in descending order
%----------------------------------------------------------------------
[mz,I] = sort(mz,'descend');
sz  = sz(I);
lb  = lb(I);
tdp = lb./sz;                                        % 4) TDP lower bound

%-Workaround in spm_max for conjunctions with negative thresholds
%----------------------------------------------------------------------
[~,maxZ,maxXYZ,regs,~] = spm_max(zval,xyzs');

% sort local maxima in descending order
[~,I]    = sort(maxZ,'descend');
maxXYZ   = maxXYZ(:,I);
regs     = regs(I);
% return unique values of regs (unsorted)
[~,I,~]  = unique(regs,'stable');
maxXYZ   = maxXYZ(:,I);                              % 5) XYZ coordinates
maxXYZmm = mat(1:3,:)*[maxXYZ; ones(1,size(maxXYZ,2))];

%-Construct & display result summary table
%----------------------------------------------------------------------

% result table
ClusTab = table(sz,lb,tdp,mz,maxXYZmm(1,:)',maxXYZmm(2,:)',maxXYZmm(3,:)');
%ClusTab.Properties.VariableNames = {'Cluster size','TDN','TDP','max(T)','x (mm)','y (mm)','z (mm)'};

% table title
fprintf('\n');
fprintf('Statistics: cluster-level summary for search volume\n')
fprintf('%c',repmat('=',1,60));
fprintf('\n');

% table header
hdr = {'   Size','TDN(lb)','TDP(lb)','max(T)','  x','  y','  z (mm)'}';
fprintf('%s\t',hdr{1:end});
fprintf('\n');
fprintf('%c',repmat('-',1,60));
fprintf('\n');

% table data
for i = 1:size(ClusTab,1)
    fprintf('%7.0f\t',ClusTab{i,1});
    fprintf('%7.0f\t',ClusTab{i,2});
    fprintf('%6.3f\t',ClusTab{i,3});
    fprintf('%6.3f\t',ClusTab{i,4});
    fprintf('%4.0f\t',ClusTab{i,5});
    fprintf('%4.0f\t',ClusTab{i,6});
    fprintf('%4.0f\t',ClusTab{i,7});
    fprintf('\n');
end
fprintf('%c',repmat('-',1,60));
fprintf('\n');

% ClusTab = table(sz,lb,tdp,mz,maxXYZmm');
% ClusTab.Properties.Description   = 'Statistics: cluster-level summary for search volume';
% ClusTab.Properties.RowNames      = string(1:length(sz));
% ClusTab.Properties.VariableNames = {'Cluster size','TDN','TDP','max(T)','[X,Y,Z]'};
% ClusTab.('TDP')    = round(ClusTab.('TDP'),3);
% ClusTab.('max(T)') = round(ClusTab.('max(T)'),3);
% disp(ClusTab);

%-Return result summary table
%----------------------------------------------------------------------
if nargout>0
    varargout = {ClusTab};
end

%-Write the result table to a text file
%----------------------------------------------------------------------
if exist('file','var')
    writetable(ClusTab,file,'Delimiter',' ','WriteRowNames',true);
end

return
