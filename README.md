# FRMIS: Fast and Robust Feature-based Stitching Algorithm for Microscopic Images

Fast and Robust Microscopic Image Stitching (FRMIS) is a fast and robust automatic stitching algorithm to generate a consistent whole-slide image. This algorithm utilizes dominant SURF features from a small part of the overlapping region to achieve pairwise registration and consider the number of matched features in the global alignment. It implements global alignment algorithms such as Minimum Spanning Tree (MST) and Shortest Path Spanning Tree (SPT) for aligning the images. FRMIS is designed to stitch 2D microscopic images from different image modalities, including bright-field, phase-contrast, and fluorescence. 

## Usage Steps

1. Clone or download the repository to your local machine.

2. Open the MATLAB script `start_stitch.m`.

3. Customize the script by setting the following parameters:
    
    - `Optimization_option`: Choose between 'False' and 'True' to enable/disable optimization.  
      **Optimization = Optimization_option{1}** disables registration optimization  
      **Optimization = Optimization_option{2}** enables registration optimization
      
    - `GlobalRegistration_option`: Choose between 'MST' and 'SPT' for global registration.  
      **GlobalRegistration = GlobalRegistration_option{1}** chooses 'MST' Minimum Spanning Tree for global registration  
      **GlobalRegistration = GlobalRegistration_option{2}** chooses 'SPT' Shortest path Spanning Tree for global registration
      
    - `blend_method_options`: Choose between 'Overlay' and 'Linear' for blending method.  
      **blend_method = blend_method_options{1}** chooses 'Overlay' blending method  
      **blend_method = blend_method_options{2}** chooses 'Linear' blending method
      
    - `alpha`: Alpha value for linear blending.
    
    - `dataset_dir`: Directory containing the images to be stitched.
    
    - `dataset_name`: Name of the dataset.
    
    Parameters specific to your dataset, available in Whole-Slide Imaging (WSI) technique, such as:
    - `width`: Width of image grid (number of columns).
    - `height`: Height of image grid (number of rows).
    - `overlap`: Overlap percent between adjacent tiles.
    - `img_num`: Total number of tiles.
    - `img_type`: Image file type.
    - `sort_type`: Sorting type indicates the pattern of grid (order of the tiles).  
        **sort_type = 1** indicates below pattern: &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; **sort_type = 2** indicates below pattern:
        ![image](https://github.com/labCOI/FRMIS/assets/60792530/e0440b5c-fc1c-4ae5-b96e-a492134e01a1)
    - `modality`: Imaging modality to adjust the SURF's threshold value.   
        **modality = modality_option{1}** indicates <ins>BrightField</ins> modality  
        **modality = modality_option{2}** indicates <ins>phase&Fluorescent</ins> modality
   
    ### Example Parameters for Stitching Image Collections from Various Datasets:

    To demonstrate the parameter inputs for stitching image collections, let's explore examples from different datasets:  
    1. **Tak Dataset:**  
    ![image](https://github.com/labCOI/FRMIS/assets/60792530/9575a0f1-379a-4702-9371-8f4c3db290bd)
    
    3. **Human Colon Dataset:**  
    ![image](https://github.com/labCOI/FRMIS/assets/60792530/2a904a4e-3bcb-4432-953d-fa0ed9dfbeeb)
        
    5. **Stem Cell Colony (SCC) Dataset - Level 3:**   
    ![image](https://github.com/labCOI/FRMIS/assets/60792530/a39ebb15-be32-4378-a7cd-e739cae6e512)
    
    7. **Stem Cell Colony (SCC) Dataset - Level 1, Level 2, Phase:**    
    ![image](https://github.com/labCOI/FRMIS/assets/60792530/fca7f7d9-0395-4982-ba1a-345f9c1649bd)
     
    9. **Stem Cell Colony (SCC) Dataset - Small, Small Phase:**   
    ![image](https://github.com/labCOI/FRMIS/assets/60792530/0cc3f0aa-74da-4e16-b485-0b8b066db609)
   
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

- Ensure that the necessary MATLAB toolboxes (such as Image Processing Toolbox) are installed and accessible.


