    cd('~/Documents/BLAM')
    addpath(genpath('Psychoobox'));
    addpath(genpath('ptbutils'));
    Screen('Preference', 'Verbosity', 1);
    scrn = PsychWindow(0, true,...
                       'color', [0 0 0],...
                       'rect', [0 0 800 700], ...
                       'alpha_blending', true);
    kbrd = BlamKeyboard(1:10);
    l_keys = length(kbrd.valid_indices);
    kf = BlamKeyFeedback(l_keys, 'fill_color', [0 0 0], ...
                         'frame_color', [255 255 255], ...
                         'rel_x_scale', repmat(0.06, 1, l_keys));

    kf.Draw(scrn.pointer);
    scrn.Flip();
    reftime = GetSecs;
    endtime = reftime + 3;
    kbrd.Start;

    while endtime > GetSecs
        [~, ~, presses, ~, ~, releases] = kbrd.Check;
        if ~isnan(presses)
            kf.SetFill(find(presses), 'green');
        end
        if ~isnan(releases)
            kf.SetFill(find(releases), 'black');
        kf.Draw(scrn.pointer);
        reftime = scrn.Flip(reftime + 0.5 * scrn.flip_interval);
    end
    scrn.Close;
    kbrd.Close;
