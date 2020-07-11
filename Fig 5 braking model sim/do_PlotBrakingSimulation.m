
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


% init

clear all
close all
randn('state', 0);

c_iFontSize = 13;

% simulation settings
vx = 60 * 1.609 / 3.6; % m/s, vehicle longitudinal speed
c_startTime = 0;
c_timeStep = 0.005;
c_endTime = 13; % s   19.5
t = c_startTime:c_timeStep:c_endTime;
c_nSamples = length(t);

% scenarios
c_povDecelerationStartTime = 2;
c_povWidth = 1.8; % m
c_initialHeadwayTime = 2; % s
c_initialHeadwayDistance = c_initialHeadwayTime * vx;
c_timeToPOVMaxDeceleration = 0.1; % s
c_VPOVMinSpeeds = [40 * 1.609 / 3.6  0]; % m/s
c_VPOVMaxDecelerations = [.15*9.81  8]; % m/s^2

% values from fitting to the Kiefer et al (2003) data as described in the
% paper
c_accumulatorGating = 0.0155;
c_accumulatorThreshold = 0.0888;

c_burstOnsetTime = 0;
c_burstPeakTime = 0.1;
c_burstStdDevsToInclude = 2;
c_burstFunction = normpdf(t, c_burstPeakTime, ...
  (c_burstPeakTime - c_burstOnsetTime) / c_burstStdDevsToInclude);
c_burstFunction = c_burstFunction - c_burstFunction(find(t >= c_burstOnsetTime, 1, 'first'));
c_burstFunction(c_burstFunction < 0) = 0;
c_burstFunction = c_burstFunction / trapz(t, c_burstFunction);

c_brakePedalGain = 2.5;


% error prediction
c_errorStartsDisappearingTime = 0;%0;
c_errorDisappearedTime = 9;%20;
c_errorPredictionStdDevsToInclude = 3;
c_errorPredictionFunction = GetErrorPredictionFunction(...
  t, c_errorStartsDisappearingTime, c_errorDisappearedTime, c_errorPredictionStdDevsToInclude);

% plot(t, c_errorPredictionFunctionAngleControl)


%% run the simulations

figure(1)
set(gcf, 'Position', [ 160         229        1130/2         350])
clf

