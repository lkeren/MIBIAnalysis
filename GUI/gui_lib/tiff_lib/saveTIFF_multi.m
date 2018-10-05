function saveTIFF_multi(counts, labels, tags, path)
    path = strsplit(path, '.'); path = path{1}; % normalizing name
    tiff = Tiff([path, '.tiff'], 'a');
    for index=1:numel(labels)
        tags{index}.BitsPerSample = 16;
        setTag(tiff, tags{index});
        setTag(tiff, 'PageName', labels{index});
        setTag(tiff, 'Compression', Tiff.Compression.Deflate);
        if tags{index}.BitsPerSample==16
            write(tiff, uint16(counts(:,:,index)));
        elseif tags{index}.BitsPerSample==8
            write(tiff, uint8(counts(:,:,index)));
        else
            warning('The bits are all messed up');
        end
        if index~=length(labels)
            writeDirectory(tiff);
        end
    end
    rewriteDirectory(tiff);
    close(tiff);
end

