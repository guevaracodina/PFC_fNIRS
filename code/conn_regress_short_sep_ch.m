function yHat = conn_regress_short_sep_ch(y)
% Performs global signal regression
% SYNTAX
% yHat = conn_regress_global(y)
% INPUT
% y     Matrix with raw signals (nTimePoints x nChannels)
% OUTPUT
% yHat  Filtered matrix without global signal, same size as y
% ______________________________________________________________________________
%% Global signal regression
% Regression variable (global signal, i.e. the mean)
% yMean = mean(y,2);
yMean = mean(y(:,[3, 24]),2); % Only regress the mean of short channels (3&24 for PFC)
g = [ones(size(yMean)) yMean];
% Regularization parameter
lambda = 0.1*max(diag(g'*g));
% Regressor: Tikhonov regression estimator
betaCoeff = pinv(g'*g + lambda*eye(size(g'*g)))*g'*y;
% Filtered signal yHat
yHat = y - g*betaCoeff;
end

% EOF

