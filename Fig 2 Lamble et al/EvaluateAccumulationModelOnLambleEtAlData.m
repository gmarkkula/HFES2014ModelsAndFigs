
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


function [rmsThetaDotPredictionError, varargout] = ...
  EvaluateAccumulationModelOnLambleEtAlData(SParameters, SObservations)

nObservations = length(SObservations);
VThetaDotAtModelReactionForObservation = zeros(nObservations, 1);
VPredictionErrorForObservation = zeros(nObservations, 1);

c_svSpeed = 50 / 3.6;
c_lvSpeed = c_svSpeed;
c_lvDeceleration = 0.7;
c_lvWidth = 1.6;
c_VSimulationTimeStamp = 0:0.01:100;


% loop through observations
for iObservation = 1:nObservations
  
  initialHeadwayDistance = SObservations(iObservation).initialHeadwayDistance;
  initialHeadwayTime = initialHeadwayDistance / c_svSpeed;
  [xF, vF, xL, vL, dL, deltaX, deltaV, iCrashSample] = SimulateRearEndScenario(...
    c_VSimulationTimeStamp, c_svSpeed, ...
    initialHeadwayTime, c_lvSpeed, ...
    c_lvDeceleration, c_lvDeceleration, 0);
  
  VTimeStamp = c_VSimulationTimeStamp(1:iCrashSample);
  VTheta = 2 * atan(c_lvWidth ./ (2 * deltaX(1:iCrashSample)));
  VThetaDot = -4 * c_lvWidth * deltaV(1:iCrashSample) ./ ...
    (4 * deltaX(1:iCrashSample).^2 + c_lvWidth^2);
  
  iAccumulationModelReactionPoint = AccumulationModel(VTimeStamp, VTheta, VThetaDot, SParameters);
  
  if isempty(iAccumulationModelReactionPoint)
    VThetaDotAtModelReactionForObservation(iObservation) = NaN;
    VPredictionErrorForObservation(iObservation) = 1000;
  else
    VThetaDotAtModelReactionForObservation(iObservation) = VThetaDot(iAccumulationModelReactionPoint);
    VPredictionErrorForObservation(iObservation) = ...
      VThetaDotAtModelReactionForObservation(iObservation) - ...
      SObservations(iObservation).averageThetaDotAtReaction;
  end
  
end % iObservation for loop

% VPredictionErrorForObservation
rmsThetaDotPredictionError = sqrt(mean(VPredictionErrorForObservation.^2));

if nargout == 2
  varargout{1} = VThetaDotAtModelReactionForObservation;
end