# FRMIS: Fast and Robust Feature-based Stitching Algorithm for Microscopic Images

Fast and Robust Microscopic Image Stitching (FRMIS) is a fast and robust automatic stitching algorithm to generate a consistent whole-slide image. This algorithm utilizes dominant SURF features from a small part of the overlapping region to achieve pairwise registration and consider the number of matched features in the global alignment. It implements global alignment algorithms such as Minimum Spanning Tree (MST) and Shortest Path Spanning Tree (SPT) for aligning the images. FRMIS is designed to stitch 2D microscopic images from different image modalities, including bright-field, phase-contrast, and fluorescence. 

## Usage Steps

1. Clone or download the repository to your local machine.

2. Open the MATLAB script `start_stitch.m`.

3. Customize the script by setting the following parameters:
    
     - `Optimization_option`: Choose between 'False' and 'True' to enable/disable optimization.  
        - **Optimization = Optimization_option{1}**: Disables registration optimization.  
        - **Optimization = Optimization_option{2}**: Enables registration optimization.

    - `GlobalRegistration_option`: Choose between 'MST' and 'SPT' for global registration.  
        - **GlobalRegistration = GlobalRegistration_option{1}**: Chooses 'MST' (Minimum Spanning Tree) for global registration.  
        - **GlobalRegistration = GlobalRegistration_option{2}**: Chooses 'SPT' (Shortest Path Spanning Tree) for global registration.

    - `blend_method_options`: Choose between 'Overlay' and 'Linear' for blending method.  
       - **blend_method = blend_method_options{1}**: Chooses 'Overlay' blending method.  
       - **blend_method = blend_method_options{2}**: Chooses 'Linear' blending method
      
    - `alpha`: Alpha value for linear blending.
    
    - `dataset_dir`: Directory containing the images to be stitched.
    
    - `dataset_name`: Name of the dataset.
    
    Specific parameters related to your dataset, which are accessible through the Whole-Slide Imaging (WSI) technique, such as:
    - `width`: Width of image grid (number of columns).
    - `height`: Height of image grid (number of rows).
    - `overlap`: Overlap percentage between adjacent tiles.
    - `img_num`: Total number of tiles.
    - `img_type`: Image file type.
    - `sort_type`: Sorting type indicates the pattern of the grid (the sequence of capturing tiles).  
      - **sort_type = 1**: Indicates the pattern shown below:    
      ![1,1,1,2](https://github.com/labCOI/FRMIS/assets/60792530/642be80e-30ed-4553-a5ec-675348643044)

      - **sort_type = 2**: Indicates the pattern shown below:  
      ![1,3,2,2](https://github.com/labCOI/FRMIS/assets/60792530/f1720eb1-6854-40e2-9b38-7d04addd923c)

    - `modality`: Imaging modality to adjust the SURF's threshold value.     
      - **modality = modality_option{1}**: Indicates the BrightField modality.    
      - **modality = modality_option{2}**: Indicates the Phase & Fluorescent modality.  
   
    ### Example Parameters for Stitching Image Collections from Various Datasets:

    To demonstrate the parameter inputs for stitching image collections, let's explore examples from different datasets:  
    1. **Tak Dataset:**  
    ![2024-05-07_125343](https://github.com/labCOI/FRMIS/assets/60792530/30ba1a7c-2dd5-463d-a5e1-0215adad5d47)

    3. **Human Colon Dataset:**  
    ![2024-05-07_125243](https://github.com/labCOI/FRMIS/assets/60792530/23270228-2601-4298-93a1-c351051fb03d)
    5. **Stem Cell Colony (SCC) Dataset - Level 3:**   
    ![2024-05-07_125016](https://github.com/labCOI/FRMIS/assets/60792530/ed71518b-5a77-415d-9212-b90d983e0522)

    7. **Stem Cell Colony (SCC) Dataset - Level 1, Level 2, Phase:**    
    ![2024-05-07_124943](https://github.com/labCOI/FRMIS/assets/60792530/2ba7447e-e50a-4099-bdc1-5e892e4e8363)

    9. **Stem Cell Colony (SCC) Dataset - Small, Small Phase:**   
    ![2024-05-07_124705](https://github.com/labCOI/FRMIS/assets/60792530/8c440aa4-feac-498b-9079-37bd91531264)

     These examples showcase various configurations of parameters for different datasets, enabling effective stitching of image collections.
4. Run the script in MATLAB.

## Output

The script generates the stitched image and saves it as a JPG file. It also saves the stitching results as a MAT file contains:

- `img_name_grid`: Grid containing the names of image files.
- `Tx_west`: Horizontal translations for the west direction.
- `Ty_west`: Vertical translations for the west direction.
- `Tx_north`: Horizontal translations for the north direction.
- `Ty_north`: Vertical translations for the north direction.
- `index_ImMatch_west`: Index of image matches in the west direction.
- `index_ImMatch_north`: Index of image matches in the north direction.
- `pointsPreviousNumb_west`: Number of extracted feature points in the right tile (I1) for the west direction.
- `pointsPreviousNumb_north`: Number of extracted feature points in the down tile (I1) for the north direction.
- `pointsNumb_west`: Number of extracted feature points in the left tile (I2) for the west direction.
- `pointsNumb_north`: Number of extracted feature points in the up tile (I2) for the north direction.
- `matchedNumb_west`: Number of matched feature points for the west direction.
- `matchedNumb_north`: Number of matched feature points for the north direction.
- `inliersNumb_west`: Number of inliers for the west direction.
- `inliersNumb_north`: Number of inliers for the north direction.
- `Level_west`: Level of translation computed  for the west direction. '1' indicates that translation found using small part of overlaping region and '2' using whole overlaping region.
- `Level_north`: Level of translation computed for the north direction. '1' indicates that translation found using small part of overlaping region and '2' using whole overlaping region.
- `weight_north`: Weight of graph' edges for the north direction.
- `weight_west`: Weight of graph' edges for the west direction.
- `time_pairwise`: Time taken for pairwise alignment.
- `valid_translations_west`: Valid translations for the west direction.
- `valid_translations_north`: Valid translations for the north direction.
- `tiling_indicator`: Indicator matrix for tile arrangement (indicates the connectivity of tiles in stitching result).
- `tile_weights`: Weights assigned to each tile.
- `global_y_img_pos`: Global Y position of images in the grid.
- `global_x_img_pos`: Global X position of images in the grid.
- `time_global_alignment`: Time taken for computing the global alignment.
- `time_assembling`: Time taken for assembling the stitched image.
- `total_time`: Total time taken for the alignment process.
- `X1`: Horizontal displacement of tiles.
- `Y1`: Vertical displacement of tiles.
- `X2`: Horizontal displacement of tiles.
- `Y2`: Vertical displacement of tiles.
- `RMSE_west`: Root Mean Square Error (RMSE) for the western neighbor tiles.
- `RMSE_north`: Root Mean Square Error (RMSE) for the northern neighbor tiles.
- `average_RMSE_global`: Average RMSE for the global alignment.

## Notes

- Make sure to provide the correct path to the directory containing your dataset.

- Adjust the parameters according to the properties of your dataset for optimal stitching results.

- This script assumes that the images are named in a sequential order and can be sorted accordingly. If your images have a different naming convention, you may need to modify the sorting logic.
  - An example of the sequential order of image names is shown below:
   ![image](https://github.com/labCOI/FRMIS/assets/60792530/031cfd95-b1a0-4a44-b536-7182ecd85c81)

- Ensure that the necessary MATLAB toolboxes (such as Image Processing Toolbox) are installed and accessible.

## Citation
If you find this work helpful for your research or project, please consider citing the accompanying article:
[Fatemeh Sadat Mohammadi, Hasti Shabani, & Mojtaba Zarei‏. "Fast and robust feature-based stitching algorithm for microscopic images." Scientific Reports 14, 13304 (2024). DOI: 10.1038/s41598-024-61970-y](https://doi.org/10.1038/s41598-024-61970-y)

