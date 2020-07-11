
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


function [RSquare, varargout] = ...
  EvaluateAccumulationModelOnKieferEtAlData(SParameters, SObservations)

nObservations = size(SObservations.MScenarios, 1);
VObservedITTCValues = SObservations.MScenarios(:, 4);
VPredictedITTCValues = zeros(size(VObservedITTCValues));
VPredictionErrorForObservation = zeros(size(VObservedITTCValues));

c_VSimulationTimeStamp = 0:0.01:200;

c_mphTompsFactor = 1.609 / 3.6;
c_g = 9.81;
c_povWidth = 73 * 2.54 / 100; % 1997 Mercury Sable is 73" wide, according to the interwebz

% loop through observations
for iObservation = 1:nObservations
  
  svSpeed = SObservations.MScenarios(iObservation, 1) * c_mphTompsFactor;
  povInitialSpeed = SObservations.MScenarios(iObservation, 2) * c_mphTompsFactor;
  povDeceleration = -SObservations.MScenarios(iObservation, 3) * c_g;
  if povDeceleration == 0
    %     initialHeadwayTime = SObservations.initialTimeHeadways.LVNDScenarios;
%     initialHeadwayTime = SParameters.LVDTHW;
distanceToReachSVSpeed = 0;%svSpeed^2 / 2 * SParameters.LVDTHW;
distanceLeftToPOV = 1097 *.75 - distanceToReachSVSpeed;
initialHeadwayTime = distanceLeftToPOV / svSpeed;
  else
    initialHeadwayTime = SObservations.initialTimeHeadways.LVDScenarios;
  end
  
  [xF, vF, xL, vL, dL, deltaX, deltaV, iCrashSample] = SimulateRearEndScenario(...
    c_VSimulationTimeStamp, svSpeed, ...
    initialHeadwayTime, povInitialSpeed, ...
    povDeceleration, povDeceleration, 0);
  assert(~isempty(iCrashSample))
  
  VTimeStamp = c_VSimulationTimeStamp(1:iCrashSample);
  VTheta = 2 * atan(c_povWidth ./ (2 * deltaX(1:iCrashSample)));
  VThetaDot = -4 * c_povWidth * deltaV(1:iCrashSample) ./ ...
    (4 * deltaX(1:iCrashSample).^2 + c_povWidth^2);
  
  iThresholdPoint = AccumulationModel(VTimeStamp, VTheta, VThetaDot, SParameters);
  
  if isempty(iThresholdPoint)
    iAccumulationModelReactionPoint = [];
  else
    iAccumulationModelReactionPoint = find(c_VSimulationTimeStamp >= ...
      c_VSimulationTimeStamp(iThresholdPoint) + SParameters.T_R, 1, 'first');
  end
  
  if isempty(iAccumulationModelReactionPoint)
    VPredictedITTCValues(iObservation) = NaN;
    VPredictionErrorForObservation(iObservation) = 1000;
  else
    VPredictedITTCValues(iObservation) = ...
      -deltaV(iAccumulationModelReactionPoint) / deltaX(iAccumulationModelReactionPoint);
    VPredictionErrorForObservation(iObservation) = ...
      VPredictedITTCValues(iObservation) - ...
      VObservedITTCValues(iObservation);
  end
  
end % iObservation for loop

totalSumOfSquares = sum( (VObservedITTCValues - mean(VObservedITTCValues)).^2 );
sumOfSquaresOfResiduals = sum(VPredictionErrorForObservation.^2);
RSquare = 1 - sumOfSquaresOfResiduals / totalSumOfSquares;

if nargout == 2
  varargout{1} = VPredictedITTCValues;
end