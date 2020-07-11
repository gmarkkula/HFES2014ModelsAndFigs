
% Copyright 2014-2020 Gustav Markkula
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%
%%%%%% 
%
% See README.md for more information on how to use this software.
%
% Paper DOI: https://doi.org/10.1177/1541931214581185
% Software/documentation DOI: https://doi.org/10.17605/OSF.IO/KHDT7
%


function [x, v, a] = SimulateOneVehicleWithInitialConstantSpeed(t, t0, x0, v0, v1, ...
  a0, a1, jerk)

x = zeros(size(t));
v = zeros(size(t));
a = zeros(size(t));

nConstantSpeedSamples = find(t > t0, 1, 'first');
assert(~isempty(nConstantSpeedSamples))

a(1:nConstantSpeedSamples) = 0;
v(1:nConstantSpeedSamples) = v0;
x(1:nConstantSpeedSamples) = x0 + v0 * (t(1:nConstantSpeedSamples) - t(1));

[x(nConstantSpeedSamples:end), v(nConstantSpeedSamples:end), ...
  a(nConstantSpeedSamples:end)] = ...
  SimulateOneVehicle(t(nConstantSpeedSamples:end), x(nConstantSpeedSamples), ...
  v0, v1, a0, a1, jerk);

if false
  figure(1)
  clf
  subplot(3, 1, 1)
  plot(t, x)
  subplot(3, 1, 2)
  plot(t, v)
  subplot(3, 1, 3)
  plot(t, a)
end