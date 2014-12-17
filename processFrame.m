function res = processFrame(frame)

frameRed = frame(:, :, 1);
frameGreen = frame(:, :, 2);
frameBlue = frame(:, :, 3);

% Treshholding between two lines
temp = (frameRed < (1.05*frameGreen + 100)) & (frameRed > (0.95*frameGreen + 20));
% Tresholding minimum and maximum values
temp = temp & frameRed < 210 & frameRed > 60 & frameGreen < 170 & frameGreen > 40;
% Blue component should be low
temp = temp & frameBlue < 120 & frameBlue > 30;



imagesc(temp);

if sum(temp(:)) > 3000
    res = 1;
else
    res = 0;
end;

