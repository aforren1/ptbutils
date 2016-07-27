function BailPtb
    sca;
    try
        PsychPortAudio('Close');
    catch ME
        warning('No audio device open.');
    end
end
