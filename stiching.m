function  main = stiching(source_directory, nb_horz_tiles, nb_vert_tiles, Overlap_west, Overlap_north, End, img_type, sort_type, dataset_name, Threshold_metric , Optimization, GlobalRegistration, blend_method, alpha,overlap_error)

tic;
% Get files from the source directory
files= dir(fullfile(source_directory,sprintf('*%s',img_type)));
files = natsortfiles({files.name});
Start =1;
file = files(Start:End);
num_Im = numel(file);

% Create index matrix for image grid
index_matrix = 1:nb_vert_tiles*nb_horz_tiles;

t = nb_vert_tiles;
nb_vert_tiles = nb_horz_tiles;
nb_horz_tiles = t;

% Sort images based on sort_type
% sort_type = 1 sorts the 5*5 image grid like below:
%  1,  2,  3,  4,   5;
%  6,  7,  8,  9,  10;
% 11, 12, 13, 14,  15;
% 16, 17, 18, 19,  20;
% 21, 22, 23, 24,  25;
% sort_type = 2 sorts the 5*5 image grid like below:
% 21, 22, 23, 24,  25;
% 16, 17, 18, 19,  20;
% 11, 12, 13, 14,  15;
%  6,  7,  8,  9,  10;
%  1,  2,  3,  4,   5;
if sort_type == 1 % % % for Tak & MIST dataset & ICIAR & USAF
    main.img_name_grid = reshape(file, nb_vert_tiles, nb_horz_tiles)';
    index_matrix = (reshape(index_matrix, nb_vert_tiles, nb_horz_tiles))';
else % % for ashlar dataset
    main.img_name_grid = reshape(file, nb_vert_tiles, nb_horz_tiles)';
    index_matrix = (reshape(index_matrix, nb_vert_tiles, nb_horz_tiles))';

    main.img_name_grid  = main.img_name_grid (sort(1:size(main.img_name_grid ,1),'descend'),:);
    index_matrix = index_matrix(sort(1:size(index_matrix,1),'descend'),:);
end
[nb_vert_tiles, nb_horz_tiles] = size(main.img_name_grid);

% Get dimensions of first image
[M N channel] = size(imread([source_directory main.img_name_grid{1,1}]));


time= toc;

% Perform pairwise alignment
[main.Tx_west, main.Ty_west, main.Tx_north, main.Ty_north, main.index_ImMatch_west, main.index_ImMatch_north,  main.pointsPreviousNumb_west, main.pointsPreviousNumb_north,...
    main.pointsNumb_west, main.pointsNumb_north, main.matchedNumb_west, main.matchedNumb_north, main.inliersNumb_west, main.inliersNumb_north,main.Level_north,main.Level_west,...
    main.weight_north,main.weight_west,main.time_pairwise,main.valid_translations_west,main.valid_translations_north] = pairwise_alignment(source_directory,...
    main.img_name_grid,index_matrix,nb_vert_tiles,nb_horz_tiles,M, N, Overlap_west, Overlap_north,channel,overlap_error,Threshold_metric ,Optimization,time);


switch Optimization
    case 'False'
        % Perform global alignment without optimization
        eval(sprintf('main.%s = global_alignment_%s(main.Tx_west, main.Ty_west, main.Tx_north, main.Ty_north,main.weight_north,main.weight_west, nb_vert_tiles,nb_horz_tiles,source_directory, main.img_name_grid, channel, Optimization,dataset_name,main.time_pairwise, blend_method, alpha,img_type);',GlobalRegistration,GlobalRegistration));

    case 'True'
        % Perform global alignment with optimization
        [main.Tx_west_optimized, main.Ty_west_optimized, main.Tx_north_optimized, main.Ty_north_optimized,main.time_pairwise_with_Optimization] = optimize_registrations(source_directory, main.img_name_grid,...
            main.Tx_west, main.Ty_west,main.Tx_north, main.Ty_north,nb_vert_tiles,nb_horz_tiles,main.valid_translations_west,main.valid_translations_north,main.time_pairwise);

        eval(sprintf('main.%s_optimized = global_alignment_%s(main.Tx_west_optimized, main.Ty_west_optimized, main.Tx_north_optimized, main.Ty_north_optimized,main.weight_north,main.weight_west, nb_vert_tiles,nb_horz_tiles,source_directory, main.img_name_grid, channel, Optimization,dataset_name,main.time_pairwise_with_Optimization, blend_method, alpha,img_type);',GlobalRegistration,GlobalRegistration));
end