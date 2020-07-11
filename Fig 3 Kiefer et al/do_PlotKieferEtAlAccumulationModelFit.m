
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

SObservations.initialTimeHeadways.LVDScenarios = 2;
SObservations.initialTimeHeadways.LVNDScenarios = 5;
% SV speed (mph); POV speed (mph); POV deceleration (g:s); ITTC at normal
% brake initiation (1/s); 
SObservations.MScenarios = [...
  30 30 -.15 0.140 
  30 30 -.28 0.165
  30 30 -.39 0.195
  45 45 -.15 0.110 
  45 45 -.28 0.130
  45 45 -.39 0.150
  60 60 -.15 0.100
  60 60 -.28 0.108
  60 60 -.39 0.132
  30 0  0    0.250
  45 0  0    0.225
  60 0  0    0.192];

c_VScenarioXPositions = [1 2 3 5 6 7 9 10 11 13 14 15];
c_CsScenarioLabels = {...
  '30/30/0.15', '30/30/0.28', '30/30/0.39', ...
  '45/45/0.15', '45/45/0.28', '45/45/0.39', ...
  '60/60/0.15', '60/60/0.28', '60/60/0.39', ...
  '30/0/0', '45/0/0', '60/0/0'};
  
c_iFontSize = 12.5;

SBestParameterization.alpha = 0;
SBestParameterization.C = 1;
SBestParameterization.E = 0.0155;
SBestParameterization.A_th = 0.0888;
SBestParameterization.LVDTHW = 0;
SBestParameterization.T_R = 0;

[rSquare, VPredictedITTCValues] = ...
  EvaluateAccumulationModelOnKieferEtAlData(SBestParameterization, SObservations);
VObservedITTCValues = SObservations.MScenarios(:, 4);
nScenarios = length(VObservedITTCValues);

figure(1)
set(gcf, 'Position', [160   466   565   240])
clf
set(gca, 'FontSize', c_iFontSize, ...
  'Position',[0.143362831858407 0.3625 0.761637168141593 0.561500000000003])
hold on
for iGroup = 1:4
  iRangeStart = (iGroup-1)*3+1;
  ViRange = iRangeStart:iRangeStart+2;
  plot(c_VScenarioXPositions(ViRange) - .1, VObservedITTCValues(ViRange), ...
    'o-', 'LineWidth', 2, 'Color', [.8 .6 .8])
  plot(c_VScenarioXPositions(ViRange) + .1, VPredictedITTCValues(ViRange), ...
    'k+-', 'LineWidth', 1.5)
end
text(mean(c_VScenarioXPositions), -.16, 'Scenario', 'HorizontalAlignment', 'center', 'FontSize', c_iFontSize)
ylabel(sprintf('Inverse TTC at\nbrake onset (1/s)'))
legHandle = legend('Kiefer et al. data', sprintf('Model'));
set(legHandle,...
  'Position',[0.355457227138643 0.749305555555555 0.334513274336283 0.216666666666667])
set(gca, 'YLim', [0 0.27])
set(gca, 'XTick', c_VScenarioXPositions)
set(gca, 'XLim', [c_VScenarioXPositions(1)-1 c_VScenarioXPositions(end)+1])
set(gca, 'XTickLabel', '')
for i = 1:nScenarios
  txtHandle = text(c_VScenarioXPositions(i), -0.015, c_CsScenarioLabels{i});
  set(txtHandle, 'Rotation', 40, 'HorizontalAlignment', 'right', 'FontSize', c_iFontSize)
end

%%
PrepareFigureForEPSOutput
print -depsc2 KieferEtAlAccumulation