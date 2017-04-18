classdef BlamForceboard < handle
    properties
        valid_indices
        p % input parser
        short_term % holds callback data
        mid_term
        long_term
        dev
        session
        listener
        possible_indices
        volts_to_newtons
        threshold
        velocity_threshold
        tmp_lag
    end

    methods
        function self = BlamForceboard(valid_indices, varargin)
            self.valid_indices = valid_indices;
            self.possible_indices = [2 9 1 8 0 10 3 11 4 12]; %[2 9 1 8 0];
            self.short_term = [];
            self.mid_term = [];
            self.long_term = [];
            tmp = daq.getDevices;
            dev = tmp(1).ID;
            session = daq.createSession('ni');
            session.addAnalogInputChannel(dev, self.possible_indices(valid_indices),...
                                          'Voltage');
            % lame hack to set all channels to single ended
            for ii = 1:length(valid_indices)
                session.Channels(ii).InputType = 'SingleEnded';
            end
            session.Rate = 200;
            session.IsContinuous = true;
            listener = session.addlistener('DataAvailable', ...
                                           @(src, event) ...
                                            BlamForceboard.getdat(src, event, self));
            self.dev = dev;
            self.session = session;
            self.listener = listener;

            % recheck -- the ADC channels were switched around (2 & 4 I
            % think?)
            self.volts_to_newtons = [18.2049152048295 19.2608319684787 17.3105298895872 ...
                                  20.3675850551795 20.1679260919799 17.3444730115356 ...
                                  17.9301218244265 18.9872094827267 16.7497447173567 ...
                                  17.7921183901903];
            %self.volts_to_newtons = self.volts_to_newtons(valid_indices);
            self.threshold = 1.2; % newtons
            self.velocity_threshold = 0.06; % newtons
            %self.threshold = 0.08; % volts
            %self.velocity_threshold = 0.004; % volts
            self.session.NotifyWhenDataAvailableExceeds = session.Rate * 0.05;
            self.session.prepare;
            self.tmp_lag = zeros(1, length(valid_indices));
        end

        function Start(self)
            self.session.startBackground;
        end

        function Stop(self)
            stop(self.session);
        end

        function Close(self)
            stop(self.session);
            delete(self.listener);
            delete(self.session);
            delete(self);
        end

        function [press_times, press_array, release_times, release_array] = Check(self)
            tmp_cur = median(self.short_term(:, 3:end));
            press_array = (tmp_cur > self.threshold) & (self.tmp_lag < self.threshold);
            release_array = (tmp_cur < self.threshold) & (self.tmp_lag > self.threshold);
            self.tmp_lag = tmp_cur;
            if any(press_array)
                press_array = tmp_cur == max(tmp_cur);
                press_times = self.short_term(1, 1);
            else
                press_times = nan;
                press_array = nan;
            end

            if any(release_array)
                release_times = self.short_term(1, 1);
            else
                release_times = nan;
                release_array = nan;
            end
        end

        function [press1, t_press1, data, max_press, t_max_press] = CheckMid(self)
        % retrieve all data for a chunk (e.g. for an entire state)
        % and reset that storage
        % call right at the beginning of a block (to clean up non-relevant input) and
        % right at the end (to keep all trial-specific presses together)
            data = self.mid_term;
            % reset the mid-term storage
            self.mid_term = [];
            out = zeros(1, size(data, 2) - 2);
            for ii = 3:size(data, 2)
                cands = find(medfilt1(diff(data(:, ii)), 5) > self.velocity_threshold);
                if ~isempty(cands)
                    out(ii - 2) = cands(1);
                else
                    out(ii - 2) = nan;
                end
            end

            if all(isnan(out))
                press1 = nan;
                t_press1 = nan;
                max_press = nan;
                t_max_press = nan;
            else
                % need to do == because nans aren't included in indexing
                press1 = find(min(out) == out);
                t_press1 = data(min(out), 1);
                
                [max_press, index] = max(data(:, 2 + press1));
                t_max_press = data(index, 1);
				% hack to prevent multi-element first presses (and therefore crashes)
				if length(press1) > 1
				    press1 = nan;
					t_press1 = nan;
					max_press = nan;
					t_max_press = nan;
				end
            end

        end

    end

    methods(Static)
        function getdat(src, event, self)
            % subtracting 50 ms gets us closer to the actual time of the event
            self.short_term = [(GetSecs + (0:(1/self.session.Rate):((length(event.TimeStamps)-1)/self.session.Rate))).' - 0.05, ...
                         event.TimeStamps, event.Data .* self.volts_to_newtons];
            self.mid_term = [self.mid_term; self.short_term];
            self.long_term = [self.long_term; self.short_term];
        end
    end
end
