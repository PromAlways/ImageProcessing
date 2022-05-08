%% image-Processing Project 

clear all
clc
%% เริ่มการตรวจจับเวลาการประมวลผล 
t = -4*pi:pi/100000:4*pi;
    x = 5*sin(t);
    N = length(t);
    tic
    for n=1:N
        if x(n) > 4.5
           x(n) = 4.5;
        elseif x(n) < -4.5
               x(n) = -4.5;
        else
        end
    end
%% การจับภาพวัตถุ %%
A = webcamlist;
Cam = webcam('HD Pro Webcam C920');
    set(Cam,'Resolution','800x600');
    Cam.Brightness = 65;
    Cam.Focus = 40;
EG = snapshot(Cam); imshow(EG);
delete(Cam);
h = fspecial('motion',5,5);
IF = imfilter(EG,h); imshow(IF);
%% แยกระดับแบบสี RGB ให้เป็น 3 เลเยอร์ %
rmat=IF(:,:,1);
gmat=IF(:,:,1);
bmat=IF(:,:,1);
figure;
subplot(2,2,1), imshow(rmat); title('Red Plane');
subplot(2,2,2), imshow(gmat); title('Green Plane');
subplot(2,2,3), imshow(bmat); title('Blue Plane');
subplot(2,2,4), imshow(IF); title('Original Image');
levelr = 0.4;
levelg = 0.4;
levelb = 0.4;
i1=im2bw(rmat,levelr);
i2=im2bw(gmat,levelg);
i3=im2bw(bmat,levelb);
Isum = (i1&i2&i3);
figure;
subplot(2,2,1), imshow(i1); title('Red Plane');
subplot(2,2,2), imshow(i2); title('Green Plane');
subplot(2,2,3), imshow(i3); title('Blue Plane');
subplot(2,2,4), imshow(Isum); title('Sum of all the planes');
%% หาเส้นรอบวัตถุ เพื่อความละเอียด ความสูง ความกว่าง จุดศูนย์กลาง และพื้นที่ทั้งหมด
BW = bwareaopen(Isum,30);
[B,L] = bwboundaries(BW,'holes');
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2),boundary(:,1),'y','LineWidth',1)
end
 
prop = regionprops(BW,'Area','Centroid','MajorAxisLength','MinorAxisLength','Perimeter');
total=0;
figure,imshow(BW);
%% เชื่อมต่อกับพอร์ตของบอร์ด Lambda Nu Sc-840
s = serial('COM3'); 	(ในที่นี้กำหนดเป็นพอร์ต COM3 )
    set(s,'BaudRate',9600,'Databits',8,'Stopbits',1);
    set(s,'Terminator','CR');
fopen(s)
%% ทำการเปรียบเทียบขนาด ตามเงื่อนไข
for n=1:size(prop,1)
cent=prop(n).Centroid;
X=cent(1);Y=cent(2);
    if prop(n).Area>96500
    text(X-10,Y,'Egg Size 0')
        fprintf(s,'@1 N1\r\n');        
    elseif prop(n).Area>87500 && prop(n).Area<96499    
    text(X-10,Y,'Egg Size 1');
        fprintf(s,'@1 N2\r\n');        
    elseif prop(n).Area>78000 && prop(n).Area<87499
    text(X-10,Y,'Egg Size 2')
        fprintf(s,'@1 N3\r\n');        
    elseif prop(n).Area<77999
    text(X-10,Y,'Egg Size 3')
        fprintf(s,'@1 N4\r\n');       
    end
end
hold on
    title(['Total of Area: ',num2str(prop(1).Area),'pixel']);
%%
fprintf(s,'@1 F0\r\n');
fclose(s)
delete(s)
clear s
 
toc
    plot(t); 
