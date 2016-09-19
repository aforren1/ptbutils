classdef BlamTr < handle
    properties
        keys
        keycodes
        p % input parser
    end
    
    methods
        function self = BlamTr(varargin)
           self.p = inputParser;
           self.p.FunctionName = 'BlamTr';
           self.p.addParamValue('keys',...
                                {{'SPACE', 'ESCAPE', 't', 'd', 'f', 'g', 'h', '5'}}, ...
                                @iscell);
           self.p.parse(varargin{:});
           
           opts = self.p.Results;
           self.keys = opts.keys{1};
           KbName('UnifyKeyNames');
           self.keycodes = KbName(self.keys);
           keys = zeros(1, 256);
           keys(self.keycodes) = 1;
           KbQueueCreate(-1, keys);
        end
        
        function Start(self)
            KbQueueStart;
        end
                function Stop(self)
            KbQueueStop;
        end

        function Flush(self)
            KbQueueFlush;
        end

        function Close(self)
            KbQueueRelease;
            delete(self);
        end
        
        function [press_times, press_vals, release_times, release_vals] = Check(self)
            [~, pressed, released] = KbQueueCheck;
            if any(pressed > 0)
                press_keycodes = find(pressed > 0);
                press_vals = KbName(press_keycodes);
                press_times = pressed(pressed > 0);
            else
                press_vals = nan;
                press_times = nan;
            end
            
            if any(released > 0)
                release_keycodes = find(released > 0);
                release_vals = KbName(release_keycodes);
                release_times = released(released > 0);
            else
                release_vals = nan;
                release_times = nan;
            end
            
        end
        
    end
end