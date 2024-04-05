function [Tx_west, Ty_west, Tx_north, Ty_north,time_pairwise_with_Optimization] = optimize_registrations(source_directory, img_name_grid,Tx_west, Ty_west,Tx_north, Ty_north,...
    nb_vert_tiles,nb_horz_tiles,valid_translations_west,valid_translations_north,time_pairwise)
tic
% compute repeatability
rx = ceil((max(Tx_north(~isnan(valid_translations_north))) - min(Tx_north(~isnan(valid_translations_north))))/2);
tY = Ty_north; % temporarily remove non valid translatons to compute Y range
tY(isnan(valid_translations_north)) = NaN;
ry = max(ceil((max(tY,[],2) - min(tY,[],2))/2));
repeatability1 = max(rx,ry);

ry = ceil((max(Ty_west(~isnan(valid_translations_west))) - min(Ty_west(~isnan(valid_translations_west))))/2);
tX = Tx_west; % temporarily remove non valid translatons to compute X range
tX(isnan(valid_translations_west)) = NaN;
rx = max(ceil((max(tX,[],1) - min(tX,[],1))/2));
repeatability2 = max(rx,ry);

% repeatability search range is 2r +1 (to encompase +-r)
r = max(repeatability1, repeatability2);
r = 2*max(r, 1) + 1;


% build the cross correlation search bounds and perform the search
for j = 1:nb_horz_tiles

    % loop over the rows correcting invalid correlation values
    for i = 1:nb_vert_tiles

        % if not the first column, and both images exist
        if j ~= 1 && ~isempty(img_name_grid{i,j-1}) && ~isempty(img_name_grid{i,j})
            bounds = [Ty_west(i,j)-r, Ty_west(i,j)+r, Tx_west(i,j)-r, Tx_west(i,j)+r];
            [Ty_west(i,j), Tx_west(i,j)] = cross_correlation_hill_climb_(source_directory, img_name_grid{i,j-1}, img_name_grid{i,j}, bounds, Tx_west(i,j), Ty_west(i,j));
        end

        % if not the first row, and both images exist
        if i ~= 1 && ~isempty(img_name_grid{i-1,j}) && ~isempty(img_name_grid{i,j})
            bounds = [Ty_north(i,j)-r, Ty_north(i,j)+r, Tx_north(i,j)-r, Tx_north(i,j)+r];
            [Ty_north(i,j), Tx_north(i,j)] = cross_correlation_hill_climb_(source_directory, img_name_grid{i-1,j}, img_name_grid{i,j}, bounds, Tx_north(i,j), Ty_north(i,j));
        end
    end

end
time_pairwise_with_Optimization = toc + time_pairwise;
end
