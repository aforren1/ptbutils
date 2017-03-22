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
%     click_freq - Frequency of the beep (Hz) or vector [freq1, freq2, freq3]
%     inter_click_interval - Period of click train (in seconds)
%     num_clicks - Number of clicks in the train (3 or 4, usually...)
    Fs = 44100;
    click_dur = 0.04;
    if length(click_freq) ~= 1 & length(click_freq) ~= num_clicks
        error('invalid number of frequencies/clicks...')
    end
    % 
    if length(click_freq) == 1
        click_freq = repmat(click_freq, 1, num_clicks);
    end

    for i = 1:length(click_freq)
        beep{i} = MakeBeep(click_freq(i), click_dur, Fs);
    end
    
    space = zeros(1, (inter_click_interval * Fs) - length(beep{1}));
    ramp = linspace(0, 1, 0.1 * length(beep{1}));
    rampdown = fliplr(ramp);
    
    for i = 1:length(beep)
        beep{i}(1:length(ramp)) = beep{i}(1:length(ramp)) .* ramp;
        beep{i}(end - length(ramp) + 1:end) = beep{i}(end - length(ramp) + 1:end) .* rampdown;
    end

    out = zeros(1, Fs * 0.5 - round(length(beep{1})/2));
    out = [out, beep{1}];
    for i = 1:(length(beep) - 1)
        out = [out, space, beep{i + 1}];
    end
end