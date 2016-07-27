classdef BlamKeyboard < PsychHandle
    properties
        valid_indices;
        valid_keys;
        valid_keycodes;
        p;
    end

    methods
        function self = BlamKeyboard(valid_indices, varargin)
            self.p = inputParser;
            self.p.FunctionName = 'BlamKeyboard';
            self.p.addRequired('valid_indices');
            self.p.addParamValue('possible_keys', {{'a','w','e','f','v','b','h','u','i','l'}}, @(x) iscell(x));
            self.p.parse(valid_indices, varargin{:});

            KbName('UnifyKeyNames');
            opts = self.p.Results;
            self.valid_keys = opts.possible_keys{1}(valid_indices);
            self.valid_keycodes = KbName(self.valid_keys);
            self.valid_indices = valid_indices;

            keys = zeros(1, 256);
            keys(self.valid_keycodes) = 1;
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

        function [press_times, press_names, press_array, ...
                  release_times, release_names, release_array] = Check(self)
        % Newer presses are pushed on the front, e.g.
        % the press at index 2 happened before the press at index 1
            [~, pressed, released] = KbQueueCheck;
            if any(pressed > 0)
                % pressed returns a 1x256 vector. Non-zero values represent presses
                press_keycodes = find(pressed > 0);
                press_names = KbName(press_keycodes);
                press_times = pressed(pressed > 0);
                press_array = ismember(self.valid_keycodes, press_keycodes);
            else % no new presses
                press_keycodes = nan;
                press_times = nan;
                press_names = nan;
                press_array = nan;
            end

            if any(released > 0)
                % released returns a 1x256 vector. Non-zero values represent releasees
                release_keycodes = find(released > 0);
                release_names = KbName(release_keycodes);
                release_times = released(released > 0);
                release_array = ismember(self.valid_keycodes, release_keycodes);
            else % no new releasees
                release_keycodes = nan;
                release_times = nan;
                release_names = nan;
                release_array = nan;
            end

        end % end CheckKeyResponse

    end % end methods
end % end classdef
