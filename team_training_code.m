function [ model,STRUCT] = team_training_code(input_directory,output_directory) % train_ECG_leads_classifier
% %--------------------------------------------------------------
% Purpose: Train ECG leads and obtain classifier models
% for 12-lead, 6-leads, 3-leads and 2-leads ECG sets
% Inputs:
% 1. input_directory
% 2. output_directory
%
% Outputs:
% model: trained model
% 4 logistic regression models for 4 different sets of leads
%
% Author: Erick Andres Perez Alday, PhD, <perezald@ohsu.edu>
% Version 1.0 Aug-2020
% Revision History
% By: Nadi Sadr, PhD, <nadi.sadr@dbmi.emory.edu>
% Version 2.0 1-Dec-2020
% Version 2.2 25-Jan-2021
% ----------------------------------------------------------------
model=0;
disp('Loading data...')

% Find files.
input_files = {};
features =[];
for f = dir(input_directory)'
    if exist(fullfile(input_directory, f.name), 'file') == 2 && f.name(1) ~= '.' && all(f.name(end - 2 : end) == 'mat')
        input_files{end + 1} = f.name;
    end
end

% Extract classes from dataset.
% read number of unique classes
classes = get_classes(input_directory,input_files);
% [MY_classes,STRUCT2] = get_classes_MY(input_directory,input_files);
% fprintf('size Struct2:%6.0f%6.0f\n',size(STRUCT2));

num_classes = length(classes);     % number of classes
num_files   = length(input_files);
Total_data  = cell(1,num_files);
Total_header= cell(1,num_files);

% % Load data recordings and header files
% Iterate over files.
label=zeros(num_files,num_classes);
   STRUCT=[];
for i = 1:num_files
    disp(['    ', num2str(i), '/', num2str(num_files), '...'])
    % Load data.
    file_tmp = strsplit(input_files{i},'.');
    tmp_input_file = fullfile(input_directory, file_tmp{1});
    [data,hea_data] = load_challenge_data(tmp_input_file);
    Total_data{i}=data;
    Total_header{i}=hea_data;

end

for i = 1:num_files
    
            STRUCT(i).num=i;
            STRUCT(i).file=input_files{i};
  header_data = Total_header{i};   
    % % Extract labels
    for j = 1 : length(header_data)
        if startsWith(header_data{j},'#Dx')
            tmp = strsplit(header_data{j},': ');
            % Extract more than one label if avialable
            tmp_c = strsplit(tmp{2},',');
            for k=1:length(tmp_c)
                idx=find(strcmp(classes,tmp_c{k}));
                label(i,idx)=1;
                STRUCT(i).diagn{k}=tmp_c{k};
            end
            break
        end
    end
end

    for ii=1:numel(STRUCT)
        [~,ind_diagn]=ismember(STRUCT(ii).diagn,classes);
        STRUCT(ii).ind_diagn=ind_diagn;
    end


fprintf('size Struct:%6.0f%6.0f\n',size(STRUCT));

disp('Saving image files ..')


%  leads   : I II III aVR aVL aVF V1 V2 V3 V4 V5 V6 
% leads_idx: 1  2   3   4   5   6  7  8  9 10 11 12

for i = 1:num_files

    TTT1=(['    ', num2str(i), '/', num2str(num_files), '...']);
   fprintf('%s',TTT1);
   
    data = Total_data{i};
    header_data = Total_header{i};
    % % Check the number of available ECG leads
    tmp_hea = strsplit(header_data{1},' ');
    num_leads = str2num(tmp_hea{2});
    [leads, leads_idx] = get_leads(header_data,num_leads);

    fprintf(' n_leads=%4.0f',num_leads);
    fprintf(' %s',leads{:}); fprintf('\n');
      % % Extract features   --> save IMG files for training 
  
    model=0;
  %  file_key='A';
     load('List_8320.mat');
    List_16K=List_8320;;
             file_key=input_files{i}(1:1);
    get_12ECG_save_IMG(data,header_data,model,STRUCT,output_directory,i,file_key,List_16K);
    

end

disp('Training model..')

% % train 4 DL_networks  models for 4 different sets of leads

% % % Train 12-lead ECG model
 disp('Training 12-lead ECG model...')
 num_leads = 12;
 opt_CHALL_leads=num_leads;
 driver_train_CNN_leads
 model=[];
 model.net=NET_tot.CNN(1).net;model.num_leads=num_leads;
 save_ECG12leads_model(model,output_directory,classes);
 
 

