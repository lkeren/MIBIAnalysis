function [tags] = getTagStruct(tiffObj)
    tags = struct();
    try tags.PageName = getTag(tiffObj,'PageName'); catch end
    try tags.SubFileType = getTag(tiffObj,'SubFileType'); catch end
    try tags.Photometric = getTag(tiffObj,'Photometric'); catch end
    try tags.ImageLength = getTag(tiffObj,'ImageLength'); catch end
    try tags.ImageWidth = getTag(tiffObj,'ImageWidth'); catch end
    try tags.RowsPerStrip = getTag(tiffObj,'RowsPerStrip'); catch end
    try tags.BitsPerSample = getTag(tiffObj,'BitsPerSample'); catch end
    try tags.Compression = getTag(tiffObj,'Compression'); catch end
    try tags.SampleFormat = getTag(tiffObj,'SampleFormat'); catch end
    try tags.SamplesPerPixel = getTag(tiffObj,'SamplesPerPixel'); catch end
    try tags.PlanarConfiguration = getTag(tiffObj,'PlanarConfiguration'); catch end
    try tags.ImageDescription = getTag(tiffObj,'ImageDescription'); catch end
    try tags.Orientation = getTag(tiffObj,'Orientation'); catch end
end

