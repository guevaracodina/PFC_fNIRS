% Dynamic Functional Connectivity
clear; close all; clc
load ('..\data\topo_data_resting_state.mat')

%% Load data
fNIRSdata = HbO;
addpath(genpath('C:\Edgar\Dropbox\Matlab\MODA'))
% Reference: 
% Iatsenko, D., McClintock, P. V. E., & Stefanovska, A. (2016). Extraction
% of instantaneous frequencies from ridges in time–frequency
% representations of signals. Signal Processing, 125, 290–303.
% https://doi.org/10.1016/j.sigpro.2016.01.024
HbO_pulse_rate = HbO(:,10); figure; plot(t, HbO_pulse_rate);
fs = 1 / mean(diff(t));
% save ('..\data\HbO_pulse_rate.mat', 'HbO_pulse_rate');

%% Load plot and modify colormap
close all
uiopen('..\data\pulse_rate_HbO_25Hz.fig',1);
h = gcf;
set(h, 'color', 'w')
dt = findobj(gca(),'Type','DataTip');
delete(dt);
colorbar
colormap(plasma)
clim([0 0.75e-5]);
set(gca, 'FontSize', 11)
% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 4 1.8])
set(h, 'PaperPosition', [0.1 0.1 4 1.8])
print(h, '-dpng', '..\figures\Figure1f_pulse_rate.png', '-r300');

% EOF