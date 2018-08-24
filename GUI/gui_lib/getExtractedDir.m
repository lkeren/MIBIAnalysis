function [extracted_dir] = getExtractedDir(dir)
    old_dir = strsplit(dir, filesep);
    old_dir{end+1} = old_dir{end};
    old_dir{end-1} = 'extracted';
    extracted_dir = strjoin(old_dir, filesep);
end

