classdef BlamKeyboard < handle
    properties
        valid_indices
        valid_keys
        valid_keycodes
        p
        mid_term
        long_term
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

            self.mid_term = [];
            self.long_term = []; % unused
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

        function [press_times, press_array, release_times, release_array] = Check(self)
        % [press_times, press_names, press_array, ...
        %  release_times, release_names, release_array] ...
        %  = kbrd.Check;
            [~, pressed, released] = KbQueueCheck;
            if any(pressed > 0)
                % pressed returns a 1x256 vector. Non-zero values represent presses
                press_keycodes = find(pressed > 0);
                press_times = pressed(pressed > 0);
                press_array = ismember(self.valid_keycodes, press_keycodes);
                remap_indices = arrayfun(@(x) find(self.valid_keycodes == x, 1), press_keycodes);
                press_n_times = [remap_indices; press_times]';
                self.mid_term = [self.mid_term; sortrows(press_n_times, 2)];
            else % no new presses
                press_times = nan;
                press_array = nan;
            end

            if any(released > 0)
                % released returns a 1x256 vector. Non-zero values represent releasees
                release_keycodes = find(released > 0);
                release_times = released(released > 0);
                release_array = ismember(self.valid_keycodes, release_keycodes);
            else % no new releasees
                release_times = nan;
                release_array = nan;
            end

        end % end Check

        function [press1, t_press1, data, max_press, t_max_press] = CheckMid(self)
            max_press = nan;
            data = self.mid_term;
            if ~isempty(data)
                press1 = data(1, 1);
                t_press1 = data(1, 2);
                t_max_press = t_press1;
            else
                press1 = nan;
                t_press1 = nan;
            end
            self.mid_term = [];
        end

    end % end methods
end % end classdef
