function data = updatePCC(data, fix, mov, pcorr)
    if data(fix).pcc < pcorr
        data(fix).pcc = pcorr;
    end
    if data(mov).pcc < pcorr
        data(mov).pcc = pcorr;
    end
end

