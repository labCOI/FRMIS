function [best_tiling_indicator, tiling_coeff, global_y_img_pos, global_x_img_pos] = shortest_path_spanning_tree(Y1, X1, Y2, X2, W1, W2)

[nb_vertical_tiles, nb_horizontal_tiles] = size(Y1);


% Compute tiles positions
[best_tiling_indicator, global_y_img_pos, global_x_img_pos, tiling_coeff] = shortest_path_spanning_tree_worker(nb_vertical_tiles,nb_horizontal_tiles, ...
    Y1, X1, Y2, X2, W1, W2);

% translate the positions to (1,1)
global_y_img_pos = round(global_y_img_pos - min(global_y_img_pos(:)))+ 1;
global_x_img_pos = round(global_x_img_pos - min(global_x_img_pos(:))) + 1;
end


function [best_tiling_indicator, global_y_img_pos, global_x_img_pos, tiling_coeff] = shortest_path_spanning_tree_worker(nb_vertical_tiles,nb_horizontal_tiles, Y1, X1, Y2, X2, W1, W2)

global_y_img_pos = zeros(nb_vertical_tiles,nb_horizontal_tiles);
global_x_img_pos = zeros(nb_vertical_tiles,nb_horizontal_tiles);

tiling_coeff = zeros(nb_vertical_tiles,nb_horizontal_tiles);

best_cost = Inf;
for i = 1:nb_vertical_tiles
    for j= 1:nb_horizontal_tiles
        visited = zeros(nb_vertical_tiles,nb_horizontal_tiles);
        distance = inf(nb_vertical_tiles,nb_horizontal_tiles);    % it stores the shortest distance between each node and the source node;
        parent = zeros(nb_vertical_tiles,nb_horizontal_tiles,2);
        distance(i,j) = 0;
        tiling_indicator = zeros(nb_vertical_tiles,nb_horizontal_tiles);

        for count = 1:(nb_vertical_tiles*nb_horizontal_tiles)-1
            temp = inf(nb_vertical_tiles,nb_horizontal_tiles);
            for k = 1:nb_vertical_tiles

                for l= 1:nb_horizontal_tiles
                    if visited(k,l) == 0   % in the tree;
                        temp(k,l)= distance(k,l);

                    end
                end;
            end
            [M, u] = min(temp(:));    % it starts from node with the shortest distance to the source;
            [row, col] = ind2sub(size(temp),u);
            visited(row, col) = 1;       % mar it as visited;
            
            if col<nb_horizontal_tiles &&( ( W2(row, col+1) + distance(row, col)) < distance(row, col+1) )
                distance(row, col+1) = distance(row, col) + W2(row, col+1);   % update the shortest distance when a shorter path is found;
                parent(row, col+1,1) = row;                                     % update its parent;
                parent(row, col+1,2) = col;                                    % update its parent;
                tiling_indicator(row, col+1) = StitchingConstants.MST_CONNECTED_LEFT;
            end;
            if col>1 &&( ( W2(row, col) + distance(row, col)) < distance(row, col-1) )
                distance(row, col-1) = distance(row, col) + W2(row, col);   % update the shortest distance when a shorter path is found;
                parent(row, col-1,1) = row;                                     % update its parent;
                parent(row, col-1,2) = col;                                    % update its parent;
                tiling_indicator(row, col-1) = StitchingConstants.MST_CONNECTED_RIGHT;
            end;
            if row<nb_vertical_tiles &&( ( W1(row+1, col) + distance(row, col)) < distance(row+1, col) )
                distance(row+1, col) = distance(row, col) + W1(row+1, col);   % update the shortest distance when a shorter path is found;
                parent(row+1, col,1) = row;                                     % update its parent;
                parent(row+1, col,2) = col;                                  % update its parent;
                tiling_indicator(row+1, col) = StitchingConstants.MST_CONNECTED_NORTH;
            end;
            if row>1 && ( ( W1(row, col) + distance(row, col)) < distance(row-1, col) )
                distance(row-1, col) = distance(row, col) + W1(row, col);   % update the shortest distance when a shorter path is found;
                parent(row-1, col,1) = row;                                     % update its parent;
                parent(row-1, col,2) = col;                                   % update its parent;
                tiling_indicator(row-1, col) = StitchingConstants.MST_CONNECTED_SOUTH;
            end;
        end;
        cost  = sum(distance(:));
        if cost < best_cost
            best_cost = cost;
            best_distance = distance;
            best_tiling_indicator =tiling_indicator;
            best_parent = parent;
        end
    end
end
tic
for d1 = 1:nb_vertical_tiles
    for d2 = 1:nb_horizontal_tiles
        path =[d1 d2];
        if best_parent(d1,d2) ~= 0   % if there is a path!

            t1 = d1;
            t2 = d2;
            while best_parent(t1,t2) ~= 0
                p1 = best_parent(t1,t2,1);
                p2 = best_parent(t1,t2,2);
                path = [p1 p2 ;path ];

                t1 = p1;
                t2 = p2;
            end;
        end;
        for s = 2:size(path,1)
            mst_i = path(s,1);
            mst_j = path(s,2);

            if tiling_coeff( mst_i, mst_j) == 0
			    % Check the neighbor below
                if best_tiling_indicator( mst_i, mst_j) == StitchingConstants.MST_CONNECTED_NORTH
                    global_y_img_pos(mst_i,mst_j) = global_y_img_pos(mst_i-1,mst_j) + Y1(mst_i,mst_j);
                    global_x_img_pos(mst_i,mst_j) = global_x_img_pos(mst_i-1,mst_j) + X1(mst_i,mst_j);

                    % update tiling indicator
                    tiling_coeff(mst_i,mst_j) =  best_distance(mst_i,mst_j);

                end

                % Check the neighbor above
                if best_tiling_indicator( mst_i, mst_j) == StitchingConstants.MST_CONNECTED_SOUTH
                    global_y_img_pos(mst_i,mst_j) = global_y_img_pos(mst_i+1,mst_j) - Y1(mst_i+1,mst_j);
                    global_x_img_pos(mst_i,mst_j) = global_x_img_pos(mst_i+1,mst_j) - X1(mst_i+1,mst_j);

                    % update tiling indicator

                    tiling_coeff(mst_i,mst_j) =  best_distance(mst_i,mst_j);

                end

                % Check the neighbor to the right
                if best_tiling_indicator( mst_i, mst_j) == StitchingConstants.MST_CONNECTED_LEFT
                    global_y_img_pos(mst_i,mst_j) = global_y_img_pos(mst_i,mst_j-1) + Y2(mst_i,mst_j);
                    global_x_img_pos(mst_i,mst_j) = global_x_img_pos(mst_i,mst_j-1) + X2(mst_i,mst_j);

                    % update tiling indicator

                    tiling_coeff(mst_i,mst_j) =  best_distance(mst_i,mst_j);

                end

                % Check the neighbor to the left
                if best_tiling_indicator( mst_i, mst_j) == StitchingConstants.MST_CONNECTED_RIGHT
                    global_y_img_pos(mst_i,mst_j) = global_y_img_pos(mst_i,mst_j+1) - Y2(mst_i,mst_j+1);
                    global_x_img_pos(mst_i,mst_j) = global_x_img_pos(mst_i,mst_j+1) - X2(mst_i,mst_j+1);

                    % update tiling indicator

                    tiling_coeff(mst_i,mst_j) =  best_distance(mst_i,mst_j);

                end
            end
        end
    end
end

end