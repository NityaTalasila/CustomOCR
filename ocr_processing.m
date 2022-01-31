function [test_mode,test_method,mins,widthBOX,heightBOX] = testing(test_mode,test_method,mins,widthBOX,heightBOX)
warning('off','all')
fig=figure;

% Setup
if test_mode == 2
    camList = webcamlist;
    web_cam = camList(2);
    cam = webcam(web_cam{:});
    cam.Resolution = cam.AvailableResolutions{end}; % Set webcam res to max
    currentFrame = snapshot(cam);
    ax = axes(fig);
    im = image(ax,zeros(size(currentFrame),'uint8'));
    axis(ax,'image');
    try
        preview(cam,im)
    catch
        
    end
end

% Video
if test_mode == 1
    vo2_text = [];
    vco2_text = [];
    v = VideoReader('testvid1trim.mp4');
    currentFrame = readFrame(v);
    imshow(currentFrame)
end
% Visualization for camera position and function
global objectRegion1 objectRegion2 rows1 cols1 rows2 cols2

videoPlayer = vision.VideoPlayer('Position',[50,300,680,400]);
%%   TEST METHOD 1

if test_method == 1
    tic
    vo2approved = 1;
    vco2approved = 1;
    sizing_run = 1;
    while toc <= 5
        % current frame
        figure(fig);
        I = rgb2gray(currentFrame);
        while sizing_run ~= 0
            % create center for VO2
            while vo2approved == 1
                if exist('vo2modified')
                    edits = input(['Please enter a new width and height for VO2 as shown: [width,height]\n']);
                    widthBOX1 = edits(1);
                    heightBOX1 = edits(2);
                    figure;
                    imshow(currentFrame);
                    fprintf('Please click in the center of the VO2 numbers\n')
                    [rows1,cols1] = ginput(1);
                else
                    fprintf('Please click in the center of the VO2 numbers\n')
                    [rows1,cols1] = ginput(1);
                    widthBOX1 = widthBOX;
                    heightBOX1 = heightBOX;
                end
                % compute box dimensions for VO2
                VOX1 = (rows1 - widthBOX1/2);
                VOX2 = (rows1 + widthBOX1/2);
                VOY1 = (cols1 - heightBOX1/2);
                VOY2 = (cols1 + heightBOX1/2);
                vo2_text_frame = I(VOY1:VOY2,VOX1:VOX2);
                vo2approved = 0;
            end
            
            % create center for VCO2
            while vco2approved == 1
                if exist('vco2modified')
                    edits = input(['Please enter a new width and height for VCO2 as shown: [width,height]\n']);
                    widthBOX2 = edits(1);
                    heightBOX2 = edits(2);
                    figure;
                    imshow(currentFrame);
                    fprintf('Please click in the center of the VCO2 numbers\n')
                    [rows2,cols2] = ginput(1);
                else
                    fprintf('Please click in the center of the VCO2 numbers\n')
                    [rows2,cols2] = ginput(1);
                    widthBOX2 = widthBOX;
                    heightBOX2 = heightBOX;
                end
                % create box dimensions for VCO2
                VCOX1 = (rows2 - widthBOX2/2);
                VCOX2 = (rows2 + widthBOX2/2);
                VCOY1 = (cols2 - heightBOX2/2);
                VCOY2 = (cols2 + heightBOX2/2);
                vco2_text_frame = I(VCOY1:VCOY2,VCOX1:VCOX2);
                vco2approved = 0;
            end
            % show inital results
            subplot(1,2,1); imshow(vo2_text_frame);
            subplot(1,2,2); imshow(vco2_text_frame);
            text1 = ocr(vo2_text_frame);
            text2 = ocr(vco2_text_frame);
            vo2_text = str2double(text1.Text)
            vco2_text = str2double(text2.Text)
            
            vo2approved = input(['Are you satisfied with the VO2 textboxes?(0 = Yes; 1 = No)\n']);
            vo2modified = 1;
            vco2approved = input(['Are you satisfied with the VCO2 textboxes?(0 = Yes; 1 = No)\n']);
            vco2modified = 1;
            
            if vo2approved == 1 || vco2approved == 1
                sizing_run = 1;
            else
                sizing_run = 0;
            end
            
        end
    end
    
    tic
    while toc <= mins*60 + 5
        if test_mode == 1
            currentFrame = readFrame(v);
        elseif test_mode == 2
            currentFrame = snapshot(cam);
        end
        I = rgb2gray(currentFrame);
        % create text frames for new frame
        vo2_text_frame = I(VOY1:VOY2,VOX1:VOX2);
        vco2_text_frame = I(VCOY1:VCOY2,VCOX1:VCOX2);
        subplot(1,2,1); imshow(vo2_text_frame);
        subplot(1,2,2); imshow(vco2_text_frame);
        % OCR number reading and output
        text1 = ocr(vo2_text_frame);
        text2 = ocr(vco2_text_frame);
        vo2_text = str2double(text1.Text)
        vco2_text = str2double(text2.Text)
    end
    
