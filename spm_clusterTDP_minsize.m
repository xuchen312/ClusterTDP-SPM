function varargout = spm_clusterTDP_minsize(xSPM,u,alpha,guess)
% Find the minimum significant cluster size threshold for a given alpha
% function [k,Pc] = spm_clusterTDP_minsize(xSPM,u,alpha,guess)
% xSPM  - Structure containing SPM, distribution & filtering details
% u     - Cluster defining threshold
%         If less than zero, u is taken to be uncorrected P-value
% alpha - FWE-corrected level (defaults to 0.05)
% guess - Set to NaN to use a Newton-Rhapson search (default)
%         Or provide a explicit list (e.g. 1:1000) of cluster sizes to
%         search over.
%         If guess is a (non-NaN) scalar nothing happens, except the the
%         corrected P-value of guess is printed. 
%
% Finds the corrected cluster size (spatial extent) threshold for a given
% cluster defining threshold u and FWE-corrected level alpha. 
%
%_________________________________________________________________________
% 
% Based on $Id: CorrClusTh.m,v 1.3 2012/10/29 09:32:10 nichols Exp $ Thomas Nichols, Marko Wilke
% Based on SPM2 CorrClusTh.m,v 1.10 2006/05/08 15:31:02

% settings
epsP = 1e-6;   % Corrected P-value convergence criterion (fraction of alpha)
du   = 1e-6;   % Step-size for Newton-Rhapson
maxi = 100;    % Maximum interations for refined search


% check inputs
if nargin<1 | isempty(xSPM)
  [~,xSPM] = spm_getSPM;
end

