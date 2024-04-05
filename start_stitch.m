clear all;close all;clc;
warning('off')
% Enter Directory and name of the dataset
dataset_dir = 'C:\Users\Administrator\Downloads\Small_Fluorescent_Test_Dataset\Tak_Dataset-Corrected1\026-01-91-Corrected\'
dataset_name = '026-01-91-Corrected'

modality_option = {'BrightField','phase&Fluorescent'};
Optimization_option = {'False','True'};
GlobalRegistration_option = {'MST','SPT'};
blend_method_options = {'Overlay','Linear'};

% Choose optimization, global registration, and blending options
Optimization = Optimization_option{1};
GlobalRegistration = GlobalRegistration_option{1};
blend_method = blend_method_options{1};

% Adjust alpha value for lieanr blending
alpha = 1.5; % controls the linear blending, higher alpha will blend the edges more, alpha of 0 turns the linear blending into average blending

% Set parameters based on the dataset
% %% Parameters for Tak dataset
width = 10; % Width of image grid (number of columns)
height = 10; % Height of image grid (number of rows)
overlap = 25; % Overlap percent between adjacent tiles
img_num = 100; % Total number of images
img_type = '.jpg'; % Image file type
sort_type = 1; % Sorting type indicates patern of grid
modality = modality_option{1}; %'BrightField' modality

% %% Parameters for human colon dataset
% width = 29; height = 21; overlap = 3; img_num = 609; img_type = '.tif'; sort_type = 2;modality = modality_option{1};
% %% Parameters for stem cell colony (SCC) dataset: Level3
% width = 23; height = 24; overlap = 10; img_num = 552; img_type = '.tif'; sort_type = 1;modality = modality_option{2};
% %% Parameters for stem cell colony (SCC) dataset: Level1, Level2, phase
% width = 10; height = 10; overlap = 10; img_num = 100; img_type = '.tif'; sort_type = 1;modality = modality_option{2};
% %% Parameters for stem cell colony (SCC) dataset: small, small_phase
% width = 5; height = 5; overlap = 19; img_num = 25; img_type = '.tif'; sort_type = 1;modality = modality_option{2};
% %% Parameters for USAF & ICIAR
%     width = 10; height = 10; overlap = 30; img_num = 100; img_type = '.tif'; sort_type = 1;modality = modality_option{1};

% Define threshold metric based on modality
switch modality
    case 'BrightField'
        Threshold_metric = 1000;
    case 'phase&Fluorescent'
        Threshold_metric = 1;
end

overlap_error = 2;

% Perform stitching
stitching_results = stiching(dataset_dir, width, height, overlap, overlap, img_num, img_type, sort_type, dataset_name, Threshold_metric , Optimization, GlobalRegistration, blend_method, alpha,overlap_error)
fprintf('\n Stitching %s done', dataset_name);

% Save stitching results to a .mat file
save(sprintf('%s_stitching_result_Optimization_%s_%s_%s.mat', dataset_name, Optimization, GlobalRegistration, blend_method ));
