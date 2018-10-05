function [counts, labels, tags] = sortByMass(counts, labels, tags, path)
    % we have two basic conditions. EITHER we have data from Leeat's
    % scripts, OR we have data from the IonPath extractor.
    
    % we have data from the IonPath extractor
    if exist('tags{1}.PageName')
        try
            masses = double(size(tags));
            for i=1:numel(tags)
                % we could also here try to pull the mass from the
                % ImageDescription json string, but for now we're going to
                % use the PageName tag becuase it's a little easier.
                pagename = strsplit(tags{i}.PageName, ' (');
                mass = pagename{end};
                masses(i) = str2double(strrep(mass, ')', ''));
            end
            
            [~, idx] = sort(masses);
        catch e
            error(e)
        end
    else % we have data from Leeat's extractor, so assume path is usefull
        [folder, ~, ~] = fileparts(path); % remember that path should be to a POINT folder
        panelPath = [folder, filesep, 'panel'];
        csvList = dir(fullfile(panelPath, '*.csv'));
        if numel(csvList)==1
            filepath = [csvList.folder, filesep, csvList.name];
            panel = dataset('File', filepath, 'Delimiter', ',');
        elseif isempty(csvList)
            error(['No CSV file was found inside of ', panelPath]);
        else
            error(['Too many CSV files were found inside of ', panelPath]);
        end
        idx = zeros(size(tags));
        % disp(labels)
        for i=1:numel(labels)
            id = find(strcmp(labels, panel.Label{i}));
            % disp(['{',num2str(id),'} ', labels{i}])
            idx(i) = id;
        end
%         disp(idx);
%         disp(panel.Label);
%         disp(labels(idx));
%         counts = counts(:,:,idx);
%         labels = labels(idx);
%         tags = tags(idx);
    end
    
    try
        counts = counts(:,:,idx);
    catch
        % do nothing
    end
    labels = labels(idx);
    tags = tags(idx);
end

