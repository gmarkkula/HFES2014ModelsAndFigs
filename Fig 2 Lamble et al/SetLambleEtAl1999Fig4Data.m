
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




c_LambleEtAl1999Fig4_VHorizontalEccentricities = [0 17 24 44 63 90];
c_LambleEtAl1999Fig4_nHorizontalEccentricities = ...
  length(c_LambleEtAl1999Fig4_VHorizontalEccentricities);
c_LambleEtAl1999Fig4_nObservationsPerPlotPoint = 4 * 12;
c_LambleEtAl1999Fig4_fromStdDevToCIFactor = 1.96 / sqrt(c_LambleEtAl1999Fig4_nObservationsPerPlotPoint);

% estimated from horizontal eccentricty data in Fig. 4 of (Lamble et al.,
% 1999)

c_LambleEtAl1999Fig4_VMean40m = [...
  0.00211
  0.00452
  0.00498
  0.00710
  0.00731
  0.01302];
c_LambleEtAl1999Fig4_VErrorBar40m = [...
  0.00021
  0.00042
  0.00051
  0.00080
  0.00063
  0.00195];
c_LambleEtAl1999Fig4_VStdDev40m = c_LambleEtAl1999Fig4_VErrorBar40m / ...
  c_LambleEtAl1999Fig4_fromStdDevToCIFactor;

c_LambleEtAl1999Fig4_VMean20m = [...
  0.00380
  0.00617
  0.00646
  0.00739
  0.00858
  0.01483];
c_LambleEtAl1999Fig4_VErrorBar20m = [...
  0.00042
  0.00042
  0.00055
  0.00051
  0.00059
  0.00173];
c_LambleEtAl1999Fig4_VStdDev20m = c_LambleEtAl1999Fig4_VErrorBar20m / ...
  c_LambleEtAl1999Fig4_fromStdDevToCIFactor;