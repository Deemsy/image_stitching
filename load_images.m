function images = load_images(directory_path)

%get only the files with an extension of JPG in directory_path
contents = dir(fullfile(directory_path,'*.JPG'));      

%get directory indices in case '.' and '..' appear in the list
directory_indices = [contents.isdir]; 
images = {contents(~directory_indices).name}'; 

%put the image names (with their path) into a cell array-images
  if ~isempty(images)
    images = cellfun(@(x) fullfile(directory_path,x),... 
                       images,'UniformOutput',false);
 %images can be accessed using images{i} where i>0
  end

end