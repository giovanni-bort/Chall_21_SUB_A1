
function get_12ECG_save_IMG(ECG,Header,model,STRUCT,ECG_DL_directory,num_file,file_key,List_16K)

       % addfunction path needed
       % addpath(genpath('Tools_01/'))

[H_recording,Total_time,H_num_leads,H_Fs,H_gain,H_age,H_sex]=extract_data_from_header(Header);

    fprintf('File,time');fprintf(' %s %8.2f ',H_recording,Total_time);
    fprintf('leads:%6.0f Fs:%8.1f age:sex%6.0f%6.0f\n',H_num_leads,H_Fs,H_age,H_sex);
    fprintf('Gain:');fprintf('%8.1f',H_gain);
    fprintf(' max:%8.0f',max(max(ECG)));
    fprintf('\n');

  % ---- Check file in lisk_OK -------------
[KNEW_NAME,K_TYPE,K_NUM]=extract_info_from_name(H_recording);
Hrec_chk=[file_key,num2str(K_NUM,'%05.0f')];
fprintf(' **Hrecording: %s  -- ',Hrec_chk);

[is_16K,loc_16K]=ismember(Hrec_chk,List_16K);
if(is_16K>0),fprintf(' is present: %s   **** SAVE IMG_files **\n',List_16K{loc_16K});
else
    fprintf(' *** not present in 16K ****\n');
end

%-----------------------------  
    
    
     %Version do_04_02  copiede 11.4.20
global out_labels_1 out_labels_2 KK_ERROR


if(is_16K>0),

%     try
%    Hz=500;
   Hz=H_Fs;
    
    fprintf('Version last_ECG_preproc -- size(ECG)=%6.0f%8.0f\n',size(ECG));

    j=1;
     filename=' ';
     
     Zero_Leads=sum(abs(ECG),2)==0;
    fprintf(' Zero_leads:');fprintf('%2.0f',Zero_Leads); fprintf('\n');

     
%    last_05_27_function    
     last_ECG_preproc
     
fprintf('end preproc......\n');

 
NN_Leads=2;
save_Leads_ECG_IMG

NN_Leads=3;
save_Leads_ECG_IMG

NN_Leads=6;
save_Leads_ECG_IMG


NN_Leads=12;
save_Leads_ECG_IMG



    
% %      catch MSG_ERROR
% %         
% % paz_error=sprintf('ERROR: file:%6.0f Key:%s; ',num_file,file_key);
% % paz_error2=sprintf('%1.0f',Zero_Leads);
% % text_error=[paz_error '*' paz_error2 '* ' MSG_ERROR.message ' ' MSG_ERROR.stack(1).name ' line:' num2str(MSG_ERROR.stack(1).line)];
% %    KK_ERROR=KK_ERROR+1;
% %    fprintf('------ ERORR n. %6.0f -------------\n',KK_ERROR);
% % %    fprintf(':ERORR: %s\n',text_error);
% % 
% % save_annotation(text_error,'err_annotations.txt');
% %     end   % end di try



end


end
