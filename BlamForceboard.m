classdef BlamForceboard < PsychHandle
    properties
        valid_indices;
        zero_baseline; % from the countdown file
        force_min; % in newtons
        force_max;
        volt_2_newts;
        daq;
        p;
    end

    methods
        function self = BlamForceboard(valid_indices, varargin)
            if ~ispc
                error('DAQ only works on Windows (barring new hardware)');
            end
            self.p = inputParser;
            self.p.FunctionName = 'BlamForceboard';
            self.p.addRequired('valid_indices');
            self.p.addParamValue('force_min', 1, @(x) isnumeric(x));
            self.p.addParamValue('force_max', 5, @(x) isnumeric(x));
            self.p.parse(valid_indices, varargin{:});


            daqreset;
            daqs = daqhwinfo('nidaq');
            daq_ids = daqs.InstalledBoardIds;

            if length(daq_ids) >= 1
                daq_id = daq_ids{1};
            else
                error('No NI-DAQ device available.');
            end

            self.daq = analoginput('nidaq', daq_id);
            self.daq.inputType = 'SingleEnded';

            temp_pos = [0 8 1 9 2 10 3 11 4 12]; % setup for nidaq
            valid_channels = temp_pos(valid_indices);
            addchannel(self.daq, valid_channels);
            dev.valid_indices = valid_indices;

            set(self.daq, 'SampleRate', 200);
            set(self.daq, 'SamplesPerTrigger', 4000);
            set(self.daq, 'TriggerType', 'Manual');
            set(self.daq, 'BufferingMode', 'Manual');
            set(self.daq, 'BufferingConfig', [2 2000]);

            self.volt_2_newts = [16.991 19.261 17.311 20.368 20.168...
                                 17.344 17.930 18.987 16.750 17.792];

            self.volt_2_newts = self.volt_2_newts(valid_indices);
        end

        function Start(self)
            stop(self.daq);
            start(self.daq);
            trigger(self.daq);
        end

        function Stop(self)
            stop(self.daq);
        end

        function Close(self)
            delete(self.daq);
            delete(self);
        end

        function [press_times, press_array, ptb_time] = Check(self)

        end

end
