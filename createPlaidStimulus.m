function [output, edge, thresh, result] = createPlaidStimulus(stimParams, stripesPerImage, scaleContrast, stripeAngle)
% CREATE PLAID STIMULUS
%   stimParams - defined using stimInitialize.m; should contain a the
%       convolutional bandpass filter to use, in space domain
%       (stimParams.bpfilter)
%   stripesPerImage - Define approximate number of repetitions of lines
%       across image (previous variable name: relCutOff)
%   scaleContrast - Scale the edge contrast relative to the
%       empirically found maximum that prevented too much clipping for SOC
%       stimuli (default = maximum);
%   stripeAngle - Orientation of first grating in [0,2*pi]
%   Note: uses a randomly determined phase

if isempty(scaleContrast)
    % Scale the edge contrast (this value was found empirically to maximize
    % contrast whilst preventing too much clipping for SOC stimuli)
    scaleContrast = 0.18;
else
    scaleContrast = scaleContrast * 0.18;
end

stimWidth  = stimParams.stimulus.srcRect(3)-stimParams.stimulus.srcRect(1);
stimHeight = stimParams.stimulus.srcRect(4)-stimParams.stimulus.srcRect(2);

% Create grating 1
cpi = stripesPerImage;
[x,y] = meshgrid(linspace(0,1,stimWidth), linspace(0,1,stimHeight));

th = stripeAngle;

xr = x*cos(th) - y*sin(th);
phX = rand*2*pi; % phase 

result1 = cos(2*pi*xr*cpi*sqrt(2)+phX);

% Create grating 2
[x,y] = meshgrid(linspace(0,1,stimWidth), linspace(0,1,stimHeight));

th = stripeAngle+pi/2;

xr = x*cos(th) - y*sin(th);
phX = rand*2*pi; % phase 

result2 = cos(2*pi*xr*cpi*sqrt(2)+phX);

% Combine gratings

result = (result1+result2)/2;

% % % compare with grating created using knkutils
% result = makegrating2d(size(stimParams.stimulus.images(1),cpi,0,1);

% Threshold the filtered noise
thresh = result - min(result(:)) > (max(result(:)) - min(result(:)))/2;

% Grab edges with derivative filter
edge1 = [0, 0, 0; 1, 0, -1; 0, 0, 0];
edge2 = [0, 1, 0; 0, 0, 0; 0, -1, 0];
edge = -1*(imfilter(double(thresh), edge1, 'circular').^2 + imfilter(double(thresh), edge2, 'circular').^2);

% Scale the edge contrast
edge = scaleContrast*edge; 

% Filter convolutionally with bpfilter in the image domain
output = imfilter(edge, stimParams.bpFilter, 'circular');

return

end

