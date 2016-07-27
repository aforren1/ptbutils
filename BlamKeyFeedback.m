classdef BlamKeyFeedback < Rectangle & Rainbow

    properties
        num_indices;
        default_frame;
        default_fill;
    end

    methods
        function self = BlamKeyFeedback(num_indices, varargin)
        % call: self = BlamKeyFeedback(num_indices, 'fill_color', [0 0 0], ...
        %                              'frame_color', [255 255 255]);
            varargin{length(varargin) + 1} = 'rel_x_pos';
            varargin{length(varargin) + 1} = linspace(.12, .88, num_indices);
            varargin{length(varargin) + 1} = 'rel_y_pos';
            varargin{length(varargin) + 1} = repmat(.9, 1, num_indices);

            self = self@Rectangle(varargin{:});
            self.fill_color = repmat(self.fill_color', 1, num_indices);
            self.frame_color = repmat(self.frame_color', 1, num_indices);
            self.default_fill = self.fill_color;
            self.default_frame = self.frame_color;
            self.num_indices = num_indices;
        end

        function SetFill(self, index, color)
            self.fill_color(:, index) = self.(color);
        end

        function SetFrame(self, index, color)
            self.frame_color(:, index) = self.(color);
        end

        function Reset(self)
            self.frame_color = self.default_frame;
            self.fill_color = self.default_fill;
        end

    end
end
