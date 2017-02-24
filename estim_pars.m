%% estim_pars
% Estimates parameters

%%
function nsteps = estim_pars;
  % created 2015/02/10 by Goncalo Marques
  % modified 2015/02/10 by Bas Kooijman, 2015/03/31, 2015/07/30 by Goncalo Marques, 2017/02/03
  
  %% Syntax 
  % <../estim_pars.m *estim_pars*>
  
  %% Description
  % Runs the entire estimation procedure
  %
  % * gets the parameters
  % * gets the data
  % * intiates the estimation procedure
  % * sends the results for handling
  %
  % Input
  %
  % * no input
  %  
  % Output
  %
  % * no output
  
  %% Remarks
  % estim_options sets many options
  % option filter = 0 selects filter_nat, which always gives a pass, but still allows for costomized filters in the predict file
  
global pets toxs pars_init_method method filter cov_rules

petsnumber = length(pets);
toxsnumber = length(toxs);

% get data
[data, auxData, metaData, txtData, weights] = mydata_pets;

if petsnumber == 1
  pars_initnm = ['pars_init_', pets{1}];
  if toxsnumber == 0
    resultsnm = ['results_', pets{1}, '.mat'];
  else
    resultsnm = ['results_', pets{1}, '_', toxs{1}, '.mat'];
  end
else
  pars_initnm = 'pars_init_group';
  resultsnm = 'results_group.mat';
end

% set parameters
if pars_init_method == 0
  if petsnumber ~= 1
    error('    For multispecies estimation get_pars cannot be used (pars_init_method cannot be 0)');
  elseif toxsnumber ~= 0
    error('    For estimation with toxicant get_pars cannot be used (pars_init_method cannot be 0)');
  else
    [par, metaPar, txtPar, flag] = get_pars(data.(pets{1}), auxData.(pets{1}), metaData.(pets{1}));
  end
elseif pars_init_method == 1
  if toxsnumber == 0
    load(resultsnm, 'par');
    [par2, metaPar, txtPar] = feval(pars_initnm, metaData.(pets{1}));
    if length(fieldnames(par.free)) ~= length(fieldnames(par2.free))
      fprintf('The number of parameters in pars.free in the pars_init and in the .mat file are not the same. \n');
      return;
    end
    par.free = par2.free;
  else
    load(resultsnm, 'par', 'metaPar', 'txtPar');
  end
elseif pars_init_method == 2
  if toxsnumber == 0
    [par, metaPar, txtPar] = feval(pars_initnm, metaData.(pets{1}));
  else
    [~, ~, metaDataAux, ~, ~] = feval(['mydata_', pets{1}]);   % This is a provisory way of getting metaData for pars_init
    [par, metaPar, txtPar] = feval(pars_initnm, metaDataAux);
    [par, metaPar, txtPar] = feval([pars_initnm, '_', toxs{1}], par, metaPar, txtPar);
  end
end

if petsnumber == 1
  estim_options('cov_rules', '1species');
else
  estim_options('cov_rules', metaPar.covRules);
end

covRulesnm = ['cov_rules_', cov_rules];

% check parameter set if you are using a filter
if filter
  filternm = ['filter_', metaPar.model];
  pass = 1;
  for i = 1:petsnumber
    [passSpec, flag]  = feval(filternm, feval(covRulesnm, par,i));
    if ~passSpec
      fprintf('The seed parameter set is not realistic. \n');
      print_filterflag(flag);
    end
    pass = pass * passSpec;
  end
  if ~pass 
    error('The seed parameter set is not realistic.');
  end
else
  filternm = 'filter_nat'; % this filter always gives a pass
  pass = 1;
end

if ~strcmp(method, 'no')
%   if strcmp(method, 'sidpsm')
%      if petsnumber == 1
%        [x_final,f_final,histout] =  petsidpsm(par, data, auxData, weights, filternm);
%      end
%   else
    if strcmp(method, 'nm')
       if petsnumber == 1
       %[q, info, itercount] = petregr_f('predict_pets', par, data, auxData, weights, filternm);
         [xfinal,finalobj,iter] = petsidpsm(par, data, auxData, weights, filternm);
       else
       par = groupregr_f('predict_pets', par, data, auxData, weights, filternm); % WLS estimate parameters using overwrite
       end
    end
end

% Results
results_pets(par, metaPar, txtPar, data, auxData, metaData, txtData, weights);

if filter
  if petsnumber == 1
    feval(['warning_', metaPar.model], par);
  else
    for i = 1:length(pets)
      feval(['warning_', metaPar.model], feval(covRulesnm, par,i));
    end
  end
end

function par = cov_rules_1species(par, i)
% cov_rules family of functions takes the parameters of the group and
%   computes the parameters of each pet for the multispecies estimation
% This is the simplest case (to be used when we have only one species) 
%   where there is no transformation, i.e. it receives par and it returns par