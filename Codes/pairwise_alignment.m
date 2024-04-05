function  [Tx_west, Ty_west, Tx_north, Ty_north, index_ImMatch_west,index_ImMatch_north, pointsPreviousNumb_west,pointsPreviousNumb_north,...
    pointsNumb_west,pointsNumb_north,matchedNumb_west,matchedNumb_north,inliersNumb_west,inliersNumb_north,Level_north,Level_west,weight_north,weight_west,time_pairwise,valid_translations_west,valid_translations_north] = pairwise_alignment(source_directory, img_name_grid,index_matrix,...
    nb_vert_tiles,nb_horz_tiles,M, N, Overlap_west,  Overlap_north,channel,overlap_error, Threshold_metric,Optimization,time)
t = tic;

% Initialize variables
Level_north = NaN(nb_vert_tiles,nb_horz_tiles);
Level_west = NaN(nb_vert_tiles,nb_horz_tiles);

Ty_north = NaN(nb_vert_tiles,nb_horz_tiles);
Tx_north = NaN(nb_vert_tiles,nb_horz_tiles);

matchedNumb_north = NaN(nb_vert_tiles,nb_horz_tiles);

Ty_west = NaN(nb_vert_tiles,nb_horz_tiles);
Tx_west = NaN(nb_vert_tiles,nb_horz_tiles);

matchedNumb_west = NaN(nb_vert_tiles,nb_horz_tiles);

weight_north = NaN(nb_vert_tiles,nb_horz_tiles);
weight_west = NaN(nb_vert_tiles,nb_horz_tiles);

index_ImMatch_north = NaN(nb_vert_tiles,nb_horz_tiles);
index_ImMatch_west = NaN(nb_vert_tiles,nb_horz_tiles);

pointsNumb_north = NaN(nb_vert_tiles,nb_horz_tiles);
pointsPreviousNumb_north = NaN(nb_vert_tiles,nb_horz_tiles);

pointsNumb_west = NaN(nb_vert_tiles,nb_horz_tiles);
pointsPreviousNumb_west = NaN(nb_vert_tiles,nb_horz_tiles);

inliersNumb_north = NaN(nb_vert_tiles,nb_horz_tiles);
inliersNumb_west = NaN(nb_vert_tiles,nb_horz_tiles);

% Adjust feature extraction portion based on tile overlap
if Overlap_north > 5
    OverlapY = 5;
    Y_pixel = round(M*OverlapY/100);

else
    OverlapY = Overlap_north;
    Y_pixel = round(M*OverlapY/100);
end

if Overlap_west > 5
    OverlapX = 5;
    X_pixel = round(N*OverlapX/100);

else
    OverlapX = Overlap_west;
    X_pixel = round(N*OverlapX/100);
end

