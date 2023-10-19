
function [cellIndex,outlineIndex,nucCoord] = segmentOutline(I,coef)
% [cellIndex,outlineIndex,nucCoord]=hdCellProps(Image, values)

% segmentOutline is a function for extracting the contour of a cell 
%
% it uses unimodal intensity historgram thresholding as initial step
% followed by repeated (i) filling of holes and (ii) active contour
% calculations
%
% SYNOPSIS   [cellIndex,outlineIndex,nucCoord] = segmentOutline(I,coef)
%
% INPUT      I              :  FA image for segmentation
%            coef           :  coefficient of the unimodal threshold, default is 2
%
% OUTPUT     cellIndex      :  augmented cands structure (see fsmPrepTestLocalMaxima.m)
%            outlineIndex   :  local maxima map
%            nucCoord       :  
%
% DEPENDENCES   segmentOutline uses { cutFirstHistMode, activecontour}
%               segmentOutline is used by { hdDetection_linkByOverLap } line 91
%
% AM, 4th of july, 2014

if nargin == 0
    close all
        I =imread('A:\johan\pos4_t001.tif');%coef2 FIRST image - GOOD EXAMPLE

    
%     I =imread('A:\johan\140404_tirf\HGF_007_processed_tifs\pos11_t001.tif');%coef2 FIRST image - GOOD EXAMPLE
%         I =imread('A:\johan\140404_tirf\HGF_007_processed_tifs\pos27_t088.tif');%coef2 LAst image - GOOD EXAMPLE

%     I = imread('C:\Users\Matov\Desktop\FA_errors\pos11_t112.tif'); % coef0.7 IMAGE FOR WHICH IT HAS PROBLEMS
    coef = 0.5;%0.7;
end

I = double(I);
 [Ind,cutOff]=cutFirstHistMode(I,0);% switch to 1 to see HIST
 I1=I>cutOff*coef;
%  figure,imshow(I1,[])
 
  BWdfill = imfill(I1, 'holes');
% figure, imshow(BWdfill);
 
 bw = activecontour(I, BWdfill);
%  figure,imshow(bw,[])
 
  I11 = imfill(bw, 'holes');
% figure,imshow(I11,[])

 bw1 = activecontour(I,I11);
%  figure,imshow(bw1,[])
 
   I111 = imfill(bw1, 'holes');
% figure,imshow(I111,[])

 I3 = I111.*I;
%  figure,imshow(I3,[])
%  figure,imshow(I,[])
 trhShow = I3;
 BWoutline = bwperim(I111);
I(BWoutline) = 20000;
figure, imshow(I,[]), title('outlined original image');
 
 
% figure, imshow(trhShow,[0,1]);
thrCellOutline=bwperim(I111);


outlineIndex=find(thrCellOutline); % OUTPUT NB 2

%     X = bwlabel(I111);

    trhProps = regionprops(I111,'Centroid','Area');
%Then find the amount of objects: if more than one keep objects separated  remove the smallest one....
 trhLabel = I111;
if length(trhProps)>1
    sizeC=zeros(length(trhProps),1);
    for i=1:length(trhProps)
        sizeC(i,1)=trhProps(i,1).Area;
    end
    %ES- 21-6-2011: changed commando, now it should really pick the largest area as a cell; 
    cellIdx=find(sizeC(:,1)==max(sizeC(:,1)));
    trhShow=zeros(size(trhLabel));
    trhShow(find(trhLabel==cellIdx))=1;
    %ES- 18-07-2011: added the centroid of the largest object as centre of
    %cell to relate FAs to later on..
    nucCoord(1,1)=trhProps(cellIdx,1).Centroid(1,1);
    nucCoord(1,2)=trhProps(cellIdx,1).Centroid(1,2);
else 
    nucCoord(1,1)=trhProps.Centroid(1,1);
    nucCoord(1,2)=trhProps.Centroid(1,2);
end
clear trhLabel trhProps


%Get the linear index of the object(s) and of the perimeter
cellIndex=find(trhShow);
