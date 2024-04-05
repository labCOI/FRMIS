function img = read_img(srcDir, imgName)
img = [];
if ~isempty(imgName)
    if exist([srcDir imgName],'file')
        img =imread([srcDir imgName]);
        [~,~,channel] = size(img);
        if channel == 3
            img =  double(rgb2gray(img));
        else
            img =  double(img);
        end
     end
end
end
