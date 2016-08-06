function out = GenClick(click_freq, inter_click_interval, num_clicks)
% GENCLICK Generates a click train at a sampling rate of 44.1 kHz
%
% GenClick(click_freq, inter_click_interval, num_clicks);
%
% Use 1046 (high C) for click freq
% I add (0.5 - 1/2*length(beep)) seconds to the front of the click train,
% to make lining up easier(?). The middle of the first beep would then occur at 0.5s
%
% Inputs:
%     click_freq - Frequency of the beep (Hz)
%     inter_click_interval - Period of click train (in seconds)
%     num_clicks - Number of clicks in the train (3 or 4, usually...)
    Fs = 44100;
    click_dur = 0.04; % static
    beep = MakeBeep(click_freq, click_dur, Fs);
    space = zeros(1, (inter_click_interval * Fs) - length(beep));
    ramp = linspace(0, 1, .1*length(beep));
    rampdown = fliplr(ramp);
    beep(1:length(ramp)) = beep(1:length(ramp)) .* ramp;
    beep(end - length(ramp) + 1:end) = beep(end - length(ramp) + 1:end) .* rampdown;


    out = zeros(1, Fs*0.5 - (length(beep)/2));
    out = [out, beep];
    for ii = 1:(num_clicks - 1)
        out = [out, space, beep];
    end
end
