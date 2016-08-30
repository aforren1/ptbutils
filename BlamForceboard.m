classdef BlamForceboard < handle
    properties
        valid_indices
        p % input parser
        data % holds callback data
        data_lag
        long_term
        dev
        session
        listener
        possible_indices
        volts_2_newts
        threshold

    end

    methods
        function self = BlamForceboard(valid_indices, varargin)
            self.valid_indices = valid_indices;
            self.possible_indices = [0 8 1 9 2 10 3 11 4 12];
            self.data = [];
            self.data_lag = [];
            self.long_term = [];
            dev = daq.getDevices(1).ID;
            session = daq.createSession('ni');
            session.addAnalogInputChannel(dev, self.possible_indices(valid_indices), 'Voltage');
            session.Rate = 250;
            session.IsContinuous = true;
            listener = session.addlistener('DataAvailable', ...
                                           @(src, event) ...
                                            BlamForceboard.getdat(src, event, self));
            self.dev = dev;
            self.session = session;
            self.listener = listener;

            self.volts_2_newts = [16.991 19.261 17.311 20.368 20.168...
                                  17.344 17.930 18.987 16.750 17.792];

            self.volts_2_newts = self.volts_2_newts(valid_indices);
            self.threshold = 0.3;
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
            tmp_lag = mean(self.data_lag(:, 3:end), 1);
            tmp_cur = mean(self.data(:, 3:end), 1);
            press_array = (tmp_cur > self.threshold && tmp_lag < self.threshold);
            release_array = tmp_cur < self.threshold;
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

    end

    methods(Static)
        function getdat(src, event, self)
            self.data_lag = self.data;
            self.data = [repmat(GetSecs, length(event.TimeStamps), 1), ...
                         event.TimeStamps, event.Data .* self.volts_2_newts];
            self.long_term = [self.long_term; self.data];
        end
    end
end
