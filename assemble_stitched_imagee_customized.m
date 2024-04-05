function I = assemble_stitched_imagee_customized(source_directory, img_name_grid, global_y_img_pos, global_x_img_pos,tile_weights, fusion_method, alpha)


% get the size of a single image

tempI = imread([source_directory img_name_grid{1}]);
[img_height, img_width,img_channels] = size(tempI);

class_str = class(tempI);


% determine how big to make the image
stitched_img_height = max(global_y_img_pos(:) + img_height-1 );
stitched_img_width = max(global_x_img_pos(:) + img_width-1);
% initialize image

nb_img_tiles = numel(img_name_grid);
% create the ordering vector so that images with lower ccf values are placed before other images
% the result is the images with higher ccf values overwrite those with lower values
[~,assemble_ordering] = sort(tile_weights(:), 'descend');

fusion_method =lower(fusion_method);
switch fusion_method
    case 'overlay'
        I = zeros(stitched_img_height, stitched_img_width,img_channels, class_str);

        % Assemble images so that the lower the image numbers get priority over higher image numbers
        % the earlier images aquired are layered upon the later images
        for k = 1:nb_img_tiles
            img_idx = assemble_ordering(k);
            %             img_idx =k;
            if ~isempty(img_name_grid{img_idx})
                % Read the current image
                current_image = imread([source_directory img_name_grid{img_idx}]);
                if ~isempty(current_image)
                    % Assemble the image to the global one
                    x_st = global_x_img_pos(img_idx);
                    x_end = global_x_img_pos(img_idx)+img_width-1;
                    y_st = global_y_img_pos(img_idx);
                    y_end = global_y_img_pos(img_idx)+img_height-1;
                    if img_channels==3
                        I(y_st:y_end,x_st:x_end,:) = current_image;
                    else
                        I(y_st:y_end,x_st:x_end) = current_image;
                    end
                end
            end
        end



    case 'linear'

        I = zeros(stitched_img_height, stitched_img_width,img_channels, 'single');

        % generate the pixel weights matrix (its the same size as the images)
        w_mat = single(compute_linear_blend_pixel_weights_([img_height, img_width], alpha,img_channels));
        countsI = zeros(stitched_img_height, stitched_img_width,img_channels, 'single');
        % Assemble images
        for k = 1:nb_img_tiles
            % Read the current image
            img_idx = assemble_ordering(k);
            if ~isempty(img_name_grid{img_idx})
                current_image = single(imread([source_directory img_name_grid{img_idx}]));
                if ~isempty(current_image)
                    current_image = current_image.*w_mat;
                    % Assemble the image to the global one
                    x_st = global_x_img_pos(img_idx);
                    x_end = global_x_img_pos(img_idx)+img_width-1;
                    y_st = global_y_img_pos(img_idx);
                    y_end = global_y_img_pos(img_idx)+img_height-1;
                    if img_channels ==3
                        I(y_st:y_end,x_st:x_end,:) = I(y_st:y_end,x_st:x_end,:) + current_image;
                        countsI(y_st:y_end,x_st:x_end,:) = countsI(y_st:y_end,x_st:x_end,:) + w_mat;
                    else
                        I(y_st:y_end,x_st:x_end) = I(y_st:y_end,x_st:x_end) + current_image;
                        countsI(y_st:y_end,x_st:x_end) = countsI(y_st:y_end,x_st:x_end) + w_mat;
                    end
                end
            end
        end
        I = I./countsI;
        I = cast(I,class_str);




end

end