% % % Train 6-lead ECG model
disp('Training 6-lead ECG model...')
num_leads = 6;
opt_CHALL_leads=num_leads;
driver_train_CNN_leads
 model=[];
 model.net=NET_tot.CNN(1).net;model.num_leads=num_leads;
save_ECG6leads_model(model,output_directory,classes);



% Train 3-lead ECG model
disp('Training 3-lead ECG model...')
num_leads = 3;
opt_CHALL_leads=num_leads;
driver_train_CNN_leads
 model=[];
 model.net=NET_tot.CNN(1).net;model.num_leads=num_leads;
save_ECG3leads_model(model,output_directory,classes);



% Train 2-lead ECG model
disp('Training 2-lead ECG model...')
num_leads = 2;
opt_CHALL_leads=num_leads;
driver_train_CNN_leads
 model.net=NET_tot.CNN(1).net;model.num_leads=num_leads;
save_ECG2leads_model(model,output_directory,classes);

end

function save_ECG12leads_model(model,output_directory,classes) %save_ECG_model
% Save results.
tmp_file = 'twelve_lead_ecg_model.mat';
filename=fullfile(output_directory,tmp_file);
save(filename,'model','classes','-v7.3');

disp('Done.')
end

function save_ECG6leads_model(model,output_directory,classes) %save_ECG_model
% Save results.
tmp_file = 'six_lead_ecg_model.mat';
filename=fullfile(output_directory,tmp_file);
save(filename,'model','classes','-v7.3');

disp('Done.')
end

function save_ECG3leads_model(model,output_directory,classes) %save_ECG_model
% Save results.
tmp_file = 'three_lead_ecg_model.mat';
filename=fullfile(output_directory,tmp_file);
save(filename,'model','classes','-v7.3');

disp('Done.')
end

function save_ECG2leads_model(model,output_directory,classes) %save_ECG_model
% Save results.
tmp_file = 'two_lead_ecg_model.mat';
filename=fullfile(output_directory,tmp_file);
save(filename,'model','classes','-v7.3');

disp('Done.')
end

function save_ECGleads_features(features,output_directory) %save_ECG_model
% Save results.
tmp_file = 'features.mat';
filename=fullfile(output_directory,tmp_file);
save(filename,'features');
end

% find unique number of classes
function classes = get_classes(input_directory,files)

classes={};
num_files = length(files);
k=1;
for i = 1:num_files
    g = strrep(files{i},'.mat','.hea');
    input_file = fullfile(input_directory, g);
    fid=fopen(input_file);
    tline = fgetl(fid);
    tlines = cell(0,1);

    while ischar(tline)
        tlines{end+1,1} = tline;
        tline = fgetl(fid);
        if startsWith(tline,'#Dx')
            tmp = strsplit(tline,': ');
            tmp_c = strsplit(tmp{2},',');
            for j=1:length(tmp_c)
                idx2 = find(strcmp(classes,tmp_c{j}));
                if isempty(idx2)
                    classes{k}=tmp_c{j};
                    k=k+1;
                end
            end
            break
        end
    end

    fclose(fid);

end
classes=sort(classes);
end


% find unique number of classes
function [classes,STRUCT] = get_classes_MY(input_directory,files)
	
	classes={};
    STRUCT=[];
	num_files = length(files);
	k=1;
    	for i = 1:num_files
            STRUCT(i).num=i;
            STRUCT(i).file=files{i};
            
            
		g = strrep(files{i},'.mat','.hea');
		input_file = fullfile(input_directory, g);
	        fid=fopen(input_file);
	        tline = fgetl(fid);
        	tlines = cell(0,1);

		while ischar(tline)
        	    tlines{end+1,1} = tline;
	            tline = fgetl(fid);
			if startsWith(tline,'#Dx')
				tmp = strsplit(tline,': ');
				tmp_c = strsplit(tmp{2},',');
				for j=1:length(tmp_c)
                                        STRUCT(i).diagn{j}=tmp_c{j};

		                	idx2 = find(strcmp(classes,tmp_c{j}));
		                	if isempty(idx2)
                	        		classes{k}=tmp_c{j};
                        			k=k+1;
                			end
				end
			break
        		end
		end
        	fclose(fid);
	end
	classes=sort(classes)
end




function [data,tlines] = load_challenge_data(filename)

% Opening header file
fid=fopen([filename '.hea']);

if (fid<=0)
    disp(['error in opening file ' filename]);
end

tline = fgetl(fid);
tlines = cell(0,1);
while ischar(tline)
    tlines{end+1,1} = tline;
    tline = fgetl(fid);
end
fclose(fid);

f=load([filename '.mat']);

try
    data = f.val;
catch ex
    rethrow(ex);
end

end