% loop through the two lead vehicle braking scenarios
for iPOVAcc = 1:2
  c_povMaxDeceleration = c_VPOVMaxDecelerations(iPOVAcc);
  c_povMinSpeed = c_VPOVMinSpeeds(iPOVAcc);
  
  povOpticalSize = zeros(1, c_nSamples);
  povOpticalSize(1) = NaN;
  
  povOpticalExpansion = zeros(1, c_nSamples);
  povOpticalExpansion(1) = NaN;
  
  povInverseTau = zeros(1, c_nSamples);
  povInverseTau(1) = NaN;
  povInverseTauExpected = zeros(1, c_nSamples);
  povInverseTauDeviation = zeros(1, c_nSamples);
  povInverseTauDeviationsReactedTo = zeros(1, c_nSamples);
  
  brakePedal = zeros(1, c_nSamples);
  brakePedalDot = zeros(1, c_nSamples);
  
  accumulationRate = zeros(1, c_nSamples);
  accumulatorActivation = zeros(1, c_nSamples);
  
  oveRequestedAcceleration = zeros(1, c_nSamples);
  oveJerk = zeros(1, c_nSamples);
  oveAcceleration = zeros(1, c_nSamples);
  oveSpeed = zeros(1, c_nSamples);
  oveSpeed(1) = vx;
  ovePosition = zeros(1, c_nSamples);
  
  [povPosition, povSpeed, povAcceleration] = ...
    SimulateOneVehicleWithInitialConstantSpeed(...
    t, c_povDecelerationStartTime, c_initialHeadwayDistance, vx, c_povMinSpeed, ...
    0, -c_povMaxDeceleration, -c_povMaxDeceleration / c_timeToPOVMaxDeceleration);
  
  headwayDistance = zeros(1, c_nSamples);
  headwayDistance(1) = NaN;
  relativeSpeed = zeros(1, c_nSamples);
  relativeSpeed(1) = NaN;
  
  for i = 2:c_nSamples
    
    % vehicle dynamics
    brakePedal(i) = min(1, brakePedal(i-1) + c_timeStep * brakePedalDot(i-1));
    oveRequestedAcceleration(i) = brakePedal(i-1) * (-8);
    oveJerk(i) = (oveRequestedAcceleration(i-1) - oveAcceleration(i-1)) / 0.1;
    oveAcceleration(i) = oveAcceleration(i-1) + c_timeStep * oveJerk(i-1);
    oveSpeed(i) = max(0, oveSpeed(i-1) + c_timeStep * oveAcceleration(i-1));
    ovePosition(i) = ovePosition(i-1) + c_timeStep * oveSpeed(i-1);
    
    % driver model
    headwayDistance(i) = povPosition(i) - ovePosition(i);
    relativeSpeed(i) = povSpeed(i) - oveSpeed(i);
    povOpticalSize(i) = 2 * atan(c_povWidth ./ (2 * headwayDistance(i)));
    povOpticalExpansion(i) = -4 * c_povWidth * relativeSpeed(i) ./ ...
      (4 * headwayDistance(i).^2 + c_povWidth^2);
    povInverseTau(i) = povOpticalExpansion(i) / povOpticalSize(i);
    
    % bursts and accumulation
    [povInverseTauExpected(i), povInverseTauDeviation(i), ...
      accumulationRate(i), accumulatorActivation(i), ...
      povInverseTauDeviationsReactedTo(i)] = ...
      DeviationFromPredictionAccumulationUpdate(...
      povInverseTau(i), povInverseTauDeviationsReactedTo(1:i-1), ...
      c_errorPredictionFunction,  c_accumulatorGating, ...
      c_accumulatorThreshold, c_timeStep, ...
      accumulatorActivation(i-1), brakePedal(i) < 1);
    % -- get current braking 
    %   (povInverseTauDeviationsReactedTo contains the magnitudues of 
    %    prediction errors already reacted to, at the simulation time steps 
    %    where the accumulator threshold was crossed)
    brakePedalDot(i) = c_brakePedalGain * ...
      dot(fliplr(povInverseTauDeviationsReactedTo(1:i-1)), ...
      c_burstFunction(1:i-1));
    
  end %
  
  
  % plotting
  
  c_nPlots = 4;
 
  
  subplot(c_nPlots, 2, iPOVAcc)
  hold on
  set(gca, 'FontSize', c_iFontSize)
  plot(t, povAcceleration, '-', 'LineWidth', 2, 'Color', [1 .7 .7])
  plot(t, oveAcceleration, 'k-', 'LineWidth', 2)
  if iPOVAcc == 1
    set(gca, 'XLim', [0 t(end)])
    ylabel(sprintf('Long. acc.\n(m/s^2)'))
    title('Moderate deceleration')
    set(gca, 'YLim', [-9 1])
    set(gca, 'YTick', [-8 0])
    h = annotation('textarrow',[0.258407079646018 0.221238938053097],...
  [0.842857142857143 0.877142857142857], 'TextEdgeColor','none','String',{'Lead veh.'}, ...
      'FontSize', c_iFontSize, 'Color', 'k', 'TextColor', 'k');

    annotation('textarrow',[0.447787610619469 0.414159292035398],...
  [0.837142857142857 0.865714285714286],'TextEdgeColor','none','String',{'Model'}, ...
      'FontSize', c_iFontSize);

  else
    title('Strong deceleration')
    set(gca, 'YLim', [-9 1])
    set(gca, 'YTick', [-8 0])
    set(gca, 'XLim', [0 8])
  end
  
  subplot(c_nPlots, 2, 2+iPOVAcc)
  hold on
  set(gca, 'FontSize', c_iFontSize)
  plot(t, povInverseTauExpected, '-', 'LineWidth', 2, 'Color', [.7 .7 1])
  plot(t, povInverseTau, 'k-', 'LineWidth', 1)
  yLim = get(gca, 'YLim');
  yLim(1) = 0;
  set(gca, 'YLim', yLim)
  if iPOVAcc == 1
    set(gca, 'XLim', [0 t(end)])
    ylabel(sprintf('1/\\tau\n(1/s)'))
    set(gca, 'YLim', [-0.02 0.25])
    annotation('textarrow',[0.230088495575221 0.233628318584071],...
  [0.667571428571428 0.614285714285714],'TextEdgeColor','none','String',{'Actual'}, ...
      'FontSize', c_iFontSize);

    annotation('textarrow',[0.431858407079646 0.431858407079646],...
  [0.650428571428572 0.602857142857143],'TextEdgeColor','none',...
      'String',{'Predicted'}, ...
      'FontSize', c_iFontSize);

  else
    set(gca, 'XLim', [0 8])
    set(gca, 'YLim', [-.1 1.1])
  end
  
  subplot(c_nPlots, 2, 4+iPOVAcc)
  hold on
  set(gca, 'FontSize', c_iFontSize)
  plot(t, accumulatorActivation, 'k-', 'LineWidth', 1)
  plot([t(1) t(end)], [c_accumulatorThreshold c_accumulatorThreshold], 'k--', 'LineWidth', 1)
  set(gca, 'YLim', [0 1.2*c_accumulatorThreshold])
  if iPOVAcc == 1
    set(gca, 'XLim', [0 t(end)])
    ylabel('A (-)')
    text(11.5, c_accumulatorThreshold, 'A_0', 'VerticalAlignment', 'top', 'FontSize', c_iFontSize)
  else
    set(gca, 'XLim', [0 8])
  end
  
  
  subplot(c_nPlots, 2, 6+iPOVAcc)
  set(gca, 'FontSize', c_iFontSize)
  plot(t, brakePedal*100, '-', 'LineWidth', 2, 'Color', [.9 .2 .2]);
  xlabel('Time (s)')
  if iPOVAcc == 1
    set(gca, 'XLim', [0 t(end)])
    ylabel(sprintf('Brake\npedal (%%)'))
  else
    set(gca, 'XLim', [0 8])
  end
  set(gca, 'YLim', [-10 120])
  
end

%%

PrepareFigureForEPSOutput
print -depsc2 BrakingSimulation.eps