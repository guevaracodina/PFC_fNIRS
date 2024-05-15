% plot_PFC_sensitivity_map
clear; clc; close all
fig = open('C:\Edgar\Dropbox\CIACYT\Students\Michelle\fNIRS Yoga\paper\eNeuro\PFC_optodes_sensitivity_no_probe_linear_luminance.fig');
cmap = colormap(fig);
RGBbrain = cmap(1,:);
%  Brain gray color
% 0.969200000000000	0.927300000000000	0.896100000000000
cmap = colormap(plasma(256));
cmap(1,:) = RGBbrain;
colormap(cmap);
set(fig, 'Units', 'inches')
set(fig, 'PaperPosition', [0.1 0.1 2.5 2.5])
set(fig, 'Position', [0.1 0.1 2.5 2.5])
% print(fig, '..\figures\Fig1a_03_colorbar.png', '-dpng', '-r300')
% Find the current axes in the figure (assuming there is only one)
ax = gca(fig);
% Hide the colorbar
colorbar(ax, 'off');
% print(fig, '..\figures\Fig1a_03.png', '-dpng', '-r300')
cmap2 = repmat(RGBbrain, [256 1]);
colormap(cmap2);
print(fig, '..\figures\Fig1a_02.png', '-dpng', '-r300')

% EOF