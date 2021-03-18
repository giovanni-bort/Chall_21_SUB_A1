 %function save_Leads_ECG_IMG
 
% salva un file IMG  per paziente in CINC20_ECG_IMG1
% nome file: ECG_Xnnnn_ddd.mat   X:AQISHE    nnnn: 0001    ddd:0167  diagnosi(es. 01+67)
%
       AVR=(-I - II)/2;     % AVR_mean=(-I_mean -  II_mean)/2;
       AVL=( I - III)/2;    % AVL_mean=( I_mean - III_mean)/2;
       AVF=(II + III)/2;    % AVF_mean=(II_mean + III_mean)/2;
if(NN_Leads==2),          % II , V5
   Ini_File='ECG_02L_';
  % ECG_mean=[ II_mean  V5_mean  ];
   ECG_TMP=[ II ; V5 ];
end
if(NN_Leads==3),         %I II , V2
   Ini_File='ECG_03L_';
  % ECG_mean=[ I_mean II_mean III_mean AVR_mean AVL_mean AVF_mean V2_mean  ];
   ECG_TMP=[  I ; II ; III ; AVR ; AVL ; AVF; V2 ];
end

if(NN_Leads==6),         % I II III AVR  AVL AVF
       Ini_File='ECG_06L_';
 %  ECG_mean=[ I_mean II_mean III_mean AVR_mean AVL_mean AVF_mean ];
   ECG_TMP=[ I;II;III ; AVR ; AVL ; AVF ];
end
if(NN_Leads==12),         % all 12 leads
   Ini_File='ECG_12L_';
 %  ECG_mean=[ I_mean II_mean III_mean AVR_mean AVL_mean AVF_mean V1_mean V2_mean V3_mean V4_mean V5_mean V6_mean ];
   ECG_TMP=[ I ; II ; III ; AVR ; AVL ; AVF; V1; V2; V3; V4; V5; V6];
end

% ECG_mean=[ I_mean II_mean III_mean V1_mean V2_mean V3_mean V4_mean V5_mean V6_mean ];
% ECG_TMP=[ I;II;III; V1; V2; V3; V4; V5; V6];

if(size(ECG_TMP,2)<5000), ECG_TMP(1,5000)=0;end
ECG_PRO=ECG_TMP(1:end,1:5000)';
%ECG_CINC.dati=ECG_PRO(:);
fprintf('%3.0f Leads - ECG: %4.0f%6.0f samples\n',NN_Leads, size(ECG_PRO));
% ECG_CINC.dati=[ECG_PRO(:)' ECG_mean];                % ECG_data + ECG_median
ECG_CINC.dati=[ECG_PRO(:)' ];                % ********** ECG_data  ***********
 ECG_CINC.diagn=STRUCT(num_file).diagn;
 ECG_CINC.ind_diagn=STRUCT(num_file).ind_diagn;
ECG_CINC.Fs=Hz;
[ind_dia_star,TEMP2,TEMP3]=check_DIAGN_star(STRUCT(num_file).diagn);

% ---- Check file in lisk_OK -------------
[KNEW_NAME,K_TYPE,K_NUM]=extract_info_from_name(H_recording);
Hrec_chk=[file_key,num2str(K_NUM,'%05.0f')];
fprintf(' **Hrecording: %s  -- ',Hrec_chk);

[is_16K,loc_16K]=ismember(Hrec_chk,List_16K);
if(is_16K>0),fprintf(' is present: %s   **** SAVE IMG2 **\n',List_16K{loc_16K});
else
    fprintf(' *** not present in 16K ****\n');
end


if(ne(K_NUM,num_file)),fprintf('***** DIVERSI***');end
fprintf('NEW:%s  K_NUM=%6.0f  num_file:%6.0f  type: %s  %s \n',KNEW_NAME,K_NUM,num_file,K_TYPE,file_key);
% fprintf('size DIA_*:%6.0f%6.0f\n',size(ind_dia_star));
%  file_00X=fullfile(ECG_DL_directory,['ECG_',file_key,num2str(num_file,'%05.0f_'),num2str(STRUCT(num_file).ind_diagn,'%02.0f')]);
%  file_00X=fullfile(['ECG_',file_key,num2str(num_file,'%05.0f_'),num2str(STRUCT(num_file).ind_diagn,'%02.0f')]);

%file_00X=fullfile(['ECG_',file_key,num2str(num_file,'%05.0f_'),num2str(ind_dia_star,'%02.0f')]); % ERROR**

% file_00X=fullfile(['ECG_',file_key,num2str(K_NUM,'%05.0f_'),num2str(ind_dia_star,'%02.0f') ]);
file_00X=fullfile([Ini_File,file_key,num2str(K_NUM,'%05.0f_'),num2str(ind_dia_star,'%02.0f') ]);

opt_IMG=1;
if(is_16K>0),opt_IMG=1;end
 
 %----------------- OPT_IMG=1  --------------------------------------------
if(opt_IMG==1),
%  imgLoc ='CINC21_ECG_IMG1'; % IMG1: Image RAW+median ECG 1
%   imgLoc ='CINC21_ECG_IMR1'; % IMR1: Image RAW ECG 1
   imgLoc =ECG_DL_directory; % IMR1: Image RAW ECG 1
   
   if ~exist(imgLoc, 'dir')
        mkdir(imgLoc)
   end
   
   fprintf('Save ECG images in : %s (Wavelet scalogram)\n',imgLoc);
    data=ECG_CINC.dati(:);
    Fs=ECG_CINC.Fs;
    [~,signalLength] = size(data);
    signalLength = numel(data);
    fprintf(' -> %6.0f samples %6.0f%6.0f ',signalLength,size(ECG_CINC.dati));
    fb = cwtfilterbank('SignalLength',signalLength, 'SamplingFrequency',Fs,'VoicesPerOctave',12);

    cfs = abs(fb.wt(data));
    im = ind2rgb(im2uint8(rescale(cfs)),jet(128));
    
    %imgLoc = fullfile(imageRoot,char(labels(ii)));
%     imgLoc = imageRoot;
    
%     imFileName = strcat(num2str(ii,'%04.0f_'),char(ALL_LABELS(ii)),'_',num2str(ii),'.jpg');        % ARR_23.jpg
%     imFileName = strcat(num2str(ii,'%04.0f_'),num2str(ii),'.jpg');  
%     imFileName = strrep(files(ii).name,'.mat','.jpg');
opt_QUAL=75;
    imFileName = [file_00X '.jpg'];
    imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName),'quality',opt_QUAL);
    fprintf('IMG:   %s ',imFileName); fprintf(' %s ',ECG_CINC.diagn{:}); fprintf(' %3.0f ',ECG_CINC.ind_diagn); fprintf('\n');

