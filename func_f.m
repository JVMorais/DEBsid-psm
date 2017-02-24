
function [f] = func_f(x, qvec,index_par, data, auxData)
%
% Purpose:
%
%    Function func_f is an user provided function which
%    computes the value of the objective function at a
%    point provided by the optimizer.
%
% Input:  
%
%         x (point given by the optimizer).
%
% Output: 
%
%         f (function value at the given point).
%
% Copyright (C) 2005 A. L. Custodio and L. N. Vicente.
%
% http://www.mat.uc.pt/sid-psm
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
%
%
% -----------------------------------------------------------------------------
%  Block to be user modified.
% -----------------------------------------------------------------------------
% f = (x(2)-x(1)^2)^2;

%input
  global lossfunction W Y meanY np parnm nm;
  fileLossfunc = ['lossfunction_', lossfunction];
  
  loss_func = str2func (fileLossfunc);
  
% %scale function
%   x = scale (x);
   
%vector to struct
  qvec(index_par)= x;
  q = cell2struct(mat2cell(qvec, ones(np, 1), [1]),parnm);

% Predict Function:
  [prdData, info] = predict_pets(q, data, auxData); 
  [P, meanP] = struct2vector(prdData, nm);


[f] = loss_func(Y, meanY, P, meanP, W);

% -----------------------------------------------------------------------------
%  End of block to be user modified.
% -----------------------------------------------------------------------------
%
% End of func_f.