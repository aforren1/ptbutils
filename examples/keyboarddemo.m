function [data, tmptime] = keyboarddemo
%cd('~/Documents/BLAM')
    addpath(genpath('Psychoobox'));
    addpath(genpath('ptbutils'));
    Screen('Preference', 'Verbosity', 1);
    Screen('Preference', 'SkipSyncTests', 1);
    ii = 1;
    tmptime = [];

    win = PobWindow('screen', max(Screen('screens')),...
                    'color', [0 0 0],...
                    'rect', [0 0 1400 1200]);
    kbrd = BlamForceboard(1:10);
    l_keys = length(kbrd.valid_indices);
    kf = BlamKeyFeedback(l_keys, 'fill_color', [0 0 0], ...
                         'frame_color', [255 255 255], ...
                         'rel_x_scale', 0.06);
    kf.Register(win.pointer);
    kf.Prime();
    kf.Draw();
    win.Flip();

    kbrd.session.prepare;
    kbrd.Start;
    reftime = GetSecs;
    ref2 = reftime;
    endtime = GetSecs + 2;

    while GetSecs < endtime
        [~, presses, ~, releases] = kbrd.Check;
        if ~isnan(presses)
            kf.SetFill(find(presses), 'gray');
        end
        if ~isnan(releases)
            kf.SetFill(find(releases), 'black');
        end
        kf.Prime();
        kf.Draw();
        reftime = win.Flip(reftime + 0.5 * win.flip_interval);
        tmptime(ii) = reftime;
        % hack to allow daq to collect data...
        ii = ii + 1;
        pause(1e-5);
    end
    [p1, t_p1, dat, mx, t_mx] = kbrd.CheckMid;
    disp(['First press: ', num2str(p1)]);
    disp(['Time first press: ', num2str(t_p1 - ref2)]);
    
    win.Close;
    kbrd.Stop;
    data.current = kbrd.short_term;
    data.mid = dat;
    data.long = kbrd.long_term;
    kbrd.Close;
    kf.Close;
    sca
end
