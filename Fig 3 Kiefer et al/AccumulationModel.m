
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


function [iReactionPoint, varargout] = AccumulationModel(VTimeStamp, VTheta, VThetaDot, SParameters)

bPlot = false;
bOutputActivation = (nargout == 2);

c_PFunction = @(theta, thetaDot) (1-SParameters.alpha) * thetaDot./theta + SParameters.alpha * thetaDot;
VStimulus = c_PFunction(VTheta, VThetaDot);

% VTau = VTheta ./ VThetaDot
% VTauDot = DoTwoPointNumericalDifferentiation(VTimeStamp, VTau);
% VStimulus = -VTauDot;

VTimeStepLength = diff(VTimeStamp);
VActivationChange = SParameters.C * VStimulus - SParameters.E;
VActivation = zeros(size(VTimeStamp));
iReactionPoint = [];
for i = 2:length(VTimeStamp)
  VActivation(i) = max(0, VActivation(i-1) + VTimeStepLength(i-1) * VActivationChange(i-1));
  if VActivation(i) >= SParameters.A_th && isempty(iReactionPoint)
    iReactionPoint = i;
    if ~bPlot && ~bOutputActivation
      break
    end
  end
end

if bOutputActivation
  varargout{1} = VActivation;
end


if bPlot
%   figure(98)
%   clf
%   hold on
%   plot(VTimeStamp, VTau, 'b');
%   plot(VTimeStamp, VTauDot, 'b--');
  figure(99)
  clf
  subplot(2, 1, 1)
  hold on
  plot(VTimeStamp, VTheta, 'b-')
  plot(VTimeStamp, VThetaDot, 'b--')
  plot(VTimeStamp, VStimulus, 'r-')
  set(gca, 'YLim', [0 10*SParameters.A_th])
  subplot(2, 1, 2)
  hold on
  plot([VTimeStamp(1) VTimeStamp(end)], [SParameters.A_th SParameters.A_th], 'k:')
  plot(VTimeStamp, VActivation, 'r');
  if ~isempty(iReactionPoint)
    plot([VTimeStamp(iReactionPoint) VTimeStamp(iReactionPoint)], get(gca, 'YLim'), 'r:')
  end
  set(gca, 'YLim', [0 10*SParameters.A_th])
  pause
end
