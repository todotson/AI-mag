classdef GuiUtils < handle
    %% init
    methods (Static, Access = public)
        function fig = get_gui(id, position, name)
            fig = figure(id);
            
            clf(fig)
            set(fig, 'Position', position)
            set(fig, 'Name', name)
            set(fig, 'NumberTitle', 'off')
            set(fig, 'MenuBar', 'none')
            set(fig, 'Resize','off')
        end
        
        function set_logo(parent, filename)
            [img, map, alphachannel] = imread(filename);
            n_img_x = size(img, 2);
            n_img_y = size(img, 1);
            
            ax = axes(parent, 'Units', 'normalized', 'Position',[0 0 1 1]);
            
            pos = getpixelposition(ax);
            n_ax_x = pos(3);
            n_ax_y = pos(4);
            
            n_img_x_new = n_ax_y.*(n_img_x./n_img_y);
            n_img_y_new = n_ax_x.*(n_img_y./n_img_x);
            
            n_img_x_new = min(n_img_x_new, n_ax_x);
            n_img_y_new = min(n_img_y_new, n_ax_y);
            
            img = imresize(img, [n_img_y_new n_img_x_new]);
            alphachannel = imresize(alphachannel, [n_img_y_new n_img_x_new]);
            
            image(ax, img, 'AlphaData', alphachannel);
            axis(ax, 'off');
            axis(ax, 'image');
        end
        
        function obj = get_panel(parent, position, name)
            obj = uipanel(parent, 'Title', name, 'FontSize', 12);
            design.GuiUtils.set_position(obj, position)
        end
    end
    methods (Static, Access = public)
        function get_button(parent, position, name, callback)
            obj = uicontrol(parent, 'Style', 'pushbutton', 'FontSize', 12, 'String', name, 'CallBack', callback);
            design.GuiUtils.set_position(obj, position)
        end
        
        function obj = get_menu(parent, position, name, callback)
            obj = uicontrol(parent, 'Style', 'popupmenu', 'FontSize', 12, 'String', name, 'CallBack', callback);
            design.GuiUtils.set_position(obj, position)
        end
        
        function obj = get_status(parent, position)
            obj = uicontrol(parent, 'Style', 'pushbutton', 'Enable', 'inactive', 'FontSize', 12);
            design.GuiUtils.set_position(obj, position)
        end
        
        function obj = get_text(parent, position, name)
            obj = uicontrol(parent, ...
                'Style','text',...
                'FontSize', 12,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'String', name...
                );
            design.GuiUtils.set_position(obj, position)
        end
        
        function obj = set_text_todo(obj, name)
                set(obj, 'String', name)
        end

        function set_status(obj, is_valid)
            if is_valid==true
                set(obj, 'BackgroundColor', 'g')
                set(obj, 'String', 'valid')
            else
                set(obj, 'BackgroundColor', 'r')
                set(obj, 'String', 'invalid')
            end
        end
        
        function set_menu(obj, is_valid)
            if is_valid==true
                set(obj, 'BackgroundColor', 'g')
            else
                set(obj, 'BackgroundColor', 'r')
            end
        end
    end
        
    methods (Static, Access = public)
                function set_visible(obj, visible)
            set(obj, 'Visible', visible);
        end

                function set_position(obj, position)
            if all(position>=0)&&all(position<=1)
                set(obj, 'Units', 'normalized');
                set(obj, 'Position', position);
            else
                set(obj, 'Units', 'pixels');
                set(obj, 'Position', position);
            end
        end
    end
end