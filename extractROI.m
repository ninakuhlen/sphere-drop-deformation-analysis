function roiFrame = extractROI(frame, roi)
    % extractROI - Extracts the Region of Interest (ROI) from a frame
    % Input:
    %   frame - The current frame (grayscale or color)
    %   roi - [x, y, width, height] array defining the ROI
    % Output:
    %   roiFrame - Extracted ROI from the frame

    x = roi(1);
    y = roi(2);
    width = roi(3);
    height = roi(4);

    % Extract the ROI
    roiFrame = frame(y:y+height-1, x:x+width-1);
end
