
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



function [xF, vF, xL, vL, dL, deltaX, deltaV, iCrashSample] = SimulateRearEndScenario(...
  t, svSpeed, ...
  initialTimeHeadway, initialPOVSpeed, ...
  povInitialDeceleration, povMaxDeceleration, timeToMaxPOVDeceleration, ...
  varargin)

c_scenarioTimeStep = t(2) - t(1);
assert(all(round(diff(t)*100) == round(c_scenarioTimeStep*100))) % constant time step required (requiring only two decimals, to avoid some problem with rounding...)

% simulate scenario
dL = ones(size(t)) * povMaxDeceleration;
if timeToMaxPOVDeceleration > 0
  iMaxDecReachedSample = round(timeToMaxPOVDeceleration / c_scenarioTimeStep);
  dL(1:iMaxDecReachedSample) = ...
    linspace(povInitialDeceleration, povMaxDeceleration, iMaxDecReachedSample);
end
vF0 = svSpeed;
vL0 = initialPOVSpeed;
deltaX0 = initialTimeHeadway * vF0;
xF = vF0 * t;
vF = ones(size(xF)) * vF0;
vL = max(vL0 + cumtrapz(t, -dL), 0);
%           max(vL0 - dL * t, 0);
xL = deltaX0 + cumtrapz(t, vL);
deltaX = xL - xF;
deltaV = vL - vF;
iCrashSample = find(deltaX <= 0, 1, 'first') - 1;


if ~isempty(varargin) && strcmp(varargin{1}, 'plot')
  figure(999)
  clf
  
  subplot(4, 1, 1)
  plot(t(1:iCrashSample), deltaX(1:iCrashSample), 'k-')
  ylabel('Headway (m)')
  title(sprintf('SV %d km/h; POV %.0f km/h; THW %.1f s; d %.1f->%.1f m/s^2; T_d %.1f s', ...
    svSpeed * 3.6, ...
    initialPOVSpeed*3.6, ...
    initialTimeHeadway, ...
    povInitialDeceleration, ...
    povMaxDeceleration, ...
    timeToMaxPOVDeceleration))
  set(gca, 'XLim', [0 t(iCrashSample)])
  
  subplot(4, 1, 2)
  hold on
  plot(t(1:iCrashSample), vF(1:iCrashSample)*3.6, 'k-')
  plot(t(1:iCrashSample), vL(1:iCrashSample)*3.6, 'k--')
  set(gca, 'XLim', [0 t(iCrashSample)])
  legend('SV', 'POV')
  ylabel('Speed (km/s)')
  
  subplot(4, 1, 3)
  plot(t(1:iCrashSample), dL(1:iCrashSample))
  ylabel('POV dec. (m/s^2)')
  set(gca, 'XLim', [0 t(iCrashSample)])
  
  subplot(4, 1, 4)
  ITTC = -deltaV ./ deltaX;
  plot(t(1:iCrashSample), ITTC(1:iCrashSample))
  ylabel('ITTC (1/s)')
  axis([0 t(iCrashSample) 0 1])
%   dReq = CalculateDReq(xF, vF, xL, vL, -dL);
%   plot(t(1:iCrashSample), dReq(1:iCrashSample))
%   ylabel('Req. SV dec. (m/s^2)')
%   axis([0 t(iCrashSample) 0 10])
  xlabel('Time (s)')
  
  pause
end