
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


function VErrorPredictionFunction = GetErrorPredictionFunction(...
  t, errorStartsDisappearingTime, errorDisappearedTime, errorPredictionStdDevsToInclude)

errorDisappearanceRateFunction = normpdf(t, ...
  mean([errorStartsDisappearingTime errorDisappearedTime]), ...
  (errorDisappearedTime - errorStartsDisappearingTime) / ...
  (2 * errorPredictionStdDevsToInclude));
errorDisappearanceRateFunction = errorDisappearanceRateFunction - ...
  errorDisappearanceRateFunction(find(t >= errorStartsDisappearingTime, 1, 'first'));
errorDisappearanceRateFunction(errorDisappearanceRateFunction < 0) = 0;
errorDisappearanceRateFunction = errorDisappearanceRateFunction / ...
  trapz(t, errorDisappearanceRateFunction);
VErrorPredictionFunction = 1 - cumtrapz(t, errorDisappearanceRateFunction);