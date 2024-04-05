function   mainn = global_alignment_MST(Tx_west, Ty_west, Tx_north, Ty_north,...
    weight_north, weight_west, nb_vert_tiles, nb_horz_tiles,...
    source_directory, img_name_grid, channel, Optimization, dataset_name, time_pairwise, blend_method, alpha,img_type );
mainn.time_pairwise = time_pairwise;
tic
% Compute Minimum Spanning Tree (MST)
[mainn.tiling_indicator, mainn.tile_weights, mainn.global_y_img_pos, mainn.global_x_img_pos] = minimum_spanning_tree_customized(Ty_north, Tx_north, Ty_west, Tx_west, weight_north, weight_west);

mainn.time_global_alignment = toc;
tic
% Assemble stitched image
I = assemble_stitched_imagee_customized(source_directory, img_name_grid, mainn.global_y_img_pos, mainn.global_x_img_pos, mainn.tile_weights, blend_method, alpha);
mainn.time_assembling = toc;

mainn.total_time =mainn.time_pairwise + mainn.time_global_alignment
tic
% Write the stitched image to disk
imwrite(I,sprintf('%s_stitching_result_Optimization_%s_MST%s',dataset_name,Optimization,img_type))
time_write_image = toc;
% Compute displacement for each tile in the horizontal and vertical directions
mainn.X1 = mainn.global_x_img_pos;
mainn.Y1 = mainn.global_y_img_pos;
for f = nb_vert_tiles:-1:2
    mainn.X1(f,:) = mainn.X1(f,:) - mainn.X1(f-1,:);
    mainn.Y1(f,:) = mainn.Y1(f,:) - mainn.Y1(f-1,:);
end
mainn.X1(1,:) = NaN;
mainn.Y1(1,:) = NaN;

mainn.X2 = mainn.global_x_img_pos;
mainn.Y2 = mainn.global_y_img_pos;
for f = nb_horz_tiles:-1:2
    mainn.X2(:,f) = mainn.X2(:,f) - mainn.X2(:,f-1);
    mainn.Y2(:,f) = mainn.Y2(:,f) - mainn.Y2(:,f-1);
end
mainn.X2(:,1) = NaN;
mainn.Y2(:,1) = NaN;
% Extract subregions and compute RMSE for each adjucent tile
mainn.RMSE_west = NaN(nb_vert_tiles,nb_horz_tiles);
mainn.RMSE_north = NaN(nb_vert_tiles,nb_horz_tiles);

for j = 1:nb_horz_tiles

    for i = 1:nb_vert_tiles


        if channel == 3
            I1 = im2double(rgb2gray(imread([source_directory img_name_grid{i,j}])));
        else
            I1 = im2double(imread([source_directory img_name_grid{i,j}]));

        end

        if i > 1



            if channel == 3
                I2 = im2double(rgb2gray(imread([source_directory img_name_grid{i-1,j}])));
            else
                I2 = im2double(imread([source_directory img_name_grid{i-1,j}]));
            end

            sub_I2 = extract_subregion(I2, mainn.X1(i,j), mainn.Y1(i,j));
            sub_I1 = extract_subregion(I1, -mainn.X1(i,j), -mainn.Y1(i,j));
            mainn.RMSE_north(i,j)  = sqrt( mean((sub_I2(:)-sub_I1(:)).^2));

        end
        if j > 1


            if channel == 3
                I2 = im2double(rgb2gray(imread([source_directory img_name_grid{i,j-1}])));
            else
                I2 = im2double(imread([source_directory img_name_grid{i,j-1}]));
            end


            sub_I2 = extract_subregion(I2, mainn.X2(i,j), mainn.Y2(i,j));
            sub_I1 = extract_subregion(I1, -mainn.X2(i,j), -mainn.Y2(i,j));
            mainn.RMSE_west(i,j)  = sqrt( mean((sub_I2(:)-sub_I1(:)).^2));

        end


    end
end
mainn.average_RMSE_global =  mean(cat(2, mean(mainn.RMSE_north(2:end,:),'all'), mean(mainn.RMSE_west(:,2:end),'all')));
