
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


clear all
close all
SParameters.alpha = 1;
SParameters.C = 1;
SParameters.E = 0.0005541;
SParameters.A_th = 0.001425;
SStochasticParameters = SParameters;
SStochasticParameters.E = 0.0013;

c_xLim = [0 4];
c_iFontSize = 12.5;
c_lightColor = [.7 .7 1];

SObservations = struct(...
  'initialHeadwayDistance', {20 40}, ...
  'averageThetaDotAtReaction', {0.00358 0.00215});
nObservations = length(SObservations);
c_svSpeed = 50 / 3.6;
c_lvSpeed = c_svSpeed;
c_lvDeceleration = 0.7;
c_lvWidth = 1.6;
c_VSimulationTimeStamp = 0:0.01:100;


figure(1)
set(gcf, 'Position', [ 160         529        1130/2         160])
clf

for iObservation = 1:nObservations
  
  initialHeadwayTime = SObservations(iObservation).initialHeadwayDistance / c_svSpeed;
  
  [xF, vF, xL, vL, dL, deltaX, deltaV, iCrashSample] = SimulateRearEndScenario(...
    c_VSimulationTimeStamp, c_svSpeed, ...
    initialHeadwayTime, c_lvSpeed, ...
    c_lvDeceleration, c_lvDeceleration, 0);
  assert(~isempty(iCrashSample))
  
  VTimeStamp = c_VSimulationTimeStamp(1:iCrashSample);
  VTheta = 2 * atan(c_lvWidth ./ (2 * deltaX(1:iCrashSample)));
  VThetaDot = -4 * c_lvWidth * deltaV(1:iCrashSample) ./ ...
    (4 * deltaX(1:iCrashSample).^2 + c_lvWidth^2);
  
  [iModelReactionPoint, VActivation] = AccumulationModel(VTimeStamp, VTheta, ...
    VThetaDot, SParameters);
    
  figure(1)
  subplot(1, 2, 1)
  set(gca, 'FontSize', c_iFontSize)
  hold on
  h(iObservation) = plot(VTimeStamp, VThetaDot, 'k-', 'LineWidth', iObservation);
  h(3) = plot3(VTimeStamp(iModelReactionPoint), VThetaDot(iModelReactionPoint), 1, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
  
  
  subplot(1, 2, 2)
  set(gca, 'FontSize', c_iFontSize)
  hold on
  plot(VTimeStamp, VActivation, 'k-', 'LineWidth', iObservation)
  plot3(VTimeStamp(iModelReactionPoint), VActivation(iModelReactionPoint), 1, 'ro', 'MarkerSize', 10, 'LineWidth', 2)
  
  
  if iObservation == 1
    rng(6)
    c_nTotalSimulations = 10000;
    for i = 1:c_nTotalSimulations
      [ViModelReactionPoint(i), VActivation] = StochasticAccumulationModel(VTimeStamp, VTheta, ...
        VThetaDot, SStochasticParameters, 0.0075, 0);
      if ismember(i, [2 18])
        plot3(VTimeStamp(1:ViModelReactionPoint(i)), ...
          VActivation(1:ViModelReactionPoint(i)), -ones(ViModelReactionPoint(i),1), ...
          '-', 'Color', c_lightColor, 'LineWidth', 2)
      end
    end
    VPDFBinEdges = VTimeStamp(1):.08:VTimeStamp(end);
    VnObservationsWithinBin = histc(VTimeStamp(ViModelReactionPoint), VPDFBinEdges);
    VPDFBinProbabilities = VnObservationsWithinBin / c_nTotalSimulations;
    ViNonZeroBins = find(VPDFBinProbabilities > 0);
    plot3(VPDFBinEdges(ViNonZeroBins), ...
      VPDFBinProbabilities(ViNonZeroBins) * .004 + SParameters.A_th, ...
      -ones(size(ViNonZeroBins)), '-', ...
      'LineWidth', 2.5, 'Color', c_lightColor)
  end
  
end

%%

subplot(1, 2, 1)
plot([VTimeStamp(1) VTimeStamp(end)], [SParameters.E SParameters.E], 'k--');
set(gca, 'XLim', c_xLim)
set(gca, 'YLim', [0 0.006])
ylabel('d\theta/dt (rad/s)')
xlabel('Time (s)')
legend(h(1:2), {'20 m', '40 m'}, 'Position',...
  [0.268731563421829 0.630208333333334 0.171681415929204 0.325])
htxt = text(3.5, SParameters.E, 'M', 'FontSize', c_iFontSize, 'VerticalAlignment', 'bottom');

subplot(1, 2, 2)
h = plot([VTimeStamp(1) VTimeStamp(end)], [SParameters.A_th SParameters.A_th], 'k--');
set(gca, 'XLim', c_xLim)
set(gca, 'YLim', [0 2 * SParameters.A_th])
ylabel('A (rad)')
% legend(h, {'A_0'})
xlabel('Time (s)')
htxt = text(3.5, SParameters.A_th, 'A_0', 'FontSize', c_iFontSize, 'VerticalAlignment', 'bottom');
annotation('textarrow',[0.787610619469027 0.792920353982301],...
  [0.85 0.65],'TextEdgeColor','none','String',{'Detection'}, 'FontSize', c_iFontSize)
annotation('arrow',[0.755752212389381 0.707964601769911],...
  [0.8365 0.6625]);

%%

PrepareFigureForEPSOutput
print -depsc2 LambleEtAlIllustration.eps