classdef BlamForce < PsychHandle
    properties
        session
        force_min
        force_max
        valid_indices
        sampling_rate
        listener
        volt_2_newts
        temp_data
    end

    methods
        function self = BlamForce(valid_indices, varargin)
            if ~ispc
                error('DAQ only works on Windows (barring new hardware)');
            end

            self.p = inputParser;
            self.p.FunctionName = 'BlamForceboard';
            self.p.addRequired('valid_indices');
            self.p.addParamValue('force_min', 1, @(x) isnumeric(x));
            self.p.addParamValue('force_max', 5, @(x) isnumeric(x));
            self.p.addParamValue('sampling_rate', 120, @(x) isnumeric(x));
            self.p.parse(valid_indices, varargin{:});
            opts = self.p.Results;

            self.force_min = opts.force_min;
            self.force_max = opts.force_max;

            self.volt_2_newts = [16.991 19.261 17.311 20.368 20.168...
                                 17.344 17.930 18.987 16.750 17.792];

            self.volt_2_newts = self.volt_2_newts(valid_indices);

            temp_pos = [0 8 1 9 2 10 3 11 4 12]; % setup for nidaq
            valid_channels = temp_pos(valid_indices);
            device_name = daq.getDevices.ID;
            session = daq.createSession('ni');

            addAnalogInputChannel(session, device_name, valid_channels, 'Voltage');
            session.IsContinuous = true;
            session.Rate = opts.sampling_rate;
            % append incoming data to new data, which is unloaded each cycle
            self.temp_data = nan(1000, 2 + length(valid_channels));

            session.dothis = @(src, event) data_writer(event.TimeStamp, event.Data, src.temp_data);
            session.listener = addlistener(session, 'DataAvailable', session.dothis);
            self.session = session;
        end

        function Start(self)
            startBackground(self.session);
        end

        function Stop(self)
            stop(self.session);
        end

        function Close(self)
            delete(self.listener);
            delete(self.session);
            delete(self);
        end

        function [press_times, press_array, ptb_time] = Check(self)
            % remove nan rows
            tmp_array = self.temp_data(~any(isnan(self.temp_data), 2), :);
            press_times = tmp_array(:, 1);
            press_array = tmp_array(:, 2:end);

            % do transformations on array (recale to [0, 1] based on min force?)

            % clear temp array
            self.temp_data(:, :) = nan;

        end

    end % end methods
end % end classdef

% local function
data_writer(timestamp, data, temp_data)
    start_idx = find(sum(isnan(temp_data), 2) > 0, 1, 'first');
    len_data = length(timestamp);

    temp_data(start_idx:start_idx+len_data, 1) = GetSecs; % PTB timestamp
    temp_data(start_idx:start_idx+len_data, 2) = timestamp;
    temp_data(start_idx:start_idx+len_data, 3:size(data, 2)) = data;
end
