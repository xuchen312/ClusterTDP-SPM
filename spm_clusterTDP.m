function varargout = spm_clusterTDP(varargin)
%
% Run clusterTDP inference
%
% =========================================================================
% FORMAT:                          spm_clusterTDP([xSPM,file])
%         [hReg,xSPM,SPM,TabDat] = spm_clusterTDP([xSPM,file])
% -------------------------------------------------------------------------
% Inputs (optional; if empty or not specified, the default is used):
%  -   xSPM: an input structure containing SPM, distribution & filtering
%            details (see spm_getSPM.m for details; default: compute xSPM
%            interactively) 
%  -   file: a character array specifying the output name for a CSV file
%            (default: output table is not saved)
%
% Outputs (optional, for interactive exploration):
%  -   hReg: handle of MIP XYZ registry object 
%            (see spm_XYZreg.m for details)
%  -   xSPM: an evaluated/thresholded structure containing SPM,
%            distribution & filtering details
%            (see spm_getSPM.m for details)
%  -    SPM: an SPM structure
%            (see spm_getSPM.m for details)
%  - TabDat: a structure containing table data with fields
%            (see spm_clusterTDP_list.m for details)
% =========================================================================
%

%-Set default modality
%----------------------------------------------------------------------
try
  modality = spm_get_defaults('modality');
  spm('Defaults',modality);
catch
  spm('Defaults','FMRI');
end

%-Check input arguments
%----------------------------------------------------------------------
if nargin > 2; error('Too many input arguments'); end
if nargin > 1
    if ~isempty(varargin{1})
        if isstruct(varargin{1})
            xSPM = varargin{1};
        else
            error('The 1st argument must be ''xSPM''');
        end
    end
    if ~isempty(varargin{2})
        if ischar(varargin{2})
            file = varargin{2};
        else
            error('The 2nd argument must be ''file''');
        end
    end
end
if nargin == 1
    if ~isempty(varargin{1})
        if isstruct(varargin{1})
            xSPM = varargin{1};
        elseif ischar(varargin{1})
            file = varargin{1};
        else
            error(['Unrecognised input: ' varargin{1}]);
        end
    end
end
if exist('file','var')
    [fpath,fname,fext] = fileparts(file);
    if isempty(fext)
        file = strcat(file,'.csv');
    elseif ~strcmpi(fext,'.csv')
        error('Unexpected output file extension: %s',fext);
    end
    if isempty(fname)
        file = fullfile(fpath,strcat('ClusTab',fext));
        warning('Found empty file name and use ''ClusTab.csv''');
    end
end

%-Query SPM and setup GUI
%----------------------------------------------------------------------
if exist('xSPM','var')
    [hReg,xSPM,SPM] = spm_clusterTDP_ui('Setup',xSPM);
else
    [hReg,xSPM,SPM] = spm_clusterTDP_ui('Setup');
end

%-Compute result summary table "TabDat"
%----------------------------------------------------------------------
TabDat = spm_clusterTDP_list('List',xSPM,hReg);

%-Display table "TabDat"
%----------------------------------------------------------------------
spm_clusterTDP_list('TxtList',TabDat);

%-Check output file name & write result table to a csv file
%----------------------------------------------------------------------
if exist('file','var')
    spm_clusterTDP_list('CSVList',TabDat,file);
end

%-Return outputs for interactive exploration of results in control panel
%----------------------------------------------------------------------
if nargout > 0
    varargout = {hReg,xSPM,SPM,TabDat};
end

return
