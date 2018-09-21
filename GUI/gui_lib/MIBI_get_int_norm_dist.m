function [intND] = MIBI_get_int_norm_dist(data, K)
    [IDX, closestDvecBA] = gui_MibiGetClosestDDoubleCountPeaks(data,data,K);
    if isempty(closestDvecBA)
        intND=[];
    else
        intND = mean(closestDvecBA(:,[2:K]),2);
    end
end

