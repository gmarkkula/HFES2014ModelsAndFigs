
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

SObservations = struct(...
  'initialHeadwayDistance', {20 40}, ...
  'averageThetaDotAtReaction', {0.00358 0.00215});

c_VLightColor = [1 .5 1];
c_iFontSize = 12.5;
c_iMarkerSize = 4;
c_VAxisRange = [-5 95 0 0.02];

SetLambleEtAl1999Fig4Data


figure(1)
set(gcf, 'Position', [ 160         529        1130/2         160])
clf

subplot(1, 2, 1)
cla
set(gca, 'FontSize', c_iFontSize)
hold on

for i = 1:c_LambleEtAl1999Fig4_nHorizontalEccentricities
  
  x = c_LambleEtAl1999Fig4_VHorizontalEccentricities(i);
  m = c_LambleEtAl1999Fig4_VMean40m(i);
  e = c_LambleEtAl1999Fig4_VStdDev40m(i);
  h(2) = plot(x, m, 'ks', 'MarkerFaceColor', 'k', 'MarkerSize', c_iMarkerSize);
  plot3([x x], [m-e m+e], [-1 -1], 'k-', 'LineWidth', 1)
  
end

for i = 1:c_LambleEtAl1999Fig4_nHorizontalEccentricities
  
  x = c_LambleEtAl1999Fig4_VHorizontalEccentricities(i);
  m = c_LambleEtAl1999Fig4_VMean20m(i);
  e = c_LambleEtAl1999Fig4_VStdDev20m(i);
  h(1) = plot(x, m, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', ...
    c_VLightColor, 'MarkerSize', c_iMarkerSize, 'Color', c_VLightColor);
  plot3([x x], [m-e m+e], [-1 -1], 'k-', 'LineWidth', 1)
  
end


axis(c_VAxisRange)
xlabel('Eccentricity (°)')
ylabel(sprintf('d\\theta/dt at\ndetection (rad/s)'))
legend(h, {'20 m', '40 m'}, 'Position', ...
  [0.233333333333332 0.673958333333337 0.171681415929204 0.325])

%%


subplot(1, 2, 2)
set(gca, 'FontSize', c_iFontSize)
cla
hold on

SBestParameterization.alpha = 1;
SBestParameterization.C = 1;
SBestParameterization.E = 0.0013;
SBestParameterization.A_th = 0.001425;
for C = [.175 .3 .367 .433 .5 1] 
  SThisParameterization = SBestParameterization;
  SThisParameterization.C = C;
  for initialHeadway = [40 20]
    SThisObservation.initialHeadwayDistance = initialHeadway;
    SThisObservation.averageThetaDotAtReaction = 0;
    if initialHeadway == 20
      VColor = c_VLightColor;
      sLineSpec = 'o';
      iHeadway = 1;
    else
      VColor = 'k';
      sLineSpec = 's';
      iHeadway = 2;
    end
    [modelReactionThetaDotMean, modelReactionThetaDotStdDev] = ...
      EvaluateStochAccModelOnLambleEtAlData(SThisParameterization, SThisObservation);
    
    hold on
    plot(C, modelReactionThetaDotMean, sLineSpec, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', VColor, 'MarkerSize', c_iMarkerSize)
    e = modelReactionThetaDotStdDev;
    plot3([C C], ...
      [modelReactionThetaDotMean-e modelReactionThetaDotMean+e], ...
      [-1 -1], 'k-', 'LineWidth', 1)
    drawnow
    
  end
end
set(gca, 'XDir', 'reverse')
xlabel('C (-)')
ylabel(sprintf('d\\theta/dt at\ndetection (rad/s)'))
axis([0.1 1.1 0 0.02])

%%

PrepareFigureForEPSOutput
print -depsc2 LambleEtAlEccentricityAndNoise.eps