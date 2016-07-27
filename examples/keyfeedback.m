scrn = PsychWindow(0, true,...
                   'color', [0 0 0],...
                   'rect', [0 0 400 400], ...
                   'alpha_blending', true);
kf = BlamKeyFeedback(6, 'fill_color', [0 0 0], 'frame_color', [255 255 255], 'rel_x_scale', repmat(0.1, 1, 6));
kf.Draw(scrn.pointer);
scrn.Flip;
WaitSecs(.3);
kf.SetFrame(2, 'blue');
kf.SetFill([1, 4], 'green');
kf.SetFill(2, 'red');
kf.Draw(scrn.pointer);
scrn.Flip;
WaitSecs(.3);
KbWait;
scrn.Close;
