%function valuta_Leads_Trained_NN
% 
% valuta un file_IMG  del paziente   con una trained_NN contenuta in  model.net
%
% Parametri pasati: H_Fs
%
NN_Leads=Max_leads;
fprintf('H_Fs:%6.0f\n',H_Fs);
       III=II - I ;
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





% file_00X=fullfile(['ECG_',file_key,num2str(K_NUM,'%05.0f_'),num2str(ind_dia_star,'%02.0f') ]);
%file_00X=fullfile([Ini_File,file_key,num2str(K_NUM,'%05.0f_'),num2str(ind_dia_star,'%02.0f') ]);

 
 %----------------- OPT_IMG=1  --------------------------------------------
HH_Hz=500;
data_leads=ECG_CINC.dati(:);
    [~,signalLength] = size(data_leads);
    signalLength = numel(data_leads);
    fprintf(' -> %6.0f samples %6.0f%6.0f ',signalLength,size(ECG_CINC.dati));
    fb = cwtfilterbank('SignalLength',signalLength, 'SamplingFrequency',HH_Hz,'VoicesPerOctave',12);

    cfs = abs(fb.wt(data_leads));
    im = ind2rgb(im2uint8(rescale(cfs)),jet(128));

    
        opt_QUAL=75;
    IMG_full_file=fullfile(pwd,'NEW_IMAGE.jpg');
    imwrite(imresize(im,[224 224]),IMG_full_file,'quality',opt_QUAL);

    
    ECG_image=imread(IMG_full_file);
    
    fprintf('Image- size:');fprintf('%6.0f',size(ECG_image));
    fprintf(' sum:%10.0f%10.0f%10.0f \n',sum(sum(ECG_image)));

    
    [YPred,probs] = classify(model.net,ECG_image);
    iii=find(probs>0.04);
    if(numel(iii)<1),[iitmp,iii]=max(probs);end            % max of NN
 %   if(numel(iii)<1), iii=find(out_labels>0);end            % out_label of "do"
    my_label=[];  my_label(1:numel(probs))=0;
    my_label(iii)=1;
    
    
    my_scores=probs;
    
    fprintf('---Ypred');fprintf('%6.0f',YPred);fprintf('\n');
    fprintf('---score');fprintf('%6.3f',probs);fprintf('\n');

    


   