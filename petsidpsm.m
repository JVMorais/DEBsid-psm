%SID_PSM algorithm

function [xfinal,finalobj,iter] =  petsidpsm(par, data, auxData, weights, filternm);

 global Y meanY W np parnm nm;

% prepare variable
  %   st: structure with dependent data values only
  st = data;
  [nm nst] = fieldnmnst_st(st); % nst: number of data sets
    
  for i = 1:nst   % makes st only with dependent variables
    fieldsInCells = textscan(nm{i},'%s','Delimiter','.');
    auxVar = getfield(st, fieldsInCells{1}{:});   % data in field nm{i}
    k = size(auxVar, 2);
    if k >= 2
      st = setfield(st, fieldsInCells{1}{:}, auxVar(:,2));
    end
  end
  
%Y: vector with all dependent data
%W: vector with all weights
  [Y, meanY] = struct2vector(st, nm);
  W = struct2vector(weights, nm);

%free parameters - structure to vector
  parnm = fieldnames(par.free);
  np = numel(parnm);
  n = sum(cell2mat(struct2cell(par.free))); 
  if (n == 0)
    return; % no parameters to iterate
  end
  index_par = 1:np;
  index_par = index_par(cell2mat(struct2cell(par.free)) == 1);  % indices of free parameters

  free = par.free; % free is here removed, and after iteration added again
  q = rmfield(par, 'free'); % copy input parameter matrix into output
  qvec = cell2mat(struct2cell(q));

%par.free
 x_initial = qvec(index_par);
 const = 1;
 output = 2;

[x_final,f_final,histout] = sid_psm(x_initial, qvec, data, auxData, index_par,const,output, filternm);

xfinal = x_final;
finalobj = f_final;

%end of petsidpsm