classdef BlamForceboard < handle
    properties
        valid_indices
        p % input parser
        data % holds callback data
        data_lag
        mid_term
        long_term
        dev
        session
        listener
        possible_indices
        volts_2_newts
        threshold
        velocity_threshold
    end

    methods
        function self = BlamForceboard(valid_indices, varargin)
            self.valid_indices = valid_indices;
            self.possible_indices = [2 9 1 8 0 10 3 11 4 12];
            self.data = [];
            self.data_lag = [];
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
            self.volts_2_newts = [16.991 19.261 17.311 20.368 20.168...
                                  17.344 17.930 18.987 16.750 17.792];

            self.volts_2_newts = self.volts_2_newts(valid_indices);
            %self.threshold = 1.2; % newtons
            self.threshold = 0.1; % volts
            self.velocity_threshold = 0.003; % volts
            self.session.NotifyWhenDataAvailableExceeds = session.Rate * 0.05;
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
            tmp_cur = median(self.data(:, 3:end));
            press_array = (tmp_cur > self.threshold);% & (tmp_lag < self.threshold);
            release_array = (tmp_cur < self.threshold);% & (tmp_lag > self.threshold);
            if any(press_array)
                press_times = self.data(1, 1);
            else
                press_times = nan;
                press_array = nan;
            end

            if any(release_array)
                release_times = self.data(1, 1);
            else
                release_times = nan;
                release_array = nan;
            end
        end

        function [press1, t_press1, data] = CheckMid(self)
        % retrieve all data for a chunk (e.g. for an entire state)
        % and reset that storage
        % call right at the beginning of a block (to clean up non-relevant input) and
        % right at the end (to keep all trial-specific presses together)
            out = zeros(1, size(self.mid_term, 2) - 2);
            for ii = 3:size(self.mid_term, 2)
                cands = find(medfilt1(diff(self.mid_term(:, ii)), 3) > 0.003);
                if ~isempty(cands)
                    out(ii - 2) = cands(1);
                else
                    out(ii - 2) = nan;
                end
            end

            % need to do == because nans aren't included in indexing
            press1 = find(min(out) == out);
            t_press1 = self.mid_term(min(out), 1);
            data = self.mid_term;
            % reset the mid-term storage
            self.mid_term = [];
        end

    end

    methods(Static)
        function getdat(src, event, self)
            self.data_lag = self.data;
            self.data = [(GetSecs + (0:(1/self.session.Rate):((length(event.TimeStamps)-1)/self.session.Rate))).', ...
                         event.TimeStamps, event.Data]; %bsxfun(@times, event.Data, self.volts_2_newts)];
            self.mid_term = [self.mid_term; self.data];
            self.long_term = [self.long_term; self.data];
        end
    end
end
