Screen('Preference', 'Verbosity', 1);

win = PobWindow('screen', 0,...
                  'color', [0 0 0],...
                  'rect', [20 20 550 700]);

kf = BlamKeyFeedback(5, 'fill_color', [0 0 0], 'frame_color', [255 255 255], ...
                     'rel_x_scale', 0.1);
kf.Register(win.pointer);
kf.Prime();
kf.Draw(1:5);
win.Flip;
KbWait;
kf.SetFrame(2, 'blue');  
kf.SetFill([1, 3], 'green');
kf.SetFill(2, 'red');
kf.fill_alpha(2) = 100;
kf.Prime();
kf.Draw(1:5);
win.Flip;
WaitSecs(.3);
KbWait;
win.Close;
