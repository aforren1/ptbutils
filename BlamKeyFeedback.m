classdef BlamKeyFeedback < PobRectangle & Rainbow

    properties
        num_indices;
        default_frame;
        default_fill;
    end

    methods
        function self = BlamKeyFeedback(num_indices, varargin)
        % call: self = BlamKeyFeedback(6, 'fill_color', [0 0 0], ...
        %                              'frame_color', [255 255 255], 'rel_x_scale', 0.1);
            self = self@PobRectangle();

            self.p.parse(varargin{:});
            opts = self.p.Results;
            self.Add(1:num_indices, 'rel_x_pos', linspace(.12, .88, num_indices), ...
                     'rel_y_pos', repmat(0.9, 1, num_indices), ...
                     'frame_color', repmat(opts.frame_color', 1, num_indices), ...
                     'fill_color', repmat(opts.fill_color', 1, num_indices),...
                     'rel_x_scale', repmat(opts.rel_x_scale, 1, num_indices), ...
                     'rel_y_scale', repmat(opts.rel_y_scale, 1, num_indices));
            self.default_fill = repmat(opts.fill_color', 1, num_indices);
            self.default_frame = repmat(opts.frame_color', 1, num_indices);
            self.num_indices = num_indices;
        end

        function SetFill(self, index, color)
            self.fill_color(:, index) = repmat(self.(color)', 1, length(index));
        end

        function SetFrame(self, index, color)
            self.frame_color(:, index) = repmat(self.(color)', 1, length(index));
        end

        function Draw(self)
            Draw@PobRectangle(self, 1:self.num_indices);
        end

        function Reset(self)
            self.frame_color = self.default_frame;
            self.fill_color = self.default_fill;
        end

    end
end
