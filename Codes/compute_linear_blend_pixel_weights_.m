function w_mat = compute_linear_blend_pixel_weights_(size_I, alpha,img_channels)
d_min_mat_i = zeros(size_I(1), 1);
d_min_mat_j = zeros(1, size_I(2));
for i = 1:size_I(1)
    d_min_mat_i(i,1) = min(i, size_I(1) - i + 1);
end
for j = 1:size_I(2)
    d_min_mat_j(1,j) = min(j, size_I(2) - j + 1);
end

w_matt = d_min_mat_i*d_min_mat_j; 
w_matt = w_matt.^alpha;
if img_channels ==3
w_mat = cat(3, w_matt,w_matt);
w_mat = cat(3, w_mat,w_matt);
else
  w_mat =w_matt;  
end
end