function seqIdx = GetCubicTraj(sizeAxis,levelAxis)
    sizeAxis = sizeAxis(levelAxis);
    iCntX = sizeAxis(1);
    iCntY = sizeAxis(2);
    iCntZ = sizeAxis(3);

    deltaX = 1;
    deltaY = 1;
    deltaZ = 1;
    
    idxZ = 1;
    idxY = 1;
    idxX = 1;
    
    idxMove = 1;
    iCntChangeEventX = 1;
    iCntChangeEventY = 1;
    
    seqIdx = zeros(iCntX*iCntY*iCntZ,3);
    
    while idxZ < iCntZ+1
        seqIdx(idxMove,:) = [idxX,idxY,idxZ];
        idxMove = idxMove + 1;
       
        if ~rem(iCntChangeEventX,iCntX) 
            if ~rem(iCntChangeEventY,iCntY)
                deltaY = -deltaY;
                deltaX = -deltaX;
                idxZ = idxZ + deltaZ;
                iCntChangeEventY = 1;
                iCntChangeEventX = 1;
            elseif ~rem(iCntChangeEventX,iCntX)
                deltaX = -deltaX;
                idxY = idxY + deltaY;
                iCntChangeEventY = iCntChangeEventY + 1;
                iCntChangeEventX = 1;
            end
        else
            iCntChangeEventX = iCntChangeEventX + 1;
            idxX = idxX + deltaX;
        end
        
    end
    seqIdx = seqIdx(:,levelAxis);
end