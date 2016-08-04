function out = GenBeep(beep_freq)
% Wrapper around MakeBeep + linear ramp
%
% GenBeep(1046);
%
% Use 1046 (high C) for beep freq
%

    Fs = 44100;
    beep_dur = 0.04;
    beep = MakeBeep(beep_freq, beep_dur, Fs);
    rampup = linspace(0, 1, 0.1 * length(beep));
    rampdown = fliplr(rampup);

    beep(1:length(rampup)) = beep(1:length(rampup)) .* rampup;
    beep(end - length(rampdown) + 1:end) = beep(end - length(rampdown) + 1:end) .* rampdown;

    out = beep;
end
