
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


function [predictedControlError, deviationFromExpectedControlError, ...
  newAccumulationRate, newAccumulatorActivation, ...
  newControlErrorDeviationReactedTo] = ...
  DeviationFromPredictionAccumulationUpdate(...
  currentControlError, VPreviousControlErrorDeviationsReactedTo, ...
  VErrorPredictionFunction,  accumulatorGating, accumulatorThreshold, ...
  timeStep, currentAccumulatorActivation, bCanReact)

if isnan(currentControlError)
  currentControlError = 0;
end

% -- get predicted error
predictedControlError = dot(fliplr(VPreviousControlErrorDeviationsReactedTo), ...
  VErrorPredictionFunction(1:length(VPreviousControlErrorDeviationsReactedTo)));
% -- get deviation between actual and predicted error
deviationFromExpectedControlError = currentControlError - predictedControlError;
% -- drive accumulator with deviation
newAccumulationRate = deviationFromExpectedControlError - accumulatorGating;
newAccumulatorActivation = max(0, currentAccumulatorActivation + newAccumulationRate * timeStep);
% -- accumulator reaction?
newControlErrorDeviationReactedTo = 0;
if abs(newAccumulatorActivation) > accumulatorThreshold
  if bCanReact
    % add a new burst
    newControlErrorDeviationReactedTo = deviationFromExpectedControlError;
  end
  % reset accumulator
  newAccumulatorActivation = accumulatorThreshold *.6;
end % if accumulation reaction

