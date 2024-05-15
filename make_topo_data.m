% Read Homer output
clear; close all; clc
load('C:\Edgar\Dropbox\CIACYT\Projects\2024\bioRxiv\data\Training35\derivatives\homer\test_stim.mat')
dc = output.dc.GetDataTimeSeries('reshape');
t = output.dc.GetTime();
HbO = squeeze(dc(:,1,:));
HbR = squeeze(dc(:,2,:));
HbT = squeeze(dc(:,3,:));
% Flag to display data
displayVis = true;
clear dc
for idx=1:24
    detIdx(idx) = output.dc.measurementList(3*idx-2).GetDetectorIndex;
end
for idx=1:24
    srcIdx(idx) = output.dc.measurementList(3*idx-2).GetSourceIndex;
end
clear output idx
% VMOE original timing --> final timing
% V = 144.3200; --> 14.32 (0:14)
% M = 205.9600; --> 75.96 (1:15)
% O = 470.9600; --> 340.96 (5:40)
% E = 478.2400; --> 348.24 (5:48)
% original 13057 frames at 25 fps --> 522.28 sec
% Remove first 130 seconds (3250 frames)
idxBeg = 3250;
t = t(idxBeg:end);
t = t-t(1);
HbO = HbO(idxBeg:end, :);
HbR = HbR(idxBeg:end, :);
HbT = HbT(idxBeg:end, :);
%  Final t = 392.28 sec (6:32 min, 9807 frames @25 fps)
% pyanthem frame rate = 163.46666666666667 = 163+7/15

%% Plot channels timecourse
plotHbO_HRF(t, HbO)

%% Read optode positions
snirf = SnirfClass('C:\Edgar\Dropbox\CIACYT\Projects\2024\bioRxiv\data\Training35\test_stim.snirf'); % change the file name to your snirf file name
probe = snirf.probe;
sourcePos = probe.sourcePos2D(:,1:2);
detPos = probe.detectorPos2D(:,1:2);
measurements = snirf.Get_SD;
measurements = measurements.MeasList(1:24,1:2);
clear snirf
save('..\data\topo_data_resting_state.mat')

%% Interpolate

% I'd like to ask you to write a MATLAB function that takes the following input arguments:
% - fNIRSdata: a matrix composed of 9808 time-points and 24 channels
% - sourcePos: a matrix with 10 rows and 2 columns, where each row contains the X Y coordinates of a source
% - detPos: a matrix with 8 rows and 2 columns, where each row contains the X Y coordinates of a detector
% - srcIdx: a column vector of 24 elements, with the index of the source that is part of a channel, along with the corresponding detector.
% - detIdx: a column vector of 24 elements, with the index of the detector that is part of a channel, along with the corresponding source.
% This function should compute the following output arguments:
% - channelPos: a matrix with 24 rows and 2 columns, where each row contains the X Y coordinates of the channel, which should be computed as the average of the corresponding source-detector coordinates
% - fNIRSinterp: a 128x256x9808 time points tensor, where every 128x256 slice contains the interpolated data of the channels located at channelPos

[channelPos, fNIRSinterp, fNIRSdata] = interpolate_fNIRS(HbO, sourcePos, detPos, srcIdx, detIdx);
save('..\data\fNIRS_resting_state.mat', 'fNIRSinterp', '-v7.3');

%% Visualize Sources and detectors (measurements)
channelList = [1:2, 4:23];
hProbe = figure;
set(hProbe, 'color', 'w')
hold on
% Sources
for idx=1:10
    plot(sourcePos(idx,1), sourcePos(idx,2), 'rs')
    text(sourcePos(idx,1)-0.1, sourcePos(idx,2)-0.3, sprintf('S%0d', idx), 'Color', 'r')
    axis tight
end
% Detectors
for idx=1:8
    plot(detPos(idx,1), detPos(idx,2), 'bo')
    text(detPos(idx,1)-0.1, detPos(idx,2)-0.3, sprintf('D%0d', idx), 'Color', 'b')
    axis tight
end
% Channels
for idx=1:22
    plot(channelPos(idx,1), channelPos(idx,2), 'k.')
    text(channelPos(idx,1)+0.1, channelPos(idx,2), sprintf('%d', channelList(idx)))
    axis tight
end
for idx=1:24
    plot([sourcePos(measurements(idx,1),1) detPos(measurements(idx,2),1)], ...
        [sourcePos(measurements(idx,1),2) detPos(measurements(idx,2),2)], 'k--', 'Color', [0.5 0.5 0.5])
end
ylim([-0.75 8])
xlim([-9 6])
set(hProbe, 'Units', 'inches')
set(hProbe, 'PaperPosition', [0.1 0.1 6 4])
set(hProbe, 'Position', [0.1 0.1 6 4])
% print(hProbe, '..\figures\Fig1d_probe_PFC_template.png', '-dpng', '-r300')

