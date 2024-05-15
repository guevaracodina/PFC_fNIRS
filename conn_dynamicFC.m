% Dynamic Functional Connectivity
% Reference: 
% Liao, W., Wu, G.-R., Xu, Q., Ji, G.-J., Zhang, Z., Zang, Y.-F., & Lu, G.
% (2014). DynamicBC: A MATLAB Toolbox for Dynamic Brain Connectome
% Analysis. Brain Connectivity, 4(10), 780–790.
% https://doi.org/10.1089/brain.2014.0253
clear; close all; clc
load ('..\data\topo_data_resting_state.mat')

%% Load data
fNIRSdata = HbO;
% Calculate channel positions
% For each channel, compute the mean position of the source and detector
for idxCh = 1:length(srcIdx)
    channelPos(idxCh, :) = (sourcePos(srcIdx(idxCh), :) + detPos(detIdx(idxCh), :))./2;
end
chIdx = [srcIdx; detIdx];      %S-D indices for each channel
% Remove short channels
idx2remove = [3, 24];
% Brite Frontal with 22 long channels and 2 short separation channels using
% 8 Rx and 10 Tx (for Homer Export)
chIdx(:,idx2remove) = [];
channelPos(idx2remove,:) = [];
% Filter data in the connectivity band
hpf = 0.009;
lpf = 0.08;
fs = 1 / mean(diff(t));
% low pass filter
lpf_norm = lpf / (fs / 2);
if lpf_norm > 0  % No lowpass if filter is
    FilterOrder = 3;
    [z, p, k] = butter(FilterOrder, lpf_norm, 'low');
    [sos, g] = zp2sos(z, p, k);
    fNIRSdata = filtfilt(sos, g, double(fNIRSdata));
end

% high pass filter
hpf_norm = hpf / (fs / 2);
if hpf_norm > 0
    FilterOrder = 5;
    [z, p, k] = butter(FilterOrder, hpf_norm, 'high');
    [sos, g] = zp2sos(z, p, k);
    fNIRSdata = filtfilt(sos, g, fNIRSdata);
end
% Regress SSC (short separation channels)
fNIRSdata = conn_regress_short_sep_ch(fNIRSdata);
fNIRSdata(:,idx2remove) = [];
% chOrder = [1 22 2 21 3 18 4 16 5 17 6 15 7 20 8 19 9 12 10 11 13 14]'; % Ordered L&R in alternate fashion
chOrder = [1:10 13 22 21 18 16 17 15 20 19 12 11 14]';
fNIRSdata = fNIRSdata(:,chOrder);

%% Plot resting-state data
plotHbO_resting_State(t, fNIRSdata)

%% Compute dynamic functional connectivity
addpath('C:\Edgar\Dropbox\Matlab\DynamicBC')
% Reference: 
% Liao, W., Wu, G.-R., Xu, Q., Ji, G.-J., Zhang, Z., Zang, Y.-F., & Lu, G.
% (2014). DynamicBC: A MATLAB Toolbox for Dynamic Brain Connectome
% Analysis. Brain Connectivity, 4(10), 780–790.
% https://doi.org/10.1089/brain.2014.0253


% [nobs, nvar] = size(fNIRSdata);
overlap = 0.1;
window = 50;
pvalue = 0.05;
save_info.flag_nii = false;
save_info.slw_alignment = false;
save_info.flag_1n = false;
save_info.nii_mat_name = 'nii_mat';
save_info.save_dir = '..\data\';

FCM = DynamicBC_sliding_window_FC(fNIRSdata,window,overlap,pvalue,save_info);

%% Display dynamic FC
% figure;
% for idx=1:217
%     imagesc(FCM.Matrix{idx}, [-1 1]); axis image; colorbar; colormap(ioi_get_colormap('bipolar'))
%     title(sprintf('t=%0.1f, frame=%d', FCM.time_alignment(idx)/25), idx);
%     drawnow;
% end

%% Print selected frames
idxPlot = 1;
idxT = [1 9 20 31 34 41 92 141 189 194 217];
h = figure; set(h, 'color', 'w')
chStep = 4;
for idx = idxT
    subplot(4,3,idxPlot)
    imagesc(FCM.Matrix{idx}, [-1 1]); axis image; colormap(ioi_get_colormap('bipolar'))
    set(gca, 'XTick', 1:chStep:22, 'XTickLabel', chOrder(1:chStep:end)); % Set custom X tick labels
    xtickangle(45);
    set(gca, 'YTick', 1:chStep:22, 'YTickLabel', chOrder(1:chStep:end)); % Set custom Y tick labels
    set(gca, 'FontSize', 6)
    title(sprintf('t=%0.1fs', FCM.time_alignment(idx)/25), 'FontSize', 11);
    idxPlot = idxPlot + 1;
end
subplot(4,3,idxPlot)
imagesc(chOrder, chOrder, zeros(size(FCM.Matrix{idx})), [-1 1]);
hold on
hColorBar = colorbar;
hColorBar.FontSize = 8;
set(h, 'Units', 'inches')
set(h, 'PaperPosition', [0.1 0.1 4 4])
set(h, 'Position', [0.1 0.1 4 4])
print(h, '..\figures\Fig1e.png', '-dpng', '-r300')

% EOF