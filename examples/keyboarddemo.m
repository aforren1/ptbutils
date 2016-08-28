    cd('~/Documents/BLAM')
    addpath(genpath('Psychoobox'));
    addpath(genpath('ptbutils'));
    Screen('Preference', 'Verbosity', 1);

    win = PobWindow('screen', 0,...
                    'color', [0 0 0],...
                    'rect', [20 20 550 700]);
    kbrd = BlamKeyboard(1:10);
    l_keys = length(kbrd.valid_indices);
    kf = BlamKeyFeedback(l_keys, 'fill_color', [0 0 0], ...
                         'frame_color', [255 255 255], ...
                         'rel_x_scale', 0.06);
    kf.Register(win.pointer);
    kf.Prime();
    kf.Draw(1:10);
    win.Flip();
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
        end
        kf.Prime();
        kf.Draw(1:10);
        reftime = win.Flip(reftime + 0.5 * win.flip_interval);
    end
    win.Close;
    kbrd.Close;