end


%------------------------- OPT_IMG = 2 ------------------------------------
%----------------- OPT_IMG=2  --------------------------------------------
if(opt_IMG==2),
   %imgLoc ='ECG_DL_CINC20_IMG_2';
   imgLoc ='CINC20_ECG_IMG2_OK';
   if ~exist(imgLoc, 'dir')
        mkdir(imgLoc)
   end
   fprintf('Save ECG images in : %s  (leads images)\n',imgLoc);
tic

   T_1=toc;

      %---------- extract ECG data and create ECGfull-----------------
 BBB=ECG_CINC.dati;
 ECGM=BBB(45001:end);
 ECG2=reshape(BBB(1:45000),5000,9);
 MED2=reshape(BBB(45001:end),(numel(BBB)-45000)/9,9);
 ECGnew=[]; 
   ECGnew(1:5000,[1 2 3 7:12])=ECG2(1:5000,1:9);
   ECGnew(:,4)=-(ECGnew(:,1)+ECGnew(:,2))/2.0;   %aVR = - (I+II)/2
   ECGnew(:,5)= (ECGnew(:,1)-ECGnew(:,3))/2.0;   %aVL =   (I-III)/2
   ECGnew(:,6)= (ECGnew(:,2)+ECGnew(:,3))/2.0;   %aVF =   (II+III)/2
 ECGmed=[];
   ECGmed(:,[1 2 3 7:12])=MED2(:,1:9);
   ECGmed(:,4)=-(ECGmed(:,1)+ECGmed(:,2))/2.0;   %aVR = - (I+II)/2
   ECGmed(:,5)= (ECGmed(:,1)-ECGmed(:,3))/2.0;   %aVL =   (I-III)/2
   ECGmed(:,6)= (ECGmed(:,2)+ECGmed(:,3))/2.0;   %aVF =   (II+III)/2
 ECGfull=[ECGnew ; ECGmed];
 %--------------------------------------------

 ECG2=ECGfull(:,[7 8 9 10 11 12 5 1 2 6 3 4]);
T_1b=toc;
NN=size(ECG2,1);K_pass=2;
k=0;XX=[];VV2=[];
for I=1:NN
    for J=1:12
        k=k+1;
        XX(k,1)=I;
        XX(k,2)=J;
       VV2(k,1)=ECG2(I,J);
    end
end
 [Xm,Ym] = meshgrid(1:K_pass:NN, 0.5:0.1:12.5);
 EXTRM='nearest';
F1=scatteredInterpolant(XX,VV2);
F1.Method='linear';
F1.ExtrapolationMethod=EXTRM;
VVq=F1(Xm,Ym);
IM3=imagesc(VVq);

 k_jet=256;
 im = ind2rgb(im2uint8(rescale(IM3.CData)),jet(k_jet)); %(128));
% % %  imwrite(imresize(im,[224 224]),'NEWIMAGE2.jpg');

 
  
 opt_QUAL=75;
    imFileName = [file_00X '.jpg'];
     imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName),'quality',opt_QUAL);
    fprintf('IMG2:   %s ',imFileName); fprintf(' %s ',ECG_CINC.diagn{:}); fprintf(' %3.0f ',ECG_CINC.ind_diagn); fprintf('\n');

  
%   imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName));
%   fprintf('IMG:   %s ',imFileName); fprintf(' %6s ',LABELS(ii).diagn{:}); fprintf(' %3.0f ',LABELS(ii).ind_diagn); 
%   fprintf(' n=%6.0f',NN);
T_2=toc;
%fprintf(' t:%8.1f  mean:%8.1f',T_2-T_1,T_2/(ii-K_ini+1))
     fprintf('\n');
   
   
   
end    


   