% get data from SPM
df   = xSPM.df;
STAT = xSPM.STAT;
n    = 1;
R    = xSPM.R;
S    = xSPM.S;
M    = xSPM.M;
VOX  = sqrt(diag(M(1:3,1:3)'*M(1:3,1:3)))';
FWHM = xSPM.FWHM;
FWHMmm= FWHM.*VOX; 				    %-FWHM {mm}
v2r  = 1/prod(FWHM(~isinf(FWHM)));  %-voxels to resels

sf_ShowVolInfo(R,S,VOX,FWHM,FWHMmm)

% get initial threshold to use
if nargin<2 | isempty(u)
    u = xSPM.u;
end

% if below 1, assume this to be a p-value
if u <= 1
    uP = u;
    u = spm_u(u,df,STAT);
else
    switch STAT
        case 'T'
            uP = 1-spm_Tcdf(u,df(end));  % T-map
        case 'F'
            uP = 1-spm_Fcdf(u,df);       % F-map
        case 'X'
            uP = 1-spm_Xcdf(u,df(1));    % X-map
        otherwise
            error('Unsupported STAT type: %s. Please use ''T'', ''F'' or ''X''.', STAT);
    end
end

% get corrected cluster size threshold, assume 0.05, FWE-corrected
if nargin<3 | isempty(alpha)
  alpha = 0.05;
end

% get cluster sizes to check, assume brute-force
if nargin<4 | isempty(guess)
  guess = NaN;  % 1:1000;
end


% initialize
epsP = alpha*epsP;
Status = 'OK';

% check options
if length(guess)==1 & ~isnan(guess)
  
  %
  % Dummy case... just report P-value
  %

  k  = guess;
  Pc = spm_P(1,k*v2r,u,df,STAT,R,n,S);
  
  Status = 'JustPvalue';

elseif (spm_P(1,1*v2r,u,df,STAT,R,n,S)<alpha)

  %
  % Crazy setting, where 1 voxel cluster is significant
  %

  k = 1;
  Pc = spm_P(1,1*v2r,u,df,STAT,R,n,S);
  Status = 'TooRough';

elseif isnan(guess)

  %
  % Automated search
  % 

  % Initial (lower bound) guess is the expected number of voxels per cluster
  [P Pn Em En] = spm_P(1,0,u,df,STAT,R,n,S);
  kr = En; % Working in resel units
  rad = (kr)^(1/3); % Parameterize proportional to cluster diameter

  %
  % Crude linear search bound answer
  %
  Pcl  = 1;   % Lower bound on P
  radu = rad; % Upper bound on rad
  Pcu  = 0;   % Upper bound on P
  radl = Inf; % Lower bound on rad
  while (Pcl > alpha)
    Pcu  = Pcl;
    radl = radu; % Save previous result
    radu = radu*1.1;
    Pcl  = spm_P(1,radu^3   ,u,df,STAT,R,n,S);
  end

  %
  % Newton-Rhapson refined search
  %
  d = 1;		    
  os = NaN;     % Old sign
  ms = (radu-radl)/10;  % Max step
  du = ms/100;
  % Linear interpolation for initial guess
  rad = radl*(alpha-Pcl)/(Pcu-Pcl)+radu*(Pcu-alpha)/(Pcu-Pcl);
  iter = 1;
  while abs(d) > epsP
    Pc  = spm_P(1,rad^3   ,u,df,STAT,R,n,S);
    Pc1 = spm_P(1,(rad+du)^3,u,df,STAT,R,n,S);
    d   = (alpha-Pc)/((Pc1-Pc)/du);
    os = sign(d);  % save old sign
    % Truncate search if step is too big
    if abs(d)>ms, 
      d = sign(d)*ms;
    end
    % Keep inside the given range
    if (rad+d)>radu, d = (radu-rad)/2; end
    if (rad+d)<radl, d = (rad-radl)/2; end
    % update
    rad = rad + d;
    iter = iter+1;
    if (iter>=maxi), 
      Status = 'TooManyIter';
      break; 
    end
  end
  % Convert back
  kr = rad^3;
  k = ceil(kr/v2r);
  Pc  = spm_P(1,k*v2r,u,df,STAT,R,n,S);

%
% Brute force!
%
else
  Pc = 1;
  for k = guess
    Pc = spm_P(1,k*v2r,u,df,STAT,R,n,S);
    %fprintf('k=%d Pc=%g\n',k,Pc);
    if Pc <= alpha, 
      break; 
    end
  end;
  if (Pc > alpha)
    Status = 'OutOfRange';
  end
end

switch (Status)
 case {'JustPvalue'}
  fprintf(['  For a cluster-defining threshold of P = %0.3f (T = %0.4f) a cluster size threshold of\n'...
	   '  %d has corrected P-value %g\n\n'],...
	  uP,u,k,Pc);
 case {'OK'}
  fprintf(['  For a cluster-defining threshold of P = %0.3f (T = %0.4f) the level %0.3f corrected\n'...
	   '  cluster size threshold is %d and has size (corrected P-value) %g\n\n'],...
	  uP,u,alpha,k,Pc);
 case 'TooRough'
  fprintf(['\n  WARNING: Single voxel cluster is significant!\n\n',...
           '  For a cluster-defining threshold of P = %03.f (T = %0.4f) a k=1 voxel cluster\n'...
	   '  size threshold has size (corrected P-value) %g\n\n'],...
	  uP,u,Pc); 
 case 'TooManyIter'
  fprintf(['\n  WARNING: Automated search failed to converge\n' ...
	   '  Try systematic search.\n\n']); 
 case 'OutOfRange'  
  fprintf(['\n  WARNING: Within the range of cluster sizes searched (%g...%g)\n',...
	     '  a corrected P-value <= alpha was not found (smallest P: %g)\n\n'],...
	  guess(1),guess(end),Pc); 
  fprintf([  '  Try increasing the range or an automatic search.\n\n']); 
 otherwise
  error('Unknown status code');
end

if nargout==1
  varargout = {k};
elseif nargout>1
  varargout = {k,Pc};
end

function sf_ShowVolInfo(R,S,VOX,FWHM,FWHMmm)

fprintf('\n  Search Volume:  %7d %0.2fx%.02fx%0.2f voxels\n',S,VOX);
fprintf('                  %7.2f cmm, %5.2f L, %5.2f RESELS\n',S*prod(VOX),S*prod(VOX)/100^3,R(end));
fprintf(['                  %0.2fx%.02fx%0.2f mm FWHM, ','%0.2fx%.02fx%0.2f vox FWHM\n\n'],FWHMmm,FWHM);
return
