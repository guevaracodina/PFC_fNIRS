function [channelPos, fNIRSinterp, fNIRSdata] = interpolate_fNIRS(fNIRSdata, sourcePos, detPos, srcIdx, detIdx)
tic
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
fNIRSdata = conn_regress_short_sep_ch(fNIRSdata);
fNIRSdata(:,idx2remove) = [];

nX = 256; % Number of pixels along X for interpolation
nY = 128; % Number of pixels along Y for interpolation
nT = size(fNIRSdata, 1);
nChannels = size(fNIRSdata, 2);

% Decimate fNIRSdata to a fifth of its original sampling frequency
decimationFactor = 1;
nT = ceil(size(fNIRSdata, 1) / decimationFactor);
decimatedData = zeros(nT, size(fNIRSdata, 2));
for idxCh = 1:nChannels % Loop through each channel
    decimatedData(:, idxCh) = decimate(fNIRSdata(:, idxCh), decimationFactor);
end

% Define the interpolation grid
xq = linspace(min(channelPos(:, 1)), max(channelPos(:, 1)), nX);
yq = linspace(min(channelPos(:, 2)), max(channelPos(:, 2)), nY);
[Xq, Yq] = meshgrid(xq, yq);

% Initialize the interpolated fNIRS data tensor
fNIRSinterp = zeros(nY, nX, nT);
xPos = channelPos(:, 1);
yPos = channelPos(:, 2);

% Interpolate fNIRS data for each time point
% parfor t = 1:nT
%     Vq = griddata(channelPos(:, 1), channelPos(:, 2), fNIRSdata(t, :), Xq, Yq, 'natural');
%     fNIRSinterp(:, :, t) = Vq;
% end
parfor t = 1:nT
    F = scatteredInterpolant(xPos, yPos, fNIRSdata(t, :)', 'natural', 'none');
    Vq = F(Xq, Yq);
    fNIRSinterp(:, :, t) = flipud(Vq);
end
toc
% Elapsed time is 448.068552 seconds. --> with regular for
% Elapsed time is 147.363126 seconds. --> with parfor
end