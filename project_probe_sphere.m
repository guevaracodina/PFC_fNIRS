clear; clc; close all;
% Load the image (replace 'your_image.jpg' with the path to your image file)
img = flipud(imread('..\figures\channels_probe.png'));

% Sphere circumference in cm
circumference = 50;

% Calculate the sphere's radius
radius = circumference / (2 * pi);

% Image dimensions in cm
imageWidth = 10.5;
imageHeight = 5.2;

% The horizontal angular extent of the image on the sphere
theta_width = 4 * pi * (imageWidth / circumference); % in radians

% Calculate the vertical angular extent of the image on the sphere
theta_height = 2 * pi * (imageHeight / circumference); % in radians

% Calculate the angular offset for positioning the image 1 cm above the equator
offset_cm = 6; % 1 cm above the equator
offset_rad = 2 * pi * (offset_cm / circumference); % convert cm to radians

% Adjust the range of spherical coordinates to start 1 cm above the equator
theta_start = -pi/2 + offset_rad; % Start 1 cm above the equator
theta_end = theta_start + theta_height;

% Create a sphere
[X, Y, Z] = sphere(100); % More points for a smoother sphere

% Scale the sphere to the correct size
X = X * radius;
Y = Y * radius;
Z = Z * radius;

% Display the sphere with 50% transparency
figure;
sph = surf(X, Y, Z, 'EdgeColor', 'none', 'FaceColor', [0.8 0.8 0.8]);
alpha(sph, 0); % Set the sphere's transparency to 50%


% Hold on to plot the image on top of the sphere
hold on;

% Calculate the portion of the sphere where the image will be mapped
phi = linspace(-theta_width/2, theta_width/2, size(img, 2));
theta = linspace(theta_start, theta_end, size(img, 1));

% Convert spherical coordinates to Cartesian coordinates for the image projection
[Phi, Theta] = meshgrid(phi, theta);
X_img = radius * cos(Theta) .* cos(Phi);
Y_img = radius * cos(Theta) .* sin(Phi);
Z_img = radius * sin(Theta);

% Plot the image on the calculated part of the sphere
surf(X_img, Y_img, Z_img, flipud(img), 'EdgeColor', 'none', 'FaceColor', 'texturemap');

% Adjust view and axis
axis equal;
% view([60 30]); % Set a good viewing angle
view([90 0]); % Set a good viewing angle
grid off
colormap(flipud(gray(4)))