%% Visualize timecourse
if false
    maxVal = max(fNIRSinterp(:));
    minVal = min(fNIRSinterp(:));
    figure; h=gcf; set(h,'color','w')
    colormap(plasma(256))
    % t=decimate(t, 1);
    xq = linspace(min(channelPos(:, 1)), max(channelPos(:, 1)), size(fNIRSinterp,1));
    yq = linspace(min(channelPos(:, 2)), max(channelPos(:, 2)), size(fNIRSinterp,2));
    for idx=1:numel(t)
        imagesc(xq, yq, squeeze(fNIRSinterp(:,:,idx)), [minVal maxVal]);
        % imagesc(squeeze(fNIRSinterp(:,:,idx)), [minVal maxVal]);
        axis image
        title(sprintf('Frame:%d, t=%0.2f', idx, t(idx)));
        drawnow();
    end
    hold on
    for idx=1:22
        plot(channelPos(idx,1), channelPos(idx,2), 'k.')
        % text(channelPos(idx,1), 0.95*channelPos(idx,2), sprintf('S%0dD%0d', srcIdx(idx), detIdx(idx)))
    end
end

%% Visualize selected frames
figure; h=gcf; set(h,'color','w')
colormap(plasma(256))
% t=decimate(t, 1);
xq = linspace(min(channelPos(:, 1)), max(channelPos(:, 1)), size(fNIRSinterp,1));
yq = linspace(min(channelPos(:, 2)), max(channelPos(:, 2)), size(fNIRSinterp,2));
idxPlot = 1;
nT = numel(t);
idxT = [1 358    871	1384 1500 1800	4107  6315   8524	8706 nT];
maxVal = max(max(max(1e6*fNIRSinterp(:,:,idxT))));
% minVal = min(fNIRSinterp(:));
minVal = 0.01*maxVal;
for idx = idxT
    subplot(4,3,idxPlot)
    % Micromolar*mm
    imagesc(xq, yq, 1e6*squeeze(fNIRSinterp(:,:,idx)), [minVal maxVal]);
    % imagesc(squeeze(fNIRSinterp(:,:,idx)), [minVal maxVal]);
    axis image; axis off
    title(sprintf('t=%0.2fs', t(idx)), 'FontSize', 11);
    idxPlot = idxPlot + 1;
end
subplot(4,3,idxPlot)
imagesc(xq, yq, 100.*ones(size(squeeze(fNIRSinterp(:,:,idx)))), [minVal maxVal]);
hold on
for idx=1:22
    plot(channelPos(idx,1), channelPos(idx,2), 'k.')
    % text(channelPos(idx,1), 0.95*channelPos(idx,2), sprintf('S%0dD%0d', srcIdx(idx), detIdx(idx)))
    axis tight
end
hColorBar = colorbar;
hColorBar.FontSize = 6;
set(h, 'Units', 'inches')
set(h, 'PaperPosition', [0.1 0.1 4 4])
set(h, 'Position', [0.1 0.1 4 4])
% print(h, '..\figures\Fig1d.png', '-dpng', '-r300')

%% Unmix the data into a dimensionality-reduced representation
% Next, load a dataset by clicking File > Load data.... For this section,
% we will load the dataset demo1.mat. Currently, you can import any .mat or
% hdf5 file that contains the following variables:
% 
% 1) Temporal variable (H, required): A 2D matrix of shape [n,t], where each
% row is a component and each column is a time-point. This variable is
% referred to as "H" in the pyanthem environment. 
% 2) Spatial variable (W, % optional): A 3D matrix of shape [h,w,n], where h
% and w represent the spatial height and width of your dataset. If this
% variable is not given, no video output is possible.
% 3) Framerate (fr, optional): A single float value, representing the frame
% rate of your dataset in Hz. If a framerate is not given, pyanthem will
% provide a default.
if false
tic
nComp = 13;  % Number of components
nX = size(fNIRSinterp, 2);
nY = size(fNIRSinterp, 1);
nT = size(fNIRSinterp, 3);
fNIRSinterp = reshape(fNIRSinterp, [nX*nY, nT]);
[coeff,score,latent] = pca(fNIRSinterp, 'Economy',true, 'NumComponents', nComp,...
    'Centered', true);
fr = 5;                                 % Frame rate after decimation
H_nF = coeff';                          % Temporal variable
W_nF = reshape(score, [nY, nX, nComp]); % Spatial variable
fNIRSinterp = reshape(fNIRSinterp, [nY, nX, nT]);    % reshape to original
toc
save('..\data\fNIRS_resting_state_unmix.mat','fr', 'H_nF', 'W_nF');

%% Visualize spatial components
if displayVis
    nRows = ceil(sqrt(nComp));
    figure; h2=gcf; set(h2,'color','w')
    colormap(plasma(256))
    for idx=1:nComp
        subplot(nRows,nRows,idx)
        imagesc(squeeze(W_nF(:,:,idx)), [min(W_nF(:)), max(W_nF(:))]);
        axis image
    end
end
end
%% Run PyAnthem
% Run miniconda (goes to C:Users\flexln)
% activate pyanthem 
% Run python 3.7.12 (type python)
% import pyanthem
% pyanthem.run()
% EOF
