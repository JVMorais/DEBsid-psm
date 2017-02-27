%% distance_log
% logarythimic distance between two vectors

function [ dist ] = distance_log( vec1, vec2 )
% created 2017/01/22 by Goncalo Marques

%% Syntax
% [dist] = <../distance_log.m *distance_log*> (vec1, vec2)

%% Description
% Computes the logarythmic distance between two vectors. Given by:
%   sqrt(sum(log10(vec1./vec2).^2))
%
% Input
%
% * vec1: vector 1 with positive entries
% * vec2: vector 2 with positive entries and same length of vector 1
%  
% Output
%
% * dist: distance between the two vectors

  if any(vec1 == 0) || any(vec2 == 0)
    error('distance_log cannot be used if there is a zero on one of the vectors');
  else
    dist = sqrt(sum(log10(vec1./vec2).^2));
  end
end

