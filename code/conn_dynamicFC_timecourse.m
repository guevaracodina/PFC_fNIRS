% Dynamic Functional Connectivity
% Reference: 
% Liao, W., Wu, G.-R., Xu, Q., Ji, G.-J., Zhang, Z., Zang, Y.-F., & Lu, G.
% (2014). DynamicBC: A MATLAB Toolbox for Dynamic Brain Connectome
% Analysis. Brain Connectivity, 4(10), 780–790.
% https://doi.org/10.1089/brain.2014.0253
clear; close all; clc
addpath('C:\Edgar\Dropbox\Matlab\DynamicBC')
load('..\data\nii_mat')

%% Compute dynamic functional connectivity time-course metrics
nFrames = numel(FCM.Matrix);
meanFC = zeros(size([nFrames 1]));
for idx=1:nFrames
    currMat = FCM.Matrix{idx};
    meanFC(idx) = nanmean(currMat(:));
end
t = FCM.time_alignment/25;
h = figure;
set(h, 'color', 'w')
plot(t, meanFC, 'k-', 'LineWidth', 1.5); hold on;
x1 = 340.96; x2 = 348.24; y1 = 0; y2 = 1.1;
patch([x1 x2 x2 x1], [y1 y1 y2 y2], 'red', 'FaceAlpha', 0.6, 'EdgeColor','red');
x_line = 14.32;
line([x_line x_line], [y1 y2], 'Color', 'red', 'LineStyle', '--', 'LineWidth', 1.5, 'Color', [1 0 0 0.8]);
x_line = 75.96;
line([x_line x_line], [y1 y2], 'Color', 'red', 'LineStyle', '--', 'LineWidth', 1.5, 'Color', [1 0 0 0.8]);
xlim([1 max(t)]); ylim([y1 y2])
xlabel('Time (s)')
ylabel('<FC>')
set(gca, 'FontSize', 11)
% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 4 1.8])
set(h, 'PaperPosition', [0.1 0.1 4 1.8])
print(h, '-dpng', '..\figures\Figure1g_mean_FC.png', '-r300');

% EOF