% compute the transformation of each tile with adjacent north and west tiles
for j = 1:nb_horz_tiles
    %     fprintf('  col: %d  / %d\n', j ,nb_horz_tiles);
    fprintf('.');
    for i = 1:nb_vert_tiles

        %     read image from disk

        if channel == 3
            I1 = im2double(rgb2gray(imread([source_directory img_name_grid{i,j}])));
        else
            I1 = im2double(imread([source_directory img_name_grid{i,j}]));

        end

        if i > 1
            %       compute translation north


            if channel == 3
                I2 = im2double(rgb2gray(imread([source_directory img_name_grid{i-1,j}])));
            else
                I2 = im2double(imread([source_directory img_name_grid{i-1,j}]));
            end
            % compute trasnform in north direction using small part of overlaping region
            [Ty_north(i,j), Tx_north(i,j),index_ImMatch_north(i,j),pointsPreviousNumb_north(i,j),pointsNumb_north(i,j),matchedNumb_north(i,j),inliersNumb_north(i,j),status] = compute_trasnform_north( I1, I2,index_matrix(i,j), M,N, Y_pixel, Overlap_north, Threshold_metric);
            if status == 0
                Level_north(i,j) = 1;
            elseif status ~= 0 && OverlapY ~= Overlap_north;
                % compute trasnform in north direction using whole overlaping region
                [Ty_north(i,j), Tx_north(i,j),index_ImMatch_north(i,j),pointsPreviousNumb_north(i,j),pointsNumb_north(i,j),matchedNumb_north(i,j),inliersNumb_north(i,j),status] = compute_trasnform_north( I1, I2,index_matrix(i,j), M,N, round(M*Overlap_north/100), Overlap_north, Threshold_metric);
                if status == 0
                    Level_north(i,j) = 2;
                end
            end
            %
        end
        if j > 1
            %       compute translation west

            if channel == 3
                I2 = im2double(rgb2gray(imread([source_directory img_name_grid{i,j-1}])));
            else
                I2 = im2double(imread([source_directory img_name_grid{i,j-1}]));
            end
            % compute trasnform in west direction using small part of overlaping region
            [Ty_west(i,j), Tx_west(i,j),index_ImMatch_west(i,j),pointsPreviousNumb_west(i,j),pointsNumb_west(i,j),matchedNumb_west(i,j),inliersNumb_west(i,j),status] = compute_trasnform_west( I1, I2,index_matrix(i,j), M,N, X_pixel, Overlap_west, Threshold_metric);
            if status == 0
                Level_west(i,j) = 1;
            elseif status ~= 0 && OverlapX ~= Overlap_west;
                % compute trasnform in west direction using whole overlaping region
                [Ty_west(i,j), Tx_west(i,j),index_ImMatch_west(i,j),pointsPreviousNumb_west(i,j),pointsNumb_west(i,j),matchedNumb_west(i,j),inliersNumb_west(i,j),status] = compute_trasnform_west( I1, I2,index_matrix(i,j), M,N, round(N*Overlap_west/100), Overlap_west, Threshold_metric);

                if status == 0
                    Level_west(i,j) = 2;
                end
            end
        end
    end
end
% Filter outliying translations
[Tx_west, Ty_west, Tx_north, Ty_north,matchedNumb_west,matchedNumb_north,valid_translations_west,valid_translations_north] = filter_translations(Tx_west, Ty_west, Tx_north, Ty_north,matchedNumb_west,matchedNumb_north,nb_vert_tiles,nb_horz_tiles,M, N, Overlap_west,  Overlap_north,overlap_error);

% compute graph weights
N1 = 1./matchedNumb_north;
N2 = 1./matchedNumb_west;
maxN = max(max(N1(:)),max(N2(:)));
weight_north = (N1./ maxN);
weight_west =  (N2./ maxN);

for n = 2:nb_vert_tiles
    idx = isnan(Tx_north(n,:));
    if any(idx) && nnz(idx) == numel(idx)
        Tx_north(n,idx) = round(mean(Tx_north(~isnan(Tx_north))));
        Ty_north(n,idx) = round(mean(Ty_north(~isnan(Ty_north))));

    elseif any(idx) && nnz(idx) ~= numel(idx)
        Tx_north(n,idx) = floor(mean(Tx_north(n,(~idx)))+0.5);
        Ty_north(n,idx) = floor(mean(Ty_north(n,(~idx)))+0.5);

    end
end
weight_north (isnan(weight_north)) = max(weight_north(~isnan(weight_north) ))+.1;
weight_north(1,:)= NaN;

for n = 2:nb_horz_tiles
    idx = isnan(Tx_west(:,n));
    if any(idx) && nnz(idx) == numel(idx)
        Tx_west(idx,n) = round(mean(Tx_west(~isnan(Tx_west))));
        Ty_west(idx,n) = round(mean(Ty_west(~isnan(Ty_west))));

    elseif any(idx) && nnz(idx) ~= numel(idx)
        Tx_west(idx,n) = floor(mean(Tx_west((~idx),n))+0.5);
        Ty_west(idx,n) = floor(mean(Ty_west((~idx),n))+0.5);

    end
end
weight_west (isnan(weight_west)) = max(weight_west(~isnan(weight_west) ))+.1;
weight_west(:,1) = NaN;

time_pairwise = toc(t) +time;