%%     TEST METHOD 2
    
elseif test_method == 2 || test_method == 0
    tic
    vo2approved = 1;
    vco2approved = 1;
    sizing_run = 1;
    while toc <= 5
        % current frame
        figure(fig);
        I = rgb2gray(currentFrame);
        while sizing_run ~= 0
            
            % VO2
            while vo2approved == 1
                if exist('vo2modified')
                    edits = input(['Please enter a new width and height for VO2 as shown: [width,height]\n']);
                    widthBOX1 = edits(1);
                    heightBOX1 = edits(2);
                    figure;
                    imshow(currentFrame);
                    fprintf('Please click in the center of the VO2 numbers\n')
                    [rows1,cols1] = ginput(1);
                else
                    if test_method == 2
                        % create VO2 text box
                        fprintf('Highlight V02ml for anchoring:\nTop Left of V02ml\nBottom right V02ml\n')
                        % create marker points for tracking VO2
                        objectRegion1 = round(getPosition(imrect));
                        fprintf('Please click in the center of the VO2 numbers\n')
                        [rows1,cols1] = ginput(1);
                    end
                    points1 = detectMinEigenFeatures(rgb2gray(currentFrame),'ROI',objectRegion1);
                    tracker1 = vision.PointTracker('MaxBidirectionalError',1);
                    initialize(tracker1,points1.Location,currentFrame);
                    % tracker points for VO2
                    [points1,~] = tracker1(currentFrame);
                    widthBOX1 = widthBOX;
                    heightBOX1 = heightBOX;
                end
                Left1 = min(points1);
                Right1 = max(points1);
                Xoffset1 = rows1 - Left1(1);
                Yoffset1 = cols1 - Right1(2);
                % compute box dimensions for VO2
                VOX1 = (Left1(1) + Xoffset1 - widthBOX1/2);
                VOX2 = (Left1(1) + Xoffset1 + widthBOX1/2);
                VOY1 = (Right1(2) + Yoffset1 - heightBOX1/2);
                VOY2 = (Right1(2) + Yoffset1 + heightBOX1/2);
                vo2_text_frame = I(VOY1:VOY2,VOX1:VOX2);
                vo2approved = 0;
            end
            
            % VCO2
            while vco2approved == 1
                if exist('vco2modified')
                    edits = input(['Please enter a new width and height for VCO2 as shown: [width,height]\n']);
                    widthBOX2 = edits(1);
                    heightBOX2 = edits(2);
                    figure;
                    imshow(currentFrame);
                    fprintf('Please click in the center of the VCO2 numbers\n')
                    [rows2,cols2] = ginput(1);
                else
                    if test_method == 2
                        % create VCO2 text box
                        fprintf('Highlight VC02ml for anchoring:\nTop Left of VC02ml\nBottom right VC02ml\n')
                        % create marker points for tracking VCO2
                        objectRegion2 = round(getPosition(imrect));
                        fprintf('Please click in the center of the VCO2 numbers\n')
                        [rows2,cols2] = ginput(1);
                    end
                    points2 = detectMinEigenFeatures(rgb2gray(currentFrame),'ROI',objectRegion2);
                    tracker2 = vision.PointTracker('MaxBidirectionalError',1);
                    initialize(tracker2,points2.Location,currentFrame);
                    % tracker points for VCO2
                    [points2,~] = tracker2(currentFrame);
                    widthBOX2 = widthBOX;
                    heightBOX2 = heightBOX;
                end
                Left2 = min(points2);
                Right2 = max(points2);
                Xoffset2 = rows2 - Left2(1);
                Yoffset2 = cols2 - Right2(2);
                % compute box dimensions for VCO2
                VCOX1 = (Left2(1) + Xoffset2 - widthBOX2/2);
                VCOX2 = (Left2(1) + Xoffset2 + widthBOX2/2);
                VCOY1 = (Right2(2) + Yoffset2 - heightBOX2/2);
                VCOY2 = (Right2(2) + Yoffset2 + heightBOX2/2);
                vco2_text_frame = I(VCOY1:VCOY2,VCOX1:VCOX2);
                vco2approved = 0;
            end
            % show initial results
            subplot(1,2,1); imshow(vo2_text_frame);
            subplot(1,2,2); imshow(vco2_text_frame);
            text1 = ocr(vo2_text_frame);
            text2 = ocr(vco2_text_frame);
            vo2_text = str2double(text1.Text)
            vco2_text = str2double(text2.Text)
            if test_method == 2
                vo2approved = input(['Are you satisfied with the VO2 textboxes?(0 = Yes; 1 = No)\n']);
            end
            vo2modified = 1;
            if test_method == 2
                vco2approved = input(['Are you satisfied with the VCO2 textboxes?(0 = Yes; 1 = No)\n']);
            end
            vco2modified = 1;
            
            if vo2approved == 1 || vco2approved == 1
                sizing_run = 1;
            else
                sizing_run = 0;
            end
        end
    end
    
    
    tic
    while toc < mins*60 + 5
        if test_mode == 1
            currentFrame = readFrame(v);
        elseif test_mode == 2
            currentFrame = snapshot(cam);
        end
        % recreate points for each frame
        [points1,validity] = tracker1(currentFrame);
        [points2,validity] = tracker2(currentFrame);
        I = rgb2gray(currentFrame);
        
        % VO2
        Left1 = min(points1);
        Right1 = max(points1);
        Xoffset1 = rows1 - Left1(1);
        Yoffset1 = cols1 - Right1(2);
        % compute box dimensions for VO2
        VOX1 = (Left1(1) + Xoffset1 - widthBOX1/2);
        VOX2 = (Left1(1) + Xoffset1 + widthBOX1/2);
        VOY1 = (Right1(2) + Yoffset1 - heightBOX1/2);
        VOY2 = (Right1(2) + Yoffset1 + heightBOX1/2);
        vo2_text_frame = I(VOY1:VOY2,VOX1:VOX2);
        
        % VCO2
        Left2 = min(points2);
        Right2 = max(points2);
        Xoffset2 = rows2 - Left2(1);
        Yoffset2 = cols2 - Right2(2);
        % compute box dimensions for VCO2
        VCOX1 = (Left2(1) + Xoffset2 - widthBOX2/2);
        VCOX2 = (Left2(1) + Xoffset2 + widthBOX2/2);
        VCOY1 = (Right2(2) + Yoffset2 - heightBOX2/2);
        VCOY2 = (Right2(2) + Yoffset2 + heightBOX2/2);
        vco2_text_frame = I(VCOY1:VCOY2,VCOX1:VCOX2);
        
        subplot(1,2,1); imshow(vo2_text_frame);
        subplot(1,2,2); imshow(vco2_text_frame);
        % OCR number reading and output
        text1 = ocr(vo2_text_frame);
        text2 = ocr(vco2_text_frame);
        vo2_text = str2double(text1.Text)
        vco2_text = str2double(text2.Text)
    end
    
    if test_mode == 1
        release(videoPlayer);
    elseif test_mode == 0 || test_mode == 2
        closePreview(cam)
        clear('cam')
    end
end
